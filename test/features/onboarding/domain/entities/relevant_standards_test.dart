import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/domain/services/profile_analysis_service.dart';

void main() {
  group('RelevantStandards', () {
    test('supports value storage via constructor', () {
      const standards = RelevantStandards(
        icd10Codes: ['E11', 'I10'],
        loincCodes: ['2345-7', '8480-6'],
        guidelineIds: ['ADA-2024', 'JNC-8'],
        medicationClasses: ['metformin', 'ace_inhibitors'],
        estimatedSizeMB: 45,
      );

      expect(standards.icd10Codes, ['E11', 'I10']);
      expect(standards.loincCodes, ['2345-7', '8480-6']);
      expect(standards.guidelineIds, ['ADA-2024', 'JNC-8']);
      expect(standards.medicationClasses, ['metformin', 'ace_inhibitors']);
      expect(standards.estimatedSizeMB, 45);
    });

    test('default values are empty or zero', () {
      const standards = RelevantStandards();

      expect(standards.icd10Codes, isEmpty);
      expect(standards.loincCodes, isEmpty);
      expect(standards.guidelineIds, isEmpty);
      expect(standards.medicationClasses, isEmpty);
      expect(standards.estimatedSizeMB, 0);
    });
  });
}
