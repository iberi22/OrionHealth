// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Integration test: full app startup smoke test
/// Run: flutter test integration_test/app_init_test.dart --flavor prod

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Initialization', () {
    testWidgets('app starts without "Error de Inicializacion"', (tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify the error screen is NOT showing
      expect(
        find.text('Error de Inicializaci' '\u00f3n'),
        findsNothing,
        reason: 'App showed initialization error screen',
      );

      // Verify some normal widget is present
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
        reason: 'App should have a MaterialApp widget',
      );
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
