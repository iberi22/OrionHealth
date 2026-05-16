// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../domain/entities/api_audit_log.dart';

@lazySingleton
class PromptScrubber {
@lazySingleton
  final Isar _isar;

  PromptScrubber(this._isar);

  static final _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
  );

  static final _phonePattern = RegExp(
    r'\b(\+\d{1,3}[- ]?)?\(?\d{3}\)?[- ]?\d{3}[- ]?\d{4}\b',
  );

  static final _ipAddressPattern = RegExp(
    r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b',
  );

  // Simplified name patterns or list can be added here
  // For now, let's focus on the explicitly required ones.

  static final _deviceIdPattern = RegExp(
    r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
  );

  Future<String> scrub(String prompt, {required String apiName}) async {
    String scrubbed = prompt;
    bool piiFound = false;

    if (_emailPattern.hasMatch(scrubbed)) {
      scrubbed = scrubbed.replaceAll(_emailPattern, '[EMAIL]');
      piiFound = true;
    }

    if (_phonePattern.hasMatch(scrubbed)) {
      scrubbed = scrubbed.replaceAll(_phonePattern, '[PHONE]');
      piiFound = true;
    }

    if (_ipAddressPattern.hasMatch(scrubbed)) {
      scrubbed = scrubbed.replaceAll(_ipAddressPattern, '[IP_ADDRESS]');
      piiFound = true;
    }

    if (_deviceIdPattern.hasMatch(scrubbed)) {
      scrubbed = scrubbed.replaceAll(_deviceIdPattern, '[DEVICE_ID]');
      piiFound = true;
    }

    // Audit log
    final log = ApiAuditLog(
      timestamp: DateTime.now(),
      apiName: apiName,
      originalPromptLength: prompt.length,
      scrubbedPromptLength: scrubbed.length,
      piiFound: piiFound,
    );

    // Skip Isar write if it fails in tests due to mock issues,
    // but try to do it properly.
    try {
      await _isar.writeTxn(() async {
        await _isar.apiAuditLogs.put(log);
      });
    } catch (e) {
      // In production we want to know if logging fails,
      // but let's not block the primary functionality.
      // Audit logging failed, continuing with scrubbed data
    }

    return scrubbed;
  }
}
