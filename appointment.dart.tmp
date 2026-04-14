import 'package:isar/isar.dart';

part 'appointment.g.dart';

enum AppointmentStatus { scheduled, confirmed, completed, cancelled, noShow }

enum AppointmentType {
  consultation,
  followUp,
  checkup,
  emergency,
  telemedicine,
  laboratory,
  imaging,
}

@collection
class Appointment {
  Id id = Isar.autoIncrement;

  String? doctorName;

  String? specialty;

  DateTime? dateTime;

  @enumerated
  AppointmentStatus status = AppointmentStatus.scheduled;

  @enumerated
  AppointmentType type = AppointmentType.consultation;

  String? location;

  String? notes;

  int? durationMinutes;

  String? reminderSent; // ISO date string of when reminder was sent

  Appointment({
    this.doctorName,
    this.specialty,
    this.dateTime,
    this.status = AppointmentStatus.scheduled,
    this.type = AppointmentType.consultation,
    this.location,
    this.notes,
    this.durationMinutes,
    this.reminderSent,
  });

  Appointment copyWith({
    String? doctorName,
    String? specialty,
    DateTime? dateTime,
    AppointmentStatus? status,
    AppointmentType? type,
    String? location,
    String? notes,
    int? durationMinutes,
    String? reminderSent,
  }) {
    return Appointment(
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      type: type ?? this.type,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      reminderSent: reminderSent ?? this.reminderSent,
    )..id = this.id;
  }

  /// Check if the appointment is upcoming (in the future)
  bool get isUpcoming {
    if (dateTime == null) return false;
    return dateTime!.isAfter(DateTime.now()) &&
        status != AppointmentStatus.cancelled &&
        status != AppointmentStatus.completed;
  }

  /// Check if the appointment is past
  bool get isPast {
    if (dateTime == null) return false;
    return dateTime!.isBefore(DateTime.now());
  }

  /// Get display label for the status
  String get statusLabel {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Programada';
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.noShow:
        return 'No asistió';
    }
  }

  /// Get display label for the type
  String get typeLabel {
    switch (type) {
      case AppointmentType.consultation:
        return 'Consulta';
      case AppointmentType.followUp:
        return 'Seguimiento';
      case AppointmentType.checkup:
        return 'Chequeo';
      case AppointmentType.emergency:
        return 'Emergencia';
      case AppointmentType.telemedicine:
        return 'Telemedicina';
      case AppointmentType.laboratory:
        return 'Laboratorio';
      case AppointmentType.imaging:
        return 'Imágenes';
    }
  }

  @override
  String toString() {
    return 'Appointment(id: $id, doctorName: $doctorName, specialty: $specialty, dateTime: $dateTime, status: $status)';
  }
}
