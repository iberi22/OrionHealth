import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/emergency_contact.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/medical_condition.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/medical_id.dart';
import 'package:orionhealth_health/features/emergency/presentation/cubit/emergency_cubit.dart';
import 'package:orionhealth_health/features/emergency/presentation/pages/emergency_edit_page.dart';
import 'package:orionhealth_health/features/emergency/presentation/pages/emergency_id_page.dart';

class MockEmergencyCubit extends Mock implements EmergencyCubit {}

void main() {
  late MockEmergencyCubit mockCubit;

  final tMedicalId = MedicalIdEntity(
    userId: 'user-123',
    fullName: 'Jane Doe',
    dateOfBirth: DateTime(1990, 5, 15),
    bloodType: BloodType.oPositive,
    allergies: const ['Penicillin'],
    chronicConditions: const [MedicalCondition(name: 'Asthma', severity: ConditionSeverity.moderate)],
    currentMedications: const ['Albuterol'],
    primaryContact: const EmergencyContact(
      name: 'John Doe',
      relationship: 'Spouse',
      phone: '+15551234567',
    ),
    organDonor: OrganDonor.yes,
    lastUpdated: DateTime(2026, 8, 30),
  );

  setUpAll(() {
    registerFallbackValue(tMedicalId);
  });

  setUp(() {
    mockCubit = MockEmergencyCubit();
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget makeTestableWidget(Widget child) {
    return BlocProvider<EmergencyCubit>.value(
      value: mockCubit,
      child: MaterialApp(
        routes: {
          '/emergency/edit': (context) => const Scaffold(body: Text('Edit Screen')),
        },
        home: child,
      ),
    );
  }

  group('EmergencyIdPage', () {
    testWidgets('shows loading indicator when state is loading', (tester) async {
      when(() => mockCubit.state).thenReturn(const EmergencyState.loading());
      when(() => mockCubit.load(any())).thenAnswer((_) async {});

      await tester.pumpWidget(makeTestableWidget(const EmergencyIdPage(userId: 'user-123')));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when state is notSet', (tester) async {
      when(() => mockCubit.state).thenReturn(const EmergencyState.notSet());
      when(() => mockCubit.load(any())).thenAnswer((_) async {});

      await tester.pumpWidget(makeTestableWidget(const EmergencyIdPage(userId: 'user-123')));

      expect(find.text('No Medical ID set'), findsOneWidget);
      expect(find.text('Create Medical ID'), findsOneWidget);
    });

    testWidgets('shows critical card when state has medicalId', (tester) async {
      when(() => mockCubit.state).thenReturn(EmergencyState.loaded(tMedicalId));
      when(() => mockCubit.load(any())).thenAnswer((_) async {});

      await tester.pumpWidget(makeTestableWidget(const EmergencyIdPage(userId: 'user-123')));

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.textContaining('O Positivo'), findsWidgets);
      expect(find.text('ALERGIAS'), findsOneWidget);
      expect(find.text('Penicillin'), findsOneWidget);
      expect(find.text('MEDICAMENTOS'), findsOneWidget);
      expect(find.text('CONTACTO DE EMERGENCIA'), findsOneWidget);
      expect(find.textContaining('John Doe'), findsWidgets);
    });

    testWidgets('shows error text when error is present', (tester) async {
      when(() => mockCubit.state).thenReturn(const EmergencyState.error('Failed to load'));
      when(() => mockCubit.load(any())).thenAnswer((_) async {});

      await tester.pumpWidget(makeTestableWidget(const EmergencyIdPage(userId: 'user-123')));

      expect(find.text('Error: Failed to load'), findsOneWidget);
    });
  });

  group('EmergencyEditPage', () {
    testWidgets('renders edit form with initial fields and saves successfully', (tester) async {
      when(() => mockCubit.state).thenReturn(EmergencyState.loaded(tMedicalId));
      when(() => mockCubit.save(any())).thenAnswer((_) async {});

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(makeTestableWidget(const EmergencyEditPage(userId: 'user-123')));
      await tester.pumpAndSettle();

      expect(find.text('Medical ID'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);

      final saveButton = find.widgetWithText(FilledButton, 'Guardar Medical ID');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      verify(() => mockCubit.save(any())).called(1);
    });
  });
}
