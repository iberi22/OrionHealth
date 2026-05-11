import 'package:isar/isar.dart';

part 'isar_credential.g.dart';

@collection
class IsarCredential {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String credentialId;

  late String issuer;

  late String subject;

  late String type;

  late String schemaId;

  /// Claims stored as JSON string for maximum flexibility
  late String claimsJson;

  late DateTime issuanceDate;

  DateTime? expirationDate;

  String? proof;

  bool isRevoked = false;

  IsarCredential();
}
