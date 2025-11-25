part of 'health_report_bloc.dart';

abstract class HealthReportState {}

class HealthReportInitial extends HealthReportState {}

class HealthReportLoading extends HealthReportState {}

class HealthReportLoaded extends HealthReportState {
  final List<HealthReport> reports;

  HealthReportLoaded(this.reports);
}

class HealthReportError extends HealthReportState {
  final String message;

  HealthReportError(this.message);
}
