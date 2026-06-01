import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_standards/medical_standards.dart';

import '../domain/entities/medical_query.dart';
import '../domain/entities/medical_insight.dart';
import '../domain/entities/ai_response.dart';
import '../domain/services/medical_analysis_service.dart';
import '../infrastructure/llm/medical_llm_adapter.dart';
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

// Cubit
class MedicalAssistantCubit extends Cubit<MedicalAssistantState> {
  final MedicalLlmAdapter _llmAdapter;
  final MedicalAnalysisService _analysisService;
  final LabInterpreter _labInterpreter;
  final VitalSignAnalyzer _vitalAnalyzer;
  final RiskCalculator _riskCalculator;
  MedicalAssistantCubit({
    MedicalLlmAdapter? llmAdapter,
    MedicalAnalysisService? analysisService,
    LabInterpreter? labInterpreter,
    VitalSignAnalyzer? vitalAnalyzer,
    RiskCalculator? riskCalculator,
  })  : _llmAdapter = llmAdapter ?? MedicalLlmAdapter(),
        _analysisService = analysisService ?? MedicalAnalysisService(),
        _labInterpreter = labInterpreter ?? LabInterpreter(),
        _vitalAnalyzer = vitalAnalyzer ?? VitalSignAnalyzer(),
        _riskCalculator = riskCalculator ?? RiskCalculator(),
        super(const MedicalAssistantIdle());

  /// Submit a medical query with STRICT confidence enforcement.
  ///
  /// Rules enforced:
  /// - AI NEVER diagnoses below 90% confidence
  /// - AI ALWAYS explains what symptoms COULD mean
  /// - AI ALWAYS provides normal ranges for labs
  /// - AI ALWAYS recommends consulting a doctor
  /// - When in doubt, ask for MORE DATA not less
  Future<void> submitQuery(String question, {String? userId}) async {
    emit(const MedicalAssistantLoading(message: 'Analizando tu pregunta...'));

    try {
      final queryId = DateTime.now().millisecondsSinceEpoch.toString();
      final query = MedicalQuery(
        id: queryId,
        question: question,
        timestamp: DateTime.now(),
        userId: userId,
        contextTags: _extractTags(question),
      );

      // Gather user context from memory
      final userContext = await _getUserContext(userId);
      final chronicConditions =
          userContext['conditions'] as List<Icd10Code>? ?? [];
      final labValues =
          userContext['labs'] as Map<String, double>? ?? {};
      final vitals = userContext['vitals'] as Map<String, double>? ?? {};

      // ---- Lab Analysis ----
      emit(const MedicalAssistantLoading(message: 'Analizando laboratorios...'));
      final labInsights = <MedicalInsight>[];

      for (final entry in labValues.entries) {
        final response = _analysisService.analyzeLabWithConfidence(
          labCode: entry.key,
          value: entry.value,
          unit: null,
          patientCondition: chronicConditions.isNotEmpty
              ? chronicConditions.first.code
              : null,
        );
        labInsights.addAll(response.insights);
      }

      // ---- Vital Signs Analysis ----
      emit(const MedicalAssistantLoading(message: 'Analizando signos vitales...'));
      final vitalInsights = <MedicalInsight>[];

      if (vitals.containsKey('systolic') || vitals.containsKey('diastolic')) {
        final bpResponse = _analysisService.analyzeVitalWithConfidence(
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

      final allInsights = [...labInsights, ...vitalInsights, ...riskInsights];

      // ---- Generate Response with confidence enforcement ----
      emit(const MedicalAssistantLoading(message: 'Generando respuesta...'));
      final response = await _llmAdapter.generateResponse(
        query: query,
        insights: allInsights,
        userContext: userContext,
      );

      // ---- Enforce confidence rules in metadata ----
      final confidence = response.confidence ?? 0.0;
      final confidenceLevel = ConfidenceThreshold.getLevel(confidence);

      // If confidence is very low and no insights, add data request
      if (confidence < 0.5 && allInsights.isEmpty) {
        final enhancedResponse = _addDataRequest(response, question);
        emit(MedicalAssistantResponse(
          response: enhancedResponse,
          query: query,
        ));
        return;
      }

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

  /// Reset to idle state.
  void reset() {
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

  Future<Map<String, dynamic>> _getUserContext(String? userId) async {
    if (userId == null) {
      return {};
    }

    // Stub: would query user health data from local repositories
    return {
      'conditions': <Icd10Code>[],
      'labs': <String, double>{},
      'vitals': <String, double>{},
      'medications': <String>[],
    };
  }
}
