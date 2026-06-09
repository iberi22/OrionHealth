// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2025 OrionHealth

import 'dart:developer' as developer;
import 'pii_entity.dart';

/// Configuration for PII quality gates, defining confidence thresholds.
class QualityGateConfig {
  final double defaultMinConfidence;
  final Map<String, double> labelThresholds;

  const QualityGateConfig({
    this.defaultMinConfidence = 0.7,
    this.labelThresholds = const {},
  });

  factory QualityGateConfig.fromJson(Map<String, dynamic> json) {
    return QualityGateConfig(
      defaultMinConfidence: (json['defaultMinConfidence'] as num?)?.toDouble() ?? 0.7,
      labelThresholds: (json['labelThresholds'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultMinConfidence': defaultMinConfidence,
      'labelThresholds': labelThresholds,
    };
  }
}

/// Span-boundary guards for entity predictions.
///
/// Ported from OpenMed (Python) Apache 2.0.
class QualityGate {
  QualityGate._();

  /// Validate span boundaries for every entity against [text].
  ///
  /// Checks performed per entity:
  /// - start < end (no inverted or zero-length spans)
  /// - start >= 0 and end <= text.length
  /// - text[start:end] matches entity.text (catch stale spans)
  ///
  /// Violations are logged and a 'span_valid' flag is written into entity.metadata.
  /// Returns a new list of entities with updated metadata.
  static List<PiiEntity> validateSpans(List<PiiEntity> entities, String text) {
    final textLen = text.length;

    return entities.map((entity) {
      final problems = <String>[];
      final start = entity.start;
      final end = entity.end;

      // --- invariant checks ---
      if (start >= end) {
        if (start == end) {
          problems.append("zero-length span");
        } else {
          problems.append("inverted span (start=$start >= end=$end)");
        }
      }

      if (start < 0) {
        problems.append("negative start ($start)");
      }

      if (end > textLen) {
        problems.append("end ($end) exceeds text length ($textLen)");
      }

      // --- text-match check (only when bounds are sane) ---
      if (problems.isEmpty && start >= 0 && end <= textLen) {
        final actual = text.substring(start, end);
        if (actual != entity.text) {
          // Allow whitespace-only differences (common after span trimming)
          if (actual.split(RegExp(r'\s+')).join(' ') ==
              entity.text.split(RegExp(r'\s+')).join(' ')) {
            developer.log(
              "SpanValidation: Entity '${entity.label}' @ [$start:$end]: "
              "whitespace-only text difference (span='$actual', stored='${entity.text}')",
              name: 'QualityGate',
            );
          } else {
            problems.append(
                "text mismatch: span gives '$actual', entity stores '${entity.text}'");
          }
        }
      }

      // --- report ---
      if (problems.isNotEmpty) {
        final msg = "Entity '${entity.label}' @ [$start:$end]: ${problems.join('; ')}";
        developer.log("SpanValidation: $msg", name: 'QualityGate', level: 900); // Warning level
      }

      final meta = Map<String, dynamic>.from(entity.metadata ?? {});
      meta['span_valid'] = problems.isEmpty;

      return entity.copyWith(metadata: meta);
    }).toList();
  }

  /// Return pairs of entities whose character spans overlap.
  static List<(PiiEntity, PiiEntity)> detectOverlaps(List<PiiEntity> entities) {
    final sortedEnts = List<PiiEntity>.from(entities)
      ..sort((a, b) => a.start.compareTo(b.start));

    final overlaps = <(PiiEntity, PiiEntity)>[];
    for (var i = 0; i < sortedEnts.length - 1; i++) {
      final a = sortedEnts[i];
      for (var j = i + 1; j < sortedEnts.length; j++) {
        final b = sortedEnts[j];
        if (b.start < a.end) {
          overlaps.add((a, b));
        } else {
          break; // No further overlaps possible for 'a'
        }
      }
    }
    return overlaps;
  }

  /// Filters results based on confidence thresholds and (optionally) span validity.
  static List<PiiEntity> applyGates(
    List<PiiEntity> entities, {
    String? text,
    QualityGateConfig config = const QualityGateConfig(),
    bool dropInvalidSpans = false,
  }) {
    var results = entities;

    if (text != null) {
      results = validateSpans(results, text);
    }

    return results.where((entity) {
      // Threshold check
      final threshold = config.labelThresholds[entity.label] ?? config.defaultMinConfidence;
      if (entity.confidence < threshold) {
        return false;
      }

      // Optional span validity drop
      if (dropInvalidSpans && text != null) {
        final isValid = entity.metadata?['span_valid'] as bool? ?? true;
        if (!isValid) return false;
      }

      return true;
    }).toList();
  }
}

extension _StringList on List<String> {
  void append(String value) => add(value);
}
