import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';
import 'lab_result.dart';

/// Medication entry with dosage, frequency, start/end dates.
/// Sensitive: medication name and dosage are encrypted.
@collection
class MedicationEntry extends Equatable {
  MedicationEntry({
    required this.id,
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
  final String id;

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

  String? prescribedBy;
  String? pharmacy;
  int? refillsRemaining;
  String? notes;

  @Enumerated(EnumType.name)
  final DataSource source;

  @Enumerated(EnumType.name)
  @Index()
  SyncStatus syncStatus;

  /// Encrypted medication name (base64).
  String? encryptedName;

  /// Encrypted dosage string (base64).
  String? encryptedDosage;

  /// Whether this medication is currently active.
  @ignore
  bool get isActive {
    final now = DateTime.now();
    if (endDate != null && endDate!.isBefore(now)) return false;
    return startDate.isBefore(now) || startDate.isAtSameMomentAs(now);
  }

  /// Common medication routes.
  @ignore
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
    String? id,
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

  @override
  List<Object?> get props => [
        id,
        rxNormCode,
        medicationName,
        dosage,
        dosageUnit,
        frequency,
        route,
        startDate,
        endDate,
        createdAt,
        updatedAt,
        prescribedBy,
        pharmacy,
        refillsRemaining,
        notes,
        source,
        syncStatus,
        encryptedName,
        encryptedDosage,
      ];
}
