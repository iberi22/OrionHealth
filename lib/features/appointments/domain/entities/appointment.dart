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
  String? notes;
  String? source;

  @Enumerated(EnumType.name)
  late AppointmentStatus status;

  Appointment({
    this.id = Isar.autoIncrement,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.notes,
    this.source,
    required this.status,
  });
}
