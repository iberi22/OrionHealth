import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/application/bloc/medication_bloc.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

class FakeMedication extends Fake implements Medication {}

void main() {
  late MedicationBloc medicationBloc;
  late MockMedicationRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeMedication());
  });

  setUp(() {
    mockRepository = MockMedicationRepository();
    medicationBloc = MedicationBloc(mockRepository);
  });

  tearDown(() {
    medicationBloc.close();
  });

  group('MedicationBloc', () {
    final tMedication = Medication(
      id: 1,
      name: 'Aspirin',
      dosage: '100mg',
      startDate: DateTime(2023, 1, 1),
    );
    final tMedications = <Medication>[tMedication];

    test('initial state should be MedicationInitial', () {
      expect(medicationBloc.state, const MedicationInitial());
    });

    group('LoadMedications', () {
      test('emits [Loading, Loaded] when success', () async {
        when(() => mockRepository.getAllMedications()).thenAnswer((_) async => tMedications);

        medicationBloc.add(LoadMedications());

        expectLater(
          medicationBloc.stream,
          emitsInOrder([
            const MedicationLoading(),
            MedicationLoaded(tMedications),
          ]),
        );
      });

      test('emits [Loading, Error] when fails', () async {
        when(() => mockRepository.getAllMedications()).thenThrow(Exception('DB Error'));

        medicationBloc.add(LoadMedications());

        expectLater(
          medicationBloc.stream,
          emitsInOrder([
            const MedicationLoading(),
            const MedicationError('Exception: DB Error'),
          ]),
        );
      });
    });

    group('SaveMedication', () {
      test('calls repository and reloads', () async {
        when(() => mockRepository.saveMedication(any())).thenAnswer((_) async {});
        when(() => mockRepository.getAllMedications()).thenAnswer((_) async => tMedications);

        medicationBloc.add(SaveMedication(tMedication));

        await untilCalled(() => mockRepository.saveMedication(any()));
        verify(() => mockRepository.saveMedication(tMedication)).called(1);
      });
    });

    group('DeleteMedication', () {
      test('calls repository and reloads', () async {
        when(() => mockRepository.deleteMedication(any())).thenAnswer((_) async {});
        when(() => mockRepository.getAllMedications()).thenAnswer((_) async => []);

        medicationBloc.add(DeleteMedication(1));

        await untilCalled(() => mockRepository.deleteMedication(any()));
        verify(() => mockRepository.deleteMedication(1)).called(1);
      });
    });
  });
}
