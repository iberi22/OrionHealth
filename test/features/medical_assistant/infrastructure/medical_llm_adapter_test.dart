import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_query.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/analysis_response.dart';

void main() {
  late MedicalLlmAdapter adapter;

  setUp(() {
    adapter = MedicalLlmAdapter();
  });

  group('MedicalLlmAdapter', () {
    final testQuery = MedicalQuery(
      id: 'q1',
      question: '¿Qué significa mi glucosa de 150?',
      timestamp: DateTime.now(),
    );

    test('generateResponse handles empty insights with low confidence', () async {
      final response = await adapter.generateResponse(
        query: testQuery,
        insights: [],
        userContext: {},
      );

      expect(response.confidence, equals(0.30));
      expect(response.answer, contains('no cuento con suficientes datos'));
    });

    test('generateResponse calculates higher confidence for critical insights', () async {
      final criticalInsight = MedicalInsight(
        id: 'i1',
        title: 'Glucosa Crítica',
        description: 'Tu nivel de glucosa es peligrosamente alto.',
        severity: InsightSeverity.critical,
        category: InsightCategory.labInterpretation,
        generatedAt: DateTime.now(),
        evidence: {'value': 150.0, 'loinc': '2345-7'},
      );

      final response = await adapter.generateResponse(
        query: testQuery,
        insights: [criticalInsight],
        userContext: {},
      );

      expect(response.confidence, equals(0.95));
      expect(response.metadata?['canDiagnose'], isTrue);
    });

    test('generateResponse refines response when lab insights are present', () async {
      final labInsight = MedicalInsight(
        id: 'i2',
        title: 'Glucosa Elevada',
        description: 'Nivel de 150 mg/dL está por encima del rango normal.',
        severity: InsightSeverity.alert,
        category: InsightCategory.labInterpretation,
        generatedAt: DateTime.now(),
        recommendations: ['Repetir examen en ayunas', 'Consultar endocrino'],
        evidence: {'value': 150.0, 'loinc': '2345-7'},
      );

      final response = await adapter.generateResponse(
        query: testQuery,
        insights: [labInsight],
        userContext: {},
      );

      // Refined lab response uses MedicalResponseGenerator format
      expect(response.answer, contains('Respuesta a tu consulta:'));
      expect(response.answer, contains('¿Qué significa mi glucosa de 150?'));
      expect(response.answer, contains('Nivel de confianza: 95%'));
      expect(response.confidence, equals(0.80 + 0.15)); // alert(0.8) + lab bonus(0.15) = 0.95
    });

    test('generateResponse includes vital sign analysis bonus', () async {
      final vitalInsight = MedicalInsight(
        id: 'i3',
        title: 'Presión Alta',
        description: '140/90 es hipertensión etapa 1.',
        severity: InsightSeverity.warning,
        category: InsightCategory.vitalSignAnalysis,
        generatedAt: DateTime.now(),
      );

      final response = await adapter.generateResponse(
        query: testQuery,
        insights: [vitalInsight],
        userContext: {},
      );

      // base 0.5 + vital bonus(0.1) = 0.6
      expect(response.confidence, equals(0.60));
    });

    test('isAvailable returns true', () async {
      final available = await adapter.isAvailable();
      expect(available, isTrue);
    });
  });
}
