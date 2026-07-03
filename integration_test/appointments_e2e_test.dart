import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/appointments/presentation/pages/appointments_page.dart';
import 'package:orionhealth_health/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.configureDependencies();
    await initializeDateFormatting('es', null);
  });

  group('Appointments Flow - E2E Tests', () {
    testWidgets('E2E: Full CRUD flow with real database', (WidgetTester tester) async {
      final repo = di.getIt<AppointmentRepository>();

      // Clean start for the test
      final all = await repo.getAppointments();
      for (final a in all) {
        await repo.deleteAppointment(a.id);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: const AppointmentsPage(),
          theme: ThemeData.dark(),
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
      await VideoRecorder.recordStep(tester, 'appointments', '01_initial_list');

      // 1. CREATE
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'appointments', '02_form_open');

      await tester.enterText(find.widgetWithText(TextField, 'Nombre del Doctor'), 'Dr. Mendez');
      await tester.enterText(find.widgetWithText(TextField, 'Especialidad'), 'Cardiología');
      await tester.enterText(find.widgetWithText(TextField, 'Notas (Opcional)'), 'Chequeo anual');

      await tester.tap(find.text('GUARDAR'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'appointments', '03_after_save');

      expect(find.text('Dr. Mendez'), findsOneWidget);
      expect(find.text('Cardiología'), findsOneWidget);

      // 2. READ / UPDATE
      await tester.tap(find.text('Dr. Mendez'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Nombre del Doctor'), 'Dr. Mendez Editado');
      await tester.tap(find.text('GUARDAR'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Mendez Editado'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'appointments', '04_after_edit');

      // 3. DELETE
      await tester.tap(find.text('Dr. Mendez Editado'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ELIMINAR'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Mendez Editado'), findsNothing);
      await VideoRecorder.recordStep(tester, 'appointments', '05_after_delete');
    });
  });
}
