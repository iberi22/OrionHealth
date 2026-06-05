import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'medical_attachment.dart';

part 'medical_record.g.dart';

enum RecordType {
  labResult,
  prescription,
  clinicalNote,
  other,
}

@collection
class MedicalRecord with EquatableMixin {
  Id id = Isar.autoIncrement;

  DateTime? date;

  @Enumerated(EnumType.name)
  RecordType type;

  String? summary;

  List<MedicalAttachment> attachments;

  MedicalRecord({
    this.date,
    this.type = RecordType.other,
    this.summary,
    this.attachments = const [],
  });

  @override
  List<Object?> get props => [id, date, type, summary, attachments];

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date?.toIso8601String(),
        'type': type.name,
        'summary': summary,
        'attachments': attachments.map((a) => a.toJson()).toList(),
      };

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      type: RecordType.values.byName(json['type'] as String),
      summary: json['summary'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => MedicalAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    )..id = json['id'] as int? ?? Isar.autoIncrement;
  }

  bool get isValid => attachments.every((a) => a.isValid);
}
