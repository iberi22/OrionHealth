import 'package:isar/isar.dart';

part 'appointment.g.dart';

enum AppointmentStatus {
  upcoming,
  completed,
  cancelled,
}

@collection
class Appointment {
  Id id = Isar.autoIncrement;

  late String doctorName;
  late String specialty;
  late DateTime dateTime;
  int durationInMinutes = 30;
  String? recurrenceRule; // e.g., "FREQ=DAILY", "FREQ=WEEKLY"
  String? notes;
  String? source;

  @Enumerated(EnumType.name)
  late AppointmentStatus status;

  Appointment({
    this.id = Isar.autoIncrement,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.durationInMinutes = 30,
    this.recurrenceRule,
    this.notes,
    this.source,
    required this.status,
  });

  bool validate() {
    if (doctorName.trim().isEmpty) return false;
    if (specialty.trim().isEmpty) return false;
    if (durationInMinutes <= 0) return false;
    return true;
  }

  bool get isPast => dateTime.isBefore(DateTime.now());
}
