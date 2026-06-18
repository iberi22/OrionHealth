import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/allergies/application/allergies_cubit.dart';
import 'package:orionhealth_health/features/allergies/application/allergies_state.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/domain/repositories/allergy_repository.dart';

class MockAllergyRepository extends Mock implements AllergyRepository {}

class AllergyFake extends Fake implements Allergy {}

void main() {
  late AllergiesCubit cubit;
  late MockAllergyRepository mockRepository;

  final tAllergy = Allergy(id: 1, allergen: 'Peanuts');
  final tAllergies = [tAllergy];

  setUpAll(() {
    registerFallbackValue(AllergyFake());
  });

  setUp(() {
    mockRepository = MockAllergyRepository();
    cubit = AllergiesCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('AllergiesCubit', () {
    test('initial state should be AllergiesInitial', () {
      expect(cubit.state, equals(AllergiesInitial()));
    });

    test('emits [Loading, Loaded] when loadAllergies is successful', () async {
      when(
        () => mockRepository.getAllergies(),
      ).thenAnswer((_) async => tAllergies);

      final expectStates = [AllergiesLoading(), AllergiesLoaded(tAllergies)];

      expectLater(cubit.stream, emitsInOrder(expectStates));

      await cubit.loadAllergies();
    });

    test('emits [Loading, Error] when loadAllergies fails', () async {
      when(
        () => mockRepository.getAllergies(),
      ).thenThrow(Exception('Failed to load'));

      final expectStates = [
        AllergiesLoading(),
        const AllergiesError('Exception: Failed to load'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectStates));

      await cubit.loadAllergies();
    });

    test('calls saveAllergy and reloads allergies on success', () async {
      when(() => mockRepository.saveAllergy(any())).thenAnswer((_) async => {});
      when(
        () => mockRepository.getAllergies(),
      ).thenAnswer((_) async => tAllergies);

      await cubit.saveAllergy(tAllergy);

      verify(() => mockRepository.saveAllergy(tAllergy)).called(1);
      verify(() => mockRepository.getAllergies()).called(1);
    });

    test('calls deleteAllergy and reloads allergies on success', () async {
      when(
        () => mockRepository.deleteAllergy(any()),
      ).thenAnswer((_) async => {});
      when(() => mockRepository.getAllergies()).thenAnswer((_) async => []);

      await cubit.deleteAllergy(1);

      verify(() => mockRepository.deleteAllergy(1)).called(1);
      verify(() => mockRepository.getAllergies()).called(1);
    });
  });
}
