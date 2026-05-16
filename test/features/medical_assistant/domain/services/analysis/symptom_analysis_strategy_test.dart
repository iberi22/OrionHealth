import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/analysis/symptom_analysis_strategy.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SymptomAnalysisStrategy', () {
    late SymptomAnalysisStrategy strategy;

    setUp(() {
      strategy = SymptomAnalysisStrategy();
    });

    test('analyze - Fatigue symptom', () async {
      final response = await strategy.analyze(
        symptoms: ['Fatiga'],
        currentMedications: [],
      );

      expect(response.explanation, contains('PODRÍA ESTAR RELACIONADO CON'));
      expect(response.suggestedExams, contains('Hemograma completo'));
      expect(response.insights.any((i) => i.category == InsightCategory.symptomAnalysis), isTrue);
    });

    test('analyze - Unknown symptoms', () async {
      final response = await strategy.analyze(
        symptoms: ['Symptom X'],
        currentMedications: [],
      );

      expect(response.explanation, contains('No puedo determinar la causa específica'));
      expect(response.confidence, 0.35);
      expect(response.suggestedExams, contains('Consulta médica para evaluación completa'));
    });

    test('analyze - Fatigue with diabetes context', () async {
      final response = await strategy.analyze(
        symptoms: ['Cansancio'],
        currentMedications: [],
        knownCondition: 'Diabetes',
      );

      expect(response.explanation, contains('Control glucémico subóptimo'));
      expect(response.confidence, 0.40); // Base fatigue confidence in current impl
    });
  });
}
