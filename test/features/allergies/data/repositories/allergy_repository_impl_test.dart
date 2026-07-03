import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/allergies/data/datasources/allergy_local_datasource.dart';
import 'package:orionhealth_health/features/allergies/data/repositories/allergy_repository_impl.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';

class MockAllergyLocalDataSource extends Mock implements AllergyLocalDataSource {}

class FakeAllergy extends Fake implements Allergy {}

void main() {
  late AllergyRepositoryImpl repository;
  late MockAllergyLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeAllergy());
  });

  setUp(() {
    mockLocalDataSource = MockAllergyLocalDataSource();
    repository = AllergyRepositoryImpl(mockLocalDataSource);
  });

  group('AllergyRepositoryImpl', () {
    final tAllergies = [
      Allergy(id: 1, allergen: 'Peanuts', severity: AllergySeverity.severe),
    ];

    test('getAllergies should delegate to local data source', () async {
      when(() => mockLocalDataSource.getAllergies())
          .thenAnswer((_) async => tAllergies);

      final result = await repository.getAllergies();

      expect(result, tAllergies);
      verify(() => mockLocalDataSource.getAllergies()).called(1);
    });

    test('saveAllergy should delegate to local data source', () async {
      final tAllergy = tAllergies.first;
      when(() => mockLocalDataSource.saveAllergy(any()))
          .thenAnswer((_) async => {});

      await repository.saveAllergy(tAllergy);

      verify(() => mockLocalDataSource.saveAllergy(tAllergy)).called(1);
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
