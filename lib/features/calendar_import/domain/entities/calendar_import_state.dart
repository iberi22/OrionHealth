import '../../../appointments/domain/entities/appointment.dart';

abstract class CalendarImportState {
  const CalendarImportState();
}

class CalendarImportInitial extends CalendarImportState {
  const CalendarImportInitial();
}

class CalendarImportLoading extends CalendarImportState {
  const CalendarImportLoading();
}

class CalendarImportLoaded extends CalendarImportState {
  final List<Appointment> foundAppointments;
  const CalendarImportLoaded(this.foundAppointments);
}

class CalendarImportSuccess extends CalendarImportState {
  final int importedCount;
  const CalendarImportSuccess(this.importedCount);
}

class CalendarImportError extends CalendarImportState {
  final String message;
  const CalendarImportError(this.message);
}

class CalendarImportPermissionDenied extends CalendarImportState {
  const CalendarImportPermissionDenied();
}
