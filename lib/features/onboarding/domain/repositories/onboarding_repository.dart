import '../entities/user_profile.dart';

abstract class OnboardingRepository {
  /// Gets the current onboarding progress (temporary profile)
  Future<UserProfile?> getOnboardingProfile();

  /// Saves the current onboarding progress
  Future<void> saveOnboardingProfile(UserProfile profile);

  /// Completes onboarding, persists the final profile to main storage,
  /// and marks onboarding as finished.
  Future<void> completeOnboarding(UserProfile profile);

  /// Checks if the onboarding process has been completed.
  Future<bool> isOnboardingCompleted();

  /// Resets onboarding status (mainly for testing)
  Future<void> resetOnboarding();
}
