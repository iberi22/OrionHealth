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

    test('copyWith should update all fields', () {
      final birthDate = DateTime(1990, 1, 1);
      final profile = UserProfile().copyWith(
        name: 'John',
        age: 30,
        weight: 75.0,
        height: 180.0,
        bloodType: 'A+',
        avatarUrl: 'url',
        uniqueId: 'id',
        email: 'test@example.com',
        phoneNumber: '123456',
        allowCloudApi: false,
        onboardingCompleted: true,
        birthDate: birthDate,
        sex: 'M',
        systolicBP: 120,
        diastolicBP: 80,
        heartRate: 70,
        allergyName: 'Peanuts',
        allergySeverity: 'High',
        allergyNotes: 'None',
        llmProvider: 'openai',
        localModelName: 'gemma',
        medicalConditions: ['E11'],
        currentMedications: ['123'],
        smokingStatus: 'never',
        familyHistoryCvd: true,
        familyHistoryDiabetes: false,
        hasHypertension: true,
        hasCardiovascularDisease: false,
        hasSteroidUse: true,
        isEpsConnected: true,
        epsPatientId: 'eps123',
        ethnicity: 'hispanic',
      );

      expect(profile.name, 'John');
      expect(profile.age, 30);
      expect(profile.weight, 75.0);
      expect(profile.height, 180.0);
      expect(profile.bloodType, 'A+');
      expect(profile.avatarUrl, 'url');
      expect(profile.uniqueId, 'id');
      expect(profile.email, 'test@example.com');
      expect(profile.phoneNumber, '123456');
      expect(profile.allowCloudApi, isFalse);
      expect(profile.onboardingCompleted, isTrue);
      expect(profile.birthDate, birthDate);
      expect(profile.sex, 'M');
      expect(profile.systolicBP, 120);
      expect(profile.diastolicBP, 80);
      expect(profile.heartRate, 70);
      expect(profile.allergyName, 'Peanuts');
      expect(profile.allergySeverity, 'High');
      expect(profile.allergyNotes, 'None');
      expect(profile.llmProvider, 'openai');
      expect(profile.localModelName, 'gemma');
      expect(profile.medicalConditions, ['E11']);
      expect(profile.currentMedications, ['123']);
      expect(profile.smokingStatus, 'never');
      expect(profile.familyHistoryCvd, isTrue);
      expect(profile.familyHistoryDiabetes, isFalse);
      expect(profile.hasHypertension, isTrue);
      expect(profile.hasCardiovascularDisease, isFalse);
      expect(profile.hasSteroidUse, isTrue);
      expect(profile.isEpsConnected, isTrue);
      expect(profile.epsPatientId, 'eps123');
      expect(profile.ethnicity, 'hispanic');
    });

    test('toString should return a string representation', () {
      final profile = UserProfile(name: 'John Doe', age: 30);
      expect(profile.toString(), contains('John Doe'));
      expect(profile.toString(), contains('30'));
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
          sex: 'M',
        );
        expect(profile.validate(), isTrue);
      });

      test('should return true for boundary values', () {
        expect(UserProfile(age: 0).validate(), isTrue);
        expect(UserProfile(age: 150).validate(), isTrue);
        expect(UserProfile(systolicBP: 50).validate(), isTrue);
        expect(UserProfile(systolicBP: 250).validate(), isTrue);
        expect(UserProfile(diastolicBP: 30).validate(), isTrue);
        expect(UserProfile(diastolicBP: 150).validate(), isTrue);
        expect(UserProfile(heartRate: 30).validate(), isTrue);
        expect(UserProfile(heartRate: 220).validate(), isTrue);
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
