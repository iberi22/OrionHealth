import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/health_report.dart';
import '../../domain/repositories/health_report_repository.dart';
import '../../domain/services/report_generation_service.dart';

part 'health_report_event.dart';
part 'health_report_state.dart';

@injectable
class HealthReportBloc extends Bloc<HealthReportEvent, HealthReportState> {
  final HealthReportRepository _repository;
  final ReportGenerationService _generationService;

  HealthReportBloc(this._repository, this._generationService) : super(HealthReportInitial()) {
    on<LoadReports>(_onLoadReports);
    on<GenerateReportEvent>(_onGenerateReport);
    on<DeleteReport>(_onDeleteReport);
  }

  Future<void> _onLoadReports(LoadReports event, Emitter<HealthReportState> emit) async {
    emit(HealthReportLoading());
    try {
      final reports = await _repository.getReports();
      emit(HealthReportLoaded(reports));
    } catch (e) {
      emit(HealthReportError(e.toString()));
    }
  }

  Future<void> _onGenerateReport(GenerateReportEvent event, Emitter<HealthReportState> emit) async {
    emit(HealthReportLoading());
    try {
      final report = await _generationService.generateReport(
        prompt: event.prompt,
        contextData: event.contextData,
      );
      await _repository.saveReport(report);
      add(LoadReports());
    } catch (e) {
      emit(HealthReportError(e.toString()));
    }
  }

  Future<void> _onDeleteReport(DeleteReport event, Emitter<HealthReportState> emit) async {
    try {
      await _repository.deleteReport(event.id);
      add(LoadReports());
    } catch (e) {
      emit(HealthReportError(e.toString()));
    }
  }
}
