import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:research_package/research_package.dart';
import '../domain/repositories/i_assessment_repository.dart';
import '../domain/entities/clinical_assessment_record.dart';

abstract class ClinicalAssessmentsState extends Equatable {
  const ClinicalAssessmentsState();

  @override
  List<Object?> get props => [];
}

class ClinicalAssessmentsInitial extends ClinicalAssessmentsState {
  const ClinicalAssessmentsInitial();
}

class ClinicalAssessmentsLoading extends ClinicalAssessmentsState {
  const ClinicalAssessmentsLoading();
}

class ClinicalAssessmentsLoaded extends ClinicalAssessmentsState {
  final List<ClinicalAssessmentRecord> assessments;

  const ClinicalAssessmentsLoaded(this.assessments);

  @override
  List<Object?> get props => [assessments];
}

class ConsentCompleted extends ClinicalAssessmentsState {
  const ConsentCompleted();
}

class SurveyCompleted extends ClinicalAssessmentsState {
  const SurveyCompleted();
}

class ClinicalAssessmentsError extends ClinicalAssessmentsState {
  final String message;

  const ClinicalAssessmentsError(this.message);

  @override
  List<Object?> get props => [message];
}

@injectable
class ClinicalAssessmentsCubit extends Cubit<ClinicalAssessmentsState> {
  final IAssessmentRepository _repository;

  ClinicalAssessmentsCubit(this._repository) : super(const ClinicalAssessmentsInitial());

  Future<void> loadAssessments() async {
    emit(const ClinicalAssessmentsLoading());
    try {
      final assessments = await _repository.loadAssessments();
      emit(ClinicalAssessmentsLoaded(assessments));
    } catch (e) {
      emit(ClinicalAssessmentsError(e.toString()));
    }
  }

  Future<void> saveConsentResult(RPTaskResult result) async {
    emit(const ClinicalAssessmentsLoading());
    try {
      await _repository.saveAssessmentResult('informed_consent', result);
      emit(const ConsentCompleted());
    } catch (e) {
      emit(ClinicalAssessmentsError(e.toString()));
    }
  }

  Future<void> saveSurveyResult(RPTaskResult result) async {
    emit(const ClinicalAssessmentsLoading());
    try {
      await _repository.saveAssessmentResult('health_survey', result);
      emit(const SurveyCompleted());
    } catch (e) {
      emit(ClinicalAssessmentsError(e.toString()));
    }
  }
}
