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

  String? location;

  @Enumerated(EnumType.name)
  late AppointmentStatus status;

  String? notes;

  Appointment({
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.location,
    required this.status,
    this.notes,
  });
}
