import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/onboarding/domain/services/profile_analysis_service.dart';

void main() {
  late ProfileAnalysisService service;

  setUp(() {
    service = ProfileAnalysisService();
  });

  group('ProfileAnalysisService', () {
    test('analyzeProfile returns correct standards for diabetes', () {
      final profile = UserProfile(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        conditions: const ['Diabetes Type 2'],
      );

      final standards = service.analyzeProfile(profile);

      expect(standards.icd10Codes, contains('E11'));
      expect(standards.loincCodes, contains('2345-7')); // Glucose
      expect(standards.guidelineIds, contains('ADA-2024'));
      expect(standards.medicationClasses, contains('metformin'));
    });

    test('analyzeProfile returns correct standards for hypertension/HTA', () {
      final profile = UserProfile(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        conditions: const ['HTA'],
      );

      final standards = service.analyzeProfile(profile);

      expect(standards.icd10Codes, contains('I10'));
      expect(standards.loincCodes, contains('8480-6')); // Systolic BP
      expect(standards.guidelineIds, contains('JNC-8'));
    });

    test('analyzeProfile returns correct standards for thyroid', () {
      final profile = UserProfile(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        conditions: const ['Thyroid issues'],
      );

      final standards = service.analyzeProfile(profile);

      expect(standards.icd10Codes, contains('E03'));
      expect(standards.loincCodes, contains('3024-0')); // TSH
      expect(standards.guidelineIds, contains('ATA-2023'));
    });

    test('analyzeProfile returns correct standards for medications', () {
      final profile = UserProfile(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        medications: const ['Lisinopril 10mg', 'Metformin'],
      );

      final standards = service.analyzeProfile(profile);

      expect(standards.medicationClasses, contains('ace_inhibitors'));
      expect(standards.medicationClasses, contains('diabetes_medications'));
    });

    test('estimateStorageSizeMb returns non-zero for medical profile', () {
      final profile = UserProfile(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        conditions: const ['Diabetes'],
      );

      final size = service.estimateStorageSizeMb(profile);
      expect(size, greaterThan(0));
    });

    test('analyzeProfile returns empty for healthy profile', () {
      final profile = UserProfile(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final standards = service.analyzeProfile(profile);

      expect(standards.icd10Codes, isEmpty);
      expect(standards.loincCodes, isEmpty);
      expect(standards.guidelineIds, isEmpty);
      expect(standards.medicationClasses, isEmpty);
      expect(standards.estimatedSizeMB, 0);
    });

    test('analyzeProfile aggregates codes for multiple conditions', () {
      final profile = UserProfile(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        conditions: const ['Diabetes', 'Hypertension'],
      );

      final standards = service.analyzeProfile(profile);

      expect(standards.icd10Codes, containsAll(['E10', 'E11', 'I10', 'I11']));
      expect(standards.loincCodes, containsAll(['2345-7', '4548-4', '8480-6', '8462-4']));
      expect(standards.guidelineIds, containsAll(['ADA-2024', 'JNC-8']));
      expect(standards.medicationClasses, containsAll(['insulin', 'metformin', 'ace_inhibitors', 'beta_blockers']));
      expect(standards.estimatedSizeMB, greaterThan(0));
    });

    test('analyzeProfile handles unknown conditions gracefully', () {
      final profile = UserProfile(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        conditions: const ['Unknown condition 123'],
      );

      final standards = service.analyzeProfile(profile);

      expect(standards.icd10Codes, isEmpty);
      expect(standards.loincCodes, isEmpty);
      expect(standards.guidelineIds, isEmpty);
      expect(standards.medicationClasses, isEmpty);
      expect(standards.estimatedSizeMB, 0);
    });
  });
}
