import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/allergies/application/bloc/allergy_bloc.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/domain/repositories/allergy_repository.dart';

class MockAllergyRepository extends Mock implements AllergyRepository {}

class FakeAllergy extends Fake implements Allergy {}

void main() {
  late AllergyBloc allergyBloc;
  late MockAllergyRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeAllergy());
  });

  setUp(() {
    mockRepository = MockAllergyRepository();
    allergyBloc = AllergyBloc(mockRepository);
  });

  tearDown(() {
    allergyBloc.close();
  });

  group('AllergyBloc', () {
    final tAllergy = Allergy(id: 1, allergen: 'Peanuts');
    final tAllergies = <Allergy>[tAllergy];

    test('initial state should be AllergyInitial', () {
      expect(allergyBloc.state, const AllergyInitial());
    });

    group('LoadAllergies', () {
      test('emits [Loading, Loaded] when success', () async {
        when(() => mockRepository.getAllergies()).thenAnswer((_) async => tAllergies);

        allergyBloc.add(LoadAllergies());

        expectLater(
          allergyBloc.stream,
          emitsInOrder([
            const AllergyLoading(),
            AllergyLoaded(tAllergies),
          ]),
        );
      });

      test('emits [Loading, Error] when fails', () async {
        when(() => mockRepository.getAllergies()).thenThrow(Exception('DB Error'));

        allergyBloc.add(LoadAllergies());

        expectLater(
          allergyBloc.stream,
          emitsInOrder([
            const AllergyLoading(),
            const AllergyError('Exception: DB Error'),
          ]),
        );
      });
    });

    group('SaveAllergy', () {
      test('calls repository and reloads', () async {
        when(() => mockRepository.saveAllergy(any())).thenAnswer((_) async {});
        when(() => mockRepository.getAllergies()).thenAnswer((_) async => tAllergies);

        allergyBloc.add(SaveAllergy(tAllergy));

        await untilCalled(() => mockRepository.saveAllergy(any()));
        verify(() => mockRepository.saveAllergy(tAllergy)).called(1);
      });
    });

    group('DeleteAllergy', () {
      test('calls repository and reloads', () async {
        when(() => mockRepository.deleteAllergy(any())).thenAnswer((_) async {});
        when(() => mockRepository.getAllergies()).thenAnswer((_) async => []);

        allergyBloc.add(DeleteAllergy(1));

        await untilCalled(() => mockRepository.deleteAllergy(any()));
        verify(() => mockRepository.deleteAllergy(1)).called(1);
      });
    });
  });
}
