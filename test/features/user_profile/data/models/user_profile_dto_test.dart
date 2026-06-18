import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/data/models/user_profile_dto.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfileDto', () {
    final now = DateTime(2026, 6, 18);
    final entity = UserProfile(
      createdAt: now,
      updatedAt: now,
      name: 'Juan Perez',
      birthDate: DateTime(1990, 5, 15),
      sex: 'male',
      weight: 75.5,
      height: 1.78,
      medicalConditions: ['hypertension', 'diabetes'],
      currentMedications: ['Losartan'],
      onboardingCompleted: true,
      isEpsConnected: true,
      epsPatientId: 'EPS123',
      allergyName: 'Penicilina',
      familyHistoryCvd: true,
      familyHistoryDiabetes: false,
    );

    final defaultEntity = UserProfile(createdAt: now, updatedAt: now);

    group('fromEntity', () {
      test('copies all fields from entity', () {
        final dto = UserProfileDto.fromEntity(entity);
        expect(dto.name, 'Juan Perez');
        expect(dto.birthDate, DateTime(1990, 5, 15));
        expect(dto.sex, 'male');
        expect(dto.weight, 75.5);
        expect(dto.height, 1.78);
        expect(dto.medicalConditions, ['hypertension', 'diabetes']);
        expect(dto.currentMedications, ['Losartan']);
        expect(dto.onboardingCompleted, isTrue);
        expect(dto.isEpsConnected, isTrue);
        expect(dto.epsPatientId, 'EPS123');
        expect(dto.allergyName, 'Penicilina');
        expect(dto.familyHistoryCvd, isTrue);
        expect(dto.familyHistoryDiabetes, isFalse);
      });

      test('handles null fields', () {
        final dto = UserProfileDto.fromEntity(defaultEntity);
        expect(dto.name, isNull);
        expect(dto.birthDate, isNull);
        expect(dto.sex, isNull);
        expect(dto.weight, isNull);
        expect(dto.height, isNull);
        expect(dto.epsPatientId, isNull);
      });
    });

    group('toEntity', () {
      test('restores original entity', () {
        final dto = UserProfileDto.fromEntity(entity);
        final restored = dto.toEntity();
        expect(restored.name, 'Juan Perez');
        expect(restored.medicalConditions, hasLength(2));
        expect(restored.onboardingCompleted, isTrue);
      });

      test('handles empty defaults', () {
        final dto = UserProfileDto.fromEntity(defaultEntity);
        final restored = dto.toEntity();
        expect(restored.medicalConditions, isEmpty);
        expect(restored.currentMedications, isEmpty);
        expect(restored.onboardingCompleted, isFalse);
        expect(restored.isEpsConnected, isFalse);
      });
    });

    group('toJson', () {
      test('includes all non-null fields', () {
        final json = UserProfileDto.fromEntity(entity).toJson();
        expect(json['name'], 'Juan Perez');
        expect(json['birthDate'], '1990-05-15T00:00:00.000');
        expect(json['sex'], 'male');
        expect(json['weight'], 75.5);
        expect(json['height'], 1.78);
        expect(json['medicalConditions'], ['hypertension', 'diabetes']);
        expect(json['onboardingCompleted'], isTrue);
        expect(json['epsPatientId'], 'EPS123');
        expect(json['familyHistoryCvd'], isTrue);
        expect(json['familyHistoryDiabetes'], isFalse);
      });

      test('omits null fields', () {
        final json = UserProfileDto.fromEntity(defaultEntity).toJson();
        expect(json.containsKey('name'), isFalse);
        expect(json.containsKey('birthDate'), isFalse);
        expect(json.containsKey('sex'), isFalse);
        expect(json.containsKey('weight'), isFalse);
        expect(json.containsKey('height'), isFalse);
      });

      test('includes empty lists even when empty', () {
        final json = UserProfileDto.fromEntity(defaultEntity).toJson();
        expect(json['medicalConditions'], isEmpty);
        expect(json['currentMedications'], isEmpty);
      });

      test('includes bool defaults', () {
        final json = UserProfileDto.fromEntity(defaultEntity).toJson();
        expect(json['onboardingCompleted'], isFalse);
        expect(json['isEpsConnected'], isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes full json', () {
        final json = {
          'name': 'Maria',
          'birthDate': '1992-03-10T00:00:00.000',
          'sex': 'female',
          'weight': 62.0,
          'height': 1.65,
          'medicalConditions': ['asthma'],
          'currentMedications': ['Salbutamol'],
          'onboardingCompleted': true,
          'isEpsConnected': false,
          'epsPatientId': null,
          'allergyName': null,
          'familyHistoryCvd': null,
          'familyHistoryDiabetes': null,
        };
        final dto = UserProfileDto.fromJson(json);
        expect(dto.name, 'Maria');
        expect(dto.birthDate, DateTime(1992, 3, 10));
        expect(dto.sex, 'female');
        expect(dto.weight, 62.0);
        expect(dto.height, 1.65);
        expect(dto.medicalConditions, ['asthma']);
        expect(dto.currentMedications, ['Salbutamol']);
        expect(dto.onboardingCompleted, isTrue);
        expect(dto.isEpsConnected, isFalse);
        expect(dto.epsPatientId, isNull);
        expect(dto.familyHistoryCvd, isNull);
      });

      test('json roundtrip', () {
        final dto1 = UserProfileDto.fromEntity(entity);
        final json = dto1.toJson();
        final dto2 = UserProfileDto.fromJson(json);
        // Can't compare DTOs directly (no Equatable) — check fields
        expect(dto2.name, dto1.name);
        expect(dto2.medicalConditions, dto1.medicalConditions);
        expect(dto2.onboardingCompleted, dto1.onboardingCompleted);
        expect(dto2.familyHistoryCvd, dto1.familyHistoryCvd);
      });

      test('handles null/empty json', () {
        final dto = UserProfileDto.fromJson({});
        expect(dto.name, isNull);
        expect(dto.medicalConditions, isEmpty);
        expect(dto.currentMedications, isEmpty);
        expect(dto.onboardingCompleted, isFalse);
        expect(dto.isEpsConnected, isFalse);
      });
    });
  });
}
