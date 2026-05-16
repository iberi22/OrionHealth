import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/analysis/lab_analysis_strategy.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LabAnalysisStrategy', () {
    late LabAnalysisStrategy strategy;

    setUp(() {
      strategy = LabAnalysisStrategy();
    });

    test('analyze - Normal Glucose (2345-7)', () async {
      final response = await strategy.analyze(
        labCode: '2345-7',
        value: 85.0,
        unit: 'mg/dL',
      );

      expect(response.explanation, contains('VALOR DE LABORATORIO'));
      expect(response.confidence, 0.3);
    });

    test('analyze - Unknown Lab Code', () async {
      final response = await strategy.analyze(
        labCode: 'UNKNOWN-001',
        value: 100.0,
      );

      expect(response.explanation, contains('No tengo información específica'));
      expect(response.confidence, 0.20);
      expect(response.suggestedExams, contains('Consulta médica para interpretación'));
    });

    test('analyzeBatch - processes multiple labs', () async {
      final labValues = {
        '2345-7': 85.0,
        '17861-6': 5.7,
      };

      final insights = await strategy.analyzeBatch(
        labValues: labValues,
        chronicConditions: [],
      );

      expect(insights.length, 2);
      expect(insights[0].category, InsightCategory.labInterpretation);
      expect(insights[1].category, InsightCategory.labInterpretation);
    });
  });
}
