import '../../domain/entities/appointment.dart';

class AppointmentDto {
  final int? id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String? source;
  final String? notes;

  const AppointmentDto({
    this.id, required this.doctorName, required this.specialty,
    required this.dateTime, required this.status, this.source, this.notes,
  });

  factory AppointmentDto.fromEntity(Appointment e) => AppointmentDto(
    id: e.id, doctorName: e.doctorName, specialty: e.specialty,
    dateTime: e.dateTime, status: e.status, source: e.source, notes: e.notes,
  );

  Appointment toEntity() => Appointment(
    id: id, doctorName: doctorName, specialty: specialty,
    dateTime: dateTime, status: status, source: source, notes: notes,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id, 'doctorName': doctorName,
    'specialty': specialty, 'dateTime': dateTime.toIso8601String(),
    'status': status.name, if (source != null) 'source': source,
    if (notes != null) 'notes': notes,
  };

  factory AppointmentDto.fromJson(Map<String, dynamic> j) => AppointmentDto(
    id: j['id'] as int?, doctorName: j['doctorName'] as String,
    specialty: j['specialty'] as String, dateTime: DateTime.parse(j['dateTime'] as String),
    status: AppointmentStatus.values.firstWhere((s) => s.name == j['status']),
    source: j['source'] as String?, notes: j['notes'] as String?,
  );
}
