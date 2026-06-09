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
class MedicalRecord {
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date &&
          type == other.type &&
          summary == other.summary &&
          _listEquals(attachments, other.attachments);

  @override
  int get hashCode =>
      id.hashCode ^ date.hashCode ^ type.hashCode ^ summary.hashCode ^ _listHashCode(attachments);

  bool _listEquals(List<MedicalAttachment> a, List<MedicalAttachment> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _listHashCode(List<MedicalAttachment> list) {
    return list.fold(0, (hash, item) => hash ^ item.hashCode);
  }
}
