// Copyright 2024 OrionHealth
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:equatable/equatable.dart';

/// Represents a detected PII/PHI entity with its position, confidence, and metadata.
/// Ported from OpenMed (Python/Swift) Apache 2.0.
class PiiEntity extends Equatable {
  final String label;
  final String text;
  final double confidence;
  final int start;
  final int end;
  final String source; // 'regex', 'model', 'context'

  const PiiEntity({
    required this.label,
    required this.text,
    required this.confidence,
    required this.start,
    required this.end,
    required this.source,
  });

  factory PiiEntity.fromJson(Map<String, dynamic> json) {
    return PiiEntity(
      label: json['label'] as String,
      text: json['text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      start: json['start'] as int,
      end: json['end'] as int,
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'text': text,
      'confidence': confidence,
      'start': start,
      'end': end,
      'source': source,
    };
  }

  @override
  List<Object?> get props => [label, text, confidence, start, end, source];

  /// Merges this entity with another, taking the union of spans and max confidence.
  /// Assumes the entities are overlapping or adjacent.
  PiiEntity merge(PiiEntity other, String originalText) {
    final newStart = start < other.start ? start : other.start;
    final newEnd = end > other.end ? end : other.end;
    return PiiEntity(
      label: label == other.label ? label : '$label,${other.label}',
      text: originalText.substring(newStart, newEnd),
      confidence: confidence > other.confidence ? confidence : other.confidence,
      start: newStart,
      end: newEnd,
      source: source == other.source ? source : 'merger',
    );
  }

  /// Checks if this entity overlaps with another.
  bool overlaps(PiiEntity other) {
    return (start < other.end && other.start < end);
  }
}

/// Represents a match from a regex-based PII detection.
class PiiMatch extends Equatable {
  final String label;
  final String text;
  final int start;
  final int end;

  const PiiMatch({
    required this.label,
    required this.text,
    required this.start,
    required this.end,
  });

  PiiEntity toEntity({double confidence = 1.0, String source = 'regex'}) {
    return PiiEntity(
      label: label,
      text: text,
      confidence: confidence,
      start: start,
      end: end,
      source: source,
    );
  }

  @override
  List<Object?> get props => [label, text, start, end];
}

/// Represents a collection of detected PII entities and provides utilities for processing them.
class PiiResult extends Equatable {
  final List<PiiEntity> entities;
  final String originalText;

  const PiiResult({
    required this.entities,
    required this.originalText,
  });

  String get scrubbedText {
    if (entities.isEmpty) return originalText;

    final sorted = sortedByPosition();
    final buffer = StringBuffer();
    int lastEnd = 0;

    for (final entity in sorted) {
      if (entity.start < lastEnd) continue; // Skip overlapping
      buffer.write(originalText.substring(lastEnd, entity.start));
      buffer.write('[${entity.label.toUpperCase()}]');
      lastEnd = entity.end;
    }
    buffer.write(originalText.substring(lastEnd));

    return buffer.toString();
  }

  List<PiiEntity> sortedByPosition() {
    final list = List<PiiEntity>.from(entities);
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  List<PiiEntity> sortedByConfidence() {
    final list = List<PiiEntity>.from(entities);
    list.sort((a, b) => b.confidence.compareTo(a.confidence));
    return list;
  }

  PiiResult mergeOverlapping() {
    if (entities.isEmpty) return this;

    final sorted = sortedByPosition();
    final merged = <PiiEntity>[];

    if (sorted.isEmpty) return this;

    PiiEntity current = sorted.first;

    for (int i = 1; i < sorted.length; i++) {
      final next = sorted[i];
      if (current.overlaps(next)) {
        current = current.merge(next, originalText);
      } else {
        merged.add(current);
        current = next;
      }
    }
    merged.add(current);

    return PiiResult(entities: merged, originalText: originalText);
  }

  factory PiiResult.fromJson(Map<String, dynamic> json) {
    return PiiResult(
      entities: (json['entities'] as List)
          .map((e) => PiiEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      originalText: json['originalText'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entities': entities.map((e) => e.toJson()).toList(),
      'originalText': originalText,
      'scrubbedText': scrubbedText,
    };
  }

  @override
  List<Object?> get props => [entities, originalText];
}
