import 'package:injectable/injectable.dart';
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

@injectable
class GetUserProfileUseCase {
  final UserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfile?> call() async {
    return repository.getUserProfile();
  }
}
