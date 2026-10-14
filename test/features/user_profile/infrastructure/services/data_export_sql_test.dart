import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/services/data_export_sql.dart';

void main() {
  group('DataExportSqlBuilder', () {
    test(
      'buildSqlDump generates correct schema and inserts and can be verified like sqlite3',
      () {
        final dataMap = {
          'metadata': {
            'export_timestamp': '2026-10-14T10:00:00Z',
            'format': 'JSON + SQL',
          },
          'profile.json': {
            'count': 1,
            'data': [
              {'id': '123', 'name': 'John O\'Dea', 'createdAt': '2026-01-01'},
            ],
          },
          'medications.json': {
            'count': 2,
            'data': [
              {'uniqueId': 'med_1', 'name': 'Aspirin'},
              {'uniqueId': 'med_2', 'name': 'Ibuprofen'},
            ],
          },
        };

        final sql = DataExportSqlBuilder.buildSqlDump(dataMap);

        // Verify transaction wrappers
        expect(sql, contains('PRAGMA foreign_keys=OFF;'));
        expect(sql, contains('BEGIN;'));
        expect(sql, contains('COMMIT;'));

        // Verify metadata inserts and escapes
        expect(sql, contains('CREATE TABLE IF NOT EXISTS "_export_meta"'));
        expect(
          sql,
          contains(
            "INSERT INTO \"_export_meta\" (key, value) VALUES ('format', 'JSON + SQL');",
          ),
        );

        // Verify tables
        expect(sql, contains('CREATE TABLE IF NOT EXISTS "profile"'));
        expect(sql, contains('CREATE TABLE IF NOT EXISTS "medications"'));

        // Verify inserts and quotes
        expect(
          sql,
          contains(
            "INSERT INTO \"profile\" (id, instance_id, created_at, updated_at, deleted_at, data) VALUES ('123', '', '2026-01-01', '', '', '{\"id\":\"123\",\"name\":\"John O''Dea\",\"createdAt\":\"2026-01-01\"}');",
          ),
        );
        expect(
          sql,
          contains(
            "INSERT INTO \"medications\" (id, instance_id, created_at, updated_at, deleted_at, data) VALUES ('med_1', '', '', '', '', '{\"uniqueId\":\"med_1\",\"name\":\"Aspirin\"}');",
          ),
        );
        expect(
          sql,
          contains(
            "INSERT INTO \"medications\" (id, instance_id, created_at, updated_at, deleted_at, data) VALUES ('med_2', '', '', '', '', '{\"uniqueId\":\"med_2\",\"name\":\"Ibuprofen\"}');",
          ),
        );
      },
    );
  });
}
