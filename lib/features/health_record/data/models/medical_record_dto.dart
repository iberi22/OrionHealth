import '../../domain/entities/medical_record.dart';
import '../../domain/entities/medical_attachment.dart';

/// Data transfer object for [MedicalRecord] with JSON serialization.
///
/// Mirrors the domain entity fields: id, date, type, summary, attachments.
class MedicalRecordDto {
  final int? id;
  final DateTime? date;
  final RecordType type;
  final String? summary;
  final List<MedicalAttachmentDto> attachments;

  const MedicalRecordDto({
    this.id,
    this.date,
    this.type = RecordType.other,
    this.summary,
    this.attachments = const [],
  });

  factory MedicalRecordDto.fromEntity(MedicalRecord e) => MedicalRecordDto(
        id: e.id,
        date: e.date,
        type: e.type,
        summary: e.summary,
        attachments: (e.attachments ?? [])
            .map((a) => MedicalAttachmentDto.fromEntity(a))
            .toList(),
      );

  MedicalRecord toEntity() => MedicalRecord(
        date: date,
        type: type,
        summary: summary,
        attachments: attachments.map((a) => a.toEntity()).toList(),
      )..id = id;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (date != null) 'date': date!.toIso8601String(),
        'type': type.name,
        if (summary != null) 'summary': summary,
        'attachments': attachments.map((a) => a.toJson()).toList(),
      };

  factory MedicalRecordDto.fromJson(Map<String, dynamic> json) =>
      MedicalRecordDto(
        id: json['id'] as int?,
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : null,
        type: RecordType.values.byName(
            json['type'] as String? ?? RecordType.other.name),
        summary: json['summary'] as String?,
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((e) => MedicalAttachmentDto.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// Data transfer object for [MedicalAttachment] with JSON serialization.
class MedicalAttachmentDto {
  final String? localPath;
  final String? mimeType;
  final String? extractedText;

  const MedicalAttachmentDto({
    this.localPath,
    this.mimeType,
    this.extractedText,
  });

  factory MedicalAttachmentDto.fromEntity(MedicalAttachment e) =>
      MedicalAttachmentDto(
        localPath: e.localPath,
        mimeType: e.mimeType,
        extractedText: e.extractedText,
      );

  MedicalAttachment toEntity() => MedicalAttachment(
        localPath: localPath,
        mimeType: mimeType,
        extractedText: extractedText,
      );

  Map<String, dynamic> toJson() => {
        if (localPath != null) 'localPath': localPath,
        if (mimeType != null) 'mimeType': mimeType,
        if (extractedText != null) 'extractedText': extractedText,
      };

  factory MedicalAttachmentDto.fromJson(Map<String, dynamic> json) =>
      MedicalAttachmentDto(
        localPath: json['localPath'] as String?,
        mimeType: json['mimeType'] as String?,
        extractedText: json['extractedText'] as String?,
      );
}
