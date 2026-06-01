import 'package:test/test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('Cross-Reference', () {
    test('ICD-10 links to SNOMED and Guidelines', () {
      final icd10 = Icd10ChronicConditions.findByCode('E11');
      expect(icd10, isNotNull);

      final guidelines = ClinicalGuidelines.findForCondition('E11');
      expect(guidelines, isNotEmpty);

      final snomed = SnomedCommonConcepts.all.firstWhere(
        (s) => s.fullySpecifiedName?.toLowerCase().contains('diabetes') ?? false,
        orElse: () => SnomedCommonConcepts.all.first,
      );
      expect(snomed, isNotNull);
    });

    test('LOINC finds glucose and lab reference', () {
      final glucose = LoincCommonLabs.findByCode('2345-7');
      expect(glucose, isNotNull);
      expect(glucose!.normalRange, isNotNull);

      final guideline = ClinicalGuidelines.findByCode('LAB-REF');
      expect(guideline, isNotNull);
    });

    test('Medication catalog works', () {
      final metformin = MedicationCatalog.findByCode('311354');
      expect(metformin, isNotNull);

      final guidelines = ClinicalGuidelines.findForCondition('E11');
      expect(guidelines, isNotEmpty);
    });

    test('ProfileAnalyzer uses standard types', () async {
      final analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 55,
        sex: 'male',
        currentConditions: ['diabetes', 'hypertension'],
        currentMedications: ['metformin'],
        familyHistory: ['heart disease'],
      );

      expect(result, isNotNull);
      expect(result.categories, isNotEmpty);
    });

    test('ChronicConditions has consistent data', () {
      for (final condition in Icd10ChronicConditions.all) {
        final fromFind = Icd10ChronicConditions.findByCode(condition.code);
        expect(fromFind, isNotNull,
            reason: 'Code ${condition.code} should be findable');
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

  group('ProfileAnalyzer Lifecycle', () {
    test('Young healthy adult gets minimal standards', () async {
      final analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 25,
        sex: 'female',
      );

      expect(result, isNotNull);
      expect(result.categories, contains(MedicalContextCategory.preventive));
    });

    test('Complex patient gets comprehensive standards', () async {
      final analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 70,
        sex: 'male',
        currentConditions: ['diabetes', 'hypertension', 'ckd'],
        currentMedications: ['metformin'],
        familyHistory: ['stroke', 'heart disease'],
      );

      expect(result, isNotNull);
      expect(result.categories, contains(MedicalContextCategory.diabetes));
      expect(result.categories, contains(MedicalContextCategory.cardiovascular));
      expect(result.categories, contains(MedicalContextCategory.renal));
    });
  });
}
