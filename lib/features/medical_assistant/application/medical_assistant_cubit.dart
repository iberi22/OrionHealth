import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
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
  final IsarAgentMemory? _memory;

  MedicalAssistantCubit({
    MedicalLlmAdapter? llmAdapter,
    MedicalAnalysisService? analysisService,
    LabInterpreter? labInterpreter,
    VitalSignAnalyzer? vitalAnalyzer,
    RiskCalculator? riskCalculator,
    IsarAgentMemory? memory,
  })  : _llmAdapter = llmAdapter ?? MedicalLlmAdapter(),
        _analysisService = analysisService ?? MedicalAnalysisService(),
        _labInterpreter = labInterpreter ?? LabInterpreter(),
        _vitalAnalyzer = vitalAnalyzer ?? VitalSignAnalyzer(),
        _riskCalculator = riskCalculator ?? RiskCalculator(),
        _memory = memory,
        super(const MedicalAssistantIdle());

  /// Submit a medical query
  Future<void> submitQuery(String question, {String? userId}) async {
    emit(const MedicalAssistantLoading(message: 'Analyzing your question...'));

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
      final chronicConditions = userContext['conditions'] as List<Icd10Code>? ?? [];
      final labValues = userContext['labs'] as Map<String, double>? ?? {};
      final vitals = userContext['vitals'] as Map<String, double>? ?? {};

      emit(const MedicalAssistantLoading(message: 'Running lab analysis...'));
      final labInsights = await _analysisService.analyzeLabs(
        labValues: labValues,
        chronicConditions: chronicConditions,
      );

      emit(const MedicalAssistantLoading(message: 'Analyzing vital signs...'));
      final vitalInsights = await _analysisService.analyzeVitals(
        vitals: vitals,
        chronicConditions: chronicConditions,
      );

      emit(const MedicalAssistantLoading(message: 'Calculating health risks...'));
      final riskInsights = await _analysisService.calculateRisks(
        labValues: labValues,
        vitals: vitals,
        conditions: chronicConditions,
      );

      final allInsights = [...labInsights, ...vitalInsights, ...riskInsights];

      emit(const MedicalAssistantLoading(message: 'Generating AI response...'));
      final response = await _llmAdapter.generateResponse(
        query: query,
        insights: allInsights,
        userContext: userContext,
      );

      emit(MedicalAssistantResponse(response: response, query: query));
    } catch (e) {
      emit(MedicalAssistantError('Error processing query: $e'));
    }
  }

  /// Reset to idle state
  void reset() {
    emit(const MedicalAssistantIdle());
  }

  List<String> _extractTags(String question) {
    final tags = <String>[];
    final lower = question.toLowerCase();
    
    if (lower.contains('glucosa') || lower.contains('glucose') || lower.contains('azúcar')) {
      tags.add('diabetes');
    }
    if (lower.contains('presión') || lower.contains('blood pressure') || lower.contains('hta')) {
      tags.add('hypertension');
    }
    if (lower.contains('colesterol') || lower.contains('cholesterol') || lower.contains('lipidos')) {
      tags.add('lipids');
    }
    if (lower.contains('tiroides') || lower.contains('thyroid') || lower.contains('tsh')) {
      tags.add('thyroid');
    }
    
    return tags;
  }

  Future<Map<String, dynamic>> _getUserContext(String? userId) async {
    if (_memory == null || userId == null) {
      return {};
    }
    
    // Stub: would query isar_agent_memory for user health data
    // This would include chronic conditions, recent labs, vitals, medications
    return {
      'conditions': <Icd10Code>[],
      'labs': <String, double>{},
      'vitals': <String, double>{},
      'medications': <String>[],
    };
  }
}
