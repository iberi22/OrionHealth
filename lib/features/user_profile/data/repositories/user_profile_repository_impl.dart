import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_local_datasource.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileLocalDataSource _localDataSource;
  UserProfileRepositoryImpl(this._localDataSource);

  @override
  Future<UserProfile?> getUserProfile() => _localDataSource.getUserProfile();
  @override
  Future<void> saveUserProfile(UserProfile p) => _localDataSource.saveUserProfile(p);
  @override
  Future<void> deleteUserProfile() => _localDataSource.deleteUserProfile();
}
