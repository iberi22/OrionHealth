import 'package:injectable/injectable.dart';
import '../entities/user_profile.dart';
import '../repositories/onboarding_repository.dart';

@injectable
class GetOnboardingProfileUseCase {
  final OnboardingRepository repository;

  GetOnboardingProfileUseCase(this.repository);

  Future<UserProfile?> call() async {
    return repository.getOnboardingProfile();
  }
}
