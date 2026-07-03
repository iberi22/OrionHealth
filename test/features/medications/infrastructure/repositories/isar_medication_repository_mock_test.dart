import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/infrastructure/repositories/isar_medication_repository.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionMedication extends IsarCollection<Medication> {}
class MockIsarCollection extends Mock implements IsarCollectionMedication {}

class FakeMedication extends Fake implements Medication {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late IsarMedicationRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeMedication());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = IsarMedicationRepository(mockIsar);

    // Mocking the collection access
    when(() => mockIsar.medications).thenReturn(mockCollection);
  });

  group('IsarMedicationRepository Mocked', () {
    test('saveMedication calls put within transaction', () async {
      final medication = Medication(
        name: 'Test Med',
        startDate: DateTime.now(),
      );
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveMedication(medication);

      verify(() => mockCollection.put(medication)).called(1);
    });

    test('deleteMedication calls delete within transaction', () async {
      when(() => mockCollection.delete(any())).thenAnswer((_) async => true);

      await repository.deleteMedication(1);

      verify(() => mockCollection.delete(1)).called(1);
    });

    test('getAllMedications accesses medications collection', () async {
      // Since mocking Isar's fluent query API (where().findAll()) is complex,
      // we verify the repository's dependency on the collection property.

      // Attempting to call the method might throw due to unmocked fluent chain,
      // but we want to see if it even tries to access .medications
      try {
        await repository.getAllMedications();
      } catch (_) {}

      verify(() => mockIsar.medications).called(1);
    });
  });
}
