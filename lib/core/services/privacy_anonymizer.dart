// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs
//
// PII/PHI detection powered by PiiDetector ported from OpenMed
// (https://github.com/maziyarpanahi/openmed) — Apache 2.0.
//
// The regex patterns, label taxonomy, and validation logic (SSN Luhn, NPI,
// US Phone) originate from OpenMed and have been ported to native Dart
// for on-device, offline execution within OrionHealth (AGPL-3.0-only).

import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../domain/entities/api_audit_log.dart';
import '../medical/pii_detector.dart';
import '../medical/pii_entity.dart';

/// Formats a PII/PHI entity text into a compact placeholder string.
///
/// * `SSN` → `[XXX-XX-1234]` (last 4 visible, format-preserving)
/// * `CREDIT_CARD` → `[XXXX-XXXX-XXXX-2424]` (last 4 visible)
/// * All other types → `[TYPE]` (e.g. `[EMAIL]`, `[PHONE]`, `[IP_ADDRESS]`)
String _defaultMaskBuilder(PiiEntity entity) {
  if (entity.label == 'SSN') {
    final digits = entity.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      return '[XXX-XX-${digits.substring(digits.length - 4)}]';
    }
    return '[SSN]';
  }
  if (entity.label == 'CREDIT_CARD' || entity.label == 'CREDIT_DEBIT_CARD') {
    final digits = entity.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      return '[XXXX-XXXX-XXXX-${digits.substring(digits.length - 4)}]';
    }
    return '[CREDIT_CARD]';
  }
  return '[${entity.label}]';
}

/// Extension on [PiiResult] to mask detected entities with a configurable
/// placeholder builder.
extension PiiResultMask on PiiResult {
  /// Returns the [originalText] with each detected [PiiEntity] replaced by
  /// the placeholder produced by [maskBuilder].
  ///
  /// Non-overlapping entities are replaced from left to right; overlaps are
  /// skipped in favour of the earlier entity.
  String mask({String Function(PiiEntity entity)? maskBuilder}) {
    if (entities.isEmpty) return originalText;
    final builder = maskBuilder ?? _defaultMaskBuilder;
    final sorted = entities;
    sorted.sort((a, b) => a.start.compareTo(b.start));

    final buf = StringBuffer();
    int cursor = 0;
    for (final e in sorted) {
      if (e.start < cursor) continue;
      buf.write(originalText.substring(cursor, e.start));
      buf.write(builder(e));
      cursor = e.end;
    }
    buf.write(originalText.substring(cursor));
    return buf.toString();
  }
}

/// Scans prompts for PII/PHI entities before sending them to external LLM
/// APIs, scrubs them with format-preserving placeholders, and logs the audit
/// trail to Isar.
///
/// Backed by [PiiDetector] which implements 30+ regex patterns with context
/// boosting and validation (SSN checksum, Luhn, NPI, US Phone).
@lazySingleton
class PromptScrubber {
  final Isar _isar;
  final PiiDetector _detector;

  PromptScrubber(this._isar) : _detector = PiiDetector();

  /// Detect PII/PHI entities in [prompt], scrub them with format-preserving
  /// placeholders, log the operation, and return the scrubbed text.
  Future<String> detectAndScrub(String prompt, {required String apiName}) async {
    final result = _detector.detectPii(prompt);
    final piiFound = result.entities.isNotEmpty;

    final scrubbed = result.mask();

    // Audit log (best-effort, non-blocking)
    final log = ApiAuditLog(
      timestamp: DateTime.now(),
      apiName: apiName,
      originalPromptLength: prompt.length,
      scrubbedPromptLength: scrubbed.length,
      piiFound: piiFound,
    );

    try {
      await _isar.writeTxn(() async {
        await _isar.apiAuditLogs.put(log);
      });
    } catch (_) {
      // Non-critical — audit logging must never block PII scrubbing
    }

    return scrubbed;
  }

  /// Backward-compatible alias; delegates to [detectAndScrub].
  @Deprecated('Use detectAndScrub instead')
  Future<String> scrub(String prompt, {required String apiName}) async {
    return detectAndScrub(prompt, apiName: apiName);
  }
}
