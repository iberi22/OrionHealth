part of 'report_bloc.dart';

abstract class ReportEvent {}

class LoadReports extends ReportEvent {}

class GenerateReportEvent extends ReportEvent {
  final String prompt;
  final List<String> contextData;

  GenerateReportEvent({required this.prompt, required this.contextData});
}

class DeleteReport extends ReportEvent {
  final int id;

  DeleteReport(this.id);
}
