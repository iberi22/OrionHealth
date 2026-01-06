import 'package:isar/isar.dart';

part 'medication.g.dart';

enum MedicationFrequency {
  onceDaily,
  twiceDaily,
  threeTimesDaily,
  fourTimesDaily,
  everyOtherDay,
  weekly,
  asNeeded,
  custom,
}

enum MedicationStatus {
  active,
  completed,
  paused,
  discontinued,
}

@collection
class Medication {
  Id id = Isar.autoIncrement;

  String? name;

  String? dosage; // e.g., "20mg"

  @enumerated
  MedicationFrequency frequency = MedicationFrequency.onceDaily;

  @enumerated
  MedicationStatus status = MedicationStatus.active;

  String? instructions; // e.g., "Tomar con comida"

  DateTime? startDate;

  DateTime? endDate;

  String? prescribedBy;

  String? reason; // Why the medication was prescribed

  String? notes;

  int? remainingDoses;

  Medication({
    this.name,
    this.dosage,
    this.frequency = MedicationFrequency.onceDaily,
    this.status = MedicationStatus.active,
    this.instructions,
    this.startDate,
    this.endDate,
    this.prescribedBy,
    this.reason,
    this.notes,
    this.remainingDoses,
  });

  Medication copyWith({
    String? name,
    String? dosage,
    MedicationFrequency? frequency,
    MedicationStatus? status,
    String? instructions,
    DateTime? startDate,
    DateTime? endDate,
    String? prescribedBy,
    String? reason,
    String? notes,
    int? remainingDoses,
  }) {
    return Medication(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      remainingDoses: remainingDoses ?? this.remainingDoses,
    )..id = this.id;
  }

  /// Check if the medication is currently active
  bool get isActive {
    if (status != MedicationStatus.active) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  /// Get display label for the frequency
  String get frequencyLabel {
    switch (frequency) {
      case MedicationFrequency.onceDaily:
        return 'Diario';
      case MedicationFrequency.twiceDaily:
        return '2 veces al día';
      case MedicationFrequency.threeTimesDaily:
        return '3 veces al día';
      case MedicationFrequency.fourTimesDaily:
        return '4 veces al día';
      case MedicationFrequency.everyOtherDay:
        return 'Cada 2 días';
      case MedicationFrequency.weekly:
        return 'Semanal';
      case MedicationFrequency.asNeeded:
        return 'Según necesidad';
      case MedicationFrequency.custom:
        return 'Personalizado';
    }
  }

  /// Get display label for the status
  String get statusLabel {
    switch (status) {
      case MedicationStatus.active:
        return 'Activo';
      case MedicationStatus.completed:
        return 'Completado';
      case MedicationStatus.paused:
        return 'Pausado';
      case MedicationStatus.discontinued:
        return 'Discontinuado';
    }
  }

  /// Get formatted display string (name + dosage)
  String get displayName {
    if (dosage != null && dosage!.isNotEmpty) {
      return '$name $dosage';
    }
    return name ?? '';
  }

  @override
  String toString() {
    return 'Medication(id: $id, name: $name, dosage: $dosage, frequency: $frequency, status: $status)';
  }
}
