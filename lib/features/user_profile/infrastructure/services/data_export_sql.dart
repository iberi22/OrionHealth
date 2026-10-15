import 'dart:convert';

/// Converts a collection of exported JSON strings into a unified SQLite dump.
class DataExportSqlBuilder {
  /// Builds the SQL dump from the provided [files] (map of filename to JSON string),
  /// the [appId], and [schemaVersion].
  static String buildSqlDump({
    required Map<String, String> files,
    String appId = 'orionhealth_health',
    String schemaVersion = '1',
  }) {
    final buffer = StringBuffer();
    buffer.writeln('PRAGMA foreign_keys=OFF;');
    buffer.writeln('BEGIN;');

    // Export metadata table
    buffer.writeln(
      'CREATE TABLE IF NOT EXISTS "_export_meta" (key TEXT PRIMARY KEY, value TEXT NOT NULL);',
    );
    buffer.writeln(
      'INSERT INTO "_export_meta" (key, value) VALUES (\'format\', \'export-v1\');',
    );
    buffer.writeln(
      'INSERT INTO "_export_meta" (key, value) VALUES (\'app_id\', \'${_escape(appId)}\');',
    );
    buffer.writeln(
      'INSERT INTO "_export_meta" (key, value) VALUES (\'exported_at\', \'${_escape(DateTime.now().toUtc().toIso8601String())}\');',
    );
    buffer.writeln(
      'INSERT INTO "_export_meta" (key, value) VALUES (\'schema_version\', \'${_escape(schemaVersion)}\');',
    );

    // Process each JSON file
    for (final entry in files.entries) {
      if (!entry.key.endsWith('.json') || entry.key == 'metadata.json') {
        continue;
      }
      final tableName = _sanitizeIdentifier(entry.key.replaceAll('.json', '').replaceAll('.swalhealth', ''));
      buffer.writeln(
        'CREATE TABLE IF NOT EXISTS "$tableName" (id TEXT PRIMARY KEY, instance_id TEXT, created_at TEXT, updated_at TEXT, deleted_at TEXT, data TEXT NOT NULL);',
      );

      final dynamic decoded = jsonDecode(entry.value);
      final List<dynamic> records;

      if (decoded is Map<String, dynamic> && decoded.containsKey('data') && decoded['data'] is List) {
        records = decoded['data'] as List<dynamic>;
      } else if (decoded is List) {
        records = decoded;
      } else {
        continue; // Unrecognized structure, skip
      }

      for (final record in records) {
        if (record is! Map<String, dynamic>) continue;

        final id = _escape(record['id']?.toString() ?? record['uniqueId']?.toString() ?? '');
        final instanceId = _escape(record['instanceId']?.toString() ?? '');
        final createdAt = _escape(record['createdAt']?.toString() ?? record['timestamp']?.toString() ?? '');
        final updatedAt = _escape(record['updatedAt']?.toString() ?? '');
        final deletedAt = _escape(record['deletedAt']?.toString() ?? '');
        final data = _escape(jsonEncode(record));

        buffer.writeln(
          'INSERT INTO "$tableName" (id, instance_id, created_at, updated_at, deleted_at, data) VALUES (\'$id\', \'$instanceId\', \'$createdAt\', \'$updatedAt\', \'$deletedAt\', \'$data\');',
        );
      }
    }

    buffer.writeln('COMMIT;');
    return buffer.toString();
  }

  static String _escape(String input) {
    return input.replaceAll('\'', '\'\'');
  }

  static String _sanitizeIdentifier(String name) {
    final sanitized = name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(sanitized)) {
      throw FormatException('Invalid identifier: $name');
    }
    return sanitized;
  }
}