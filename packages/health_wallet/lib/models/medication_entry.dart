import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';
import 'lab_result.dart';

part 'medication_entry.g.dart';

/// Medication entry with dosage, frequency, start/end dates.
/// Sensitive: medication name and dosage are encrypted.
@collection
@JsonSerializable()
class MedicationEntry  {
  MedicationEntry({
    this.id = Isar.autoIncrement,
    required this.remoteId,
    required this.rxNormCode,
    required this.medicationName,
    required this.dosage,
    required this.dosageUnit,
    required this.frequency,
    required this.route,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.endDate,
    this.prescribedBy,
    this.pharmacy,
    this.refillsRemaining,
    this.notes,
    this.source = DataSource.manual,
    this.syncStatus = SyncStatus.pending,
    this.encryptedName,
    this.encryptedDosage,
  });

  @Index(unique: true)
  Id id;
  final String remoteId;

  /// RxNorm code for the medication (e.g. "311354" for Metformin 500mg).
  @Index()
  final String rxNormCode;

  /// Medication display name.
  final String medicationName;

  /// Dosage amount (e.g. "500").
  final String dosage;

  /// Dosage unit (e.g. "mg").
  final String dosageUnit;

  /// Frequency description (e.g. "twice daily", "every 8 hours").
  final String frequency;

  /// Route of administration (e.g. "oral", "topical", "injection").
  final String route;

  @Index()
  final DateTime startDate;

  /// null = ongoing medication
  final DateTime? endDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String? prescribedBy;
  final String? pharmacy;
  final int? refillsRemaining;
  final String? notes;

  @Enumerated(EnumType.name)
  final DataSource source;

  @Enumerated(EnumType.name)
  @Index()
  final SyncStatus syncStatus;

  /// Encrypted medication name (base64).
  final String? encryptedName;

  /// Encrypted dosage string (base64).
  final String? encryptedDosage;

  /// Whether this medication is currently active.
  bool get isActive {
    final now = DateTime.now();
    if (endDate != null && endDate!.isBefore(now)) return false;
    return startDate.isBefore(now) || startDate.isAtSameMomentAs(now);
  }

  /// Common medication routes.
  static const commonRoutes = [
    'oral',
    'topical',
    'injection',
    'inhaled',
    'rectal',
    'sublingual',
    'transdermal',
    'IV',
  ];

  MedicationEntry copyWith({
    Id? id,
    String? remoteId,
    String? rxNormCode,
    String? medicationName,
    String? dosage,
    String? dosageUnit,
    String? frequency,
    String? route,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? prescribedBy,
    String? pharmacy,
    int? refillsRemaining,
    String? notes,
    DataSource? source,
    SyncStatus? syncStatus,
    String? encryptedName,
    String? encryptedDosage,
  }) {
    return MedicationEntry(
      remoteId: remoteId ?? this.remoteId,
      id: id ?? this.id,
      rxNormCode: rxNormCode ?? this.rxNormCode,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      frequency: frequency ?? this.frequency,
      route: route ?? this.route,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      pharmacy: pharmacy ?? this.pharmacy,
      refillsRemaining: refillsRemaining ?? this.refillsRemaining,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      syncStatus: syncStatus ?? this.syncStatus,
      encryptedName: encryptedName ?? this.encryptedName,
      encryptedDosage: encryptedDosage ?? this.encryptedDosage,
    );
  }

  factory MedicationEntry.fromJson(Map<String, dynamic> json) =>
      _$MedicationEntryFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationEntryToJson(this);

}
