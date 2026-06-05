import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

part 'medical_attachment.g.dart';

@embedded
class MedicalAttachment with EquatableMixin {
  String? localPath;
  String? mimeType;
  String? extractedText;

  MedicalAttachment({
    this.localPath,
    this.mimeType,
    this.extractedText,
  });

  @override
  List<Object?> get props => [localPath, mimeType, extractedText];

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
}
