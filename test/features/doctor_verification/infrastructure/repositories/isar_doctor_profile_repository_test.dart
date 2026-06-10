import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'package:orionhealth_health/features/doctor_verification/data/repositories/isar_doctor_profile_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/data/repositories/isar_rating_repository.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late IsarDoctorProfileRepository profileRepository;
  late IsarRatingRepository ratingRepository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_doctor_verification');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [DoctorProfileSchema, DoctorRatingSchema],
      directory: testDir,
    );
    profileRepository = IsarDoctorProfileRepository(isar);
    ratingRepository = IsarRatingRepository(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.doctorProfiles.clear();
      await isar.doctorRatings.clear();
    });
  });

  group('IsarDoctorProfileRepository', () {
    test('saveDoctorProfile and getDoctorProfile', () async {
      final profile = DoctorProfile(
        id: 'doc1',
        fullName: 'Dr. Strange',
        specialty: 'Surgeon',
        countryCode: 'US',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await profileRepository.saveDoctorProfile(profile);

      final result = await profileRepository.getDoctorProfile('doc1');
      expect(result, isNotNull);
      expect(result!.fullName, 'Dr. Strange');
    });

    test('getAllDoctorProfiles returns all records', () async {
      final p1 = DoctorProfile(id: '1', fullName: 'A', specialty: 'S', countryCode: 'C', createdAt: DateTime.now(), updatedAt: DateTime.now());
      final p2 = DoctorProfile(id: '2', fullName: 'B', specialty: 'S', countryCode: 'C', createdAt: DateTime.now(), updatedAt: DateTime.now());

      await profileRepository.saveDoctorProfile(p1);
      await profileRepository.saveDoctorProfile(p2);

      final results = await profileRepository.getAllDoctorProfiles();
      expect(results.length, 2);
    });

    test('deleteDoctorProfile removes the record', () async {
      final profile = DoctorProfile(id: 'doc1', fullName: 'A', specialty: 'S', countryCode: 'C', createdAt: DateTime.now(), updatedAt: DateTime.now());
      await profileRepository.saveDoctorProfile(profile);

      await profileRepository.deleteDoctorProfile('doc1');

      final result = await profileRepository.getDoctorProfile('doc1');
      expect(result, isNull);
    });
  });

  group('IsarRatingRepository', () {
    test('save and find ratings', () async {
      final rating = DoctorRating(
        id: 'r1',
        doctorId: 'doc1',
        overallScore: 5,
        categoriesJson: '{}',
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
      );

      await ratingRepository.save(rating);

      final results = await ratingRepository.find('doc1');
      expect(results.length, 1);
      expect(results.first.overallScore, 5);
    });

    test('getAverageForDoctor calculates correctly', () async {
      final r1 = DoctorRating(id: '1', doctorId: 'doc1', overallScore: 4, categoriesJson: '{}', createdAt: DateTime.now(), isAnonymous: false, verifiedVisit: true);
      final r2 = DoctorRating(id: '2', doctorId: 'doc1', overallScore: 5, categoriesJson: '{}', createdAt: DateTime.now(), isAnonymous: false, verifiedVisit: true);

      await ratingRepository.save(r1);
      await ratingRepository.save(r2);

      final avg = await ratingRepository.getAverageForDoctor('doc1');
      expect(avg, 4.5);
    });

    test('getAverageForDoctor returns 0.0 for no ratings', () async {
      final avg = await ratingRepository.getAverageForDoctor('none');
      expect(avg, 0.0);
    });
  });
}
