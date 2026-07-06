import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/domain/repositories/allergy_repository.dart';
import 'package:orionhealth_health/features/allergies/domain/usecases/save_allergy_usecase.dart';

class MockAllergyRepository extends Mock implements AllergyRepository {}

class FakeAllergy extends Fake implements Allergy {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAllergy());
  });

  late MockAllergyRepository mockRepository;
  late SaveAllergyUseCase useCase;

  setUp(() {
    mockRepository = MockAllergyRepository();
    useCase = SaveAllergyUseCase(mockRepository);
  });

  final tAllergy = Allergy(
    id: 1,
    allergen: 'Peanuts',
    severity: AllergySeverity.severe,
  );

  test('should save allergy in the repository', () async {
    // arrange
    when(() => mockRepository.saveAllergy(any()))
        .thenAnswer((_) async => {});

    // act
    await useCase(tAllergy);

    // assert
    verify(() => mockRepository.saveAllergy(tAllergy)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
