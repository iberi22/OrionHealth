import 'package:test/test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('ClinicalGuidelineReference', () {
    test('guideline has required fields', () {
      expect(ClinicalGuidelines.ahaHypertension.code, isNotEmpty);
      expect(ClinicalGuidelines.ahaHypertension.displayName, isNotEmpty);
      expect(ClinicalGuidelines.ahaHypertension.url, isNotEmpty);
    });

    test('guideline has valid URL format', () {
      expect(ClinicalGuidelines.ahaHypertension.url, contains('http'));
    });
  });

  group('ClinicalGuidelines', () {
    test('findByCode returns correct guideline', () {
      final guideline = ClinicalGuidelines.findByCode('ADA-2024');
      expect(guideline, isNotNull);
      expect(guideline!.code, equals('ADA-2024'));
    });

    test('findByCode returns null for invalid code', () {
      final guideline = ClinicalGuidelines.findByCode('INVALID');
      expect(guideline, isNull);
    });

    test('findForCondition returns guidelines for diabetes', () {
      final guidelines = ClinicalGuidelines.findForCondition('E11');
      expect(guidelines, isNotEmpty);
    });

    test('findForCondition returns empty for unknown condition', () {
      final guidelines = ClinicalGuidelines.findForCondition('INVALID');
      expect(guidelines, isEmpty);
    });

    test('all returns non-empty list', () {
      expect(ClinicalGuidelines.all, isNotEmpty);
    });

    test('labReferenceRanges guideline exists', () {
      expect(ClinicalGuidelines.labReferenceRanges.code, equals('CLSI-2017'));
      expect(ClinicalGuidelines.labReferenceRanges.displayName, isNotEmpty);
    });

    test('accAhaRiskCalculator guideline exists', () {
      expect(ClinicalGuidelines.accAhaRiskCalculator.code, equals('ACC-AHA-ASCVD'));
      expect(ClinicalGuidelines.accAhaRiskCalculator.displayName, isNotEmpty);
    });

    test('guideline references have valid structure', () {
      for (final guideline in ClinicalGuidelines.all) {
        expect(guideline.code, isNotEmpty);
        expect(guideline.displayName, isNotEmpty);
        expect(guideline.url, isNotEmpty);
        expect(guideline.description, isNotEmpty);
      }
    });
  });
}
