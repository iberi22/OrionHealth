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

  Map<String, dynamic> toJson() => {
        'localPath': localPath,
        'mimeType': mimeType,
        'extractedText': extractedText,
      };

  factory MedicalAttachment.fromJson(Map<String, dynamic> json) {
    return MedicalAttachment(
      localPath: json['localPath'] as String?,
      mimeType: json['mimeType'] as String?,
      extractedText: json['extractedText'] as String?,
    );
  }

  bool get isValid => localPath != null && localPath!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalAttachment &&
          runtimeType == other.runtimeType &&
          localPath == other.localPath &&
          mimeType == other.mimeType &&
          extractedText == other.extractedText;

  @override
  int get hashCode => localPath.hashCode ^ mimeType.hashCode ^ extractedText.hashCode;
}
