import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orionhealth_health/features/medical_assistant/application/medical_assistant_cubit.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/medical_analysis_service.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/clinical_reasoner_service.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/health_context_service.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/ai_response.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/analysis_response.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_query.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/analysis/lab_interpreter.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/analysis/vital_sign_analyzer.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/analysis/risk_calculator.dart';
import 'package:orionhealth_health/core/services/privacy_anonymizer.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/medical_code.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockMedicalLlmAdapter extends Mock implements MedicalLlmAdapter {}
class MockMedicalAnalysisService extends Mock implements MedicalAnalysisService {}
class MockClinicalReasonerService extends Mock implements ClinicalReasonerService {}
class MockHealthContextService extends Mock implements HealthContextService {}
class MockPromptScrubber extends Mock implements PromptScrubber {}
class MockLabInterpreter extends Mock implements LabInterpreter {}
class MockVitalSignAnalyzer extends Mock implements VitalSignAnalyzer {}
class MockRiskCalculator extends Mock implements RiskCalculator {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MedicalAssistantCubit _buildCubit({
  MockMedicalLlmAdapter? adapter,
  MockMedicalAnalysisService? analysisService,
  MockClinicalReasonerService? reasoner,
  MockHealthContextService? healthContext,
  MockPromptScrubber? scrubber,
}) {
  final mockAdapter = adapter ?? MockMedicalLlmAdapter();
  final mockAnalysis = analysisService ?? MockMedicalAnalysisService();
  final mockReasoner = reasoner ?? MockClinicalReasonerService();
  final mockContext = healthContext ?? MockHealthContextService();
  final mockScrubber = scrubber ?? MockPromptScrubber();

  // Default stubs
  when(() => mockContext.getContextForUser(any()))
      .thenAnswer((_) async => HealthContext.empty());
  when(() => mockScrubber.scrub(any(), apiName: any(named: 'apiName')))
      .thenAnswer((invocation) async => invocation.positionalArguments[0] as String);
  when(() => mockReasoner.analyzeSymptoms(any()))
      .thenAnswer((_) async => []);
  when(() => mockReasoner.synthesizeHolisticSummary(any()))
      .thenReturn('');
  when(() => mockAnalysis.analyzeLabWithConfidence(
        labCode: any(named: 'labCode'),
        value: any(named: 'value'),
        unit: any(named: 'unit'),
        patientCondition: any(named: 'patientCondition'),
      )).thenAnswer((_) async => SafeAnalysisResponse(
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
      )).thenAnswer((_) async => SafeAnalysisResponse(
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
        history: any(named: 'history'),
      )).thenAnswer((invocation) async {
        final insights = invocation.namedArguments[const Symbol('insights')] as List<MedicalInsight>;
        return AiMedicalResponse(
          id: 'test-resp',
          queryId: 'test-query',
          answer: 'Respuesta de prueba.',
          confidence: 0.85,
          insights: insights, // pass through actual insights
          generatedAt: DateTime.now(),
        );
      });

  return MedicalAssistantCubit(
    llmAdapter: mockAdapter,
    analysisService: mockAnalysis,
    reasoner: mockReasoner,
    healthContext: mockContext,
    scrubber: mockScrubber,
    labInterpreter: MockLabInterpreter(),
    vitalAnalyzer: MockVitalSignAnalyzer(),
    riskCalculator: MockRiskCalculator(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    // Register fallback values required by mocktail for `any()` matchers
    registerFallbackValue(MedicalQuery(
      id: 'fallback',
      question: '',
      timestamp: DateTime(2025),
    ));
    registerFallbackValue(<MedicalInsight>[]);
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<Map<String, String>>[]);
  });

  group('MedicalAssistantCubit', () {
    test('initial state is MedicalAssistantIdle', () {
      final cubit = _buildCubit();
      expect(cubit.state, isA<MedicalAssistantIdle>());
    });

    test('greeting query emits Response without calling reasoner', () async {
      final mockReasoner = MockClinicalReasonerService();
      when(() => mockReasoner.analyzeSymptoms(any()))
          .thenAnswer((_) async => []);
      when(() => mockReasoner.synthesizeHolisticSummary(any())).thenReturn('');

      final cubit = _buildCubit(reasoner: mockReasoner);

      await cubit.submitQuery('hola');

      verifyNever(() => mockReasoner.analyzeSymptoms(any()));
      expect(cubit.state, isA<MedicalAssistantResponse>());
    });

    test('non-greeting query emits loading and response sequence', () async {
      // Build cubit DIRECTLY with proper stubs
      final mockAdapter = MockMedicalLlmAdapter();
      final mockContext = MockHealthContextService();
      final mockScrubber = MockPromptScrubber();
      final mockReasoner = MockClinicalReasonerService();
      final mockAnalysis = MockMedicalAnalysisService();

      // Provide some data to bypass initial check
      when(() => mockContext.getContextForUser(any()))
          .thenAnswer((_) async => const HealthContext(vitals: {'systolic': 120}));
      when(() => mockScrubber.scrub(any(), apiName: any(named: 'apiName')))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as String);
      when(() => mockReasoner.analyzeSymptoms(any())).thenAnswer((_) async => []);
      when(() => mockReasoner.synthesizeHolisticSummary(any())).thenReturn('');
      when(() => mockAnalysis.analyzeLabWithConfidence(
            labCode: any(named: 'labCode'),
            value: any(named: 'value'),
            unit: any(named: 'unit'),
            patientCondition: any(named: 'patientCondition'),
          )).thenAnswer((_) async => SafeAnalysisResponse(
            explanation: '', disclaimer: '', suggestedExams: [],
            lifestyleRecommendations: [], doctorRecommendation: '',
            confidence: 0.5, confidenceLevel: 'medium', insights: [],
          ));
      when(() => mockAnalysis.analyzeVitalWithConfidence(
            vitalType: any(named: 'vitalType'),
            value: any(named: 'value'),
            relatedVitals: any(named: 'relatedVitals'),
          )).thenAnswer((_) async => SafeAnalysisResponse(
            explanation: '', disclaimer: '', suggestedExams: [],
            lifestyleRecommendations: [], doctorRecommendation: '',
            confidence: 0.5, confidenceLevel: 'medium', insights: [],
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
            history: any(named: 'history'),
          )).thenAnswer((invocation) async {
        final insights = invocation.namedArguments[const Symbol('insights')] as List<MedicalInsight>;
        return AiMedicalResponse(
          id: 'test-resp',
          queryId: 'test-query',
          answer: 'Test response',
          confidence: 0.85,
          insights: insights,
          generatedAt: DateTime.now(),
        );
      });

      final cubit = MedicalAssistantCubit(
        llmAdapter: mockAdapter,
        analysisService: mockAnalysis,
        reasoner: mockReasoner,
        healthContext: mockContext,
        scrubber: mockScrubber,
        labInterpreter: MockLabInterpreter(),
        vitalAnalyzer: MockVitalSignAnalyzer(),
        riskCalculator: MockRiskCalculator(),
      );

      await cubit.submitQuery('tengo dolor de cabeza', userId: 'user-1');

      expect(cubit.state, isA<MedicalAssistantResponse>());
    });


    test('error during LLM generation emits MedicalAssistantError', () async {
      final throwingAdapter = MockMedicalLlmAdapter();
      when(() => throwingAdapter.generateResponse(
            query: any(named: 'query'),
            insights: any(named: 'insights'),
            userContext: any(named: 'userContext'),
            history: any(named: 'history'),
          )).thenThrow(Exception('LLM failure'));

      // Build cubit with the throwing adapter directly
      final mockContext = MockHealthContextService();
      final mockScrubber = MockPromptScrubber();
      final mockReasoner = MockClinicalReasonerService();
      final mockAnalysis = MockMedicalAnalysisService();

      // Provide some data to bypass initial check
      when(() => mockContext.getContextForUser(any()))
          .thenAnswer((_) async => const HealthContext(vitals: {'systolic': 120}));
      when(() => mockScrubber.scrub(any(), apiName: any(named: 'apiName')))
          .thenAnswer((i) async => i.positionalArguments[0] as String);
      when(() => mockReasoner.analyzeSymptoms(any())).thenAnswer((_) async => []);
      when(() => mockReasoner.synthesizeHolisticSummary(any())).thenReturn('');
      when(() => mockAnalysis.calculateRisks(
            labValues: any(named: 'labValues'),
            vitals: any(named: 'vitals'),
            conditions: any(named: 'conditions'),
          )).thenAnswer((_) async => []);

      final cubit = MedicalAssistantCubit(
        llmAdapter: throwingAdapter,
        analysisService: mockAnalysis,
        reasoner: mockReasoner,
        healthContext: mockContext,
        scrubber: mockScrubber,
        labInterpreter: MockLabInterpreter(),
        vitalAnalyzer: MockVitalSignAnalyzer(),
        riskCalculator: MockRiskCalculator(),
      );

      await cubit.submitQuery('síntoma', userId: 'u1');

      expect(cubit.state, isA<MedicalAssistantError>());
    });

    test('reset() returns cubit to idle state after response', () async {
      final cubit = _buildCubit();
      await cubit.submitQuery('hola');
      expect(cubit.state, isA<MedicalAssistantResponse>());

      cubit.reset();
      expect(cubit.state, isA<MedicalAssistantIdle>());
    });

    test('health context service is called for authenticated user', () async {
      final mockContext = MockHealthContextService();
      when(() => mockContext.getContextForUser('patient-42'))
          .thenAnswer((_) async => const HealthContext(vitals: {'systolic': 120}));

      final cubit = _buildCubit(healthContext: mockContext);
      await cubit.submitQuery('tengo tos', userId: 'patient-42');

      verify(() => mockContext.getContextForUser('patient-42')).called(1);
    });

    test('emits MedicalAssistantNeedsMoreInfo when no health data is available and not a greeting', () async {
      final mockContext = MockHealthContextService();
      when(() => mockContext.getContextForUser(any()))
          .thenAnswer((_) async => HealthContext.empty());

      final cubit = _buildCubit(healthContext: mockContext);

      await cubit.submitQuery('me siento mal');

      expect(cubit.state, isA<MedicalAssistantNeedsMoreInfo>());
    });

    test('skips data sufficiency check when force is true', () async {
      final mockContext = MockHealthContextService();
      when(() => mockContext.getContextForUser(any()))
          .thenAnswer((_) async => HealthContext.empty());

      final cubit = _buildCubit(healthContext: mockContext);

      await cubit.submitQuery('me siento mal', force: true);

      expect(cubit.state, isA<MedicalAssistantResponse>());
    });

    test('emits MedicalAssistantNeedsMoreInfo with partial response when confidence is low', () async {
      final mockContext = MockHealthContextService();
      final mockAdapter = MockMedicalLlmAdapter();

      final cubit = _buildCubit(healthContext: mockContext, adapter: mockAdapter);

      // Provide some data to bypass initial check
      when(() => mockContext.getContextForUser(any())).thenAnswer(
          (_) async => const HealthContext(vitals: {'systolic': 120}));

      // Return low confidence response
      when(() => mockAdapter.generateResponse(
            query: any(named: 'query'),
            insights: any(named: 'insights'),
            userContext: any(named: 'userContext'),
            history: any(named: 'history'),
          )).thenAnswer((_) async => AiMedicalResponse(
            id: 'low-conf',
            queryId: 'q',
            answer: 'Partial answer',
            confidence: 0.3,
            insights: [],
            generatedAt: DateTime.now(),
          ));

      await cubit.submitQuery('me duele el pecho');

      expect(cubit.state, isA<MedicalAssistantNeedsMoreInfo>());
      final state = cubit.state as MedicalAssistantNeedsMoreInfo;
      expect(state.partialAnswer, contains('POSIBLE EXPLICACIÓN'));
      expect(state.questions, isNotEmpty);
    });

    test('diagnostic insights capture ICD-10 evidence from reasoner matches', () async {
      // Build cubit DIRECTLY without _buildCubit helper to avoid stub overwrite
      final mockReasoner = MockClinicalReasonerService();
      final mockAdapter = MockMedicalLlmAdapter();
      final mockContext = MockHealthContextService();
      final mockScrubber = MockPromptScrubber();
      final mockAnalysis = MockMedicalAnalysisService();

      final highScoreCode = MedicalCode(
        code: 'I21',
        displayName: 'Infarto agudo de miocardio',
        category: 'Cardiovascular',
        standard: 'ICD-10',
      );

      // Set up stubs BEFORE building cubit
      // Provide some data to bypass initial check
      when(() => mockContext.getContextForUser(any()))
          .thenAnswer((_) async => const HealthContext(vitals: {'systolic': 120}));
      when(() => mockScrubber.scrub(any(), apiName: any(named: 'apiName')))
          .thenAnswer((invocation) async => invocation.positionalArguments[0] as String);
      when(() => mockReasoner.analyzeSymptoms(any())).thenAnswer((_) async => [
            DiagnosticMatch(code: highScoreCode, score: 0.9, reasoning: 'Dolor tipico')
          ]);
      when(() => mockReasoner.synthesizeHolisticSummary(any())).thenReturn('Resumen holistico');
      when(() => mockAnalysis.analyzeLabWithConfidence(
            labCode: any(named: 'labCode'),
            value: any(named: 'value'),
            unit: any(named: 'unit'),
            patientCondition: any(named: 'patientCondition'),
          )).thenAnswer((_) async => SafeAnalysisResponse(
            explanation: '', disclaimer: '', suggestedExams: [],
            lifestyleRecommendations: [], doctorRecommendation: '',
            confidence: 0.5, confidenceLevel: 'medium', insights: [],
          ));
      when(() => mockAnalysis.analyzeVitalWithConfidence(
            vitalType: any(named: 'vitalType'),
            value: any(named: 'value'),
            relatedVitals: any(named: 'relatedVitals'),
          )).thenAnswer((_) async => SafeAnalysisResponse(
            explanation: '', disclaimer: '', suggestedExams: [],
            lifestyleRecommendations: [], doctorRecommendation: '',
            confidence: 0.5, confidenceLevel: 'medium', insights: [],
          ));
      when(() => mockAnalysis.calculateRisks(
            labValues: any(named: 'labValues'),
            vitals: any(named: 'vitals'),
            conditions: any(named: 'conditions'),
          )).thenAnswer((_) async => []);

      // Stub generateResponse to pass insights through
      when(() => mockAdapter.generateResponse(
            query: any(named: 'query'),
            insights: any(named: 'insights'),
            userContext: any(named: 'userContext'),
            history: any(named: 'history'),
          )).thenAnswer((invocation) async {
        final insights = invocation.namedArguments[const Symbol('insights')] as List<MedicalInsight>;
        return AiMedicalResponse(
          id: 'test-resp',
          queryId: 'test-query',
          answer: 'Test response',
          confidence: 0.85,
          insights: insights,
          generatedAt: DateTime.now(),
        );
      });

      // Build cubit DIRECTLY with all mocks - NO _buildCubit helper
      final cubit = MedicalAssistantCubit(
        llmAdapter: mockAdapter,
        analysisService: mockAnalysis,
        reasoner: mockReasoner,
        healthContext: mockContext,
        scrubber: mockScrubber,
        labInterpreter: MockLabInterpreter(),
        vitalAnalyzer: MockVitalSignAnalyzer(),
        riskCalculator: MockRiskCalculator(),
      );

      await cubit.submitQuery('dolor intenso en el pecho', userId: 'u1');

      // Verify response state
      expect(cubit.state, isA<MedicalAssistantResponse>());
      final state = cubit.state as MedicalAssistantResponse;
      final diagInsights = state.response.insights
          .where((i) => i.id.startsWith('diag_'))
          .toList();
      expect(diagInsights, isNotEmpty);
      expect(diagInsights.first.severity, equals(InsightSeverity.alert));
    });

  });
}
