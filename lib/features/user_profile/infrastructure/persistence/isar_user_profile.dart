import 'package:isar/isar.dart';

part 'isar_user_profile.g.dart';

@collection
class IsarUserProfile {
  Id id = Isar.autoIncrement;

  /// Encrypted blob containing all UserProfile fields
  late List<int> encryptedBlob;

  IsarUserProfile();
}
