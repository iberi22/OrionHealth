import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';
import 'lab_result.dart';

part 'medical_concept.g.dart';

/// Medical Concept representing professional notes and recommendations.
@collection
@JsonSerializable()
class MedicalConcept {
  MedicalConcept({
    this.id = Isar.autoIncrement,
    required this.remoteId,
    required this.doctorName,
    this.professionalLicense,
    required this.notes,
    this.recommendations,
    required this.conceptDate,
    required this.createdAt,
    required this.updatedAt,
    this.source = DataSource.manual,
    this.syncStatus = SyncStatus.pending,
  });

  @Index(unique: true)
  Id id;
  final String remoteId;

  final String doctorName;
  final String? professionalLicense;

  /// Professional clinical notes
  final String notes;

  /// Specific medical recommendations
  final String? recommendations;

  /// Date of the consultation or note
  @Index()
  final DateTime conceptDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  @Enumerated(EnumType.name)
  final DataSource source;

  @Enumerated(EnumType.name)
  @Index()
  final SyncStatus syncStatus;

  MedicalConcept copyWith({
    Id? id,
    String? remoteId,
    String? doctorName,
    String? professionalLicense,
    String? notes,
    String? recommendations,
    DateTime? conceptDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DataSource? source,
    SyncStatus? syncStatus,
  }) {
    return MedicalConcept(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      doctorName: doctorName ?? this.doctorName,
      professionalLicense: professionalLicense ?? this.professionalLicense,
      notes: notes ?? this.notes,
      recommendations: recommendations ?? this.recommendations,
      conceptDate: conceptDate ?? this.conceptDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  factory MedicalConcept.fromJson(Map<String, dynamic> json) =>
      _$MedicalConceptFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalConceptToJson(this);
}
