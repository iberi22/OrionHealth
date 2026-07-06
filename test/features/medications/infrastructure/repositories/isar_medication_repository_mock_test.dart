import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/infrastructure/repositories/isar_medication_repository.dart';
import 'package:orionhealth_health/features/medications/infrastructure/services/pharmacy_api_service.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionMedication extends IsarCollection<Medication> {}
class MockIsarCollection extends Mock implements IsarCollectionMedication {}

class FakeMedication extends Fake implements Medication {}

class MockPharmacyApiService extends Mock implements PharmacyApiService {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late MockPharmacyApiService mockApiService;
  late IsarMedicationRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeMedication());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    mockApiService = MockPharmacyApiService();
    repository = IsarMedicationRepository(mockIsar, mockApiService);

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

    test('searchMedications should return local results if found in catalog', () async {
      // Use a term that doesn't exist to skip local and hit Isar/API,
      // but here we want to TEST the local catalog part without crashing on Isar.

      // "Lisinopril" should be in the catalog and there are less than 5 results for "Lisinopril"
      // actually there are few: Lisinopril.
      // If we use a term that has 5+ results it will NOT hit Isar.

      final results = await repository.searchMedications('statin');

      expect(results.length, greaterThanOrEqualTo(5));
      expect(results.any((m) => m.name.toLowerCase().contains('statin')), isTrue);

      // Verify Isar wasn't touched because we got 5+ results
      verifyNever(() => mockCollection.filter());
    });
  });
}
