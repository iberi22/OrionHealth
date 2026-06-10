import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';
import '../domain/models/research_result.dart';
import '../domain/services/medical_standards_service.dart';
import '../infrastructure/medical_research_service.dart';

enum MedicalResearchStatus { idle, loading, success, error }

class MedicalResearchState extends Equatable {
  final MedicalResearchStatus status;
  final String? loadingMessage;
  final String? errorMessage;
  final List<ResearchResult> results;
  final List<String> interactions;
  final Icd10Code? icd10Result;

  const MedicalResearchState({
    this.status = MedicalResearchStatus.idle,
    this.loadingMessage,
    this.errorMessage,
    this.results = const [],
    this.interactions = const [],
    this.icd10Result,
  });

  @override
  List<Object?> get props => [
        status,
        loadingMessage,
        errorMessage,
        results,
        interactions,
        icd10Result,
      ];

  MedicalResearchState copyWith({
    MedicalResearchStatus? status,
    String? loadingMessage,
    String? errorMessage,
    List<ResearchResult>? results,
    List<String>? interactions,
    Icd10Code? icd10Result,
  }) {
    return MedicalResearchState(
      status: status ?? this.status,
      loadingMessage: loadingMessage, // Intentionally not persisting loading message
      errorMessage: errorMessage,
      results: results ?? this.results,
      interactions: interactions ?? this.interactions,
      icd10Result: icd10Result ?? this.icd10Result,
    );
  }
}

// Cubit
@injectable
class MedicalResearchCubit extends Cubit<MedicalResearchState> {
  final MedicalResearchService _researchService;
  final MedicalStandardsService _standardsService;

  MedicalResearchCubit(
    this._researchService,
    this._standardsService,
  ) : super(const MedicalResearchState());

  Future<void> performResearch(String query) async {
    emit(state.copyWith(
      status: MedicalResearchStatus.loading,
      loadingMessage: 'Buscando evidencia médica...',
    ));
    try {
      final results = await _researchService.performResearch(query);
      emit(state.copyWith(
        status: MedicalResearchStatus.success,
        results: results,
      ));
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
