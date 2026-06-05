import 'package:injectable/injectable.dart';
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

@lazySingleton
class UserProfileService {
  final UserProfileRepository _repository;

  UserProfileService(this._repository);

  Future<UserProfile?> getProfile() async {
    return await _repository.getUserProfile();
  }

  Future<void> updateProfile(UserProfile profile) async {
    if (!profile.validate()) {
      throw Exception('Invalid profile data');
    }
    await _repository.saveUserProfile(profile);
  }

  Future<void> deleteProfile() async {
    await _repository.deleteUserProfile();
  }
}
