import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/vouch.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionVouch extends IsarCollection<Vouch> {}
class MockIsarCollection extends Mock implements IsarCollectionVouch {}

class FakeVouch extends Fake implements Vouch {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late IsarVouchRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeVouch());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = IsarVouchRepository(mockIsar);

    when(() => mockIsar.vouchs).thenReturn(mockCollection);
  });

  group('IsarVouchRepository', () {
    test('addVouch puts vouch in collection', () async {
      final vouch = Vouch(
        id: '1',
        vouchedBy: 'd1',
        targetDoctor: 'd2',
        category: 'Ethics',
        timestamp: DateTime.now(),
      );
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.addVouch(vouch);

      verify(() => mockCollection.put(vouch)).called(1);
    });
  });
}
