import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/doctor_profile_repository.dart';

class MockDoctorProfileRepository extends Mock implements DoctorProfileRepository {}

void main() {
  late MockDoctorProfileRepository repository;

  setUp(() {
    repository = MockDoctorProfileRepository();
  });

  final tDate = DateTime(2023, 1, 1);
  final tProfile = DoctorProfile(
    id: '1',
    fullName: 'Dr. Smith',
    specialty: 'Cardiology',
    countryCode: 'US',
    createdAt: tDate,
    updatedAt: tDate,
  );

  group('DoctorProfileRepository', () {
    test('getDoctorProfile returns a doctor profile', () async {
      when(() => repository.getDoctorProfile('1')).thenAnswer((_) async => tProfile);

      final result = await repository.getDoctorProfile('1');

      expect(result, equals(tProfile));
      verify(() => repository.getDoctorProfile('1')).called(1);
    });

    test('getDoctorProfile returns null when not found', () async {
      when(() => repository.getDoctorProfile('nonexistent')).thenAnswer((_) async => null);

      final result = await repository.getDoctorProfile('nonexistent');

      expect(result, isNull);
    });

    test('saveDoctorProfile saves a profile', () async {
      when(() => repository.saveDoctorProfile(tProfile)).thenAnswer((_) async {});

      await repository.saveDoctorProfile(tProfile);

      verify(() => repository.saveDoctorProfile(tProfile)).called(1);
    });

    test('deleteDoctorProfile deletes a profile', () async {
      when(() => repository.deleteDoctorProfile('1')).thenAnswer((_) async {});

      await repository.deleteDoctorProfile('1');

      verify(() => repository.deleteDoctorProfile('1')).called(1);
    });

    test('getAllDoctorProfiles returns all profiles', () async {
      when(() => repository.getAllDoctorProfiles()).thenAnswer((_) async => [tProfile]);

      final results = await repository.getAllDoctorProfiles();

      expect(results.length, 1);
      expect(results.first, equals(tProfile));
      verify(() => repository.getAllDoctorProfiles()).called(1);
    });
  });
}
