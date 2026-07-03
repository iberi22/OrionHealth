import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/sync/presentation/pages/sync_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.configureDependencies();
  });

  group('Sync Flow - E2E Tests', () {
    testWidgets('E2E: Sync data using real SyncPage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SyncPage(),
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
      await VideoRecorder.recordStep(tester, 'sync', '01_initial');

      // Verify page elements
      expect(find.text('Sincronización'), findsWidgets);
      expect(find.text('SINCRONIZAR AHORA'), findsOneWidget);

      await tester.tap(find.text('SINCRONIZAR AHORA'));
      await tester.pump(); // Trigger sync

      // Since it's an integration test with real cubit, it will try to hit the network.
      // We check for loading state.
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      await VideoRecorder.recordStep(tester, 'sync', '02_syncing');

      // Wait for completion (might fail or succeed depending on connectivity, but flow is tested)
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await VideoRecorder.recordStep(tester, 'sync', '03_complete_or_error');
    });
  });
}
