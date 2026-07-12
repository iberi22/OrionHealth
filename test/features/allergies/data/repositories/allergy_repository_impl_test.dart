import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/features/allergies/data/datasources/allergy_local_datasource.dart';
import 'package:orionhealth_health/features/allergies/data/repositories/allergy_repository_impl.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';

class MockAllergyLocalDataSource extends Mock implements AllergyLocalDataSource {}
class MockEncryptionService extends Mock implements EncryptionService {}

class FakeAllergy extends Fake implements Allergy {}

void main() {
  late AllergyRepositoryImpl repository;
  late MockAllergyLocalDataSource mockLocalDataSource;
  late MockEncryptionService mockEncryptionService;

  setUpAll(() {
    registerFallbackValue(FakeAllergy());
  });

  setUp(() {
    mockLocalDataSource = MockAllergyLocalDataSource();
    mockEncryptionService = MockEncryptionService();
    repository = AllergyRepositoryImpl(mockLocalDataSource, encryptionService: mockEncryptionService);

    // Default stubs for encryption service
    when(() => mockEncryptionService.encryptHealthData(any()))
        .thenAnswer((invocation) async => invocation.positionalArguments[0] as String);
    when(() => mockEncryptionService.decryptHealthData(any()))
        .thenAnswer((invocation) async => invocation.positionalArguments[0] as String);
  });

  group('AllergyRepositoryImpl', () {
    final tAllergies = [
      Allergy(id: 1, allergen: 'Peanuts', severity: AllergySeverity.severe),
    ];

    test('getAllergies should delegate to local data source and decrypt data', () async {
      final tAllergiesFromDb = [
        Allergy(id: 1, severity: AllergySeverity.severe)
          ..encryptedAllergen = 'Peanuts'
          ..encryptedNotes = 'Avoid',
      ];

      when(() => mockLocalDataSource.getAllergies())
          .thenAnswer((_) async => tAllergiesFromDb);

      final result = await repository.getAllergies();

      expect(result, tAllergiesFromDb);
      expect(result.first.allergen, 'Peanuts');
      expect(result.first.notes, 'Avoid');
      verify(() => mockLocalDataSource.getAllergies()).called(1);
      verify(() => mockEncryptionService.decryptHealthData('Peanuts')).called(1);
      verify(() => mockEncryptionService.decryptHealthData('Avoid')).called(1);
    });

    test('saveAllergy should delegate to local data source and encrypt data', () async {
      final tAllergy = Allergy(id: 1, allergen: 'Peanuts', severity: AllergySeverity.severe, notes: 'Avoid');

      when(() => mockLocalDataSource.saveAllergy(any()))
          .thenAnswer((_) async => {});

      await repository.saveAllergy(tAllergy);

      expect(tAllergy.encryptedAllergen, 'Peanuts');
      expect(tAllergy.encryptedNotes, 'Avoid');
      verify(() => mockLocalDataSource.saveAllergy(tAllergy)).called(1);
      verify(() => mockEncryptionService.encryptHealthData('Peanuts')).called(1);
      verify(() => mockEncryptionService.encryptHealthData('Avoid')).called(1);
    });

    test('deleteAllergy should delegate to local data source', () async {
      const tId = 1;
      when(() => mockLocalDataSource.deleteAllergy(any()))
          .thenAnswer((_) async => {});

      await repository.deleteAllergy(tId);

      verify(() => mockLocalDataSource.deleteAllergy(tId)).called(1);
    });
  });
}
