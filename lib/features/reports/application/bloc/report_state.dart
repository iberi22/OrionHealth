part of 'report_bloc.dart';

abstract class ReportState {
  const ReportState();
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportLoaded extends ReportState {
  final List<Report> reports;

  ReportLoaded(this.reports);
}

class ReportError extends ReportState {
  final String message;

  ReportError(this.message);
}
