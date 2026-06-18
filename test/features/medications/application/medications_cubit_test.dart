import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/application/medications_cubit.dart';
import 'package:orionhealth_health/features/medications/application/medications_state.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}
class FakeMedication extends Fake implements Medication {}

void main() {
  late MockMedicationRepository mockRepository;
  late MedicationsCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeMedication());
  });

  setUp(() {
    mockRepository = MockMedicationRepository();
    cubit = MedicationsCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('MedicationsCubit', () {
    final tMedication = Medication(
      id: 1,
      name: 'Test Med',
      startDate: DateTime.now(),
    );

    test('initial state should be MedicationsInitial', () {
      expect(cubit.state, equals(MedicationsInitial()));
    });

    test('loadMedications emits [MedicationsLoading, MedicationsLoaded] on success', () async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => [tMedication]);

      final expected = [
        MedicationsLoading(),
        MedicationsLoaded([tMedication]),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));

      await cubit.loadMedications();
      verify(() => mockRepository.getAllMedications()).called(1);
    });

    test('loadMedications emits [MedicationsLoading, MedicationsError] on failure', () async {
      when(() => mockRepository.getAllMedications()).thenThrow(Exception('Failed to load'));

      final expected = [
        MedicationsLoading(),
        const MedicationsError('Exception: Failed to load'),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));

      await cubit.loadMedications();
      verify(() => mockRepository.getAllMedications()).called(1);
    });

    test('saveMedication emits [MedicationsLoading, MedicationsLoaded] on success', () async {
      when(() => mockRepository.saveMedication(any())).thenAnswer((_) async => {});
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => [tMedication]);

      final expected = [
        MedicationsLoading(),
        MedicationsLoaded([tMedication]),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));

      await cubit.saveMedication(tMedication);
      verify(() => mockRepository.saveMedication(any())).called(1);
      verify(() => mockRepository.getAllMedications()).called(1);
    });

    test('deleteMedication emits [MedicationsLoading, MedicationsLoaded] on success', () async {
      when(() => mockRepository.deleteMedication(any())).thenAnswer((_) async => {});
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => []);

      final expected = [
        MedicationsLoading(),
        const MedicationsLoaded([]),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));

      await cubit.deleteMedication(1);
      verify(() => mockRepository.deleteMedication(1)).called(1);
      verify(() => mockRepository.getAllMedications()).called(1);
    });
  });
}
