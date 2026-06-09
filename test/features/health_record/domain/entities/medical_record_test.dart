import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_attachment.dart';

void main() {
  group('MedicalRecord', () {
    test('should create MedicalRecord with default values', () {
      final record = MedicalRecord();

      expect(record.type, RecordType.other);
      expect(record.attachments, isEmpty);
      expect(record.date, isNull);
      expect(record.summary, isNull);
    });

    test('should create MedicalRecord with provided values', () {
      final date = DateTime(2023, 10, 27);
      final attachment = MedicalAttachment(localPath: 'test.pdf');
      final record = MedicalRecord(
        date: date,
        type: RecordType.labResult,
        summary: 'Blood test',
        attachments: [attachment],
      );

      expect(record.date, date);
      expect(record.type, RecordType.labResult);
      expect(record.summary, 'Blood test');
      expect(record.attachments, contains(attachment));
    });

    test('should support value equality', () {
      final date = DateTime(2023, 10, 27);
      final attachment1 = MedicalAttachment(localPath: 'test.pdf');
      final attachment2 = MedicalAttachment(localPath: 'test.pdf');

      final record1 = MedicalRecord(
        date: date,
        type: RecordType.prescription,
        summary: 'Aspirin',
        attachments: [attachment1],
      )..id = 1;

      final record2 = MedicalRecord(
        date: date,
        type: RecordType.prescription,
        summary: 'Aspirin',
        attachments: [attachment2],
      )..id = 1;

      final record3 = MedicalRecord(
        date: date,
        type: RecordType.prescription,
        summary: 'Aspirin',
        attachments: [attachment1],
      )..id = 2;

      expect(record1, equals(record2));
      expect(record1, isNot(equals(record3)));
      expect(record1.hashCode, record2.hashCode);
    });

    test('should support serialization', () {
      final date = DateTime(2023, 10, 27).toUtc();
      final attachment = MedicalAttachment(localPath: 'test.pdf');
      final record = MedicalRecord(
        date: date,
        type: RecordType.labResult,
        summary: 'Blood test',
        attachments: [attachment],
      )..id = 10;

      final json = record.toJson();
      final fromJson = MedicalRecord.fromJson(json);

      expect(fromJson, equals(record));
      expect(fromJson.id, record.id);
      expect(fromJson.attachments.first, equals(attachment));
    });

    test('should handle validation', () {
      final validAttachment = MedicalAttachment(localPath: 'path.pdf');
      final invalidAttachment = MedicalAttachment(localPath: '');

      final validRecord = MedicalRecord(attachments: [validAttachment]);
      final invalidRecord = MedicalRecord(attachments: [invalidAttachment]);
      final emptyRecord = MedicalRecord(attachments: []);

      expect(validRecord.isValid, isTrue);
      expect(invalidRecord.isValid, isFalse);
      expect(emptyRecord.isValid, isTrue); // Empty is technically valid if no attachments
    });

    test('should handle empty records and null fields', () {
      final record = MedicalRecord(
        date: null,
        summary: null,
        attachments: [],
      );

      expect(record.date, isNull);
      expect(record.summary, isNull);
      expect(record.attachments, isEmpty);
    });

    test('should handle nested equality with attachments', () {
      final attachment1 = MedicalAttachment(localPath: 'path1');
      final attachment2 = MedicalAttachment(localPath: 'path1');
      final attachment3 = MedicalAttachment(localPath: 'path2');

      final record1 = MedicalRecord(attachments: [attachment1]);
      final record2 = MedicalRecord(attachments: [attachment2]);
      final record3 = MedicalRecord(attachments: [attachment3]);

      expect(record1, equals(record2));
      expect(record1, isNot(equals(record3)));
    });
  });
}
