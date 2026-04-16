import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';
import 'lab_result.dart';

part 'medical_document.g.dart';

/// Document type for classification.
enum DocumentType {
  @JsonValue('lab_report')
  labReport,
  @JsonValue('imaging')
  imaging,
  @JsonValue('prescription')
  prescription,
  @JsonValue('discharge_summary')
  dischargeSummary,
  @JsonValue('visit_note')
  visitNote,
  @JsonValue('insurance')
  insurance,
  @JsonValue('referral')
  referral,
  @JsonValue('other')
  other,
}

/// Medical document reference (PDF, image, etc.).
@collection
@JsonSerializable()
class MedicalDocument {
  MedicalDocument({
    required this.id,
    required this.title,
    required this.documentType,
    required this.filePath,
    required this.mimeType,
    required this.createdAt,
    required this.updatedAt,
    this.documentDate,
    this.provider,
    this.facility,
    this.icd10Codes,
    this.loincCodes,
    this.notes,
    this.source = DataSource.manual,
    this.syncStatus = SyncStatus.pending,
    this.encryptedMetadata,
  });
  Id id = Isar.autoIncrement;

  final String title;

  @Enumerated(EnumType.name)
  @Index()
  final DocumentType documentType;

  /// Local path or remote URL to the document file.
  final String filePath;

  /// MIME type (e.g. "application/pdf", "image/jpeg").
  final String mimeType;

  /// Date of the document (e.g. visit date, lab date).
  @Index()
  final DateTime? documentDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String? provider; // physician name
  final String? facility; // hospital/clinic name
  final List<String>? icd10Codes; // diagnoses coded
  final List<String>? loincCodes; // associated LOINC tests
  final String? notes;

  @Enumerated(EnumType.name)
  final DataSource source;

  @Enumerated(EnumType.name)
  @Index()
  final SyncStatus syncStatus;

  /// Encrypted document metadata (base64).
  final String? encryptedMetadata;

  /// File extension derived from mime type.
  @ignore
  String get fileExtension {
    switch (mimeType) {
      case 'application/pdf':
        return '.pdf';
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/dicom':
        return '.dcm';
      default:
        return '';
    }
  }

  MedicalDocument copyWith({
    int? id,
    String? title,
    DocumentType? documentType,
    String? filePath,
    String? mimeType,
    DateTime? documentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? provider,
    String? facility,
    List<String>? icd10Codes,
    List<String>? loincCodes,
    String? notes,
    DataSource? source,
    SyncStatus? syncStatus,
    String? encryptedMetadata,
  }) {
    return MedicalDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      filePath: filePath ?? this.filePath,
      mimeType: mimeType ?? this.mimeType,
      documentDate: documentDate ?? this.documentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      provider: provider ?? this.provider,
      facility: facility ?? this.facility,
      icd10Codes: icd10Codes ?? this.icd10Codes,
      loincCodes: loincCodes ?? this.loincCodes,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      syncStatus: syncStatus ?? this.syncStatus,
      encryptedMetadata: encryptedMetadata ?? this.encryptedMetadata,
    );
  }

  factory MedicalDocument.fromJson(Map<String, dynamic> json) =>
      _$MedicalDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalDocumentToJson(this);

}
