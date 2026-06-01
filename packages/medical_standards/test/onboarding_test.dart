import 'package:test/test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('ProfileAnalyzer', () {
    test('analyzeProfile with valid young adult', () async {
      final analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 25,
        sex: 'male',
      );

      expect(result, isNotNull);
      expect(result.categories, contains(MedicalContextCategory.preventive));
    });

    test('analyzeProfile with elderly patient', () async {
      final analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 65,
        sex: 'female',
        currentConditions: ['diabetes', 'hypertension'],
        familyHistory: ['heart disease'],
      );

      expect(result, isNotNull);
      expect(result.tier1, contains(MedicalContextCategory.diabetes));
      expect(result.tier1, contains(MedicalContextCategory.cardiovascular));
      expect(result.categories, contains(MedicalContextCategory.geriatrics));
    });

    test('analyzeProfile with diabetic patient', () async {
      final analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 45,
        sex: 'male',
        currentConditions: ['diabetes'],
        currentMedications: ['metformin'],
      );

      expect(result, isNotNull);
      expect(result.tier1, contains(MedicalContextCategory.diabetes));
      expect(result.categories, contains(MedicalContextCategory.cardiovascular));
    });

    test('analyzeProfile handles women health categories', () async {
      final analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 28,
        sex: 'female',
      );

      expect(result, isNotNull);
      expect(result.categories, contains(MedicalContextCategory.womensHealth));
    });

    test('analyzeProfile with pediatric patient', () async {
      final analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 5,
        sex: 'male',
      );

      expect(result, isNotNull);
      expect(result.categories, isNotEmpty);
    });

    test('analyzeProfile handles smoker risk', () async {
      final analyzer = ProfileAnalyzer();
      final result = await analyzer.analyzeProfile(
        age: 50,
        sex: 'male',
        symptoms: ['cough'],
      );

      expect(result, isNotNull);
      expect(result.categories, isNotEmpty);
    });
  });
}
