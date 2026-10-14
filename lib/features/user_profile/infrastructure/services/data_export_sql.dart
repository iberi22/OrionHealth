import 'dart:convert';

class DataExportSqlBuilder {
  static String buildSqlDump(Map<String, dynamic> dataMap) {
    final buffer = StringBuffer();
    buffer.writeln('PRAGMA foreign_keys=OFF;');
    buffer.writeln('BEGIN;');
    buffer.writeln(
      'CREATE TABLE IF NOT EXISTS "_export_meta" (key TEXT PRIMARY KEY, value TEXT NOT NULL);',
    );

    final metadata = dataMap['metadata'] as Map<String, dynamic>? ?? {};
    final format = metadata['format'] ?? 'JSON + SQL';
    final appId = 'OrionHealth';
    final exportedAt =
        metadata['export_timestamp'] ??
        DateTime.now().toUtc().toIso8601String();
    final schemaVersion = '1';

    buffer.writeln(
      'INSERT INTO "_export_meta" (key, value) VALUES (\'format\', \'${_quote(format)}\');',
    );
    buffer.writeln(
      'INSERT INTO "_export_meta" (key, value) VALUES (\'app_id\', \'${_quote(appId)}\');',
    );
    buffer.writeln(
      'INSERT INTO "_export_meta" (key, value) VALUES (\'exported_at\', \'${_quote(exportedAt)}\');',
    );
    buffer.writeln(
      'INSERT INTO "_export_meta" (key, value) VALUES (\'schema_version\', \'${_quote(schemaVersion)}\');',
    );

    final tableRegex = RegExp(r'^[A-Za-z0-9_]+$');

    dataMap.forEach((key, value) {
      if (key == 'metadata') return;
      if (key == 'README') return;

      final tableName = key
          .replaceAll('.json', '')
          .replaceAll('.swalhealth', '');
      if (!tableRegex.hasMatch(tableName)) {
        throw ArgumentError('Invalid table name: $tableName');
      }

      buffer.writeln(
        'CREATE TABLE IF NOT EXISTS "$tableName" (id TEXT PRIMARY KEY, instance_id TEXT, created_at TEXT, updated_at TEXT, deleted_at TEXT, data TEXT NOT NULL);',
      );

      List<dynamic> records = [];
      if (value is Map<String, dynamic> && value.containsKey('data')) {
        records = value['data'] as List<dynamic>;
      } else if (value is List<dynamic>) {
        records = value;
      }

      for (final record in records) {
        if (record is Map<String, dynamic>) {
          final id =
              record['id']?.toString() ??
              record['uniqueId']?.toString() ??
              'unknown_${DateTime.now().microsecondsSinceEpoch}';
          final instanceId = record['instanceId']?.toString() ?? '';
          final createdAt = record['createdAt']?.toString() ?? '';
          final updatedAt = record['updatedAt']?.toString() ?? '';
          final deletedAt = record['deletedAt']?.toString() ?? '';

          final jsonStr = jsonEncode(record);

          buffer.writeln(
            'INSERT INTO "$tableName" (id, instance_id, created_at, updated_at, deleted_at, data) VALUES (\'${_quote(id)}\', \'${_quote(instanceId)}\', \'${_quote(createdAt)}\', \'${_quote(updatedAt)}\', \'${_quote(deletedAt)}\', \'${_quote(jsonStr)}\');',
          );
        }
      }
    });

    buffer.writeln('COMMIT;');
    return buffer.toString();
  }

  static String _quote(String value) {
    return value.replaceAll("'", "''");
  }
}
