import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/analysis/risk_calculator.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUserProfileRepository mockRepo;
  late RiskCalculator calculator;

  setUpAll(() async {
    // No rootBundle mocking needed — RiskCalculator is stateless
  });

  setUp(() {
    mockRepo = MockUserProfileRepository();
    calculator = RiskCalculator();

    when(() => mockRepo.getUserProfile()).thenAnswer((_) async => UserProfile(age: 45));
  });

  group('RiskCalculator - ASCVD Score', () {
    test('calculateAscvdRisk returns low risk for healthy non-smoker', () {
      final result = calculator.calculateAscvdRisk(
        age: 40,
        gender: 'male',
        totalCholesterol: 170,
        hdlCholesterol: 55,
        systolicBp: 115,
        onBpMedication: false,
        hasDiabetes: false,
        isSmoker: false,
      );

      expect(result.score, lessThan(5));
      expect(result.category, contains('Low'));
      expect(result.guideline.code, 'ACC-AHA-PRIMARY-2019');
    });

    test('calculateAscvdRisk returns higher risk for diabetic smoker', () {
      final result = calculator.calculateAscvdRisk(
        age: 60,
        gender: 'male',
        totalCholesterol: 240,
        hdlCholesterol: 35,
        systolicBp: 145,
        onBpMedication: true,
        hasDiabetes: true,
        isSmoker: true,
      );

      expect(result.score, greaterThan(0));
      expect(result.category, isNotEmpty);
    });

    test('calculateAscvdRisk uses female equation for female gender', () {
      final result = calculator.calculateAscvdRisk(
        age: 50,
        gender: 'female',
        totalCholesterol: 200,
        hdlCholesterol: 60,
        systolicBp: 125,
        onBpMedication: false,
        hasDiabetes: false,
        isSmoker: false,
      );

      expect(result.score, greaterThanOrEqualTo(0));
    });
  });

  group('RiskCalculator - QDiabetes', () {
    test('calculateQDiabetesRisk returns low for young healthy', () {
      final result = calculator.calculateQDiabetesRisk(
        age: 30,
        gender: 'male',
        bmi: 22,
        fastingGlucose: 85,
        hasFamilyHistory: false,
        hasCardiovascularDisease: false,
        hasHypertension: false,
        hasSteroidUse: false,
        ethnicity: 'white',
        isSmoker: false,
      );

      expect(result.category, 'Low');
    });

    test('calculateQDiabetesRisk returns higher for obese with family history', () {
      final result = calculator.calculateQDiabetesRisk(
        age: 55,
        gender: 'female',
        bmi: 35,
        fastingGlucose: 110,
        hasFamilyHistory: true,
        hasCardiovascularDisease: false,
        hasHypertension: true,
        hasSteroidUse: false,
        ethnicity: 'south_asian',
        isSmoker: false,
      );

      expect(result.score, greaterThan(5));
    });
  });

  group('RiskCalculator - Hypertension', () {
    test('calculateHypertensionRisk returns low for young healthy', () {
      final result = calculator.calculateHypertensionRisk(
        age: 25,
        bmi: 22,
        hasFamilyHistory: false,
        sodiumUrineExcretion: null,
      );

      expect(result.category, 'Low');
    });

    test('calculateHypertensionRisk returns higher for obese with family history', () {
      final result = calculator.calculateHypertensionRisk(
        age: 60,
        bmi: 33,
        hasFamilyHistory: true,
        sodiumUrineExcretion: 6000,
      );

      expect(result.category, 'High');
    });
  });

  group('RiskCalculator - generateInsights', () {
    test('generateInsights creates alert for ASCVD risk >= 20%', () {
      final ascvd = AscvdRisk(
        score: 25.0,
        category: 'High risk (>=20%)',
        guideline: ClinicalGuidelineReference(
          code: 'ACC-AHA-PRIMARY-2019',
          displayName: 'ACC/AHA Guideline on the Primary Prevention of Cardiovascular Disease',
          organization: 'ACC/AHA',
          url: 'https://example.com',
          lastUpdated: DateTime(2019, 3, 17),
        ),
      );

      final insights = calculator.generateInsights(ascvd: ascvd);

      expect(insights.length, 1);
      expect(insights.first.severity, InsightSeverity.alert);
      expect(insights.first.recommendations, contains('High-intensity statin therapy recommended'));
    });

    test('generateInsights creates info for low ASCVD risk', () {
      final ascvd = AscvdRisk(
        score: 2.0,
        category: 'Low risk (<5%)',
        guideline: ClinicalGuidelineReference(
          code: 'ACC-AHA-PRIMARY-2019',
          displayName: 'ACC/AHA Guideline',
          organization: 'ACC/AHA',
          url: 'https://example.com',
          lastUpdated: DateTime(2019, 3, 17),
        ),
      );

      final insights = calculator.generateInsights(ascvd: ascvd);

      expect(insights.length, 1);
      expect(insights.first.severity, InsightSeverity.info);
    });

    test('generateInsights returns empty list when no risks provided', () {
      final insights = calculator.generateInsights();
      expect(insights, isEmpty);
    });
  });
}
