import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class OnboardingLocalDataSource {
  static const String _profileKey = 'onboarding_profile';
  static const String _completedKey = 'onboarding_completed';

  Future<String?> getProfileJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileKey);
  }

  Future<void> saveProfileJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, false);
    await prefs.remove(_profileKey);
  }
}
