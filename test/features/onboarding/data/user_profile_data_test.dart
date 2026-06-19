import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';

void main() {
  group('UserProfile Data Integrity', () {
    test('toJson and fromJson handles all fields correctly', () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: 1,
        name: 'John Doe',
        birthDate: DateTime(1990, 5, 20),
        sex: 'M',
        weightKg: 85.5,
        heightCm: 182.0,
        conditions: ['Diabetes', 'Asthma'],
        familyHistory: ['Heart disease'],
        medications: ['Metformin'],
        allergies: ['Peanuts'],
        privacyConsent: true,
        createdAt: now,
        updatedAt: now,
        onboardingStep: 5,
        onboardingCompleted: false,
        locale: 'en_US',
        isEpsConnected: true,
        epsPatientId: 'PAT-001',
      );

      final json = profile.toJson();
      final fromJson = UserProfile.fromJson(json);

      expect(fromJson, equals(profile));
      expect(fromJson.name, 'John Doe');
      expect(fromJson.weightKg, 85.5);
      expect(fromJson.conditions, contains('Asthma'));
    });

    test('fromJson handles null or missing optional fields', () {
      final now = DateTime.now();
      final minimalJson = {
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final profile = UserProfile.fromJson(minimalJson);

      expect(profile.id, 0);
      expect(profile.name, isNull);
      expect(profile.conditions, isEmpty);
      expect(profile.privacyConsent, isFalse);
      expect(profile.onboardingCompleted, isFalse);
    });

    test('Data integrity during partial copyWith updates', () {
      final now = DateTime.now();
      final profile = UserProfile(
        name: 'Original',
        createdAt: now,
        updatedAt: now,
      );

      final updated = profile.copyWith(name: 'Updated');

      expect(updated.name, 'Updated');
      expect(updated.createdAt, profile.createdAt);
      expect(updated.updatedAt, profile.updatedAt);
      expect(updated.onboardingStep, profile.onboardingStep);
    });
  });
}
