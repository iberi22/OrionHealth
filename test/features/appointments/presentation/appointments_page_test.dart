import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/presentation/pages/appointments_page.dart';
import 'package:intl/date_symbol_data_local.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  late MockAppointmentRepository mockRepository;

  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  setUp(() async {
    mockRepository = MockAppointmentRepository();
    await getIt.reset();
    getIt.registerSingleton<AppointmentRepository>(mockRepository);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: Scaffold(body: AppointmentsPage()),
    );
  }

  testWidgets('shows loading state initially', (WidgetTester tester) async {
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => <Appointment>[]);

    await tester.pumpWidget(createWidgetUnderTest());

    // Initially loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(); // Finish loading

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows appointments list when data is available', (WidgetTester tester) async {
    final appointment = Appointment(
      id: 1,
      doctorName: 'Dr. Gregory House',
      specialty: 'Diagnostic Medicine',
      // Ensure the appointment is considered upcoming relative to "DateTime.now()" in the page by using a date in the future.
      dateTime: DateTime.now().add(const Duration(days: 1)),
      status: AppointmentStatus.upcoming,
    );

    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => [appointment]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // In a sliver list, widgets might be lazy-loaded or not visible immediately depending on size.
    // We can try to scroll or find them. For a single item it should be visible.
    expect(find.text('Dr. Gregory House', skipOffstage: false), findsOneWidget);
    expect(find.text('Diagnostic Medicine', skipOffstage: false), findsOneWidget);
    expect(find.text('UPCOMING', skipOffstage: false), findsOneWidget);
  });

  testWidgets('shows empty state when no appointments exist', (WidgetTester tester) async {
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => <Appointment>[]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('No hay citas próximas', skipOffstage: false), findsOneWidget);
    expect(find.text('No hay citas pasadas', skipOffstage: false), findsOneWidget);
  });

  testWidgets('opens floating action button to add appointment', (WidgetTester tester) async {
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => <Appointment>[]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final iconAdd = find.byIcon(Icons.add);
    expect(iconAdd, findsWidgets);

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.text('Nueva Cita'), findsOneWidget);
    expect(find.text('Nombre del Doctor'), findsOneWidget);
  });
}
