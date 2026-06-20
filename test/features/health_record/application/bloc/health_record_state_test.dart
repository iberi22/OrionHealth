import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_record/application/bloc/health_record_cubit.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';

void main() {
  group('HealthRecordState', () {
    test('HealthRecordInitial supports value equality', () {
      expect(const HealthRecordInitial(), equals(const HealthRecordInitial()));
    });

    test('HealthRecordLoading supports value equality', () {
      expect(const HealthRecordLoading(), equals(const HealthRecordLoading()));
    });

    test('HealthRecordLoaded supports value equality', () {
      final records = [
        MedicalRecord(summary: 'Record 1'),
        MedicalRecord(summary: 'Record 2'),
      ];
      expect(
        HealthRecordLoaded(records),
        equals(HealthRecordLoaded(records)),
      );
    });

    test('HealthRecordFilePicked supports value equality', () {
      expect(
        const HealthRecordFilePicked(filePath: 'path', extractedText: 'text'),
        equals(const HealthRecordFilePicked(filePath: 'path', extractedText: 'text')),
      );
    });

    test('HealthRecordSaved supports value equality', () {
      expect(const HealthRecordSaved(), equals(const HealthRecordSaved()));
    });

    test('HealthRecordError supports value equality', () {
      expect(
        const HealthRecordError('error'),
        equals(const HealthRecordError('error')),
      );
    });

    test('records getter returns empty list for base states', () {
      expect(const HealthRecordInitial().records, isEmpty);
      expect(const HealthRecordLoading().records, isEmpty);
      expect(const HealthRecordSaved().records, isEmpty);
      expect(const HealthRecordError('error').records, isEmpty);
    });

    test('records getter returns records for HealthRecordLoaded', () {
      final records = [MedicalRecord(summary: 'Record 1')];
      expect(HealthRecordLoaded(records).records, equals(records));
    });

    test('props are correct for each state', () {
      expect(const HealthRecordInitial().props, isEmpty);
      expect(const HealthRecordLoading().props, isEmpty);

      final records = [MedicalRecord(summary: 'Record 1')];
      expect(HealthRecordLoaded(records).props, [records]);

      expect(
        const HealthRecordFilePicked(filePath: 'path', extractedText: 'text').props,
        ['path', 'text'],
      );

      expect(const HealthRecordSaved().props, isEmpty);
      expect(const HealthRecordError('error').props, ['error']);
    });
  });
}
