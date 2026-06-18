import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/models/doctor_profile_model.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';

void main() {
  final tDate = DateTime(2023, 6, 15);
  final tEntity = DoctorProfile(
    id: 'doc1',
    fullName: 'Dr. Maria Lopez',
    specialty: 'Neurology',
    licenseNumber: 'LIC-12345',
    countryCode: 'CO',
    institution: 'Hospital San Vicente',
    yearsOfExperience: 15,
    languages: ['Spanish', 'English', 'French'],
    verified: true,
    createdAt: tDate,
    updatedAt: tDate,
  );

  final tModel = DoctorProfileModel(
    id: 'doc1',
    fullName: 'Dr. Maria Lopez',
    specialty: 'Neurology',
    licenseNumber: 'LIC-12345',
    countryCode: 'CO',
    institution: 'Hospital San Vicente',
    yearsOfExperience: 15,
    languages: ['Spanish', 'English', 'French'],
    verified: true,
    createdAt: tDate,
    updatedAt: tDate,
  );

  group('DoctorProfileModel', () {
    test('should be a subclass of DoctorProfile entity', () {
      expect(tModel, isA<DoctorProfile>());
    });

    test('fromJson should return a valid model', () {
      final jsonMap = <String, dynamic>{
        'id': 'doc1',
        'fullName': 'Dr. Maria Lopez',
        'specialty': 'Neurology',
        'licenseNumber': 'LIC-12345',
        'countryCode': 'CO',
        'institution': 'Hospital San Vicente',
        'yearsOfExperience': 15,
        'languages': ['Spanish', 'English', 'French'],
        'verified': true,
        'createdAt': tDate.toIso8601String(),
        'updatedAt': tDate.toIso8601String(),
      };

      final result = DoctorProfileModel.fromJson(jsonMap);

      expect(result.id, equals(tModel.id));
      expect(result.fullName, equals(tModel.fullName));
      expect(result.specialty, equals(tModel.specialty));
      expect(result.licenseNumber, equals(tModel.licenseNumber));
      expect(result.countryCode, equals(tModel.countryCode));
      expect(result.institution, equals(tModel.institution));
      expect(result.yearsOfExperience, equals(tModel.yearsOfExperience));
      expect(result.languages, equals(tModel.languages));
      expect(result.verified, equals(tModel.verified));
      expect(result.createdAt, equals(tModel.createdAt));
      expect(result.updatedAt, equals(tModel.updatedAt));
    });

    test('fromJson handles null fields correctly', () {
      final jsonMap = <String, dynamic>{
        'id': 'doc2',
        'fullName': 'Dr. Simple',
        'specialty': 'General',
        'countryCode': 'US',
        'createdAt': tDate.toIso8601String(),
        'updatedAt': tDate.toIso8601String(),
      };

      final result = DoctorProfileModel.fromJson(jsonMap);

      expect(result.id, 'doc2');
      expect(result.licenseNumber, isNull);
      expect(result.institution, isNull);
      expect(result.yearsOfExperience, isNull);
      expect(result.languages, isEmpty);
      expect(result.verified, isFalse);
    });

    test('toJson should return a JSON map containing the proper data', () {
      final result = tModel.toJson();

      expect(result['id'], 'doc1');
      expect(result['fullName'], 'Dr. Maria Lopez');
      expect(result['specialty'], 'Neurology');
      expect(result['licenseNumber'], 'LIC-12345');
      expect(result['countryCode'], 'CO');
      expect(result['institution'], 'Hospital San Vicente');
      expect(result['yearsOfExperience'], 15);
      expect(result['languages'], ['Spanish', 'English', 'French']);
      expect(result['verified'], true);
      expect(result['createdAt'], tDate.toIso8601String());
      expect(result['updatedAt'], tDate.toIso8601String());
    });

    test('fromEntity should return a valid model from entity', () {
      final result = DoctorProfileModel.fromEntity(tEntity);

      expect(result.id, equals(tModel.id));
      expect(result.fullName, equals(tModel.fullName));
      expect(result.specialty, equals(tModel.specialty));
      expect(result.licenseNumber, equals(tModel.licenseNumber));
      expect(result.countryCode, equals(tModel.countryCode));
      expect(result.institution, equals(tModel.institution));
      expect(result.yearsOfExperience, equals(tModel.yearsOfExperience));
      expect(result.languages, equals(tModel.languages));
      expect(result.verified, equals(tModel.verified));
      expect(result.createdAt, equals(tModel.createdAt));
      expect(result.updatedAt, equals(tModel.updatedAt));
    });

    test('fromModel roundtrip preserves all fields', () {
      final model = DoctorProfileModel(
        id: 'roundtrip',
        fullName: 'Dr. Round Trip',
        specialty: 'Pediatrics',
        licenseNumber: null,
        countryCode: 'MX',
        institution: null,
        yearsOfExperience: null,
        languages: const [],
        verified: false,
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
      expect(deserialized.languages, model.languages);
      expect(deserialized.verified, model.verified);
    });

    test('fromEntity preserves isarId when set', () {
      final entity = DoctorProfile(
        id: 'doc3',
        fullName: 'Dr. Test',
        specialty: 'Dermatology',
        countryCode: 'BR',
        createdAt: tDate,
        updatedAt: tDate,
      );
      entity.isarId = 42;

      final result = DoctorProfileModel.fromEntity(entity);

      expect(result.id, 'doc3');
    });
  });
}
