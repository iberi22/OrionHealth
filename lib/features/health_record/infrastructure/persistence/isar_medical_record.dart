import 'package:isar/isar.dart';

part 'isar_medical_record.g.dart';

@collection
class IsarMedicalRecord {
  Id id = Isar.autoIncrement;

  /// Encrypted blob containing all MedicalRecord fields
  late List<int> encryptedBlob;

  IsarMedicalRecord();
}
