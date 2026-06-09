import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/data/models/doctor_profile_model.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';

void main() {
  final tDate = DateTime(2023, 1, 1);
  final tDoctorProfile = DoctorProfile(
    id: '1',
    fullName: 'John Doe',
    specialty: 'Cardiology',
    licenseNumber: '12345',
    countryCode: 'US',
    institution: 'General Hospital',
    yearsOfExperience: 10,
    languages: const ['English', 'Spanish'],
    verified: true,
    createdAt: tDate,
    updatedAt: tDate,
  );

  final tDoctorProfileModel = DoctorProfileModel(
    id: '1',
    fullName: 'John Doe',
    specialty: 'Cardiology',
    licenseNumber: '12345',
    countryCode: 'US',
    institution: 'General Hospital',
    yearsOfExperience: 10,
    languages: const ['English', 'Spanish'],
    verified: true,
    createdAt: tDate,
    updatedAt: tDate,
  );

  group('DoctorProfile', () {
    test('should support value equality', () {
      final tDoctorProfile2 = DoctorProfile(
        id: '1',
        fullName: 'John Doe',
        specialty: 'Cardiology',
        licenseNumber: '12345',
        countryCode: 'US',
        institution: 'General Hospital',
        yearsOfExperience: 10,
        languages: const ['English', 'Spanish'],
        verified: true,
        createdAt: tDate,
        updatedAt: tDate,
      );

      expect(tDoctorProfile, equals(tDoctorProfile2));
    });
  });

  group('DoctorProfileModel', () {
    test('should be a subclass of DoctorProfile entity', () {
      expect(tDoctorProfileModel, isA<DoctorProfile>());
    });

    test('fromJson should return a valid model', () {
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'fullName': 'John Doe',
        'specialty': 'Cardiology',
        'licenseNumber': '12345',
        'countryCode': 'US',
        'institution': 'General Hospital',
        'yearsOfExperience': 10,
        'languages': ['English', 'Spanish'],
        'verified': true,
        'createdAt': tDate.toIso8601String(),
        'updatedAt': tDate.toIso8601String(),
      };

      final result = DoctorProfileModel.fromJson(jsonMap);
      
      expect(result, equals(tDoctorProfileModel));
    });

    test('toJson should return a JSON map containing the proper data', () {
      final result = tDoctorProfileModel.toJson();

      final expectedMap = {
        'id': '1',
        'fullName': 'John Doe',
        'specialty': 'Cardiology',
        'licenseNumber': '12345',
        'countryCode': 'US',
        'institution': 'General Hospital',
        'yearsOfExperience': 10,
        'languages': ['English', 'Spanish'],
        'verified': true,
        'createdAt': tDate.toIso8601String(),
        'updatedAt': tDate.toIso8601String(),
      };

      expect(result, expectedMap);
    });

    test('fromEntity should return a valid model from entity', () {
      final result = DoctorProfileModel.fromEntity(tDoctorProfile);
      expect(result, tDoctorProfileModel);
    });
  });
}
