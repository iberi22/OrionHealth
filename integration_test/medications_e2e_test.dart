import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import 'package:orionhealth_health/features/medications/application/medications_cubit.dart';
import 'package:orionhealth_health/features/medications/application/medications_state.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'utils/video_recorder.dart';

class MockMedicationsCubit extends Mock implements MedicationsCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMedicationsCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(Medication(id: 0, name: '', startDate: DateTime.now()));
  });

  setUp(() {
    mockCubit = MockMedicationsCubit();
    GetIt.instance.registerSingleton<MedicationsCubit>(mockCubit);

    when(() => mockCubit.loadMedications()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    GetIt.instance.unregister<MedicationsCubit>();
  });

  group('Medications Flow - E2E Tests', () {
    testWidgets('E2E: CRUD Medications', (WidgetTester tester) async {
      final meds = [
        Medication(id: 1, name: 'Aspirina', dosage: '100mg', startDate: DateTime.now()),
      ];

      when(() => mockCubit.state).thenReturn(MedicationsLoaded(meds));

      await tester.pumpWidget(const MaterialApp(home: MedicationsPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'medications', '01_list');

      expect(find.text('Aspirina'), findsOneWidget);

      // Add
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Nombre'), 'Metformina');
      await tester.enterText(find.widgetWithText(TextField, 'Dosis'), '500mg');

      when(() => mockCubit.saveMedication(any())).thenAnswer((_) async {
        meds.add(Medication(id: 2, name: 'Metformina', dosage: '500mg', startDate: DateTime.now()));
        when(() => mockCubit.state).thenReturn(MedicationsLoaded(meds));
      });

      await tester.tap(find.text('GUARDAR'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.saveMedication(any())).called(1);
      await tester.pumpAndSettle();
      expect(find.text('Metformina'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medications', '02_added');
    });
  });
}
