import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

@LazySingleton(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final Isar _isar;

  UserProfileRepositoryImpl(this._isar);

  @override
  Future<UserProfile?> getUserProfile() async {
    return await _isar.userProfiles.where().findFirst();
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _isar.writeTxn(() async {
      await _isar.userProfiles.put(profile);
    });
  }
}
