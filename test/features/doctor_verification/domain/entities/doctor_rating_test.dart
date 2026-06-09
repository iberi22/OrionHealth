import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/rating_repository.dart';

class MockRatingRepository extends Mock implements RatingRepository {}

// Helper to allow mocktail to handle DoctorRating as an argument
class DoctorRatingFake extends Fake implements DoctorRating {}

void main() {
  setUpAll(() {
    registerFallbackValue(DoctorRatingFake());
  });

  group('DoctorRating', () {
    test('should return true for valid rating', () {
      final rating = DoctorRating(
        id: '1',
        doctorId: 'doc1',
        overallScore: 5,
        categories: {'bedside_manner': 5},
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
        comment: 'Excellent doctor!',
      );

      expect(rating.validate(), isTrue);
    });

    test('should return false if overallScore is less than 1', () {
      final rating = DoctorRating(
        id: '1',
        doctorId: 'doc1',
        overallScore: 0,
        categories: {'bedside_manner': 5},
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
      );

      expect(rating.validate(), isFalse);
    });

    test('should return false if overallScore is greater than 5', () {
      final rating = DoctorRating(
        id: '1',
        doctorId: 'doc1',
        overallScore: 6,
        categories: {'bedside_manner': 5},
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
      );

      expect(rating.validate(), isFalse);
    });

    test('should return false if comment is longer than 500 characters', () {
      final rating = DoctorRating(
        id: '1',
        doctorId: 'doc1',
        overallScore: 5,
        categories: {'bedside_manner': 5},
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
        comment: 'a' * 501,
      );

      expect(rating.validate(), isFalse);
    });
  });

  group('RatingRepository Interface', () {
    late MockRatingRepository mockRepository;

    setUp(() {
      mockRepository = MockRatingRepository();
    });

    test('should define save method', () async {
      final rating = DoctorRating(
        id: '1',
        doctorId: 'doc1',
        overallScore: 5,
        categories: {},
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
      );

      when(() => mockRepository.save(any())).thenAnswer((_) async => {});

      await mockRepository.save(rating);

      verify(() => mockRepository.save(rating)).called(1);
    });

    test('should define find method', () async {
      final ratings = <DoctorRating>[];
      when(() => mockRepository.find(any())).thenAnswer((_) async => ratings);

      final result = await mockRepository.find('doc1');

      expect(result, ratings);
      verify(() => mockRepository.find('doc1')).called(1);
    });

    test('should define getAverageForDoctor method', () async {
      when(() => mockRepository.getAverageForDoctor(any())).thenAnswer((_) async => 4.5);

      final result = await mockRepository.getAverageForDoctor('doc1');

      expect(result, 4.5);
      verify(() => mockRepository.getAverageForDoctor('doc1')).called(1);
    });
  });
}
