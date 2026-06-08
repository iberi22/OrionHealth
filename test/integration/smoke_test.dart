import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/main.dart';

void main() {
  testWidgets('App smoke test: verifies initial startup', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Basic verification: App starts and shows at least some text or a loading indicator.
    // Given the StartupRouter, it might show a CircularProgressIndicator or OnboardingPage.

    // We wait for the first pump.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Check for common UI elements that should be present at startup (even if in a router).
    // In this case, we just want to ensure it doesn't crash on pump.
    await tester.pump();

    // If onboarding is not completed, we should see onboarding-related text or the cubit-based page.
    // If it's loading SharedPreferences, it shows CircularProgressIndicator.
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
