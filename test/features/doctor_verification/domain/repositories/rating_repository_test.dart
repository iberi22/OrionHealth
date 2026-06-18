import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/rating_repository.dart';

class MockRatingRepository extends Mock implements RatingRepository {}

void main() {
  late MockRatingRepository repository;

  setUp(() {
    repository = MockRatingRepository();
  });

  final tDate = DateTime(2023, 1, 1);
  final tRating = DoctorRating(
    id: 'r1',
    doctorId: 'doc1',
    overallScore: 5,
    categoriesJson: '{}',
    createdAt: tDate,
    isAnonymous: false,
    verifiedVisit: true,
  );

  group('RatingRepository', () {
    test('save rating', () async {
      when(() => repository.save(tRating)).thenAnswer((_) async {});

      await repository.save(tRating);

      verify(() => repository.save(tRating)).called(1);
    });

    test('find ratings by doctorId', () async {
      when(() => repository.find('doc1')).thenAnswer((_) async => [tRating]);

      final results = await repository.find('doc1');

      expect(results.length, 1);
      expect(results.first, equals(tRating));
      verify(() => repository.find('doc1')).called(1);
    });

    test('find returns empty list when no ratings exist', () async {
      when(() => repository.find('nonexistent')).thenAnswer((_) async => []);

      final results = await repository.find('nonexistent');

      expect(results, isEmpty);
    });

    test('getAverageForDoctor returns average', () async {
      when(() => repository.getAverageForDoctor('doc1')).thenAnswer((_) async => 4.5);

      final avg = await repository.getAverageForDoctor('doc1');

      expect(avg, 4.5);
      verify(() => repository.getAverageForDoctor('doc1')).called(1);
    });

    test('getAverageForDoctor returns 0.0 when no ratings', () async {
      when(() => repository.getAverageForDoctor('nonexistent')).thenAnswer((_) async => 0.0);

      final avg = await repository.getAverageForDoctor('nonexistent');

      expect(avg, 0.0);
    });
  });
}
