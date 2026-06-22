import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionDoctorRating extends IsarCollection<DoctorRating> {}
class MockIsarCollection extends Mock implements IsarCollectionDoctorRating {}

class FakeDoctorRating extends Fake implements DoctorRating {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late IsarRatingRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeDoctorRating());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = IsarRatingRepository(mockIsar);

    when(() => mockIsar.doctorRatings).thenReturn(mockCollection);
  });

  group('IsarRatingRepository', () {
    test('save puts rating in collection', () async {
      final rating = DoctorRating(
        id: '1',
        doctorId: '1',
        overallScore: 5,
        categoriesJson: '{}',
        createdAt: DateTime.now(),
        isAnonymous: false,
        verifiedVisit: true,
      );
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.save(rating);

      verify(() => mockCollection.put(rating)).called(1);
    });
  });
}
