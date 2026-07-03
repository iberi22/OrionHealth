import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';
import '../domain/entities/medical_research_result.dart';
import '../domain/entities/research_query.dart';
import '../domain/models/research_result.dart';
import '../domain/services/medical_standards_service.dart';
import '../domain/usecases/get_research_history.dart';
import '../domain/usecases/search_medical_research.dart';

enum MedicalResearchStatus { idle, loading, success, error }

class MedicalResearchState extends Equatable {
  final MedicalResearchStatus status;
  final String? loadingMessage;
  final String? errorMessage;
  final List<ResearchResult> results;
  final List<MedicalResearchResult> history;
  final List<String> interactions;
  final Icd10Code? icd10Result;

  const MedicalResearchState({
    this.status = MedicalResearchStatus.idle,
    this.loadingMessage,
    this.errorMessage,
    this.results = const [],
    this.history = const [],
    this.interactions = const [],
    this.icd10Result,
  });

  @override
  List<Object?> get props => [
        status,
        loadingMessage,
        errorMessage,
        results,
        history,
        interactions,
        icd10Result,
      ];

  MedicalResearchState copyWith({
    MedicalResearchStatus? status,
    String? loadingMessage,
    String? errorMessage,
    List<ResearchResult>? results,
    List<MedicalResearchResult>? history,
    List<String>? interactions,
    Icd10Code? icd10Result,
  }) {
    return MedicalResearchState(
      status: status ?? this.status,
      loadingMessage: loadingMessage, // Intentionally not persisting loading message
      errorMessage: errorMessage,
      results: results ?? this.results,
      history: history ?? this.history,
      interactions: interactions ?? this.interactions,
      icd10Result: icd10Result ?? this.icd10Result,
    );
  }
}

// Cubit
@injectable
class MedicalResearchCubit extends Cubit<MedicalResearchState> {
  final SearchMedicalResearch _searchUseCase;
  final GetResearchHistory _getHistoryUseCase;
  final MedicalStandardsService _standardsService;

  MedicalResearchCubit(
    this._searchUseCase,
    this._getHistoryUseCase,
    this._standardsService,
  ) : super(const MedicalResearchState());

  Future<void> performResearch(String query) async {
    emit(state.copyWith(
      status: MedicalResearchStatus.loading,
      loadingMessage: 'Buscando evidencia médica...',
    ));
    try {
      final results = await _searchUseCase.execute(ResearchQuery(text: query));
      emit(state.copyWith(
        status: MedicalResearchStatus.success,
        results: results,
      ));
      // Refresh history after new research
      await loadHistory();
    } catch (e) {
      emit(state.copyWith(
        status: MedicalResearchStatus.error,
        errorMessage: 'Error en la investigación: $e',
      ));
    }
  }

  Future<void> checkInteractions(List<String> rxnormCodes) async {
    emit(state.copyWith(
      status: MedicalResearchStatus.loading,
      loadingMessage: 'Verificando interacciones...',
    ));
    try {
      final interactions = await _standardsService.checkDrugInteractions(rxnormCodes);
      emit(state.copyWith(
        status: MedicalResearchStatus.success,
        interactions: interactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MedicalResearchStatus.error,
        errorMessage: 'Error verificando interacciones: $e',
      ));
    }
  }

  Future<void> loadHistory() async {
    try {
      final history = await _getHistoryUseCase.execute();
      emit(state.copyWith(
        history: history,
      ));
    } catch (e) {
      // Silently fail history load
    }
  }

  Future<void> lookupIcd10(String diagnosis) async {
    emit(state.copyWith(
      status: MedicalResearchStatus.loading,
      loadingMessage: 'Buscando código ICD-10...',
    ));
    try {
      final code = await _standardsService.lookupIcd10(diagnosis);
      emit(state.copyWith(
        status: MedicalResearchStatus.success,
        icd10Result: code,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MedicalResearchStatus.error,
        errorMessage: 'Error buscando ICD-10: $e',
      ));
    }
  }

  void reset() {
    emit(const MedicalResearchState());
  }
}
