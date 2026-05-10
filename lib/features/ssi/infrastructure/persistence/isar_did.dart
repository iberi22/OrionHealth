import 'package:isar/isar.dart';

part 'isar_did.g.dart';

@collection
class IsarDid {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String did;

  String? shortForm;

  late String longForm;

  late DateTime createdAt;

  bool isAnchored = false;

  late String keyType;

  /// Full DID Document stored as JSON string
  String? didDocumentJson;

  IsarDid();
}
