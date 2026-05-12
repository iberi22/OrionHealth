import 'dart:convert';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../persistence/isar_user_profile.dart';
import '../../../auth/infrastructure/services/encryption_service.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final Isar _isar;
  final EncryptionService _encryptionService;

  UserProfileRepositoryImpl(this._isar, this._encryptionService);

  @override
  Future<UserProfile?> getUserProfile() async {
    final isarProfile = await _isar.isarUserProfiles.where().findFirst();
    if (isarProfile == null) return null;

    final decryptedData = await _encryptionService.decrypt(Uint8List.fromList(isarProfile.encryptedBlob));
    return UserProfile.fromMap(jsonDecode(decryptedData) as Map<String, dynamic>);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final encryptedData = await _encryptionService.encrypt(jsonEncode(profile.toMap()));

    await _isar.writeTxn(() async {
      final isarProfile = IsarUserProfile()
        ..id = profile.id != 0 ? profile.id : Isar.autoIncrement
        ..encryptedBlob = encryptedData.toList();

      final id = await _isar.isarUserProfiles.put(isarProfile);
      profile.id = id;
    });
  }
}
