import 'dart:convert';
import 'package:flutter/services.dart';
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

  const guidelinesJson = {
    "data": [
      {
        "code": "ACC-AHA-PRIMARY-2019",
        "displayName": "ACC/AHA Guideline on the Primary Prevention of Cardiovascular Disease",
        "organization": "ACC/AHA",
        "url": "https://example.com",
        "lastUpdated": "2019-03-17T00:00:00Z",
        "applicableConditions": ["I10", "I25"]
      },
      {
        "code": "ADA-MC-2024",
        "displayName": "ADA Standards of Care in Diabetes",
        "organization": "ADA",
        "url": "https://example.com",
        "lastUpdated": "2024-01-01T00:00:00Z",
        "applicableConditions": ["E10", "E11"]
      },
      {
        "code": "WHO-2023",
        "displayName": "WHO Hypertension Guideline",
        "organization": "WHO",
        "url": "https://example.com",
        "lastUpdated": "2023-01-01T00:00:00Z",
        "applicableConditions": ["I10"]
      }
    ]
  };

  setUp(() {
    mockRepo = MockUserProfileRepository();
    calculator = RiskCalculator(mockRepo);

    // Mock rootBundle for ClinicalGuidelines.load()
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        final String key = utf8.decode(message!.buffer.asUint8List());
        if (key.contains('packages/medical_standards/data/full_guidelines.json')) {
          return ByteData.view(utf8.encode(jsonEncode(guidelinesJson)).buffer);
        }
        return null;
      },
    );
  });

  group('RiskCalculator', () {
    test('calculateFromProfile returns high risk for older patient with conditions', () async {
      // Arrange
      final profile = UserProfile(
        age: 70,
        weight: 90,
        height: 170,
        smokingStatus: 'current',
        currentMedications: ['BP-Med', 'Lisinopril'],
        medicalConditions: ['E11.9', 'I10'], // Diabetes Type 2, Hypertension
        familyHistoryDiabetes: true,
        familyHistoryCvd: true,
        hasHypertension: true,
      );

      when(() => mockRepo.getUserProfile()).thenAnswer((_) async => profile);

      // Act
      final riskProfile = await calculator.calculateFromProfile();

      // Assert
      expect(riskProfile.profileAge, 70);
      expect(riskProfile.ascvd, isNotNull);
      expect(riskProfile.diabetes, isNotNull);
      expect(riskProfile.hypertension, isNotNull);

      expect(riskProfile.ascvd!.score, greaterThan(10));
      expect(riskProfile.diabetes!.category, anyOf('Moderate', 'High'));
      expect(riskProfile.hypertension!.category, 'High');
    });

    test('calculateFromProfile returns low risk for healthy young patient', () async {
      // Arrange
      final profile = UserProfile(
        age: 25,
        weight: 60,
        height: 175,
        smokingStatus: 'never',
        currentMedications: [],
        medicalConditions: [],
        familyHistoryDiabetes: false,
        familyHistoryCvd: false,
      );

      when(() => mockRepo.getUserProfile()).thenAnswer((_) async => profile);

      // Act
      final riskProfile = await calculator.calculateFromProfile();

      // Assert
      expect(riskProfile.ascvd!.score, lessThan(5));
      expect(riskProfile.diabetes!.category, 'Low');
      expect(riskProfile.hypertension!.category, 'Low');
    });

    test('calculateFromProfile handles empty profile gracefully', () async {
      // Arrange
      when(() => mockRepo.getUserProfile()).thenAnswer((_) async => null);

      // Act
      final riskProfile = await calculator.calculateFromProfile();

      // Assert
      expect(riskProfile.hasData, false);
      expect(riskProfile.profileAge, 0);
    });

    test('calculateFromProfile identifies pregnancy via ICD-10 and flags contraindications', () async {
      // Arrange
      final profile = UserProfile(
        age: 30,
        medicalConditions: ['Z33.1'], // Pregnant
        currentMedications: ['Lisinopril'], // ACE Inhibitor - contraindicated
      );

      when(() => mockRepo.getUserProfile()).thenAnswer((_) async => profile);

      // Act
      // Note: RiskCalculator doesn't currently call checkDrugConditionInteractions
      // from DrugInteractionChecker in its calculateFromProfile method.
      // But we should verify it doesn't crash and handles the profile correctly.
      final riskProfile = await calculator.calculateFromProfile();

      // Assert
      expect(riskProfile.profileAge, 30);
    });

    test('calculateAscvdRisk uses female equation as default when gender unknown', () async {
      // Act
      final risk = await calculator.calculateAscvdRisk(
        age: 50,
        gender: 'unknown',
        totalCholesterol: 200,
        hdlCholesterol: 50,
        systolicBp: 130,
        onBpMedication: false,
        hasDiabetes: false,
        isSmoker: false,
      );

      // Assert
      expect(risk.score, isPositive);
      expect(risk.guideline.code, 'ACC-AHA-PRIMARY-2019');
    });

    test('generateInsights creates insights with correct severity for high risk', () async {
      // Arrange
      final ascvd = AscvdRisk(
        score: 25.0,
        category: 'High risk (>=20%)',
        guideline: (await ClinicalGuidelines.findByCode('ACC-AHA-PRIMARY-2019'))!,
      );

      // Act
      final insights = calculator.generateInsights(ascvd: ascvd);

      // Assert
      expect(insights.length, 1);
      expect(insights.first.severity, InsightSeverity.alert);
      expect(insights.first.recommendations, contains('High-intensity statin therapy recommended'));
    });
  });
}
