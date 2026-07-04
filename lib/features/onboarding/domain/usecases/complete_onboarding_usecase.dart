import 'package:injectable/injectable.dart';
import '../entities/user_profile.dart';
import '../repositories/onboarding_repository.dart';

@injectable
class CompleteOnboardingUseCase {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  Future<void> call(UserProfile profile) async {
    return repository.completeOnboarding(profile);
  }
}
