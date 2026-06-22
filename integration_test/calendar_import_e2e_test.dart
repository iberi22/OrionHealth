import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/calendar_import/presentation/calendar_import_page.dart';
import 'package:orionhealth_health/features/calendar_import/application/calendar_import_cubit.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockCalendarImportCubit extends Mock implements CalendarImportCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockCalendarImportCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(<Appointment>[]);
  });

  setUp(() {
    mockCubit = MockCalendarImportCubit();
    getIt.registerSingleton<CalendarImportCubit>(mockCubit);

    when(() => mockCubit.scanCalendar()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    getIt.unregister<CalendarImportCubit>();
  });

  group('Calendar Import Flow - E2E Tests', () {
    testWidgets('E2E: Import Calendar', (WidgetTester tester) async {
      final appointments = [
        Appointment(
          id: '1',
          doctorName: 'Dr. Smith',
          specialty: 'Cardiology',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          location: 'Main Hospital',
        ),
      ];

      when(() => mockCubit.state).thenReturn(CalendarImportLoaded(foundAppointments: appointments));

      await tester.pumpWidget(const MaterialApp(home: CalendarImportPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'calendar', '01_loaded');

      expect(find.text('Dr. Smith'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);

      await tester.tap(find.text('IMPORTAR SELECCIONADOS'));
      verify(() => mockCubit.importAppointments(any())).called(1);
    });
  });
}
