import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_attachment.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/repositories/health_record_repository_impl.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late HealthRecordRepositoryImpl repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.systemTemp.path, 'test_db_health_records_repo_impl');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [MedicalRecordSchema],
      directory: testDir,
    );
    repository = HealthRecordRepositoryImpl(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() => isar.medicalRecords.clear());
  });

  group('HealthRecordRepositoryImpl', () {
    test('saveRecord should persist medical record', () async {
      final record = MedicalRecord(
        summary: 'Test Record',
        type: RecordType.clinicalNote,
        date: DateTime(2023, 1, 1),
      );

      await repository.saveRecord(record);

      final results = await isar.medicalRecords.where().findAll();
      expect(results.length, 1);
      expect(results.first.summary, 'Test Record');
    });

    test('getAllRecords should return all persisted records', () async {
      final records = [
        MedicalRecord(summary: 'Record 1'),
        MedicalRecord(summary: 'Record 2'),
      ];

      await isar.writeTxn(() async {
        await isar.medicalRecords.putAll(records);
      });

      final results = await repository.getAllRecords();
      expect(results.length, 2);
      expect(results.any((r) => r.summary == 'Record 1'), isTrue);
      expect(results.any((r) => r.summary == 'Record 2'), isTrue);
    });
  });
}
