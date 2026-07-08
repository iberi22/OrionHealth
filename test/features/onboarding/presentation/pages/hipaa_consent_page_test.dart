import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/hipaa_consent_page.dart';

void main() {
  group('HipaaConsentPage', () {
    testWidgets('renders the consent page with all sections',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HipaaConsentPage()),
      );

      // Check header
      expect(find.text('Tu privacidad es primero'), findsOneWidget);
      expect(find.text('Privacidad y Consentimiento'), findsOneWidget);

      // Check data collection section
      expect(find.text('¿Qué datos recogemos y por qué?'), findsOneWidget);

      // Check privacy commitment section
      expect(find.text('Nuestro compromiso'), findsOneWidget);

      // Check privacy policy button
      expect(find.text('Leer política de privacidad'), findsOneWidget);

      // Check action buttons
      expect(find.text('Aceptar y continuar'), findsOneWidget);
      expect(find.text('Rechazar'), findsOneWidget);
    });

    testWidgets('accept button is disabled when consent checkbox is unchecked',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HipaaConsentPage()),
      );

      // Find the accept button - should be disabled initially
      final acceptButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Aceptar y continuar'),
      );
      expect(acceptButton.onPressed, isNull);
    });

    testWidgets('accept button becomes enabled after checking consent',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HipaaConsentPage()),
      );

      // Tap the consent checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Find the accept button - should now be enabled
      final acceptButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Aceptar y continuar'),
      );
      expect(acceptButton.onPressed, isNotNull);
    });

    testWidgets('reject button pops with false', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const HipaaConsentPage(),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      // Open the consent page
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Reject
      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('privacy policy dialog opens and displays content',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HipaaConsentPage()),
      );

      // Tap the privacy policy row
      await tester.tap(find.text('Leer política de privacidad'));
      await tester.pumpAndSettle();

      // Check dialog is shown
      expect(find.text('Política de Privacidad'), findsOneWidget);
      expect(find.text('Cerrar'), findsOneWidget);

      // Close the dialog
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(find.text('Política de Privacidad'), findsNothing);
    });
  });
}
