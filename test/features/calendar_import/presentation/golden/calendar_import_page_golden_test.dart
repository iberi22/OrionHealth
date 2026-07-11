import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_appointment.dart';
import 'package:orionhealth_health/features/calendar_import/presentation/calendar_import_page.dart';
import 'package:orionhealth_health/features/calendar_import/application/calendar_import_cubit.dart';
import '../../../../core/golden_test_utils.dart';

class MockCalendarImportCubit extends Mock implements CalendarImportCubit {}

void main() {
  late MockCalendarImportCubit mockCubit;

  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  setUp(() async {
    mockCubit = MockCalendarImportCubit();
    await GetIt.I.reset();
    GetIt.I.registerSingleton<CalendarImportCubit>(mockCubit);

    // Default mock behavior
    when(() => mockCubit.scanCalendar()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Calendar Import Page Golden Tests', () {
    testWidgets('Calendar Import Page - Loaded with Appointments', (tester) async {
      setupGoldenTest(tester);

      final now = DateTime(2026, 6, 15, 10, 0);
      final appointments = [
        CalendarAppointment(
          doctorName: 'Dr. García',
          specialty: 'Cardiología',
          dateTime: now.add(const Duration(days: 2)),
        ),
        CalendarAppointment(
          doctorName: 'Dra. López',
          specialty: 'Dermatología',
          dateTime: now.add(const Duration(days: 5)),
        ),
      ];

      when(() => mockCubit.state).thenReturn(CalendarImportLoaded(appointments));
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([CalendarImportLoaded(appointments)]));

      await tester.pumpWidget(wrapWithMaterial(const CalendarImportPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CalendarImportPage),
        matchesGoldenFile("../../../../../golden/reference/calendar_import_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Calendar Import Page - Permission Denied', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(CalendarImportPermissionDenied());
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([CalendarImportPermissionDenied()]));

      await tester.pumpWidget(wrapWithMaterial(const CalendarImportPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CalendarImportPage),
        matchesGoldenFile("../../../../../golden/reference/calendar_import_page_permission_denied.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
