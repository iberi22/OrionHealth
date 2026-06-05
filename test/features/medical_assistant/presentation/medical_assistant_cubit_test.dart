import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medical_standards/medical_standards.dart';

import 'package:orionhealth_health/features/medical_assistant/application/medical_assistant_cubit.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/medical_analysis_service.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/health_context_service.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/ai_response.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/analysis_response.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_query.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/analysis/lab_interpreter.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/analysis/vital_sign_analyzer.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/analysis/risk_calculator.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMedicalLlmAdapter extends Mock implements MedicalLlmAdapter {}
class MockMedicalAnalysisService extends Mock implements MedicalAnalysisService {}
class MockHealthContextService extends Mock implements HealthContextService {}
class MockLabInterpreter extends Mock implements LabInterpreter {}
class MockVitalSignAnalyzer extends Mock implements VitalSignAnalyzer {}
class MockRiskCalculator extends Mock implements RiskCalculator {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void main() {
  late MockMedicalLlmAdapter mockAdapter;
  late MockMedicalAnalysisService mockAnalysis;
  late MedicalAssistantCubit cubit;

  setUpAll(() {
    registerFallbackValue(MedicalQuery(
      id: 'fallback',
      question: '',
      timestamp: DateTime(2025),
    ));
    registerFallbackValue(<MedicalInsight>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockAdapter = MockMedicalLlmAdapter();
    mockAnalysis = MockMedicalAnalysisService();

    // Default stubs
    when(() => mockAnalysis.analyzeLabWithConfidence(
          labCode: any(named: 'labCode'),
          value: any(named: 'value'),
          unit: any(named: 'unit'),
          patientCondition: any(named: 'patientCondition'),
        )).thenReturn(SafeAnalysisResponse(
          explanation: '',
          disclaimer: '',
          suggestedExams: [],
          lifestyleRecommendations: [],
          doctorRecommendation: '',
          confidence: 0.5,
          confidenceLevel: 'medium',
          insights: [],
        ));

    when(() => mockAnalysis.analyzeVitalWithConfidence(
          vitalType: any(named: 'vitalType'),
          value: any(named: 'value'),
          relatedVitals: any(named: 'relatedVitals'),
        )).thenReturn(SafeAnalysisResponse(
          explanation: '',
          disclaimer: '',
          suggestedExams: [],
          lifestyleRecommendations: [],
          doctorRecommendation: '',
          confidence: 0.5,
          confidenceLevel: 'medium',
          insights: [],
        ));

    when(() => mockAnalysis.calculateRisks(
          labValues: any(named: 'labValues'),
          vitals: any(named: 'vitals'),
          conditions: any(named: 'conditions'),
        )).thenAnswer((_) async => []);

    when(() => mockAdapter.generateResponse(
          query: any(named: 'query'),
          insights: any(named: 'insights'),
          userContext: any(named: 'userContext'),
        )).thenAnswer((invocation) async {
      return AiMedicalResponse(
        id: 'test-resp',
        queryId: 'test-query',
        answer: 'Respuesta de prueba.',
        confidence: 0.85,
        insights: [],
        generatedAt: DateTime.now(),
      );
    });

    cubit = MedicalAssistantCubit(
      llmAdapter: mockAdapter,
      analysisService: mockAnalysis,
      healthContextService: MockHealthContextService(),
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('MedicalAssistantCubit', () {
    test('initial state is MedicalAssistantIdle', () {
      expect(cubit.state, isA<MedicalAssistantIdle>());
    });

    test('submitQuery emits full loading sequence and response', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const MedicalAssistantLoading(message: 'Analizando tu pregunta...'),
          const MedicalAssistantLoading(message: 'Analizando laboratorios...'),
          const MedicalAssistantLoading(message: 'Analizando signos vitales...'),
          const MedicalAssistantLoading(message: 'Calculando riesgos...'),
          const MedicalAssistantLoading(message: 'Generando respuesta...'),
          isA<MedicalAssistantResponse>(),
        ]),
      );

      await cubit.submitQuery('tengo dolor de cabeza');
      await expectation;

      final state = cubit.state as MedicalAssistantResponse;
      expect(state.response.answer, equals('Respuesta de prueba.'));
    });

    test('error during LLM generation emits MedicalAssistantError', () async {
      when(() => mockAdapter.generateResponse(
            query: any(named: 'query'),
            insights: any(named: 'insights'),
            userContext: any(named: 'userContext'),
          )).thenThrow(Exception('LLM failure'));

      await cubit.submitQuery('síntoma');

      expect(cubit.state, isA<MedicalAssistantError>());
      expect((cubit.state as MedicalAssistantError).message, contains('LLM failure'));
    });

    test('reset() returns cubit to idle state after response', () async {
      await cubit.submitQuery('hola');
      expect(cubit.state, isA<MedicalAssistantResponse>());

      cubit.reset();
      expect(cubit.state, isA<MedicalAssistantIdle>());
    });

    test('low confidence response with no insights adds data request', () async {
      when(() => mockAdapter.generateResponse(
            query: any(named: 'query'),
            insights: any(named: 'insights'),
            userContext: any(named: 'userContext'),
          )).thenAnswer((_) async => AiMedicalResponse(
            id: 'low-conf',
            queryId: 'q',
            answer: 'Partial answer',
            confidence: 0.3,
            insights: [],
            generatedAt: DateTime.now(),
          ));

      await cubit.submitQuery('me duele algo');

      expect(cubit.state, isA<MedicalAssistantResponse>());
      final state = cubit.state as MedicalAssistantResponse;
      expect(state.response.answer, contains('INFORMACIÓN QUE ME AYUDARÍA'));
      expect(state.response.confidence, equals(0.25));
    });
  });
}
