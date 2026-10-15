import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/services/data_export_sql.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DataExportSqlBuilder', () {
    test('buildSqlDump generates valid SQLite syntax', () async {
      final files = {
        'metadata.json': '{"ignored": true}', // Should be ignored
        'medications.json': '{"data": [{"id": "1", "name": "Aspirin"}]}',
        'allergies.json': '{"data": [{"id": "2", "name": "Peanuts", "createdAt": "2026-10-14"}]}',
      };

      final sql = DataExportSqlBuilder.buildSqlDump(files: files);

      // Verify basic structure
      expect(sql, contains('PRAGMA foreign_keys=OFF;'));
      expect(sql, contains('BEGIN;'));
      expect(sql, contains('COMMIT;'));

      expect(sql, contains('CREATE TABLE IF NOT EXISTS "_export_meta"'));
      expect(sql, contains('CREATE TABLE IF NOT EXISTS "medications"'));
      expect(sql, contains('CREATE TABLE IF NOT EXISTS "allergies"'));

      expect(sql, contains('INSERT INTO "medications" (id, instance_id, created_at, updated_at, deleted_at, data) VALUES (\'1\', \'\', \'\', \'\', \'\', \'{"id":"1","name":"Aspirin"}\');'));

      // Test with sqlite3 in memory
      final db = await databaseFactory.openDatabase(inMemoryDatabasePath);

      // Execute the dump
      final statements = sql.split(';');
      for (final stmt in statements) {
        final trimmed = stmt.trim();
        if (trimmed.isNotEmpty) {
          await db.execute(trimmed);
        }
      }

      // Verify data
      final meds = await db.query('medications');
      expect(meds.length, 1);
      expect(meds.first['id'], '1');
      expect(meds.first['data'], '{"id":"1","name":"Aspirin"}');

      final allergies = await db.query('allergies');
      expect(allergies.length, 1);
      expect(allergies.first['id'], '2');
      expect(allergies.first['created_at'], '2026-10-14');

      await db.close();
    });
  });
}