import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late IsarRatingRepository ratingRepository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_isar_rating');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [DoctorRatingSchema],
      directory: testDir,
    );
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
      await isar.doctorRatings.clear();
    });
  });

  group('IsarRatingRepository', () {
    test('save persists a rating', () async {
      final rating = DoctorRating(
        id: 'r1',
        doctorId: 'doc1',
        overallScore: 5,
        categoriesJson: '{"bedside":5,"knowledge":5}',
        comment: 'Excellent doctor',
        createdAt: DateTime(2023, 6, 15),
        isAnonymous: false,
        verifiedVisit: true,
      );

      await ratingRepository.save(rating);

      final results = await ratingRepository.find('doc1');
      expect(results.length, 1);
      expect(results.first.id, 'r1');
      expect(results.first.overallScore, 5);
      expect(results.first.comment, 'Excellent doctor');
    });

    test('find returns multiple ratings for same doctor', () async {
      final r1 = DoctorRating(
        id: 'r1',
        doctorId: 'doc1',
        overallScore: 4,
        categoriesJson: '{}',
        createdAt: DateTime(2023, 1, 1),
        isAnonymous: false,
        verifiedVisit: true,
      );
      final r2 = DoctorRating(
        id: 'r2',
        doctorId: 'doc1',
        overallScore: 5,
        categoriesJson: '{}',
        createdAt: DateTime(2023, 2, 1),
        isAnonymous: true,
        verifiedVisit: true,
      );
      final r3 = DoctorRating(
        id: 'r3',
        doctorId: 'doc2',
        overallScore: 3,
        categoriesJson: '{}',
        createdAt: DateTime(2023, 3, 1),
        isAnonymous: false,
        verifiedVisit: false,
      );

      await ratingRepository.save(r1);
      await ratingRepository.save(r2);
      await ratingRepository.save(r3);

      final results = await ratingRepository.find('doc1');
      expect(results.length, 2);
      expect(results.any((r) => r.id == 'r1'), isTrue);
      expect(results.any((r) => r.id == 'r2'), isTrue);
    });

    test('getAverageForDoctor calculates correctly', () async {
      final r1 = DoctorRating(
        id: 'r1',
        doctorId: 'doc1',
        overallScore: 4,
        categoriesJson: '{}',
        createdAt: DateTime(2023, 1, 1),
        isAnonymous: false,
        verifiedVisit: true,
      );
      final r2 = DoctorRating(
        id: 'r2',
        doctorId: 'doc1',
        overallScore: 5,
        categoriesJson: '{}',
        createdAt: DateTime(2023, 2, 1),
        isAnonymous: false,
        verifiedVisit: true,
      );
      final r3 = DoctorRating(
        id: 'r3',
        doctorId: 'doc1',
        overallScore: 3,
        categoriesJson: '{}',
        createdAt: DateTime(2023, 3, 1),
        isAnonymous: false,
        verifiedVisit: true,
      );

      await ratingRepository.save(r1);
      await ratingRepository.save(r2);
      await ratingRepository.save(r3);

      final avg = await ratingRepository.getAverageForDoctor('doc1');
      expect(avg, closeTo(4.0, 0.01));
    });

    test('getAverageForDoctor returns 0.0 for no ratings', () async {
      final avg = await ratingRepository.getAverageForDoctor('nonexistent');
      expect(avg, 0.0);
    });

    test('getAverageForDoctor handles single rating', () async {
      final rating = DoctorRating(
        id: 'r1',
        doctorId: 'doc_single',
        overallScore: 4,
        categoriesJson: '{}',
        createdAt: DateTime(2023, 1, 1),
        isAnonymous: false,
        verifiedVisit: true,
      );

      await ratingRepository.save(rating);

      final avg = await ratingRepository.getAverageForDoctor('doc_single');
      expect(avg, 4.0);
    });

    test('find returns empty list for unknown doctor', () async {
      final results = await ratingRepository.find('unknown_doc');
      expect(results, isEmpty);
    });
  });
}
