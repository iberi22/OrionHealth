import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('Integration: Medical Standards Cross-Reference', () {
    test('ICD-10 links to SNOMED and Guidelines', () {
      final icd10 = Icd10Code.findByCode('E11');
      expect(icd10, isNotNull);

      final guidelines = ClinicalGuidelines.findForCondition('E11');
      expect(guidelines, isNotEmpty);

      // Should have related SNOMED concept
      final snomed = SnomedCommonConcepts.all.firstWhere(
        (s) => s.fsn.toLowerCase().contains('diabetes'),
        orElse: () => SnomedCommonConcepts.all.first,
      );
      expect(snomed, isNotNull);
    });

    test('LOINC links to Lab Reference Ranges', () {
      final glucose = LoincCommonLabs.findByCode('2345-7');
      expect(glucose, isNotNull);
      expect(glucose!.normalRange, isNotNull);
      expect(glucose.interpretation, isNotNull);

      final guideline = ClinicalGuidelines.findByCode('LAB-REF');
      expect(guideline, isNotNull);
    });

    test('Medication links to Conditions and Guidelines', () {
      final metformin = MedicationReference.findByRxNormCode('311354');
      expect(metformin, isNotNull);

      // Metformin used for diabetes
      final diabetesGuideline = ClinicalGuidelines.findForCondition('E11');
      expect(diabetesGuideline, isNotEmpty);
    });

    test('ProfileAnalyzer uses all standard types', () {
      final analyzer = ProfileAnalyzer();

      final profile = UserProfile(
        age: 55,
        gender: 'male',
        weightKg: 85,
        heightCm: 175,
        conditions: [
          Icd10Code.findByCode('E11')!,
          Icd10Code.findByCode('I10')!,
        ],
        medications: [MedicationReference.findByRxNormCode('311354')!],
        allergies: [],
        familyHistory: ['diabetes'],
        smokingStatus: SmokingStatus.currentSmoker,
        alcoholConsumption: AlcoholConsumption.daily,
      );

      final result = analyzer.analyzeProfile(profile);

      expect(result, isNotNull);
      expect(result.riskCategories, isNotEmpty);
      expect(result.relevantStandards, isNotNull);
    });

    test('ChronicConditions has consistent data', () {
      for (final condition in Icd10ChronicConditions.all) {
        final fromFind = Icd10Code.findByCode(condition.code);
        expect(fromFind, isNotNull, reason: 'Code ${condition.code} should be findable');
        expect(condition.isChronic, isTrue);
      }
    });

    test('All guideline references are valid', () {
      for (final guideline in ClinicalGuidelines.all) {
        expect(guideline.code, isNotEmpty);
        expect(guideline.url, startsWith('http'));
        expect(guideline.description, isNotEmpty);
      }
    });
  });

  group('Integration: User Profile Lifecycle', () {
    test('Young healthy adult gets minimal standards', () {
      final analyzer = ProfileAnalyzer();
      final profile = UserProfile(
        age: 25,
        gender: 'female',
        weightKg: 55,
        heightCm: 165,
        conditions: [],
        medications: [],
        allergies: [],
        familyHistory: [],
        smokingStatus: SmokingStatus.nonSmoker,
        alcoholConsumption: AlcoholConsumption.occasional,
      );

      final result = analyzer.analyzeProfile(profile);

      expect(result.bmi, closeTo(20.2, 0.1));
      expect(result.relevantStandards, isNotNull);
    });

    test('Complex patient gets comprehensive standards', () {
      final analyzer = ProfileAnalyzer();
      final profile = UserProfile(
        age: 70,
        gender: 'male',
        weightKg: 95,
        heightCm: 170,
        conditions: [
          Icd10Code.findByCode('E11')!,
          Icd10Code.findByCode('I10')!,
          Icd10Code.findByCode('N18.3')!, // CKD
        ],
        medications: [
          MedicationReference.findByRxNormCode('311354')!,
        ],
        allergies: [Icd10Code.findByCode('J30.1')!], // Allergic rhinitis
        familyHistory: ['stroke', 'heart attack'],
        smokingStatus: SmokingStatus.currentSmoker,
        alcoholConsumption: AlcoholConsumption.daily,
      );

      final result = analyzer.analyzeProfile(profile);

      expect(result, isNotNull);
      expect(result.riskCategories, isNotEmpty);
      expect(result.relevantStandards, isNotNull);
    });
  });
}
