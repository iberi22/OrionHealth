import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';
import 'lab_result.dart';

part 'medical_event.g.dart';

/// Event type for classification.
enum EventType {
  @JsonValue('appointment')
  appointment,
  @JsonValue('procedure')
  procedure,
  @JsonValue('hospitalization')
  hospitalization,
  @JsonValue('emergency')
  emergency,
  @JsonValue('telehealth')
  telehealth,
  @JsonValue('lab_visit')
  labVisit,
  @JsonValue('vaccination')
  vaccination,
  @JsonValue('wellness_check')
  wellnessCheck,
}

/// Generic medical event (appointment, procedure, hospital visit).
@collection
@JsonSerializable()
class MedicalEvent {
  MedicalEvent({
    required this.id,
    required this.eventType,
    required this.description,
    required this.eventDate,
    required this.createdAt,
    required this.updatedAt,
    this.endDate,
    this.provider,
    this.facility,
    this.icd10Codes,
    this.cptCodes,
    this.loincCodes,
    this.notes,
    this.source = DataSource.manual,
    this.syncStatus = SyncStatus.pending,
    this.encryptedNotes,
  });
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  @Index()
  final EventType eventType;

  final String description;

  /// Primary event date/time.
  @Index()
  final DateTime eventDate;

  /// For procedures/hospitalizations with duration.
  final DateTime? endDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String? provider; // physician name
  final String? facility; // hospital/clinic name
  final List<String>? icd10Codes; // ICD-10 diagnosis codes
  final List<String>? cptCodes; // CPT procedure codes
  final List<String>? loincCodes; // associated lab tests
  final String? notes;

  @Enumerated(EnumType.name)
  final DataSource source;

  @Enumerated(EnumType.name)
  @Index()
  final SyncStatus syncStatus;

  /// Encrypted notes field (base64).
  final String? encryptedNotes;

  /// Whether the event has ended (for procedures/hospitalizations).
  @ignore
  bool get hasEnded => endDate != null;

  /// Duration in hours (if endDate is set).
  @ignore
  double? get durationHours {
    if (endDate == null) return null;
    return endDate!.difference(eventDate).inMinutes / 60.0;
  }

  MedicalEvent copyWith({
    int? id,
    EventType? eventType,
    String? description,
    DateTime? eventDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? provider,
    String? facility,
    List<String>? icd10Codes,
    List<String>? cptCodes,
    List<String>? loincCodes,
    String? notes,
    DataSource? source,
    SyncStatus? syncStatus,
    String? encryptedNotes,
  }) {
    return MedicalEvent(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      provider: provider ?? this.provider,
      facility: facility ?? this.facility,
      icd10Codes: icd10Codes ?? this.icd10Codes,
      cptCodes: cptCodes ?? this.cptCodes,
      loincCodes: loincCodes ?? this.loincCodes,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      syncStatus: syncStatus ?? this.syncStatus,
      encryptedNotes: encryptedNotes ?? this.encryptedNotes,
    );
  }

  factory MedicalEvent.fromJson(Map<String, dynamic> json) =>
      _$MedicalEventFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalEventToJson(this);

}
