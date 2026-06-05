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
    testDir = p.join(Directory.current.path, 'test_db_health_records');
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

  test('Should save and retrieve a health record', () async {
    final attachment = MedicalAttachment(
      localPath: 'test.pdf',
      mimeType: 'application/pdf',
      extractedText: 'Extracted text content',
    );

    final record = MedicalRecord(
      date: DateTime.now(),
      type: RecordType.labResult,
      summary: 'Test summary',
      attachments: [attachment],
    );

    await repository.saveRecord(record);

    final records = await repository.getAllRecords();
    expect(records.length, 1);
    expect(records.first.summary, 'Test summary');
    expect(records.first.type, RecordType.labResult);
    expect(records.first.attachments.length, 1);
    expect(records.first.attachments.first.extractedText, 'Extracted text content');
  });

  test('Should return multiple records sorted by Isar (default)', () async {
    final record1 = MedicalRecord(summary: 'Record 1');
    final record2 = MedicalRecord(summary: 'Record 2');

    await repository.saveRecord(record1);
    await repository.saveRecord(record2);

    final records = await repository.getAllRecords();
    expect(records.length, 2);
    final summaries = records.map((r) => r.summary).toList();
    expect(summaries, containsAll(['Record 1', 'Record 2']));
  });

  test('Should handle empty records', () async {
    final records = await repository.getAllRecords();
    expect(records, isEmpty);
  });
}
