import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_event.dart';
import 'package:orionhealth_health/features/calendar_import/presentation/calendar_import_page.dart';
import 'package:orionhealth_health/features/calendar_import/application/calendar_import_cubit.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import '../../../../core/golden_test_utils.dart';

class MockCalendarImportCubit extends Mock implements CalendarImportCubit {}

void main() {
  late MockCalendarImportCubit mockCubit;

  setUpAll(() {
    getIt.allowReassignment = true;
    registerFallbackValue(
      Appointment(
        doctorName: '',
        specialty: '',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      ),
    );
    registerFallbackValue(
      CalendarEvent(
        title: 'test',
        startDateTime: DateTime.now(),
      ),
    );
    registerFallbackValue(<Appointment>[]);
    registerFallbackValue(<CalendarEvent>[]);
    registerFallbackValue(AppointmentStatus.upcoming);
    registerFallbackValue(CalendarEventSource.unknown);
  });

  setUp(() {
    mockCubit = MockCalendarImportCubit();
    getIt.registerSingleton<CalendarImportCubit>(mockCubit);
  });

  Widget buildTestWidget(CalendarImportCubit cubit) {
    return wrapWithMaterial(
      BlocProvider<CalendarImportCubit>.value(
        value: cubit,
        child: const CalendarImportPage(),
      ),
    );
  }

  group('CalendarImportPage Golden Tests', () {
    testWidgets('CalendarImportPage - Loading State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(CalendarImportLoading());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.scanCalendar()).thenAnswer((_) async {});
      when(() => mockCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(mockCubit));
      await tester.pump();

      await expectLater(
        find.byType(CalendarImportPage),
        matchesGoldenFile("../../../../golden/reference/calendar_import_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('CalendarImportPage - Loaded With Appointments', (
      tester,
    ) async {
      setupGoldenTest(tester);

      final now = DateTime(2026, 6, 15, 10, 0);
      final appointments = [
        Appointment(
          id: 1,
          doctorName: 'Dr. Andrés Martínez',
          specialty: 'Cardiología',
          dateTime: now.add(const Duration(days: 1, hours: 4)),
          status: AppointmentStatus.upcoming,
        ),
        Appointment(
          id: 2,
          doctorName: 'Dra. María González',
          specialty: 'Endocrinología',
          dateTime: now.add(const Duration(days: 3)),
          status: AppointmentStatus.upcoming,
        ),
        Appointment(
          id: 3,
          doctorName: 'Dr. Carlos Pérez',
          specialty: 'Neurología',
          dateTime: now.add(const Duration(days: 7, hours: 2)),
          status: AppointmentStatus.upcoming,
        ),
      ];

      when(
        () => mockCubit.state,
      ).thenReturn(CalendarImportLoaded(appointments));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.scanCalendar()).thenAnswer((_) async {});
      when(() => mockCubit.importAppointments(any())).thenAnswer((_) async {});
      when(() => mockCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(mockCubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(CalendarImportPage),
        matchesGoldenFile("../../../../golden/reference/calendar_import_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('CalendarImportPage - Loaded Empty', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(CalendarImportLoaded([]));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.scanCalendar()).thenAnswer((_) async {});
      when(() => mockCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(mockCubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(CalendarImportPage),
        matchesGoldenFile("../../../../golden/reference/calendar_import_empty.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('CalendarImportPage - Permission Denied', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(CalendarImportPermissionDenied());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.scanCalendar()).thenAnswer((_) async {});
      when(() => mockCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget(mockCubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(CalendarImportPage),
        matchesGoldenFile("../../../../golden/reference/calendar_import_permission_denied.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
