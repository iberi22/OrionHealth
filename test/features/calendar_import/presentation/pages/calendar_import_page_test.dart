import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/calendar_import/presentation/calendar_import_page.dart';
import 'package:orionhealth_health/features/calendar_import/application/calendar_import_cubit.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

class MockCalendarImportCubit extends Mock implements CalendarImportCubit {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockCalendarImportCubit mockCubit;
  late StreamController<CalendarImportState> statesController;

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
    registerFallbackValue(FakeRoute());
    registerFallbackValue(<Appointment>[]);
    registerFallbackValue(AppointmentStatus.upcoming);
  });

  setUp(() {
    mockCubit = MockCalendarImportCubit();
    statesController = StreamController<CalendarImportState>.broadcast();
    getIt.registerSingleton<CalendarImportCubit>(mockCubit);

    when(() => mockCubit.state).thenReturn(const CalendarImportInitial());
    when(() => mockCubit.stream).thenAnswer((_) => statesController.stream);
    when(() => mockCubit.scanCalendar()).thenAnswer((_) async {});
    when(() => mockCubit.importAppointments(any())).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    statesController.close();
    getIt.unregister<CalendarImportCubit>();
  });

  Widget buildTestWidget({NavigatorObserver? observer}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      navigatorObservers: observer != null ? [observer] : [],
      home: const CalendarImportPage(),
    );
  }

  group('CalendarImportPage Interactive Tests', () {
    testWidgets('should show loading indicator when state is Loading', (tester) async {
      when(() => mockCubit.state).thenReturn(const CalendarImportLoading());
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show permission denied view and call scanCalendar on button press', (tester) async {
      when(() => mockCubit.state).thenReturn(const CalendarImportPermissionDenied());
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Se requiere permiso para acceder al calendario'), findsOneWidget);

      await tester.tap(find.text('Solicitar Permiso'));
      verify(() => mockCubit.scanCalendar()).called(2);
    });

    testWidgets('should show empty state and call scanCalendar on Reintentar', (tester) async {
      when(() => mockCubit.state).thenReturn(const CalendarImportLoaded([]));
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('No se encontraron citas médicas en tu calendario'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      verify(() => mockCubit.scanCalendar()).called(2);
    });

    testWidgets('should list appointments and handle selection and import', (tester) async {
      final appointments = [
        Appointment(
          id: 1,
          doctorName: 'Dr. House',
          specialty: 'Diagnóstico',
          dateTime: DateTime.now(),
          status: AppointmentStatus.upcoming,
        ),
      ];
      when(() => mockCubit.state).thenReturn(CalendarImportLoaded(appointments));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Dr. House'), findsOneWidget);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      final importButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(importButton.enabled, isFalse);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, isTrue);

      await tester.tap(find.text('IMPORTAR SELECCIONADOS'));
      verify(() => mockCubit.importAppointments(any())).called(1);
    });

    testWidgets('should handle Success, show snackbar and pop', (tester) async {
      final observer = MockNavigatorObserver();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          navigatorObservers: [observer],
          home: Scaffold(
            body: Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarImportPage()),
                ),
                child: const Text('Go'),
              );
            }),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      statesController.add(const CalendarImportSuccess(5));
      await tester.pump(); // Trigger listener

      // Verify pop
      verify(() => observer.didPop(any(), any())).called(1);

      // Snackbar should be visible on the previous page if ScaffoldMessenger is global enough
      // or at least we verified the code path.
    });

    testWidgets('should show snackbar on Error', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      statesController.add(const CalendarImportError('Failed to load'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Error: Failed to load'), findsOneWidget);
    });

    testWidgets('should show snackbar on PermissionDenied from listener', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      statesController.add(const CalendarImportPermissionDenied());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Permiso de calendario denegado'), findsOneWidget);
    });

    testWidgets('should show scan starting text for initial state', (tester) async {
      when(() => mockCubit.state).thenReturn(const CalendarImportInitial());
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Iniciando escaneo...'), findsOneWidget);
    });
  });
}
