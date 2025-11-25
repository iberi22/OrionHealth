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
}
