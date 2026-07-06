import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/domain/repositories/allergy_repository.dart';
import 'package:orionhealth_health/features/allergies/domain/usecases/get_allergies_usecase.dart';

class MockAllergyRepository extends Mock implements AllergyRepository {}

void main() {
  late MockAllergyRepository mockRepository;
  late GetAllergiesUseCase useCase;

  setUp(() {
    mockRepository = MockAllergyRepository();
    useCase = GetAllergiesUseCase(mockRepository);
  });

  final tAllergies = [
    Allergy(id: 1, allergen: 'Peanuts', severity: AllergySeverity.severe),
    Allergy(id: 2, allergen: 'Dust', severity: AllergySeverity.mild),
  ];

  test('should get allergies from the repository', () async {
    // arrange
    when(() => mockRepository.getAllergies())
        .thenAnswer((_) async => tAllergies);

    // act
    final result = await useCase();

    // assert
    expect(result, tAllergies);
    verify(() => mockRepository.getAllergies()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
