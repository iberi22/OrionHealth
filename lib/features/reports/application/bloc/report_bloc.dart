import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/services/report_generation_service.dart';

part 'report_event.dart';
part 'report_state.dart';

@injectable
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository;
  final ReportGenerationService _generationService;

  ReportBloc(this._repository, this._generationService) : super(ReportInitial()) {
    on<LoadReports>(_onLoadReports);
    on<GenerateReportEvent>(_onGenerateReport);
    on<DeleteReport>(_onDeleteReport);
  }

  Future<void> _onLoadReports(LoadReports event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final reports = await _repository.getReports();
      emit(ReportLoaded(reports));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onGenerateReport(GenerateReportEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final report = await _generationService.generateReport(
        prompt: event.prompt,
        contextData: event.contextData,
      );
      await _repository.saveReport(report);
      add(LoadReports());
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onDeleteReport(DeleteReport event, Emitter<ReportState> emit) async {
    try {
      await _repository.deleteReport(event.id);
      add(LoadReports());
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
