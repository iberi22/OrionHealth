import '../../domain/entities/appointment.dart';

class AppointmentDto {
  final int? id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final int durationInMinutes;
  final String? recurrenceRule;
  final String? notes;
  final String? source;
  final String status;

  const AppointmentDto({
    this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.durationInMinutes = 30,
    this.recurrenceRule,
    this.notes,
    this.source,
    required this.status,
  });

  factory AppointmentDto.fromEntity(Appointment entity) {
    return AppointmentDto(
      id: entity.id,
      doctorName: entity.doctorName,
      specialty: entity.specialty,
      dateTime: entity.dateTime,
      durationInMinutes: entity.durationInMinutes,
      recurrenceRule: entity.recurrenceRule,
      notes: entity.notes,
      source: entity.source,
      status: entity.status.name,
    );
  }

  Appointment toEntity() {
    return Appointment(
      id: id ?? 0,
      doctorName: doctorName,
      specialty: specialty,
      dateTime: dateTime,
      durationInMinutes: durationInMinutes,
      recurrenceRule: recurrenceRule,
      notes: notes,
      source: source,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => AppointmentStatus.upcoming,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'dateTime': dateTime.toIso8601String(),
      'durationInMinutes': durationInMinutes,
      'recurrenceRule': recurrenceRule,
      'notes': notes,
      'source': source,
      'status': status,
    };
  }

  factory AppointmentDto.fromJson(Map<String, dynamic> json) {
    return AppointmentDto(
      id: json['id'] as int?,
      doctorName: json['doctorName'] as String,
      specialty: json['specialty'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      durationInMinutes: json['durationInMinutes'] as int? ?? 30,
      recurrenceRule: json['recurrenceRule'] as String?,
      notes: json['notes'] as String?,
      source: json['source'] as String?,
      status: json['status'] as String? ?? 'upcoming',
    );
  }
}
