import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_monitor_page.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:isar/isar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'utils/pump_until.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.configureDependencies();
    await initializeDateFormatting('es', null);
  });

  group('Vitals Feature - E2E Tests', () {
    testWidgets(
      'E2E: Full Vitals Flow - Dashboard, Manual Entry, and Persistence',
      (WidgetTester tester) async {
        final repo = di.getIt<VitalSignRepository>();
        final isar = di.getIt<Isar>();

        // Clean start for the test
        await isar.writeTxn(() async {
          await isar.vitalSigns.clear();
        });

        // Add some initial data so it's not completely empty
        final now = DateTime.now();
        await repo.saveVitalSigns([
          VitalSign(type: VitalSignType.heartRate, value: 72, dateTime: now),
          VitalSign(
            type: VitalSignType.bloodPressureSystolic,
            value: 120,
            dateTime: now,
          ),
          VitalSign(
            type: VitalSignType.bloodPressureDiastolic,
            value: 80,
            dateTime: now,
          ),
        ]);

        Widget buildApp() {
          return MaterialApp(
            home: const VitalsPage(),
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

        // 1. DASHBOARD VIEW
        await tester.pumpWidget(buildApp());
        await pumpUntilFound(tester, find.text('72.0'));
        await VideoRecorder.recordStep(tester, 'vitals', '01_dashboard');

        expect(find.text('72.0'), findsOneWidget);
        expect(find.text('120/80'), findsOneWidget);
        expect(find.textContaining('RITMO CARDÍACO'), findsOneWidget);

        // 2. MANUAL ENTRY
        await tester.tap(find.text('Agregar Signo Vital'));
        await tester.pumpAndSettle();
        await VideoRecorder.recordStep(tester, 'vitals', '02_add_bottom_sheet');

        await tester.enterText(find.widgetWithText(TextField, 'Valor'), '75');
        await tester.tap(find.text('Guardar'));
        await pumpUntilFound(tester, find.text('75.0'));
        await VideoRecorder.recordStep(
          tester,
          'vitals',
          '03_after_manual_entry',
        );

        // The widget might display the updated value
        expect(find.text('75.0'), findsOneWidget);

        // 3. RESTART WIDGET TREE & VERIFY PERSISTENCE
        await tester.pumpWidget(Container()); // unmount
        await tester.pumpWidget(buildApp());
        await pumpUntilFound(tester, find.text('75.0'));
        await VideoRecorder.recordStep(
          tester,
          'vitals',
          '04_restarted_persistence',
        );

        // 75.0 should still be there from real DB
        expect(find.text('75.0'), findsOneWidget);

        // 4. NAVIGATION TO MONITOR
        await tester.tap(find.byIcon(Icons.monitor_heart));
        await tester.pumpAndSettle();
        expect(find.byType(VitalsMonitorPage), findsOneWidget);
        await VideoRecorder.recordStep(tester, 'vitals', '05_monitor_page');
      },
    );
  });
}
