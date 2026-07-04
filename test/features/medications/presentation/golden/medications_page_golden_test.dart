import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/medications/application/medications_cubit.dart';
import 'package:orionhealth_health/features/medications/application/medications_state.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import '../../../../core/golden_test_utils.dart';

class MockMedicationsCubit extends Mock implements MedicationsCubit {}

void main() {
  late MockMedicationsCubit mockCubit;

  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  setUp(() async {
    mockCubit = MockMedicationsCubit();
    await GetIt.I.reset();
    GetIt.I.registerFactory<MedicationsCubit>(() => mockCubit);

    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.loadMedications()).thenAnswer((_) async {});
    when(() => mockCubit.state).thenReturn(const MedicationsInitial());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Medications Page Golden Tests', () {
    testWidgets('Medications Page - Loading State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const MedicationsLoading());

      await tester.pumpWidget(wrapWithMaterial(const MedicationsPage()));
      await tester.pump();

      await expectLater(
        find.byType(MedicationsPage),
        matchesGoldenFile("goldens/medications_page_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Medications Page - Empty State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const MedicationsLoaded([]));

      await tester.pumpWidget(wrapWithMaterial(const MedicationsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MedicationsPage),
        matchesGoldenFile("goldens/medications_page_empty.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Medications Page - Loaded State', (tester) async {
      setupGoldenTest(tester);

      final medications = [
        Medication(
          id: 1,
          name: 'Ibuprofeno',
          dosage: '400mg',
          frequency: 'Cada 8 horas',
          startDate: DateTime(2024, 1, 1),
          isActive: true,
          notes: 'Tomar después de comer',
        ),
        Medication(
          id: 2,
          name: 'Amoxicilina',
          dosage: '500mg',
          frequency: 'Cada 12 horas',
          startDate: DateTime(2023, 12, 20),
          isActive: false,
          notes: 'Tratamiento terminado',
        ),
      ];

      when(() => mockCubit.state).thenReturn(MedicationsLoaded(medications));

      await tester.pumpWidget(wrapWithMaterial(const MedicationsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MedicationsPage),
        matchesGoldenFile("goldens/medications_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Medications Page - Error State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const MedicationsError('Error al cargar medicamentos'));

      await tester.pumpWidget(wrapWithMaterial(const MedicationsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MedicationsPage),
        matchesGoldenFile("goldens/medications_page_error.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
