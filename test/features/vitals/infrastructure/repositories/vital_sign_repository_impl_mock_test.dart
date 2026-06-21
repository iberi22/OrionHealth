import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionVitalSign extends IsarCollection<VitalSign> {}
class MockIsarCollection extends Mock implements IsarCollectionVitalSign {}

class FakeVitalSign extends Fake implements VitalSign {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late VitalSignRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeVitalSign());
    registerFallbackValue(const <VitalSign>[]);
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = VitalSignRepositoryImpl(mockIsar);

    when(() => mockIsar.vitalSigns).thenReturn(mockCollection);
  });

  group('VitalSignRepositoryImpl Mocked Extended', () {
    test('saveVitalSign calls put with correct object', () async {
      final vital = VitalSign(
        type: VitalSignType.bloodPressureSystolic,
        value: 120,
        dateTime: DateTime.now(),
      );
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveVitalSign(vital);

      verify(() => mockCollection.put(vital)).called(1);
    });

    test('saveVitalSigns with multiple items calls putAll', () async {
      final vitals = [
        VitalSign(type: VitalSignType.heartRate, value: 70, dateTime: DateTime.now()),
        VitalSign(type: VitalSignType.spO2, value: 98, dateTime: DateTime.now()),
      ];
      when(() => mockCollection.putAll(any())).thenAnswer((_) async => [1, 2]);

      await repository.saveVitalSigns(vitals);

      verify(() => mockCollection.putAll(vitals)).called(1);
    });

    test('saveVitalSigns with empty list returns early and does not call putAll', () async {
      await repository.saveVitalSigns([]);
      verifyNever(() => mockCollection.putAll(any()));
    });
  });
}
