// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/logging/audit_logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return 'test_docs_refactored';
  }
}

void main() {
  late AuditLogger auditLogger;
  late Directory testDir;

  setUp(() async {
    PathProviderPlatform.instance = MockPathProvider();
    testDir = Directory('test_docs_refactored');
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
    await testDir.create();
    auditLogger = AuditLogger();
  });

  tearDown(() async {
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  test('log should create a daily log file (UTC) and append entries', () async {
    await auditLogger.log(
      userId: 'user_123',
      action: 'READ',
      resourceType: 'MedicalRecord',
      resourceId: 'rec_456',
      metadata: {'reason': 'routine check'},
    );

    final logDir = Directory(p.join(testDir.path, 'logs', 'audit'));
    final files = await logDir.list().toList();
    expect(files.length, 1);
    expect(p.basename(files.first.path), startsWith('audit_'));
    expect(p.basename(files.first.path), endsWith('.log'));

    final content = await File(files.first.path).readAsString();
    final entry = jsonDecode(content.trim());

    expect(entry['userId'], 'user_123');
    expect(entry['action'], 'READ');
    expect(entry['resourceType'], 'MedicalRecord');
    expect(entry['resourceId'], 'rec_456');
    expect(entry['metadata']['reason'], 'routine check');
    expect(entry['timestamp'], isNotNull);
    // Verify ISO 8601 UTC
    expect(entry['timestamp'], endsWith('Z'));
    expect(DateTime.tryParse(entry['timestamp'])?.isUtc, true);
  });

  test('exportAuditLogs should consolidate logs using streams', () async {
    // Manually create some log files
    final logDir = Directory(p.join(testDir.path, 'logs', 'audit'));
    await logDir.create(recursive: true);

    final file1 = File(p.join(logDir.path, 'audit_2023-01-01.log'));
    await file1.writeAsString('{"id": 1}\n{"id": 2}\n');

    final file2 = File(p.join(logDir.path, 'audit_2023-01-02.log'));
    await file2.writeAsString('{"id": 3}\n');

    final exportFile = await auditLogger.exportAuditLogs();

    expect(await exportFile.exists(), true);
    expect(p.basename(exportFile.path), startsWith('audit_export_'));

    final content = await exportFile.readAsString();
    final List<dynamic> exportedData = jsonDecode(content);

    expect(exportedData.length, 3);
    expect(exportedData[0]['id'], 1);
    expect(exportedData[1]['id'], 2);
    expect(exportedData[2]['id'], 3);
  });

  test('rotation logic should remove logs and exports older than 30 days', () async {
    final logDir = Directory(p.join(testDir.path, 'logs', 'audit'));
    await logDir.create(recursive: true);

    final now = DateTime.now().toUtc();
    final oldDate = now.subtract(const Duration(days: 31));
    final oldDateStr = "${oldDate.year}-${oldDate.month.toString().padLeft(2, '0')}-${oldDate.day.toString().padLeft(2, '0')}";

    final recentDate = now.subtract(const Duration(days: 10));
    final recentDateStr = "${recentDate.year}-${recentDate.month.toString().padLeft(2, '0')}-${recentDate.day.toString().padLeft(2, '0')}";

    final oldLogFile = File(p.join(logDir.path, 'audit_$oldDateStr.log'));
    await oldLogFile.writeAsString('{"old": true}\n');

    final recentLogFile = File(p.join(logDir.path, 'audit_$recentDateStr.log'));
    await recentLogFile.writeAsString('{"recent": true}\n');

    // Create an old export file
    final oldExportFile = File(p.join(logDir.path, 'audit_export_123.json'));
    await oldExportFile.writeAsString('[]');
    // Mock the modification date for export file (hard to do exactly without more mocks,
    // but we can set it back in time)
    await oldExportFile.setLastModified(oldDate);

    // Trigger rotation by logging something
    await auditLogger.log(
      userId: 'u',
      action: 'A',
      resourceType: 'T',
      resourceId: 'I',
    );

    expect(await oldLogFile.exists(), false);
    expect(await recentLogFile.exists(), true);
    expect(await oldExportFile.exists(), false);
  });
}
