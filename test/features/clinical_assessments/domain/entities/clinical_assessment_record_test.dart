import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/clinical_assessments/domain/entities/clinical_assessment_record.dart';

void main() {
  group('ClinicalAssessmentRecord', () {
    test('can be instantiated with all properties', () {
      final now = DateTime.now();
      final record = ClinicalAssessmentRecord(
        assessmentType: 'health_survey',
        completedAt: now,
        resultJson: '{"example": true}',
      );

      expect(record.assessmentType, 'health_survey');
      expect(record.completedAt, now);
      expect(record.resultJson, '{"example": true}');
    });

    test('has auto-increment Id by default', () {
      final record = ClinicalAssessmentRecord();

      expect(record.id, Isar.autoIncrement);
    });

    test('all fields are nullable', () {
      final record = ClinicalAssessmentRecord();

      expect(record.assessmentType, isNull);
      expect(record.completedAt, isNull);
      expect(record.resultJson, isNull);
    });

    test('can update assessmentType', () {
      final record = ClinicalAssessmentRecord(assessmentType: 'informed_consent');

      expect(record.assessmentType, 'informed_consent');

      record.assessmentType = 'active_task_tremor';

      expect(record.assessmentType, 'active_task_tremor');
    });

    test('can update resultJson', () {
      final record = ClinicalAssessmentRecord(resultJson: '{"a": 1}');

      record.resultJson = '{"b": 2}';

      expect(record.resultJson, '{"b": 2}');
    });

    test('can update completedAt', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 1));
      final record = ClinicalAssessmentRecord(completedAt: now);

      record.completedAt = later;

      expect(record.completedAt, later);
    });

    test('two instances with same values are not identical', () {
      final now = DateTime.now();
      final record1 = ClinicalAssessmentRecord(
        assessmentType: 'consent',
        completedAt: now,
        resultJson: '{}',
      );
      final record2 = ClinicalAssessmentRecord(
        assessmentType: 'consent',
        completedAt: now,
        resultJson: '{}',
      );

      expect(record1 == record2, false); // No operator== override, so reference comparison
      expect(identical(record1, record2), false);
    });
  });
}
