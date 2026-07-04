import 'package:device_calendar/device_calendar.dart' as device;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart';
import 'package:orionhealth_health/features/calendar_import/presentation/calendar_import_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'utils/video_recorder.dart';

class MockCalendarApiDatasource extends Mock implements CalendarApiDatasource {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockCalendarApiDatasource mockDatasource;

  setUpAll(() async {
    await di.configureDependencies();
    await initializeDateFormatting('es', null);
    tz.initializeTimeZones();
  });

  setUp(() {
    mockDatasource = MockCalendarApiDatasource();
    // Override the datasource in GetIt
    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<CalendarApiDatasource>(mockDatasource);
  });

  tearDown(() {
    di.getIt.unregister<CalendarApiDatasource>();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: const CalendarImportPage(),
      theme: ThemeData.dark(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }

  group('Calendar Import Flow - E2E Tests', () {
    testWidgets('E2E: Success Flow - Scan and Import', (WidgetTester tester) async {
      // Mock Permission granted
      when(() => mockDatasource.hasPermissions()).thenAnswer((_) async => true);

      // Mock Calendar and Events
      final medicalCalendar = device.Calendar(id: 'cal1', name: 'My Health');
      final medicalEvent = device.Event(
        'ev1',
        title: 'Cita con Dr. Mendez',
        description: 'Control de Cardiología',
        start: tz.TZDateTime.now(tz.local).add(const Duration(days: 1)),
      );

      when(() => mockDatasource.getCalendars()).thenAnswer((_) async => [medicalCalendar]);
      when(() => mockDatasource.getEvents(any(), startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
          .thenAnswer((_) async => [medicalEvent]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'calendar_import', '01_loaded_list');

      // Verify discovered event
      expect(find.text('Dr. Mendez'), findsOneWidget);
      expect(find.text('cita'), findsOneWidget);

      // Tap Import
      await tester.tap(find.text('IMPORTAR SELECCIONADOS'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'calendar_import', '02_import_success');

      // Verify success snackbar
      expect(find.textContaining('Se importaron 1 citas con éxito'), findsOneWidget);
    });

    testWidgets('E2E: Permission Denied Flow', (WidgetTester tester) async {
      // Mock Permission NOT granted and request fails
      when(() => mockDatasource.hasPermissions()).thenAnswer((_) async => false);
      when(() => mockDatasource.requestPermissions()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'calendar_import', '03_permission_denied');

      expect(find.text('Se requiere permiso para acceder al calendario'), findsOneWidget);
      expect(find.text('Solicitar Permiso'), findsOneWidget);
    });

    testWidgets('E2E: Empty Results Flow', (WidgetTester tester) async {
      // Mock Permission granted
      when(() => mockDatasource.hasPermissions()).thenAnswer((_) async => true);

      // Mock No calendars or no events
      when(() => mockDatasource.getCalendars()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await VideoRecorder.recordStep(tester, 'calendar_import', '04_empty_state');

      expect(find.text('No se encontraron citas médicas en tu calendario'), findsOneWidget);
    });
  });
}
