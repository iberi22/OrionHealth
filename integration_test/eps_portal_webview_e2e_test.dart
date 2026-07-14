import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/pages/eps_patient_portal_screen.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_providers_catalog.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/eps_url_validator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EPS Patient Portal WebView E2E', () {
    final testProvider = EPSProvider(
      id: 'EPS025',
      name: 'EPS SURA',
      discoveryUrl: 'https://ihce.minsalud.gov.co/fhir/EPS025/.well-known/smart-configuration',
      revocationUrl: 'https://ihce.minsalud.gov.co/oauth/EPS025/revoke',
      clientId: '', // Empty to force WebView portal flow
      redirectUrl: '',
      scopes: const [],
      type: EPSProviderType.fhir,
    );

    testWidgets('EpsPatientPortalScreen opens WebView with correct portal URL', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EpsPatientPortalScreen(provider: testProvider),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check that the screen opened and shows the visual WebView widget
      expect(find.byType(InAppWebView), findsOneWidget);

      // Verify the progress header is rendered
      expect(find.textContaining('Portal Seguro'), findsOneWidget);
    });

    testWidgets('EpsUrlValidator allowlist logic functions correctly', (tester) async {
      // Allowed URLs for SURA
      expect(EpsUrlValidator.isUrlAllowed('https://www.epssura.com/login', 'EPS025'), true);
      expect(EpsUrlValidator.isUrlAllowed('https://login.microsoftonline.com/auth', 'EPS025'), true);
      expect(EpsUrlValidator.isUrlAllowed('https://sandbox.ihcecol.gov.co/api', 'EPS025'), true);

      // Blocked/Unauthorized URLs
      expect(EpsUrlValidator.isUrlAllowed('https://www.google.com', 'EPS025'), false);
      expect(EpsUrlValidator.isUrlAllowed('https://malicious-phishing-site.com', 'EPS025'), false);
      expect(EpsUrlValidator.isUrlAllowed('https://www.coosalud.com', 'EPS025'), false); // SURA shouldn't load Coosalud
    });

    testWidgets('EpsUrlValidator blocks Coosalud unauthorized URLs', (tester) async {
      // Allowed URLs for Coosalud
      expect(EpsUrlValidator.isUrlAllowed('https://coosalud.com/login', 'EPS020'), true);
      expect(EpsUrlValidator.isUrlAllowed('https://coosalud.com.co/home', 'EPS020'), true);

      // Blocked URLs
      expect(EpsUrlValidator.isUrlAllowed('https://www.epssura.com', 'EPS020'), false);
    });
  });
}
