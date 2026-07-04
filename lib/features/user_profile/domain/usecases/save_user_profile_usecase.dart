import 'package:injectable/injectable.dart';
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

@injectable
class SaveUserProfileUseCase {
  final UserProfileRepository repository;

  SaveUserProfileUseCase(this.repository);

  Future<void> call(UserProfile profile) async {
    return repository.saveUserProfile(profile);
  }
}
