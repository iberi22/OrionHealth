import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/home/presentation/pages/home_page.dart';
import 'package:orionhealth_health/features/sync/presentation/sync_status_widget.dart';
import 'package:orionhealth_health/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Visual Regression and Flow E2E Test', () {
    testWidgets('Full flow: Login to Main Navigation', (WidgetTester tester) async {
      // Start the app
      // Note: In a real E2E we might use app.main() but here we might need to mock
      // some things or at least ensure the environment is ready.
      // For this task, we follow the logic described in the plan.

      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      // We expect to land on LoginPage (assuming onboarding is done or we are at AuthGate)
      // Since we want to test the flow, let's assume we are at LoginPage

      final pinField = find.byType(TextField);
      if (pinField.evaluate().isNotEmpty) {
        await tester.enterText(pinField, '1234');
        await tester.pumpAndSettle();

        final loginButton = find.text('Entrar');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton);
          await tester.pumpAndSettle();
        }
      }

      // Now we should be on MainNavigationPage
      // Navigate through tabs

      // Home tab (default)
      expect(find.byType(HealthStatusGrid), findsOneWidget);

      // Tap Reportes (assuming the index or label)
      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();

      // Tap Registros
      await tester.tap(find.byIcon(Icons.folder_shared_outlined));
      await tester.pumpAndSettle();

      // Tap Perfil
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.byType(SyncStatusWidget), findsOneWidget);
    });
  });
}
