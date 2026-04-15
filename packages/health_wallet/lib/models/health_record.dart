import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';
import 'lab_result.dart';
import 'vital_sign.dart';
import 'medication_entry.dart';
import 'medical_document.dart';
import 'medical_event.dart';

part 'health_record.g.dart';

/// Aggregated patient health record model.
/// Contains references to all health data sub-collections.
@collection
class HealthRecord extends Equatable {
  HealthRecord({
    required this.id,
    required this.patientId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
    this.allergies,
    this.conditions,
    this.bloodType,
    this.organDonor,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.primaryPhysician,
    this.syncStatus = SyncStatus.pending,
    this.encryptedSensitiveFields,
  });

  @Index(unique: true)
  final String id;

  /// External patient identifier.
  @Index()
  final String patientId;

  final String firstName;
  final String lastName;

  /// ISO 8601 date string (e.g. "1985-03-15").
  @Index()
  final String dateOfBirth;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Known allergies (e.g. ["Penicillin", "Peanuts"]).
  List<String>? allergies;

  /// Active conditions/diagnoses (stored as ICD-10 codes).
  List<String>? conditions;

  /// Blood type (e.g. "A+", "O-").
  String? bloodType;

  bool? organDonor;

  String? emergencyContactName;
  String? emergencyContactPhone;
  String? primaryPhysician;

  @Enumerated(EnumType.name)
  @Index()
  SyncStatus syncStatus;

  /// AES-256-GCM encrypted bundle of sensitive fields (base64).
  /// Contains: firstName, lastName, dateOfBirth, allergies, conditions.
  String? encryptedSensitiveFields;

  /// Computed full name.
  @ignore
  String get fullName => '$firstName $lastName';

  /// Compute approximate age from dateOfBirth.
  @ignore
  int get approximateAge {
    final parts = dateOfBirth.split('-');
    if (parts.length != 3) return 0;
    final birth = DateTime.tryParse(dateOfBirth);
    if (birth == null) return 0;
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  HealthRecord copyWith({
    String? id,
    String? patientId,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? allergies,
    List<String>? conditions,
    String? bloodType,
    bool? organDonor,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? primaryPhysician,
    SyncStatus? syncStatus,
    String? encryptedSensitiveFields,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      bloodType: bloodType ?? this.bloodType,
      organDonor: organDonor ?? this.organDonor,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      primaryPhysician: primaryPhysician ?? this.primaryPhysician,
      syncStatus: syncStatus ?? this.syncStatus,
      encryptedSensitiveFields: encryptedSensitiveFields ?? this.encryptedSensitiveFields,
    );
  }

  factory HealthRecord.fromJson(Map<String, dynamic> json) =>
      _$HealthRecordFromJson(json);
  Map<String, dynamic> toJson() => _$HealthRecordToJson(this);

  @override
  List<Object?> get props => [
        id,
        patientId,
        firstName,
        lastName,
        dateOfBirth,
        createdAt,
        updatedAt,
        allergies,
        conditions,
        bloodType,
        organDonor,
        emergencyContactName,
        emergencyContactPhone,
        primaryPhysician,
        syncStatus,
        encryptedSensitiveFields,
      ];
}
