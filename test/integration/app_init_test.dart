// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Integration test: full app startup smoke test
/// Run: flutter test integration_test/app_init_test.dart --flavor prod

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/main.dart' as app;
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_page.dart';

import '../helpers/test_platform.dart';

void main() {
  group('App Initialization', () {
    setUpAll(() async {
      await setUpTestPlatform();
      await getIt.reset();
      await configureDependencies();
    });

    testWidgets(
      'app starts without "Error de Inicializacion"',
      (tester) async {
        // Launch the app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 15));

        // Verify the error screen is NOT showing
        expect(
          find.text(
            'Error de Inicializaci'
            '\u00f3n',
          ),
          findsNothing,
          reason: 'App showed initialization error screen',
        );

        // Verify some normal widget is present. OnboardingPage is the first real screen.
        expect(
          find.byType(OnboardingPage),
          findsOneWidget,
          reason: 'App should have rendered the OnboardingPage',
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}
