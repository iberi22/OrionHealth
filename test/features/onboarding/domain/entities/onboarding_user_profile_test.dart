import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';

void main() {
  group('UserProfile (onboarding)', () {
    final now = DateTime.now();
    final baseProfile = UserProfile(
      createdAt: now,
      updatedAt: now,
      name: 'Juan Perez',
      birthDate: DateTime(1990, 5, 15),
      sex: 'M',
      weightKg: 75.0,
      heightCm: 175.0,
      conditions: ['Hipertension'],
      familyHistory: ['Diabetes'],
      medications: ['Losartan'],
      allergies: ['Penicilina'],
      privacyConsent: true,
      onboardingStep: 3,
      onboardingCompleted: true,
      locale: 'es_CO',
      isEpsConnected: true,
      epsPatientId: 'EPS-12345',
    );

    test('supports value equality', () {
      final profile2 = UserProfile(
        createdAt: now,
        updatedAt: now,
        name: 'Juan Perez',
        birthDate: DateTime(1990, 5, 15),
        sex: 'M',
        weightKg: 75.0,
        heightCm: 175.0,
        conditions: ['Hipertension'],
        familyHistory: ['Diabetes'],
        medications: ['Losartan'],
        allergies: ['Penicilina'],
        privacyConsent: true,
        onboardingStep: 3,
        onboardingCompleted: true,
        locale: 'es_CO',
        isEpsConnected: true,
        epsPatientId: 'EPS-12345',
      );
      expect(baseProfile, equals(profile2));
    });

    test('props are correct', () {
      expect(baseProfile.props, [
        0, // id default
        'Juan Perez',
        DateTime(1990, 5, 15),
        'M',
        75.0,
        175.0,
        ['Hipertension'],
        ['Diabetes'],
        ['Losartan'],
        ['Penicilina'],
        true,
        now,
        now,
        3,
        true,
        'es_CO',
        true,
        'EPS-12345',
      ]);
    });

    test('computes age correctly', () {
      final birthDate = DateTime(now.year - 30, 1, 1);
      final profile = UserProfile(
        createdAt: now,
        updatedAt: now,
        birthDate: birthDate,
      );
      expect(profile.age, 30);
    });

    test('age returns null when birthDate is null', () {
      final profile = UserProfile(createdAt: now, updatedAt: now);
      expect(profile.age, isNull);
    });

    test('copyWith updates specified fields only', () {
      final updated = baseProfile.copyWith(name: 'Carlos Lopez');
      expect(updated.name, 'Carlos Lopez');
      expect(updated.sex, 'M'); // unchanged
      expect(updated.weightKg, 75.0); // unchanged
    });

    test('copyWith with no args returns same profile', () {
      final copy = baseProfile.copyWith();
      expect(copy, equals(baseProfile));
    });

    test('toJson and fromJson round-trip', () {
      final json = baseProfile.toJson();
      final decoded = UserProfile.fromJson(json);
      expect(decoded, equals(baseProfile));
    });

    test('default values for optional fields', () {
      final minimal = UserProfile(createdAt: now, updatedAt: now);
      expect(minimal.id, 0);
      expect(minimal.name, isNull);
      expect(minimal.conditions, isEmpty);
      expect(minimal.familyHistory, isEmpty);
      expect(minimal.medications, isEmpty);
      expect(minimal.allergies, isEmpty);
      expect(minimal.privacyConsent, false);
      expect(minimal.onboardingStep, 0);
      expect(minimal.onboardingCompleted, false);
      expect(minimal.isEpsConnected, false);
      expect(minimal.epsPatientId, isNull);
    });

    test('supports different values', () {
      final p1 = UserProfile(createdAt: now, updatedAt: now, name: 'Alice');
      final p2 = UserProfile(createdAt: now, updatedAt: now, name: 'Bob');
      expect(p1, isNot(equals(p2)));
    });
  });
}
