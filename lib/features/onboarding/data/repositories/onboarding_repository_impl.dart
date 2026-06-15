import 'dart:convert';
import '../../domain/entities/user_profile.dart' as onboarding;
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';
import '../../../user_profile/domain/entities/user_profile.dart' as domain;
import '../../../user_profile/domain/repositories/user_profile_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;
  final UserProfileRepository _userProfileRepository;
  OnboardingRepositoryImpl(this._localDataSource, this._userProfileRepository);

  @override
  Future<onboarding.UserProfile?> getOnboardingProfile() async {
    final json = await _localDataSource.getProfileJson();
    if (json == null) return null;
    return onboarding.UserProfile.fromJson(jsonDecode(json));
  }

  @override
  Future<void> saveOnboardingProfile(onboarding.UserProfile p) async =>
      _localDataSource.saveProfileJson(jsonEncode(p.toJson()));

  @override
  Future<void> completeOnboarding(onboarding.UserProfile p) async {
    final dp = domain.UserProfile(
      name: p.name, birthDate: p.birthDate, sex: p.sex,
      weight: p.weightKg, height: p.heightCm,
      medicalConditions: p.conditions,
      currentMedications: p.medications,
      onboardingCompleted: true, isEpsConnected: p.isEpsConnected,
      epsPatientId: p.epsPatientId,
      allergyName: p.allergies.isNotEmpty ? p.allergies.join(', ') : null,
      familyHistoryCvd: p.familyHistory.any((e) => e.toLowerCase().contains('corazón') || e.toLowerCase().contains('cardio')),
      familyHistoryDiabetes: p.familyHistory.any((e) => e.toLowerCase().contains('diabetes')),
    );
    await _userProfileRepository.saveUserProfile(dp);
    await _localDataSource.markCompleted();
    await _localDataSource.clearProfile();
  }

  @override
  Future<bool> isOnboardingCompleted() => _localDataSource.isOnboardingCompleted();

  @override
  Future<void> resetOnboarding() async {
    await _localDataSource.resetAll();
    await _userProfileRepository.deleteUserProfile();
  }
}
