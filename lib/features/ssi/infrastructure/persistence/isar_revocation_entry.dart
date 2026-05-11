import 'package:isar/isar.dart';

part 'isar_revocation_entry.g.dart';

@collection
class IsarRevocationEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late String credentialId;

  /// Composite index for fast non-revocation checks
  @Index(composite: [IndexColumn('credentialIndex')])
  late String issuerPublicKey;

  late int credentialIndex;

  late DateTime revokedAt;

  late String issuerSignature;

  IsarRevocationEntry();
}
