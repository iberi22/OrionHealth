import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../user_profile/domain/entities/user_profile.dart' as domain;
import '../domain/entities/user_profile.dart' as onboarding;
import '../domain/repositories/onboarding_repository.dart';

@LazySingleton(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  final UserProfileRepository _userProfileRepository;
  static const String _onboardingProfileKey = 'onboarding_profile';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  OnboardingRepositoryImpl(this._userProfileRepository);

  @override
  Future<onboarding.UserProfile?> getOnboardingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_onboardingProfileKey);
    if (profileJson == null) return null;

    try {
      return onboarding.UserProfile.fromJson(jsonDecode(profileJson));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveOnboardingProfile(onboarding.UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_onboardingProfileKey, jsonEncode(profile.toJson()));
  }

  @override
  Future<void> completeOnboarding(onboarding.UserProfile profile) async {
    // 1. Save to main Isar storage via UserProfileRepository
    final domainProfile = _mapToDomain(profile);
    await _userProfileRepository.saveUserProfile(domainProfile);

    // 2. Mark as completed in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);

    // 3. Clear temporary onboarding profile
    await prefs.remove(_onboardingProfileKey);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  @override
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, false);
    await prefs.remove(_onboardingProfileKey);
    await _userProfileRepository.deleteUserProfile();
  }

  domain.UserProfile _mapToDomain(onboarding.UserProfile profile) {
    return domain.UserProfile(
      name: profile.name,
      birthDate: profile.birthDate,
      sex: profile.sex,
      weight: profile.weightKg,
      height: profile.heightCm,
      medicalConditions: profile.conditions,
      currentMedications: profile.medications,
      onboardingCompleted: true,
      isEpsConnected: profile.isEpsConnected,
      epsPatientId: profile.epsPatientId,
      // Map other fields as necessary
      allergyName: profile.allergies.isNotEmpty ? profile.allergies.join(', ') : null,
      familyHistoryCvd: profile.familyHistory.any((e) => e.toLowerCase().contains('corazón') || e.toLowerCase().contains('cardio')),
      familyHistoryDiabetes: profile.familyHistory.any((e) => e.toLowerCase().contains('diabetes')),
    );
  }
}
