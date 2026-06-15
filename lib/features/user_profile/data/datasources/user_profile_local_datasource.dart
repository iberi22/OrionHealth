import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/user_profile.dart';

@lazySingleton
class UserProfileLocalDataSource {
  final Isar _isar;
  UserProfileLocalDataSource(this._isar);

  Future<UserProfile?> getUserProfile() =>
      _isar.userProfiles.where().findFirst();

  Future<void> saveUserProfile(UserProfile p) =>
      _isar.writeTxn(() async => _isar.userProfiles.put(p));

  Future<void> deleteUserProfile() =>
      _isar.writeTxn(() async => _isar.userProfiles.clear());
}
