import 'package:equatable/equatable.dart';

enum AdherenceStatus {
  taken,
  skipped,
  missed,
  scheduled,
}

class MedicationAdherence extends Equatable {
  final int? id;
  final int medicationId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final AdherenceStatus status;
  final String? notes;

  const MedicationAdherence({
    this.id,
    required this.medicationId,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.notes,
  });

  MedicationAdherence copyWith({
    int? id,
    int? medicationId,
    DateTime? scheduledTime,
    DateTime? takenTime,
    AdherenceStatus? status,
    String? notes,
  }) {
    return MedicationAdherence(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        medicationId,
        scheduledTime,
        takenTime,
        status,
        notes,
      ];
}
