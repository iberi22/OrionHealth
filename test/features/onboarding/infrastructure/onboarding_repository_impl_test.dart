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
      birthDate: DateTime(1990, 1, 1),
      sex: 'M',
      weightKg: 70.0,
      heightCm: 170.0,
      conditions: ['Hypertension'],
      medications: ['Lisinopril'],
      allergies: ['Peanuts', 'Pollen'],
      familyHistory: ['Ataque al corazón', 'Diabetes mellitus'],
      createdAt: now,
      updatedAt: now,
      isEpsConnected: true,
      epsPatientId: 'EPS123',
    );

    test('getOnboardingProfile returns null when no profile is saved', () async {
      final profile = await repository.getOnboardingProfile();
      expect(profile, isNull);
    });

    test('getOnboardingProfile returns null when JSON is invalid', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('onboarding_profile', 'invalid json');

      final profile = await repository.getOnboardingProfile();
      expect(profile, isNull);
    });

    test('saveOnboardingProfile and getOnboardingProfile work correctly', () async {
      await repository.saveOnboardingProfile(sampleOnboardingProfile);
      final profile = await repository.getOnboardingProfile();

      expect(profile, equals(sampleOnboardingProfile));
    });

    test('isOnboardingCompleted returns false by default', () async {
      final completed = await repository.isOnboardingCompleted();
      expect(completed, isFalse);
    });

    test('completeOnboarding saves correctly mapped domain profile', () async {
      domain.UserProfile? capturedProfile;
      when(() => mockUserProfileRepository.saveUserProfile(any()))
          .thenAnswer((invocation) async {
        capturedProfile = invocation.positionalArguments[0] as domain.UserProfile;
      });

      await repository.completeOnboarding(sampleOnboardingProfile);

      verify(() => mockUserProfileRepository.saveUserProfile(any())).called(1);

      expect(capturedProfile, isNotNull);
      expect(capturedProfile!.name, sampleOnboardingProfile.name);
      expect(capturedProfile!.birthDate, sampleOnboardingProfile.birthDate);
      expect(capturedProfile!.sex, sampleOnboardingProfile.sex);
      expect(capturedProfile!.weight, sampleOnboardingProfile.weightKg);
      expect(capturedProfile!.height, sampleOnboardingProfile.heightCm);
      expect(capturedProfile!.medicalConditions, sampleOnboardingProfile.conditions);
      expect(capturedProfile!.currentMedications, sampleOnboardingProfile.medications);
      expect(capturedProfile!.onboardingCompleted, isTrue);
      expect(capturedProfile!.isEpsConnected, isTrue);
      expect(capturedProfile!.epsPatientId, 'EPS123');
      expect(capturedProfile!.allergyName, 'Peanuts, Pollen');
      expect(capturedProfile!.familyHistoryCvd, isTrue);
      expect(capturedProfile!.familyHistoryDiabetes, isTrue);

      final completed = await repository.isOnboardingCompleted();
      expect(completed, isTrue);

      final onboardingProfile = await repository.getOnboardingProfile();
      expect(onboardingProfile, isNull);
    });

    test('completeOnboarding mapping with cardio/corazón', () async {
      final profileWithCardio = sampleOnboardingProfile.copyWith(
        familyHistory: ['Problemas de cardio'],
      );

      domain.UserProfile? capturedProfile;
      when(() => mockUserProfileRepository.saveUserProfile(any()))
          .thenAnswer((invocation) async {
        capturedProfile = invocation.positionalArguments[0] as domain.UserProfile;
      });

      await repository.completeOnboarding(profileWithCardio);
      expect(capturedProfile!.familyHistoryCvd, isTrue);

      final profileWithCorazon = sampleOnboardingProfile.copyWith(
        familyHistory: ['Dolor de corazón'],
      );
      await repository.completeOnboarding(profileWithCorazon);
      expect(capturedProfile!.familyHistoryCvd, isTrue);
    });

    test('completeOnboarding mapping with empty allergies', () async {
      final profileNoAllergies = sampleOnboardingProfile.copyWith(
        allergies: [],
      );

      domain.UserProfile? capturedProfile;
      when(() => mockUserProfileRepository.saveUserProfile(any()))
          .thenAnswer((invocation) async {
        capturedProfile = invocation.positionalArguments[0] as domain.UserProfile;
      });

      await repository.completeOnboarding(profileNoAllergies);
      expect(capturedProfile!.allergyName, isNull);
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
