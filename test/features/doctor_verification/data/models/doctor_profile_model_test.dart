import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/models/doctor_profile_model.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';

void main() {
  final tDate = DateTime(2023, 6, 15);

  group('DoctorProfileModel Data Tests', () {
    test('fromJson handles null optional fields and defaults', () {
      final jsonMap = <String, dynamic>{
        'id': 'doc_nulls',
        'fullName': 'Dr. Null',
        'specialty': 'Testing',
        'countryCode': 'TS',
        'createdAt': tDate.toIso8601String(),
        'updatedAt': tDate.toIso8601String(),
        // optional fields missing
      };

      final result = DoctorProfileModel.fromJson(jsonMap);

      expect(result.id, 'doc_nulls');
      expect(result.licenseNumber, isNull);
      expect(result.institution, isNull);
      expect(result.yearsOfExperience, isNull);
      expect(result.languages, isEmpty);
      expect(result.verified, isFalse);
    });

    test('fromJson handles explicit nulls for optional fields', () {
      final jsonMap = <String, dynamic>{
        'id': 'doc_explicit_nulls',
        'fullName': 'Dr. Explicit',
        'specialty': 'Testing',
        'countryCode': 'TS',
        'licenseNumber': null,
        'institution': null,
        'yearsOfExperience': null,
        'languages': null,
        'verified': null,
        'createdAt': tDate.toIso8601String(),
        'updatedAt': tDate.toIso8601String(),
      };

      final result = DoctorProfileModel.fromJson(jsonMap);

      expect(result.licenseNumber, isNull);
      expect(result.institution, isNull);
      expect(result.yearsOfExperience, isNull);
      expect(result.languages, isEmpty);
      expect(result.verified, isFalse);
    });

    test('toJson produces expected map even with null fields', () {
      final model = DoctorProfileModel(
        id: 'doc_to_json',
        fullName: 'Dr. ToJson',
        specialty: 'Testing',
        countryCode: 'TS',
        createdAt: tDate,
        updatedAt: tDate,
      );

      final result = model.toJson();

      expect(result['id'], 'doc_to_json');
      expect(result['licenseNumber'], isNull);
      expect(result['institution'], isNull);
      expect(result['yearsOfExperience'], isNull);
      expect(result['languages'], isEmpty);
      expect(result['verified'], isFalse);
    });

    test('round-trip serialization/deserialization', () {
      final model = DoctorProfileModel(
        id: 'round-trip',
        fullName: 'Dr. RoundTrip',
        specialty: 'Testing',
        licenseNumber: 'LIC-999',
        countryCode: 'TS',
        institution: 'Test Hospital',
        yearsOfExperience: 10,
        languages: ['English'],
        verified: true,
        createdAt: tDate,
        updatedAt: tDate,
      );

      final json = model.toJson();
      final deserialized = DoctorProfileModel.fromJson(json);

      expect(deserialized.id, model.id);
      expect(deserialized.fullName, model.fullName);
      expect(deserialized.specialty, model.specialty);
      expect(deserialized.licenseNumber, model.licenseNumber);
      expect(deserialized.countryCode, model.countryCode);
      expect(deserialized.institution, model.institution);
      expect(deserialized.yearsOfExperience, model.yearsOfExperience);
      expect(deserialized.languages, model.languages);
      expect(deserialized.verified, model.verified);
      expect(deserialized.createdAt, model.createdAt);
      expect(deserialized.updatedAt, model.updatedAt);
    });
  });
}
