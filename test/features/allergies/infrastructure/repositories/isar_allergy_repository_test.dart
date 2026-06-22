import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/infrastructure/repositories/isar_allergy_repository.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionAllergy extends IsarCollection<Allergy> {}
class MockIsarCollection extends Mock implements IsarCollectionAllergy {}

class FakeAllergy extends Fake implements Allergy {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late IsarAllergyRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeAllergy());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = IsarAllergyRepository(mockIsar);

    when(() => mockIsar.allergys).thenReturn(mockCollection);
  });

  group('IsarAllergyRepository', () {
    test('saveAllergy puts allergy in collection', () async {
      final allergy = Allergy(allergen: 'Dust');
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveAllergy(allergy);

      verify(() => mockCollection.put(allergy)).called(1);
    });

    test('deleteAllergy deletes from collection', () async {
      const id = 1;
      when(() => mockCollection.delete(any())).thenAnswer((_) async => true);

      await repository.deleteAllergy(id);

      verify(() => mockCollection.delete(id)).called(1);
    });
  });
}
