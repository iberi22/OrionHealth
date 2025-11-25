part of 'health_report_bloc.dart';

abstract class HealthReportEvent {}

class LoadReports extends HealthReportEvent {}

class GenerateReportEvent extends HealthReportEvent {
  final String prompt;
  final List<String> contextData;

  GenerateReportEvent({required this.prompt, required this.contextData});
}

class DeleteReport extends HealthReportEvent {
  final int id;

  DeleteReport(this.id);
}
