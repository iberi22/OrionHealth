import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/second_opinion.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionSecondOpinionRequest extends IsarCollection<SecondOpinionRequest> {}
class MockIsarCollection extends Mock implements IsarCollectionSecondOpinionRequest {}

class FakeSecondOpinionRequest extends Fake implements SecondOpinionRequest {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late IsarSecondOpinionRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeSecondOpinionRequest());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = IsarSecondOpinionRepository(mockIsar);

    when(() => mockIsar.secondOpinionRequests).thenReturn(mockCollection);
  });

  group('IsarSecondOpinionRepository', () {
    test('saveRequest puts request in collection', () async {
      final request = SecondOpinionRequest(
        id: '1',
        patientId: 'p1',
        symptoms: 'fever',
        createdAt: DateTime.now(),
      );
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveRequest(request);

      verify(() => mockCollection.put(request)).called(1);
    });
  });
}
