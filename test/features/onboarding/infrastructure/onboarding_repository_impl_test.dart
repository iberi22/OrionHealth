import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart' as onboarding;
import 'package:orionhealth_health/features/onboarding/infrastructure/onboarding_repository_impl.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart' as domain;
import 'package:shared_preferences/shared_preferences.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

class FakeUserProfile extends Fake implements domain.UserProfile {}

void main() {
  late OnboardingRepositoryImpl repository;
  late MockUserProfileRepository mockUserProfileRepository;

  setUpAll(() {
    registerFallbackValue(FakeUserProfile());
  });

  setUp(() {
    mockUserProfileRepository = MockUserProfileRepository();
    repository = OnboardingRepositoryImpl(mockUserProfileRepository);
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingRepositoryImpl', () {
    final now = DateTime.now();
    final sampleOnboardingProfile = onboarding.UserProfile(
      name: 'Test User',
      createdAt: now,
      updatedAt: now,
    );

    test('getOnboardingProfile returns null when no profile is saved', () async {
      final profile = await repository.getOnboardingProfile();
      expect(profile, isNull);
    });

    test('saveOnboardingProfile and getOnboardingProfile work correctly', () async {
      await repository.saveOnboardingProfile(sampleOnboardingProfile);
      final profile = await repository.getOnboardingProfile();

      expect(profile?.name, equals(sampleOnboardingProfile.name));
    });

    test('isOnboardingCompleted returns false by default', () async {
      final completed = await repository.isOnboardingCompleted();
      expect(completed, isFalse);
    });

    test('completeOnboarding saves to domain repository and marks as completed', () async {
      when(() => mockUserProfileRepository.saveUserProfile(any()))
          .thenAnswer((_) async {});

      await repository.completeOnboarding(sampleOnboardingProfile);

      verify(() => mockUserProfileRepository.saveUserProfile(any())).called(1);

      final completed = await repository.isOnboardingCompleted();
      expect(completed, isTrue);

      final onboardingProfile = await repository.getOnboardingProfile();
      expect(onboardingProfile, isNull);
    });

    test('resetOnboarding clears state and deletes domain profile', () async {
      when(() => mockUserProfileRepository.deleteUserProfile())
          .thenAnswer((_) async {});

      await repository.saveOnboardingProfile(sampleOnboardingProfile);
      await repository.resetOnboarding();

      final completed = await repository.isOnboardingCompleted();
      expect(completed, isFalse);

      final onboardingProfile = await repository.getOnboardingProfile();
      expect(onboardingProfile, isNull);

      verify(() => mockUserProfileRepository.deleteUserProfile()).called(1);
    });
  });
}
