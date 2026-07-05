import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/calendar_import/presentation/calendar_import_page.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_appointment.dart';
import 'package:orionhealth_health/features/calendar_import/domain/repositories/calendar_import_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/video_recorder.dart';

class MockCalendarImportRepository extends Mock implements CalendarImportRepository {}
class MockAppointmentRepository extends Mock implements AppointmentRepository {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockCalendarImportRepository mockCalendarRepository;
  late MockAppointmentRepository mockAppointmentRepository;
  late MockUserProfileRepository mockUserProfileRepository;

  setUpAll(() async {
    await configureDependencies();
    registerFallbackValue(Appointment(
      doctorName: '',
      specialty: '',
      dateTime: DateTime.now(),
      status: AppointmentStatus.upcoming,
    ));
    await initializeDateFormatting('es', null);
  });

  setUp(() {
    getIt.allowReassignment = true;
    mockCalendarRepository = MockCalendarImportRepository();
    mockAppointmentRepository = MockAppointmentRepository();
    mockUserProfileRepository = MockUserProfileRepository();

    getIt.registerSingleton<CalendarImportRepository>(mockCalendarRepository);
    getIt.registerSingleton<AppointmentRepository>(mockAppointmentRepository);
    getIt.registerSingleton<UserProfileRepository>(mockUserProfileRepository);

    // Default mocks
    when(() => mockUserProfileRepository.getUserProfile())
        .thenAnswer((_) async => null);
  });

  group('Calendar Import Flow - E2E Tests', () {
    testWidgets('E2E: Success Flow - Found and Import Appointments', (WidgetTester tester) async {
      final now = DateTime.now();
      final calendarAppointments = [
        CalendarAppointment(
          doctorName: 'Dr. Smith',
          specialty: 'Cardiología',
          dateTime: now.add(const Duration(days: 1)),
        ),
      ];

      when(() => mockCalendarRepository.hasPermissions()).thenAnswer((_) async => true);
      when(() => mockCalendarRepository.fetchMedicalAppointments()).thenAnswer((_) async => calendarAppointments);
      when(() => mockAppointmentRepository.saveAppointment(any())).thenAnswer((_) async {});

      await tester.pumpWidget(const MaterialApp(home: CalendarImportPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'calendar_import', '01_loaded');

      expect(find.text('Dr. Smith'), findsOneWidget);
      expect(find.text('Cardiología'), findsOneWidget);

      await tester.tap(find.text('IMPORTAR SELECCIONADOS'));
      await tester.pumpAndSettle();

      verify(() => mockAppointmentRepository.saveAppointment(any())).called(1);
      expect(find.text('Se importaron 1 citas con éxito'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'calendar_import', '02_success');
    });

    testWidgets('E2E: Empty Flow - No Appointments Found', (WidgetTester tester) async {
      when(() => mockCalendarRepository.hasPermissions()).thenAnswer((_) async => true);
      when(() => mockCalendarRepository.fetchMedicalAppointments()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(home: CalendarImportPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'calendar_import', '03_empty');

      expect(find.text('No se encontraron citas médicas en tu calendario'), findsOneWidget);
    });

    testWidgets('E2E: Permission Denied Flow', (WidgetTester tester) async {
      when(() => mockCalendarRepository.hasPermissions()).thenAnswer((_) async => false);
      when(() => mockCalendarRepository.requestPermissions()).thenAnswer((_) async => false);

      await tester.pumpWidget(const MaterialApp(home: CalendarImportPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'calendar_import', '04_permission_denied');

      expect(find.text('Se requiere permiso para acceder al calendario'), findsOneWidget);
    });
  });
}
