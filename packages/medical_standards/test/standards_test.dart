import 'package:test/test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('Integration: Medical Standards Cross-Reference', () {
    test('ICD-10 links to SNOMED and Guidelines', () {
      final icd10 = Icd10ChronicConditions.findByCode('E11');
      expect(icd10, isNotNull);

      final guidelines = ClinicalGuidelines.findForCondition('E11');
      expect(guidelines, isNotEmpty);

      // Should have related SNOMED concept
      final snomed = SnomedCommonConcepts.all.firstWhere(
        (s) => s.displayName.toLowerCase().contains('diabetes'),
        orElse: () => SnomedCommonConcepts.all.first,
      );
      expect(snomed, isNotNull);
    });

    test('LOINC links to Lab Reference Ranges', () {
      final glucose = LoincCommonLabs.findByCode('2345-7');
      expect(glucose, isNotNull);
      expect(glucose!.description, isNotNull);

      final guideline = ClinicalGuidelines.findByCode('CLSI-2017');
      expect(guideline, isNotNull);
    });

    test('Medication links to Conditions and Guidelines', () {
      final metformin = MedicationCatalog.findByCode('6809');
      expect(metformin, isNotNull);

      // Metformin used for diabetes
      final diabetesGuideline = ClinicalGuidelines.findForCondition('E11');
      expect(diabetesGuideline, isNotEmpty);
    });

    test('ProfileAnalyzer uses all standard types', () async {
      const analyzer = ProfileAnalyzer();

      final result = await analyzer.analyzeProfile(
        age: 55,
        sex: 'male',
        currentConditions: ['Type 2 diabetes', 'Hypertension'],
        currentMedications: ['metformin'],
        familyHistory: ['diabetes'],
      );

      expect(result, isNotNull);
      expect(result.categories, isNotEmpty);
      expect(result.categories, contains(MedicalContextCategory.diabetes));
    });

    test('ChronicConditions has consistent data', () {
      for (final condition in Icd10ChronicConditions.all) {
        final fromFind = Icd10ChronicConditions.findByCode(condition.code);
        expect(fromFind, isNotNull, reason: 'Code ${condition.code} should be findable');
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
    test('Young healthy adult gets minimal standards', () async {
      const analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 25,
        sex: 'female',
        currentConditions: [],
        currentMedications: [],
        familyHistory: [],
      );

      expect(result.categories, contains(MedicalContextCategory.preventive));
    });

    test('Complex patient gets comprehensive standards', () async {
      const analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 70,
        sex: 'male',
        currentConditions: ['Type 2 diabetes', 'Hypertension', 'CKD'],
        currentMedications: ['metformin'],
        familyHistory: ['stroke', 'heart attack'],
      );

      expect(result, isNotNull);
      expect(result.categories, isNotEmpty);
      expect(result.categories, contains(MedicalContextCategory.diabetes));
      expect(result.categories, contains(MedicalContextCategory.cardiovascular));
    });
  });
}
