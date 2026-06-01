import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('ProfileAnalyzer', () {
    late ProfileAnalyzer analyzer;

    setUp(() {
      analyzer = ProfileAnalyzer();
    });

    test('analyzeProfile with valid young adult', () {
      final profile = UserProfile(
        age: 25,
        gender: 'male',
        weightKg: 70,
        heightCm: 175,
        conditions: [],
        medications: [],
        allergies: [],
        familyHistory: [],
        smokingStatus: SmokingStatus.nonSmoker,
        alcoholConsumption: AlcoholConsumption.occasional,
      );

      final result = analyzer.analyzeProfile(profile);

      expect(result, isNotNull);
      expect(result.age, equals(25));
      expect(result.riskCategories, isNotNull);
      expect(result.relevantStandards, isNotNull);
    });

    test('analyzeProfile with elderly patient', () {
      final profile = UserProfile(
        age: 65,
        gender: 'female',
        weightKg: 65,
        heightCm: 160,
        conditions: [Icd10Code.findByCode('E11')!, Icd10Code.findByCode('I10')!],
        medications: [],
        allergies: [],
        familyHistory: ['heart disease'],
        smokingStatus: SmokingStatus.formerSmoker,
        alcoholConsumption: AlcoholConsumption.none,
      );

      final result = analyzer.analyzeProfile(profile);

      expect(result, isNotNull);
      expect(result.age, equals(65));
      expect(result.riskCategories, contains('cardiovascular'));
    });

    test('analyzeProfile with diabetic patient', () {
      final profile = UserProfile(
        age: 45,
        gender: 'male',
        weightKg: 90,
        heightCm: 170,
        conditions: [Icd10Code.findByCode('E11')!],
        medications: [MedicationReference.findByRxNormCode('311354')!],
        allergies: [],
        familyHistory: [],
        smokingStatus: SmokingStatus.nonSmoker,
        alcoholConsumption: AlcoholConsumption.none,
      );

      final result = analyzer.analyzeProfile(profile);

      expect(result, isNotNull);
      expect(result.riskCategories, contains('diabetes'));
      expect(result.relevantStandards, isNotNull);
    });

    test('analyzeProfile with pregnant woman', () {
      final profile = UserProfile(
        age: 28,
        gender: 'female',
        weightKg: 60,
        heightCm: 165,
        conditions: [],
        medications: [],
        allergies: [],
        familyHistory: [],
        smokingStatus: SmokingStatus.nonSmoker,
        alcoholConsumption: AlcoholConsumption.none,
        isPregnant: true,
      );

      final result = analyzer.analyzeProfile(profile);

      expect(result, isNotNull);
      expect(result.riskCategories, contains('pregnancy'));
    });

    test('analyzeProfile with pediatric patient', () {
      final profile = UserProfile(
        age: 5,
        gender: 'male',
        weightKg: 18,
        heightCm: 105,
        conditions: [],
        medications: [],
        allergies: [],
        familyHistory: [],
        smokingStatus: SmokingStatus.nonSmoker,
        alcoholConsumption: AlcoholConsumption.none,
      );

      final result = analyzer.analyzeProfile(profile);

      expect(result, isNotNull);
      expect(result.age, equals(5));
    });

    test('analyzeProfile calculates BMI correctly', () {
      final profile = UserProfile(
        age: 30,
        gender: 'female',
        weightKg: 65,
        heightCm: 170,
        conditions: [],
        medications: [],
        allergies: [],
        familyHistory: [],
        smokingStatus: SmokingStatus.nonSmoker,
        alcoholConsumption: AlcoholConsumption.none,
      );

      final result = analyzer.analyzeProfile(profile);

      // BMI = 65 / (1.70)^2 = 65 / 2.89 = 22.5
      expect(result.bmi, closeTo(22.5, 0.1));
    });

    test('analyzeProfile identifies overweight patients', () {
      final profile = UserProfile(
        age: 40,
        gender: 'male',
        weightKg: 100,
        heightCm: 170,
        conditions: [],
        medications: [],
        allergies: [],
        familyHistory: [],
        smokingStatus: SmokingStatus.nonSmoker,
        alcoholConsumption: AlcoholConsumption.none,
      );

      final result = analyzer.analyzeProfile(profile);

      // BMI = 100 / (1.70)^2 = 100 / 2.89 = 34.6
      expect(result.bmi, greaterThan(30));
    });

    test('analyzeProfile handles smoker risk', () {
      final profile = UserProfile(
        age: 50,
        gender: 'male',
        weightKg: 80,
        heightCm: 175,
        conditions: [],
        medications: [],
        allergies: [],
        familyHistory: [],
        smokingStatus: SmokingStatus.currentSmoker,
        alcoholConsumption: AlcoholConsumption.occasional,
      );

      final result = analyzer.analyzeProfile(profile);

      expect(result.riskCategories, isNotEmpty);
    });
  });
}
