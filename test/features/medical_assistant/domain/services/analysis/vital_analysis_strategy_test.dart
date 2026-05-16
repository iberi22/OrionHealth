import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/analysis/vital_analysis_strategy.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VitalAnalysisStrategy', () {
    late VitalAnalysisStrategy strategy;

    setUp(() {
      strategy = VitalAnalysisStrategy();
    });

    test('analyze - Normal Blood Pressure', () async {
      final response = await strategy.analyze(
        vitalType: 'systolic',
        value: 110.0,
        relatedVitals: {'systolic': 110.0, 'diastolic': 70.0},
      );

      expect(response.explanation, contains('rangos normales'));
      expect(response.confidence, 0.85);
    });

    test('analyze - Hypertensive Crisis', () async {
      final response = await strategy.analyze(
        vitalType: 'systolic',
        value: 190.0,
        relatedVitals: {'systolic': 190.0, 'diastolic': 125.0},
      );

      expect(response.explanation, contains('HIPERTENSIÓN CRISIS'));
      expect(response.confidence, 0.95);
      expect(response.doctorRecommendation, contains('EMERGENCIA'));
      expect(response.insights.any((i) => i.severity == InsightSeverity.critical), isTrue);
    });

    test('analyze - Elevated Blood Pressure', () async {
      final response = await strategy.analyze(
        vitalType: 'systolic',
        value: 135.0,
        relatedVitals: {'systolic': 135.0, 'diastolic': 85.0},
      );

      expect(response.confidence, 0.60);
      expect(response.insights.any((i) => i.severity == InsightSeverity.warning), isTrue);
    });

    test('analyzeBatch - processes BP', () async {
      final vitals = {
        'systolic': 120.0,
        'diastolic': 80.0,
      };

      final insights = await strategy.analyzeBatch(
        vitals: vitals,
        chronicConditions: [],
      );

      expect(insights.length, 1);
      expect(insights[0].category, InsightCategory.vitalSignAnalysis);
    });

    test('calculateRisks - returns ASCVD placeholder insight', () async {
      final insights = await strategy.calculateRisks(
        labValues: {},
        vitals: {},
        conditions: [],
      );

      expect(insights.length, 1);
      expect(insights[0].category, InsightCategory.riskAssessment);
      expect(insights[0].title, contains('Cardiovascular'));
    });
  });
}
