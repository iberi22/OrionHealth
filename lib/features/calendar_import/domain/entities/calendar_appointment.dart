import 'calendar_event.dart';

/// Represents a discovered appointment from a calendar source.
///
/// This is a transient domain entity used during the import process
/// to decouple the discovery logic from the persistent [Appointment] entity.
class CalendarAppointment {
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String? notes;
  final CalendarEventSource source;

  const CalendarAppointment({
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.notes,
    this.source = CalendarEventSource.unknown,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarAppointment &&
          runtimeType == other.runtimeType &&
          doctorName == other.doctorName &&
          specialty == other.specialty &&
          dateTime == other.dateTime &&
          notes == other.notes &&
          source == other.source;

  @override
  int get hashCode =>
      doctorName.hashCode ^
      specialty.hashCode ^
      dateTime.hashCode ^
      notes.hashCode ^
      source.hashCode;

  @override
  String toString() {
    return 'CalendarAppointment(doctorName: $doctorName, specialty: $specialty, dateTime: $dateTime)';
  }
}
