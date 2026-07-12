// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:convert';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Service for audit logging of medical data access and sensitive operations.
///
/// Logs are persisted locally in rotating files (max 30 days) and
/// do not contain PHI (Protected Health Information).
@lazySingleton
class AuditLogger {
  static const String _logPrefix = 'audit_';
  static const String _logExtension = '.log';
  static const String _exportPrefix = 'audit_export_';
  static const String _exportExtension = '.json';
  static const int _maxDays = 30;

  bool _rotationPerformed = false;

  /// Gets the directory where audit logs are stored.
  Future<String> get _logDirectoryPath async {
    final directory = await getApplicationDocumentsDirectory();
    final logPath = p.join(directory.path, 'logs', 'audit');
    final dir = Directory(logPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return logPath;
  }

  /// Logs an access or action event.
  ///
  /// [userId] Opaque identifier of the user performing the action.
  /// [action] Description of the action (e.g., 'READ', 'WRITE', 'DELETE', 'EXPORT').
  /// [resourceType] Type of medical data accessed (e.g., 'MedicalRecord', 'Vitals', 'Allergy').
  /// [resourceId] Opaque identifier of the specific resource.
  /// [metadata] Optional additional non-PHI context.
  Future<void> log({
    required String userId,
    required String action,
    required String resourceType,
    required String resourceId,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now().toUtc();
    final entry = {
      'timestamp': now.toIso8601String(),
      'userId': userId,
      'action': action,
      'resourceType': resourceType,
      'resourceId': resourceId,
      if (metadata != null) 'metadata': metadata,
    };

    try {
      final logDir = await _logDirectoryPath;
      final today = DateFormat('yyyy-MM-dd').format(now);
      final logFile = File(p.join(logDir, '$_logPrefix$today$_logExtension'));

      final logLine = jsonEncode(entry);
      await logFile.writeAsString('$logLine\n', mode: FileMode.append, flush: true);

      // Perform rotation check once per session
      if (!_rotationPerformed) {
        await _rotateLogs();
        _rotationPerformed = true;
      }
    } catch (e) {
      // Audit logging should be best-effort and not crash the app
      stderr.writeln('Failed to write audit log: $e');
    }
  }

  /// Removes log files and export files older than [_maxDays].
  Future<void> _rotateLogs() async {
    try {
      final logDir = await _logDirectoryPath;
      final dir = Directory(logDir);
      final entities = await dir.list().toList();

      final now = DateTime.now().toUtc();
      final expirationDate = DateTime.utc(now.year, now.month, now.day).subtract(const Duration(days: _maxDays));

      for (final entity in entities) {
        if (entity is File) {
          final fileName = p.basename(entity.path);

          // Rotate logs
          if (fileName.startsWith(_logPrefix) && fileName.endsWith(_logExtension)) {
            final datePart = fileName.substring(_logPrefix.length, fileName.length - _logExtension.length);
            try {
              final fileDate = DateFormat('yyyy-MM-dd').parseUtc(datePart);
              if (fileDate.isBefore(expirationDate)) {
                await entity.delete();
              }
            } catch (_) {
              // Skip files that don't match our date format
            }
          }

          // Rotate exports
          if (fileName.startsWith(_exportPrefix) && fileName.endsWith(_exportExtension)) {
            final stat = await entity.stat();
            if (stat.modified.isBefore(expirationDate)) {
              await entity.delete();
            }
          }
        }
      }
    } catch (e) {
      stderr.writeln('Failed to rotate audit logs: $e');
    }
  }

  /// Exports all available audit logs into a single JSON file for compliance.
  ///
  /// Returns the [File] containing the exported logs.
  Future<File> exportAuditLogs() async {
    final logDir = await _logDirectoryPath;
    final dir = Directory(logDir);
    final entities = await dir.list().toList();

    // Filter and sort audit log files by date
    final logFiles = entities
        .whereType<File>()
        .where((f) {
          final name = p.basename(f.path);
          return name.startsWith(_logPrefix) && name.endsWith(_logExtension);
        })
        .toList();

    logFiles.sort((a, b) => a.path.compareTo(b.path));

    final now = DateTime.now().toUtc();
    final exportFile = File(p.join(logDir, '$_exportPrefix${now.millisecondsSinceEpoch}$_exportExtension'));
    final sink = exportFile.openWrite();

    sink.write('[\n');
    bool firstEntry = true;

    for (final file in logFiles) {
      final lines = file.openRead().transform(utf8.decoder).transform(const LineSplitter());
      await for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        if (!firstEntry) {
          sink.write(',\n');
        }
        sink.write('  $trimmed');
        firstEntry = false;
      }
    }

    sink.write('\n]');
    await sink.close();

    return exportFile;
  }
}
