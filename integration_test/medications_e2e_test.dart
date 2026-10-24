import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:isar/isar.dart';
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

  group('Medications Flow - E2E Tests', () {
    testWidgets('E2E: CRUD Medications and Persistence', (
      WidgetTester tester,
    ) async {
      final repo = di.getIt<MedicationRepository>();
      final isar = di.getIt<Isar>();

      // Clean start for the test
      await isar.writeTxn(() async {
        await isar.medications.clear();
      });

      // Add initial data
      await repo.saveMedication(
        Medication(
          name: 'Aspirina',
          dosage: '100mg',
          startDate: DateTime.now(),
        ),
      );

      Widget buildApp() {
        return MaterialApp(
          home: const MedicationsPage(),
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

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'medications', '01_list');

      expect(find.text('Aspirina'), findsOneWidget);

      // Add new medication
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Nombre'),
        'Metformina',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Dosis'), '500mg');

      await tester.tap(find.text('GUARDAR'));
      await tester.pumpAndSettle();
      await tester
          .pumpAndSettle(); // additional pump might be needed for list update

      expect(find.text('Metformina'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'medications', '02_added');

      // Restart Widget Tree & Verify Persistence
      await tester.pumpWidget(Container()); // unmount
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(
        tester,
        'medications',
        '03_restarted_persistence',
      );

      // Both Aspirina and Metformina should be in the list
      expect(find.text('Aspirina'), findsOneWidget);
      expect(find.text('Metformina'), findsOneWidget);
    });
  });
}
