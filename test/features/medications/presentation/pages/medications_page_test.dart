import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import 'package:get_it/get_it.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

class FakeMedication extends Fake implements Medication {}

void main() {
  late MockMedicationRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeMedication());
    mockRepository = MockMedicationRepository();
    final getIt = GetIt.instance;
    if (getIt.isRegistered<MedicationRepository>()) {
      getIt.unregister<MedicationRepository>();
    }
    getIt.registerSingleton<MedicationRepository>(mockRepository);
  });

  setUp(() {
    reset(mockRepository);
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: MedicationsPage(),
    );
  }

  group('MedicationsPage Tests', () {
    final tMedication = Medication(
      id: 1,
      name: 'Ibuprofen',
      dosage: '400mg',
      frequency: 'Every 8 hours',
      startDate: DateTime(2023, 1, 1),
      isActive: true,
      notes: 'Test notes',
    );

    testWidgets('shows loading state initially', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays list of medications when loaded', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => [tMedication]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Medicamentos'), findsOneWidget);
      expect(find.text('Ibuprofen'), findsOneWidget);
      expect(find.text('ACTIVO'), findsOneWidget);
    });

    testWidgets('displays empty message when no medications', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No hay medicamentos registrados'), findsOneWidget);
    });

    testWidgets('displays error message when loading fails', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenThrow(Exception('Error loading'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Exception: Error loading'), findsOneWidget);
    });

    testWidgets('opens form when clicking add button', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the add icon specifically in the AppBar
      await tester.tap(find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.add),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Medicamento'), findsOneWidget);
    });

    testWidgets('opens form when clicking add button in empty state', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Agregar Medicamento'));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Medicamento'), findsOneWidget);
    });

    testWidgets('opens edit form when clicking medication card', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => [tMedication]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ibuprofen'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Medicamento'), findsOneWidget);
      expect(find.text('Ibuprofen'), findsNWidgets(2)); // One in list, one in form
    });

    testWidgets('submits new medication through form', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => []);
      when(() => mockRepository.saveMedication(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.add),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Nombre'), 'Paracetamol');
      await tester.enterText(find.widgetWithText(TextField, 'Dosis'), '500mg');
      await tester.enterText(find.widgetWithText(TextField, 'Frecuencia'), 'Every 6 hours');

      await tester.tap(find.text('GUARDAR'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveMedication(any())).called(1);
      expect(find.text('Nuevo Medicamento'), findsNothing);
    });

    testWidgets('shows error when submitting form without name', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.add),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('GUARDAR'));
      await tester.pump(); // SnackBar shows up

      expect(find.text('El nombre es requerido'), findsOneWidget);
    });

    testWidgets('deletes medication from edit form', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => [tMedication]);
      when(() => mockRepository.deleteMedication(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ibuprofen'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      verify(() => mockRepository.deleteMedication(tMedication.id)).called(1);
      expect(find.text('Editar Medicamento'), findsNothing);
    });

    testWidgets('displays inactive medication correctly', (WidgetTester tester) async {
      final inactiveMed = Medication(
        id: 2,
        name: 'Aspirin',
        dosage: '100mg',
        startDate: DateTime.now(),
        isActive: false,
      );
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => [inactiveMed]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('INACTIVO'), findsOneWidget);
      expect(find.text('100mg'), findsOneWidget);
    });

    testWidgets('can toggle active state in form', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => [tMedication]);
      when(() => mockRepository.saveMedication(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ibuprofen'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pump();

      await tester.tap(find.text('ACTUALIZAR'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveMedication(any(that: predicate<Medication>((m) => !m.isActive))))
          .called(1);
    });

    testWidgets('can pick date in form', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.add),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fecha de inicio'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('supports refreshing medications list', (WidgetTester tester) async {
      when(() => mockRepository.getAllMedications()).thenAnswer((_) async => [tMedication]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      verify(() => mockRepository.getAllMedications()).called(2);
    });
  });
}
