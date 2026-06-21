import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/appointments/presentation/pages/appointments_page.dart';
import 'package:orionhealth_health/features/email-citas/presentation/email_connect_page.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_cubit.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_state.dart';
import 'package:orionhealth_health/features/calendar_import/presentation/calendar_import_page.dart';
import 'package:orionhealth_health/features/calendar_import/application/calendar_import_cubit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}
class MockEmailCitasCubit extends Mock implements EmailCitasCubit {}
class MockCalendarImportCubit extends Mock implements CalendarImportCubit {}

class FakeAppointment extends Fake implements Appointment {}

void main() {
  late MockAppointmentRepository mockRepository;
  late MockEmailCitasCubit mockEmailCitasCubit;
  late MockCalendarImportCubit mockCalendarImportCubit;

  setUpAll(() {
    initializeDateFormatting('es', null);
    registerFallbackValue(FakeAppointment());
    registerFallbackValue(<Appointment>[]);
    registerFallbackValue(AppointmentStatus.upcoming);
  });

  setUp(() async {
    mockRepository = MockAppointmentRepository();
    mockEmailCitasCubit = MockEmailCitasCubit();
    mockCalendarImportCubit = MockCalendarImportCubit();

    when(() => mockEmailCitasCubit.state).thenReturn(EmailCitasInitial());
    when(() => mockEmailCitasCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCalendarImportCubit.state).thenReturn(const CalendarImportInitial());
    when(() => mockCalendarImportCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCalendarImportCubit.scanCalendar()).thenAnswer((_) async => Future.value());
    when(() => mockEmailCitasCubit.close()).thenAnswer((_) async {});
    when(() => mockCalendarImportCubit.close()).thenAnswer((_) async {});

    await getIt.reset();
    getIt.registerSingleton<AppointmentRepository>(mockRepository);
    getIt.registerFactory<EmailCitasCubit>(() => mockEmailCitasCubit);
    getIt.registerFactory<CalendarImportCubit>(() => mockCalendarImportCubit);
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

  testWidgets('can trigger refresh indicator', (WidgetTester tester) async {
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => <Appointment>[]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.fling(find.byType(RefreshIndicator), const Offset(0.0, 300.0), 1000.0);
    await tester.pump(); // Start refresh
    await tester.pump(const Duration(seconds: 1)); // Wait for animation
    await tester.pumpAndSettle();

    verify(() => mockRepository.getAllAppointments()).called(2);
  });

  testWidgets('email import button navigates to EmailConnectPage', (WidgetTester tester) async {
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => <Appointment>[]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final emailButton = find.byTooltip('Importar desde correo');
    expect(emailButton, findsOneWidget);

    await tester.tap(emailButton);
    await tester.pumpAndSettle();

    // Verify navigation (EmailConnectPage should be present)
    expect(find.byType(EmailConnectPage), findsOneWidget);
  });

  testWidgets('calendar import button navigates to CalendarImportPage', (WidgetTester tester) async {
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => <Appointment>[]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final calendarButton = find.byTooltip('Importar desde calendario');
    expect(calendarButton, findsOneWidget);

    await tester.tap(calendarButton);
    // Use pump twice instead of pumpAndSettle to avoid infinite animation issues
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CalendarImportPage), findsOneWidget);
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

  testWidgets('shows error snackbar when loading fails', (WidgetTester tester) async {
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => throw Exception('Test Error'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Trigger _loadAppointments
    await tester.pump(); // Rebuild after loading error state

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Test Error'), findsOneWidget);
  });

  testWidgets('can create a new appointment', (WidgetTester tester) async {
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => <Appointment>[]);
    when(() => mockRepository.saveAppointment(any()))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Nombre del Doctor'), 'Dr. Watson');
    await tester.enterText(find.widgetWithText(TextField, 'Especialidad'), 'General');

    await tester.tap(find.text('GUARDAR'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.saveAppointment(any(
      that: isA<Appointment>()
          .having((a) => a.doctorName, 'doctorName', 'Dr. Watson')
          .having((a) => a.specialty, 'specialty', 'General'),
    ))).called(1);
    verify(() => mockRepository.getAllAppointments()).called(2);
  });

  testWidgets('can edit an existing appointment', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    final appointment = Appointment(
      id: 1,
      doctorName: 'Dr. House',
      specialty: 'Diagnostics',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      status: AppointmentStatus.upcoming,
    );

    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => [appointment]);
    when(() => mockRepository.saveAppointment(any()))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dr. House', skipOffstage: false));
    await tester.pumpAndSettle();

    expect(find.text('Editar Cita'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Nombre del Doctor'), 'Dr. Wilson');

    await tester.tap(find.text('GUARDAR'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.saveAppointment(any(
      that: isA<Appointment>()
          .having((a) => a.id, 'id', 1)
          .having((a) => a.doctorName, 'doctorName', 'Dr. Wilson'),
    ))).called(1);
  });

  testWidgets('can delete an appointment', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    final appointment = Appointment(
      id: 1,
      doctorName: 'Dr. House',
      specialty: 'Diagnostics',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      status: AppointmentStatus.upcoming,
    );

    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => [appointment]);
    when(() => mockRepository.deleteAppointment(any()))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dr. House', skipOffstage: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ELIMINAR'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.deleteAppointment(1)).called(1);
  });

  testWidgets('can navigate calendar months', (WidgetTester tester) async {
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => <Appointment>[]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final initialMonthText = find.textContaining(DateFormat.MMMM('es').format(DateTime.now()).toUpperCase());
    expect(initialMonthText, findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    final nextMonth = DateTime(DateTime.now().year, DateTime.now().month + 1);
    expect(find.textContaining(DateFormat.MMMM('es').format(nextMonth).toUpperCase()), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(initialMonthText, findsOneWidget);
  });

  testWidgets('can change date and time in _AppointmentForm', (WidgetTester tester) async {
    when(() => mockRepository.getAllAppointments())
        .thenAnswer((_) async => <Appointment>[]);
    when(() => mockRepository.saveAppointment(any()))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Tap Fecha ListTile
    await tester.tap(find.text('Fecha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Tap Hora ListTile
    await tester.tap(find.text('Hora'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Change status
    await tester.tap(find.text('upcoming'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('completed').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('GUARDAR'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.saveAppointment(any(
      that: isA<Appointment>()
          .having((a) => a.status, 'status', AppointmentStatus.completed),
    ))).called(1);
  });
}
