import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/calendar_import/presentation/calendar_import_page.dart';
import 'package:orionhealth_health/features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'utils/video_recorder.dart';

class MockCalendarApiDatasource extends Mock implements CalendarApiDatasource {}
class MockAppointmentRepository extends Mock implements AppointmentRepository {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockCalendarApiDatasource mockCalendarDatasource;
  late MockAppointmentRepository mockAppointmentRepo;
  late MockUserProfileRepository mockUserProfileRepo;

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;
    await initializeDateFormatting('es', null);

    registerFallbackValue(Appointment(
      doctorName: '',
      specialty: '',
      dateTime: DateTime.now(),
      status: AppointmentStatus.upcoming,
    ));
  });

  setUp(() {
    mockCalendarDatasource = MockCalendarApiDatasource();
    mockAppointmentRepo = MockAppointmentRepository();
    mockUserProfileRepo = MockUserProfileRepository();

    di.getIt.registerSingleton<CalendarApiDatasource>(mockCalendarDatasource);
    di.getIt.registerSingleton<AppointmentRepository>(mockAppointmentRepo);
    di.getIt.registerSingleton<UserProfileRepository>(mockUserProfileRepo);
  });

  tearDown(() {
    di.getIt.unregister<CalendarApiDatasource>();
    di.getIt.unregister<AppointmentRepository>();
    di.getIt.unregister<UserProfileRepository>();
  });

  group('Calendar Import Flow - E2E Tests', () {
    testWidgets('E2E: Medical events filtering and import', (WidgetTester tester) async {
      // 1. Mock setup
      when(() => mockUserProfileRepo.getUserProfile()).thenAnswer((_) async => UserProfile(uniqueId: 'PAT-123'));
      when(() => mockCalendarDatasource.hasPermissions()).thenAnswer((_) async => true);

      final mockCalendar = Calendar(id: 'cal1', name: 'Personal', isReadOnly: false);
      when(() => mockCalendarDatasource.getCalendars()).thenAnswer((_) async => [mockCalendar]);

      final now = DateTime.now();
      final events = [
        Event('cal1', title: 'Cita con Dr. Garcia', start: now.add(const Duration(days: 1)), end: now.add(const Duration(days: 1, hours: 1))),
        Event('cal1', title: 'Almuerzo con amigos', start: now.add(const Duration(days: 2)), end: now.add(const Duration(days: 2, hours: 1))),
        Event('cal1', title: 'Consulta Especialista Cardiología', start: now.add(const Duration(days: 3)), end: now.add(const Duration(days: 3, hours: 1))),
      ];

      when(() => mockCalendarDatasource.getEvents(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
          .thenAnswer((_) async => events);

      when(() => mockAppointmentRepo.saveAppointment(any())).thenAnswer((_) async => 1);

      // 2. Launch Page
      await tester.pumpWidget(
        MaterialApp(
          home: const CalendarImportPage(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
        ),
      );

      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'calendar_import', '01_scanning_and_loaded');

      // 3. Verify filtering (should only show 2 medical events)
      expect(find.text('Dr. Garcia'), findsOneWidget);
      expect(find.text('Cardiología'), findsOneWidget);
      expect(find.text('Almuerzo con amigos'), findsNothing);

      // 4. Perform Import
      await tester.tap(find.text('IMPORTAR SELECCIONADOS'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'calendar_import', '02_success');

      // 5. Verify results
      verify(() => mockAppointmentRepo.saveAppointment(any())).called(2);
      expect(find.textContaining('Se importaron 2 citas con éxito'), findsOneWidget);
    });
  });
}
