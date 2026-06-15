import '../../domain/entities/medication.dart';

class MedicationDto {
  final int? id;
  final String name;
  final String? dosage;
  final String? frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  const MedicationDto({
    this.id, required this.name, this.dosage, this.frequency,
    this.startDate, this.endDate, this.notes,
  });

  factory MedicationDto.fromEntity(Medication e) => MedicationDto(
    id: e.id, name: e.name, dosage: e.dosage, frequency: e.frequency,
    startDate: e.startDate, endDate: e.endDate, notes: e.notes,
  );

  Medication toEntity() => Medication(
    id: id, name: name, dosage: dosage, frequency: frequency,
    startDate: startDate, endDate: endDate, notes: notes,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id, 'name': name, if (dosage != null) 'dosage': dosage,
    if (frequency != null) 'frequency': frequency,
    if (startDate != null) 'startDate': startDate!.toIso8601String(),
    if (endDate != null) 'endDate': endDate!.toIso8601String(),
    if (notes != null) 'notes': notes,
  };

  factory MedicationDto.fromJson(Map<String, dynamic> j) => MedicationDto(
    id: j['id'] as int?, name: j['name'] as String, dosage: j['dosage'] as String?,
    frequency: j['frequency'] as String?,
    startDate: j['startDate'] != null ? DateTime.parse(j['startDate'] as String) : null,
    endDate: j['endDate'] != null ? DateTime.parse(j['endDate'] as String) : null,
    notes: j['notes'] as String?,
  );
}
