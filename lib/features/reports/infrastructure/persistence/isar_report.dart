import 'package:isar/isar.dart';

part 'isar_report.g.dart';

@collection
class IsarReport {
  Id id = Isar.autoIncrement;

  /// Encrypted blob containing all Report fields
  late List<int> encryptedBlob;

  IsarReport();
}
