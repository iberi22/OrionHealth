import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';

import '../domain/entities/medical_query.dart';
import '../domain/entities/medical_insight.dart';
import '../domain/entities/ai_response.dart';
import '../domain/services/medical_analysis_service.dart';
import '../domain/services/health_context_service.dart';
import '../infrastructure/llm/medical_llm_adapter.dart';
import '../domain/services/clinical_reasoner_service.dart';
import '../../../core/services/privacy_anonymizer.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/di/injection.dart';
import '../../../features/local_agent/infrastructure/llm_service.dart';
import '../infrastructure/analysis/lab_interpreter.dart';
import '../infrastructure/analysis/vital_sign_analyzer.dart';
import '../infrastructure/analysis/risk_calculator.dart';

// States
abstract class MedicalAssistantState extends Equatable {
  const MedicalAssistantState();

  @override
  List<Object?> get props => [];
}

class MedicalAssistantIdle extends MedicalAssistantState {
  const MedicalAssistantIdle();
}

class MedicalAssistantLoading extends MedicalAssistantState {
  final String? message;
  const MedicalAssistantLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class MedicalAssistantResponse extends MedicalAssistantState {
  final AiMedicalResponse response;
  final MedicalQuery query;
  const MedicalAssistantResponse({
    required this.response,
    required this.query,
  });

  @override
  List<Object?> get props => [response, query];
}

class MedicalAssistantError extends MedicalAssistantState {
  final String message;
  const MedicalAssistantError(this.message);

  @override
  List<Object?> get props => [message];
}

class MedicalAssistantNeedsMoreInfo extends MedicalAssistantState {
  final String message; // explanation of what's missing
  final List<String> questions; // specific questions to ask
  final String? partialAnswer; // optional partial analysis

  const MedicalAssistantNeedsMoreInfo({
    required this.message,
    required this.questions,
    this.partialAnswer,
  });

  @override
  List<Object?> get props => [message, questions, partialAnswer];
}

// Cubit
class MedicalAssistantCubit extends Cubit<MedicalAssistantState> {
  static const _tag = 'MedicalAssistantCubit';

  final MedicalLlmAdapter _llmAdapter;
  final MedicalAnalysisService _analysisService;
  final ClinicalReasonerService _reasoner;
  final HealthContextService _healthContext;
  final PromptScrubber _scrubber;

  final List<Map<String, String>> _conversationHistory = [];

  // ignore: unused_field
  final LabInterpreter _labInterpreter;
  // ignore: unused_field
  final VitalSignAnalyzer _vitalAnalyzer;
  // ignore: unused_field
  final RiskCalculator _riskCalculator;

  MedicalAssistantCubit({
    MedicalLlmAdapter? llmAdapter,
    MedicalAnalysisService? analysisService,
    LabInterpreter? labInterpreter,
    VitalSignAnalyzer? vitalAnalyzer,
    RiskCalculator? riskCalculator,
    ClinicalReasonerService? reasoner,
    HealthContextService? healthContext,
    PromptScrubber? scrubber,
    MemoryGraph? memory,
    LlmService? llmService,
  })  : _llmAdapter = llmAdapter ??
            MedicalLlmAdapter(
              scrubber: getIt<PromptScrubber>(),
              llmService: llmService ?? getIt<LlmService>(),
            ),
        _analysisService = analysisService ?? MedicalAnalysisService(),
        _labInterpreter = labInterpreter ?? LabInterpreter(),
        _vitalAnalyzer = vitalAnalyzer ?? VitalSignAnalyzer(),
        _riskCalculator = riskCalculator ?? getIt<RiskCalculator>(),
        _reasoner = reasoner ?? getIt<ClinicalReasonerService>(),
        _healthContext = healthContext ?? getIt<HealthContextService>(),
        _scrubber = scrubber ?? getIt<PromptScrubber>(),
        super(const MedicalAssistantIdle());

  /// Submit a medical query with STRICT confidence enforcement.
  ///
  /// Rules enforced:
  /// - AI NEVER diagnoses below 90% confidence
  /// - AI ALWAYS explains what symptoms COULD mean
  /// - AI ALWAYS provides normal ranges for labs
  /// - AI ALWAYS recommends consulting a doctor
  /// - When in doubt, ask for MORE DATA not less
  Future<void> submitQuery(String question, {String? userId, bool force = false}) async {
    emit(const MedicalAssistantLoading(message: 'Analizando tu pregunta...'));

    _conversationHistory.add({'role': 'user', 'content': question});

    try {
      final queryId = DateTime.now().millisecondsSinceEpoch.toString();
      final isGreeting = _isGreeting(question);

      final query = MedicalQuery(
        id: queryId,
        question: question,
        timestamp: DateTime.now(),
        userId: userId,
        contextTags: _extractTags(question),
      );

      if (isGreeting) {
        final greetingResponse = AiMedicalResponse(
          id: 'greeting_$queryId',
          queryId: queryId,
          answer:
              '¡Hola! Soy tu asistente médico de OrionHealth. ¿En qué puedo ayudarte hoy? Puedes preguntarme sobre tus análisis de sangre, signos vitales o síntomas generales.',
          confidence: 1.0,
          insights: [],
          generatedAt: DateTime.now(),
          metadata: {'is_greeting': true},
        );
        _conversationHistory.add({
          'role': 'assistant',
          'content': greetingResponse.answer,
        });
        emit(MedicalAssistantResponse(response: greetingResponse, query: query));
        return;
      }

      // Gather real user context from typed Isar repos
      AppLogger.d(_tag, 'Loading health context for user=$userId...');
      final healthCtx =
          await _healthContext.getContextForUser(userId ?? 'anonymous');
      final userContext = healthCtx.toContextMap();
      final chronicConditions = healthCtx.conditions;
      final labValues = healthCtx.labValues;
      final vitals = healthCtx.vitals;

      // Data sufficiency check
      final hasNoLabData = labValues.isEmpty;
      final hasNoVitals = vitals.isEmpty;
      final hasNoConditions = chronicConditions.isEmpty;

      if (!force && hasNoLabData && hasNoVitals && hasNoConditions) {
        const message =
            'Para darte un análisis más preciso, necesito conocer mejor tu situación.';
        const questions = [
          '¿Tienes resultados de análisis de sangre recientes?',
          '¿Cuáles son tus signos vitales actuales (presión, frecuencia cardíaca)?',
          '¿Padeces alguna enfermedad crónica conocida?',
          '¿Estás tomando algún medicamento actualmente?',
          '¿Con qué frecuencia e intensidad presentas estos síntomas?',
        ];
        _conversationHistory.add({
          'role': 'assistant',
          'content': message,
        });
        emit(const MedicalAssistantNeedsMoreInfo(
          message: message,
          questions: questions,
        ));
        return;
      }

      // ---- Lab Analysis ----
      emit(const MedicalAssistantLoading(message: 'Analizando laboratorios...'));
      final labInsights = <MedicalInsight>[];

      for (final entry in labValues.entries) {
        final response = await _analysisService.analyzeLabWithConfidence(
          labCode: entry.key,
          value: entry.value,
          unit: null,
          patientCondition:
              chronicConditions.isNotEmpty ? chronicConditions.first.code : null,
        );
        labInsights.addAll(response.insights);
      }

      // ---- Vital Signs Analysis ----
      emit(const MedicalAssistantLoading(message: 'Analizando signos vitales...'));
      final vitalInsights = <MedicalInsight>[];

      if (vitals.containsKey('systolic') || vitals.containsKey('diastolic')) {
        final bpResponse = await _analysisService.analyzeVitalWithConfidence(
          vitalType: vitals.containsKey('systolic') ? 'systolic' : 'diastolic',
          value: vitals['systolic'] ?? vitals['diastolic'] ?? 0,
          relatedVitals: vitals,
        );
        vitalInsights.addAll(bpResponse.insights);
      }

      // ---- Risk Calculation ----
      emit(const MedicalAssistantLoading(message: 'Calculando riesgos...'));
      final riskInsights = await _analysisService.calculateRisks(
        labValues: labValues,
        vitals: vitals,
        conditions: chronicConditions,
      );

      // ---- Symptom Analysis (Agentic Reasoner) ----
      // Scrub PII from user input before it enters the clinical reasoning engine
      emit(const MedicalAssistantLoading(message: 'Razonando sobre tus síntomas...'));
      final scrubbedQuestion =
          await _scrubber.scrub(question, apiName: 'clinical_reasoner');
      final diagnosticMatches = await _reasoner.analyzeSymptoms(scrubbedQuestion);
      final diagnosticInsights = diagnosticMatches
          .map((m) => MedicalInsight(
                id: 'diag_${m.code.code}',
                title: 'Posible asociación: ${m.code.displayName}',
                description:
                    '${m.reasoning} (Confianza: ${(m.score * 100).toInt()}%)',
                severity:
                    m.score >= 0.8 ? InsightSeverity.alert : InsightSeverity.warning,
                category: InsightCategory.symptomAnalysis,
                generatedAt: DateTime.now(),
                guidelineReference: m.code.code,
                evidence: {
                  'code': m.code.code,
                  'standard': m.code.standard,
                  'holistic_mental': m.code.mentalHealthImpact,
                  'holistic_physical': m.code.physicalHealthImpact,
                  'score': m.score,
                },
              ))
          .toList();

      // ---- Holistic Synthesis ----
      final matchedCodes = diagnosticMatches.map((m) => m.code).toList();
      final holisticSummary = _reasoner.synthesizeHolisticSummary(matchedCodes);

      final allInsights = [
        ...labInsights,
        ...vitalInsights,
        ...riskInsights,
        ...diagnosticInsights
      ];

      // ---- Generate Response with confidence enforcement ----
      emit(const MedicalAssistantLoading(message: 'Generando respuesta...'));
      final response = await _llmAdapter.generateResponse(
        query: query,
        insights: allInsights,
        userContext: {
          ...userContext,
          'holisticSummary': holisticSummary,
        },
        history: _conversationHistory,
      );

      final hasNoDiagnosticMatches = diagnosticMatches.isEmpty;

      // If we have some data but low confidence
      if (hasNoDiagnosticMatches &&
          !isGreeting &&
          (response.confidence ?? 0.0) < 0.5) {
        final finalResponse = _addDataRequest(response, question);
        final questions = _generateContextualQuestions(
            question, chronicConditions, labValues);
        _conversationHistory.add({
          'role': 'assistant',
          'content': finalResponse.answer,
        });
        emit(MedicalAssistantNeedsMoreInfo(
          message: 'He iniciado un análisis pero necesito más información.',
          questions: questions,
          partialAnswer: finalResponse.answer,
        ));
        return;
      }

      _conversationHistory.add({
        'role': 'assistant',
        'content': response.answer,
      });

      // emit the response directly, the MedicalLlmAdapter now handles safety phrasing via LLM
      emit(MedicalAssistantResponse(response: response, query: query));
    } catch (e) {
      emit(MedicalAssistantError('Error procesando tu consulta: $e'));
    }
  }

  /// When confidence is very low, always ask for more data.
  AiMedicalResponse _addDataRequest(
    AiMedicalResponse baseResponse,
    String question,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Respecto a tu pregunta sobre "$question":');
    buffer.writeln();
    buffer.writeln('POSIBLE EXPLICACIÓN:');
    buffer.writeln('No tengo suficiente información médica para proporcionar '
        'una interpretación específica. ');
    buffer.writeln('Esto es normal cuando se trata de síntomas generales o '
        'datos incompletos.');
    buffer.writeln();
    buffer.writeln('INFORMACIÓN QUE ME AYUDARÍA A AYUDARTE MEJOR:');
    buffer.writeln('• ¿Tienes resultados de laboratorio recientes?');
    buffer.writeln('• ¿Tienes condiciones médicas conocidas?');
    buffer.writeln('• ¿Estás tomando algún medicamento?');
    buffer.writeln('• ¿Puedes describir los síntomas con más detalle?');
    buffer.writeln();
    buffer.writeln('MI RECOMENDACIÓN:');
    buffer.writeln('Consulta con tu médico de cabecera para una evaluación. '
        'Lleva los datos que tengas disponibles a tu cita.');
    buffer.writeln();
    buffer.writeln('CONFIDENCE: 25% — Necesito más datos para ayudarte mejor.');
    buffer.writeln();
    buffer.writeln('⚠️ Esta información es solo educativa y no sustituye '
        'la evaluación de un profesional de salud.');

    return baseResponse.copyWith(
      answer: buffer.toString(),
      confidence: 0.25,
      metadata: {
        ...?baseResponse.metadata,
        'confidenceLevel': 'very_low',
        'canDiagnose': false,
        'needsMoreData': true,
        'dataRequest': true,
      },
    );
  }

  List<String> _generateContextualQuestions(
    String question,
    List<dynamic> conditions,
    Map<String, double> labValues,
  ) {
    final questions = <String>[];
    final lower = question.toLowerCase();

    if (lower.contains('dolor') || lower.contains('pain')) {
      questions.add(
          '¿Dónde exactamente sientes el dolor? ¿Cómo lo describirías (agudo, sordo, pulsante)?');
      questions.add(
          '¿Cuánto tiempo llevas con este dolor? ¿Es constante o intermitente?');
    }
    if (lower.contains('cansancio') ||
        lower.contains('fatiga') ||
        lower.contains('tired')) {
      questions.add(
          '¿Desde cuándo sientes cansancio? ¿Afecta tus actividades diarias?');
      questions.add('¿Has tenido cambios recientes en tu dieta o sueño?');
    }
    if (labValues.isEmpty) {
      questions.add(
          '¿Tienes resultados de análisis de sangre de los últimos 6 meses?');
    }
    if (conditions.isEmpty) {
      questions.add(
          '¿Tienes alguna enfermedad o condición médica diagnosticada previamente?');
    }

    // Always add a general one
    questions.add('¿Hay algún otro síntoma que quieras mencionar?');

    return questions.take(4).toList(); // Max 4 questions at a time
  }

  /// Reset to idle state.
  void reset() {
    _conversationHistory.clear();
    emit(const MedicalAssistantIdle());
  }

  List<String> _extractTags(String question) {
    final tags = <String>[];
    final lower = question.toLowerCase();

    if (lower.contains('glucosa') ||
        lower.contains('glucose') ||
        lower.contains('azúcar')) {
      tags.add('diabetes');
    }
    if (lower.contains('presión') ||
        lower.contains('blood pressure') ||
        lower.contains('hta')) {
      tags.add('hypertension');
    }
    if (lower.contains('colesterol') ||
        lower.contains('cholesterol') ||
        lower.contains('lipidos')) {
      tags.add('lipids');
    }
    if (lower.contains('tiroides') ||
        lower.contains('thyroid') ||
        lower.contains('tsh')) {
      tags.add('thyroid');
    }

    return tags;
  }
  
  bool _isGreeting(String question) {
    final lower = question.toLowerCase().trim();
    final greetings = [
      'hola', 'buenos días', 'buenas tardes', 'buenas noches', 
      'hi', 'hello', 'hey', 'saludos', 'que tal'
    ];
    return greetings.any((g) => lower == g || lower.startsWith('$g '));
  }
}
