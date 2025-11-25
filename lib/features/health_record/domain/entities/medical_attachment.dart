import 'package:isar/isar.dart';

part 'medical_attachment.g.dart';

@embedded
class MedicalAttachment {
  String? localPath;
  String? mimeType;
  String? extractedText;

  MedicalAttachment({
    this.localPath,
    this.mimeType,
    this.extractedText,
  });
}
