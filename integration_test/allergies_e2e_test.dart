import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/allergies/presentation/pages/allergies_page.dart';
import 'package:orionhealth_health/features/allergies/domain/repositories/allergy_repository.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
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

  group('Allergies Flow - True E2E Tests', () {
    testWidgets('E2E: CRUD Allergies', (WidgetTester tester) async {
      final repo = di.getIt<AllergyRepository>();
      final isar = di.getIt<Isar>();

      // Clean start for the test
      await isar.writeTxn(() async {
        await isar.allergys.clear();
      });

      // Add some initial data so it's not completely empty
      await repo.saveAllergy(
        Allergy(allergen: 'Penicilina', severity: AllergySeverity.severe),
      );
      await repo.saveAllergy(
        Allergy(allergen: 'Polen', severity: AllergySeverity.mild),
      );

      Widget buildApp() {
        return MaterialApp(
          home: const AllergiesPage(),
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
      await pumpUntilFound(tester, find.text('Penicilina'));
      await VideoRecorder.recordStep(tester, 'allergies', '01_list');

      expect(find.text('Penicilina'), findsOneWidget);
      expect(find.text('Polen'), findsOneWidget);

      // Add allergy
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Alérgeno'),
        'Nueces',
      );

      await tester.tap(find.text('GUARDAR'));

      await pumpUntilFound(tester, find.text('Nueces'));
      await VideoRecorder.recordStep(tester, 'allergies', '02_added');

      expect(find.text('Nueces'), findsOneWidget);

      // RESTART WIDGET TREE & VERIFY PERSISTENCE
      await tester.pumpWidget(Container()); // unmount
      await tester.pumpWidget(buildApp());
      await pumpUntilFound(tester, find.text('Nueces'));
      await VideoRecorder.recordStep(
        tester,
        'allergies',
        '03_restarted_persistence',
      );

      // Nueces should still be there from real DB
      expect(find.text('Nueces'), findsOneWidget);
    });
  });
}
