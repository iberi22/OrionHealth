import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('should create UserProfile with default values', () {
      final profile = UserProfile();
      expect(profile.allowCloudApi, isTrue);
      expect(profile.onboardingCompleted, isFalse);
      expect(profile.medicalConditions, isEmpty);
      expect(profile.currentMedications, isEmpty);
      expect(profile.isEpsConnected, isFalse);
    });

    test('copyWith should return a new object with updated values', () {
      final profile = UserProfile(name: 'John Doe', age: 30);
      final updatedProfile = profile.copyWith(name: 'Jane Doe', age: 25);

      expect(updatedProfile.name, 'Jane Doe');
      expect(updatedProfile.age, 25);
      expect(profile.name, 'John Doe');
      expect(profile.age, 30);
    });

    group('validate', () {
      test('should return true for valid profile', () {
        final profile = UserProfile(
          age: 30,
          weight: 70.0,
          height: 175.0,
          bloodType: 'O+',
          systolicBP: 120,
          diastolicBP: 80,
          heartRate: 70,
        );
        expect(profile.validate(), isTrue);
      });

      test('should return false for invalid age', () {
        expect(UserProfile(age: -1).validate(), isFalse);
        expect(UserProfile(age: 151).validate(), isFalse);
      });

      test('should return false for invalid weight', () {
        expect(UserProfile(weight: 0).validate(), isFalse);
        expect(UserProfile(weight: -10).validate(), isFalse);
      });

      test('should return false for invalid height', () {
        expect(UserProfile(height: 0).validate(), isFalse);
        expect(UserProfile(height: -10).validate(), isFalse);
      });

      test('should return false for invalid blood pressure', () {
        expect(UserProfile(systolicBP: 49).validate(), isFalse);
        expect(UserProfile(systolicBP: 251).validate(), isFalse);
        expect(UserProfile(diastolicBP: 29).validate(), isFalse);
        expect(UserProfile(diastolicBP: 151).validate(), isFalse);
      });

      test('should return false for invalid heart rate', () {
        expect(UserProfile(heartRate: 29).validate(), isFalse);
        expect(UserProfile(heartRate: 221).validate(), isFalse);
      });

      test('should return false for invalid blood type', () {
        expect(UserProfile(bloodType: 'X+').validate(), isFalse);
      });

      test('should return false for invalid sex', () {
        expect(UserProfile(sex: 'X').validate(), isFalse);
      });
    });
  });
}
