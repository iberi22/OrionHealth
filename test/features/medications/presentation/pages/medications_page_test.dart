import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import 'package:get_it/get_it.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late MockMedicationRepository mockRepository;

  setUpAll(() {
    mockRepository = MockMedicationRepository();
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<MedicationRepository>()) {
      getIt.registerSingleton<MedicationRepository>(mockRepository);
    }
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
      startDate: DateTime.now(),
      isActive: true,
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
  });
}
