// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs
//
// Screenshot Flow E2E Test — Captures REAL UI screenshots
// 
// Flows through ALL major screens of OrionHealth and captures
// high-quality screenshots of the actual app UI running on a
// real Android device or desktop.
//
// HOW TO USE:
//   flutter test integration_test/screenshot_flow_e2e_test.dart
//   flutter test integration_test/screenshot_flow_e2e_test.dart -d <device_id> --update-goldens
//   flutter test integration_test/screenshot_flow_e2e_test.dart -d windows --update-goldens
//
// Output: integration_test/screenshots/*.png (organized by flow)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/main.dart' as app;

/// Captures a screenshot of the current UI state.
///
/// The screenshot is saved to integration_test/screenshots/<flow>/<step>.png
/// when run with --update-goldens.
Future<void> captureScreenshot(
  WidgetTester tester,
  String flow,
  String stepName,
) async {
  // Wait for UI to settle
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Capture the full MaterialApp widget
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../screenshots/$flow/$stepName.png'),
  );

  // Print to CI logs
  // ignore: avoid_print
  print('📸 Screenshot captured: $flow / $stepName');
}

/// Helper: Navigate to a tab in the bottom navigation bar
Future<void> navigateToTab(
  WidgetTester tester,
  String tabLabel,
) async {
  final tabFinder = find.text(tabLabel);
  if (tabFinder.evaluate().isNotEmpty) {
    await tester.tap(tabFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
}

/// Helper: Simulate typing text into a TextField
Future<void> typeText(
  WidgetTester tester,
  String hintText,
  String text,
) async {
  final field = find.ancestor(
    of: find.byWidgetPredicate(
      (w) => w is TextField && 
             w.decoration?.hintText?.toLowerCase().contains(hintText.toLowerCase()) == true,
    ),
    matching: find.byType(TextField),
  );

  if (field.evaluate().isNotEmpty) {
    await tester.enterText(field, text);
    await tester.pumpAndSettle();
  } else {
    // Fallback: try hint text directly
    final hintFinder = find.text(hintText);
    if (hintFinder.evaluate().isNotEmpty) {
      await tester.enterText(hintFinder, text);
      await tester.pumpAndSettle();
    }
  }
}

/// Helper: Tap a button by its text label
Future<void> tapButton(
  WidgetTester tester,
  String label,
) async {
  final button = find.widgetWithText(TextButton, label);
  final elevatedButton = find.widgetWithText(ElevatedButton, label);
  final outlinedButton = find.widgetWithText(OutlinedButton, label);
  final rawText = find.text(label);

  if (button.evaluate().isNotEmpty) {
    await tester.tap(button);
  } else if (elevatedButton.evaluate().isNotEmpty) {
    await tester.tap(elevatedButton);
  } else if (outlinedButton.evaluate().isNotEmpty) {
    await tester.tap(outlinedButton);
  } else if (rawText.evaluate().isNotEmpty) {
    await tester.tap(rawText);
  }
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Track test start time
  final testStart = DateTime.now();

  setUpAll(() async {
    // Mock SharedPreferences to start with a fresh state
    SharedPreferences.setMockInitialValues({});
  });

  group('📸 OrionHealth Screenshot Flow — Real UI', () {
    testWidgets('FLOW 01: App Launch & Onboarding', (tester) async {
      // Initialize DI and launch the real app
      await di.getIt.reset();
      await di.configureDependencies();
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Capture: Splash / App Logo
      await captureScreenshot(tester, '01_launch', '01_app_splash');

      // Try to capture onboarding welcome screen
      // The app may auto-navigate to onboarding if no profile exists
      await captureScreenshot(tester, '01_launch', '02_onboarding_welcome');

      // Try common onboarding buttons
      final nextButton = find.text('Next');
      final getStartedButton = find.text('Get Started');
      final empezarButton = find.text('Empezar');
      final continuarButton = find.text('Continuar');

      // If onboarding is showing, navigate through it
      for (int i = 0; i < 6; i++) {
        if (empezarButton.evaluate().isNotEmpty) {
          await tester.tap(empezarButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          break;
        }
        if (getStartedButton.evaluate().isNotEmpty) {
          await tester.tap(getStartedButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          break;
        }
        if (nextButton.evaluate().isNotEmpty) {
          await tester.tap(nextButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await captureScreenshot(tester, '01_launch', '03_onboarding_step_${i + 1}');
        } else if (continuarButton.evaluate().isNotEmpty) {
          await tester.tap(continuarButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else {
          break;
        }
      }

      // Final onboarding state
      await captureScreenshot(tester, '01_launch', '04_onboarding_complete');
    });

    testWidgets('FLOW 02: Auth & PIN Setup', (tester) async {
      // Re-initialize and navigate to auth
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Capture whatever auth screen is showing
      await captureScreenshot(tester, '02_auth', '01_auth_screen');

      // If PIN setup is visible, try to fill it
      final pinFields = find.byWidgetPredicate(
        (w) => w is TextField && (w.obscureText == true),
      );
      if (pinFields.evaluate().isNotEmpty) {
        await captureScreenshot(tester, '02_auth', '02_pin_setup_empty');

        // Try to type into PIN fields
        if (pinFields.evaluate().length >= 2) {
          await tester.enterText(pinFields.at(0), '123456');
          await tester.enterText(pinFields.at(1), '123456');
          await tester.pumpAndSettle();
          await captureScreenshot(tester, '02_auth', '03_pin_filled');
        }
      }

      // Capture locked state if visible
      await captureScreenshot(tester, '02_auth', '04_auth_state');
    });

    testWidgets('FLOW 03: Dashboard & Home', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Dashboard tab if available
      await navigateToTab(tester, 'Dashboard');
      await captureScreenshot(tester, '03_dashboard', '01_dashboard_main');

      // Check for health status grid
      final statusGrid = find.byWidgetPredicate(
        (w) => w.runtimeType.toString().contains('HealthStatus'),
      );
      if (statusGrid.evaluate().isNotEmpty) {
        await captureScreenshot(tester, '03_dashboard', '02_health_status');
      }

      // Check for module cards
      final moduleCards = find.byWidgetPredicate(
        (w) => w.runtimeType.toString().contains('ModuleCard'),
      );
      if (moduleCards.evaluate().isNotEmpty) {
        await captureScreenshot(tester, '03_dashboard', '03_module_cards');
      }
    });

    testWidgets('FLOW 04: Health Records', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Health Records tab
      await navigateToTab(tester, 'Health Records');
      await navigateToTab(tester, 'Registros');
      await navigateToTab(tester, 'Registros Médicos');
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreenshot(tester, '04_records', '01_records_list');

      // Check for upload buttons
      final uploadButtons = find.byWidgetPredicate(
        (w) => w is IconButton && 
               (w.icon == Icons.add || 
                w.icon == Icons.camera_alt ||
                w.icon == Icons.picture_as_pdf),
      );

      if (uploadButtons.evaluate().isNotEmpty) {
        // Tap upload FAB or button
        final fab = find.byType(FloatingActionButton);
        if (fab.evaluate().isNotEmpty) {
          await tester.tap(fab);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await captureScreenshot(tester, '04_records', '02_upload_options');
        }
      }
    });

    testWidgets('FLOW 05: Reports', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Reports tab
      await navigateToTab(tester, 'Reports');
      await navigateToTab(tester, 'Reportes');
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreenshot(tester, '05_reports', '01_reports_list');

      // Try to tap a report card
      final reportCards = find.byWidgetPredicate(
        (w) => w.runtimeType.toString().contains('Report') && 
               w is Card,
      );
      if (reportCards.evaluate().isNotEmpty) {
        await tester.tap(reportCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await captureScreenshot(tester, '05_reports', '02_report_detail');
      }
    });

    testWidgets('FLOW 06: User Profile', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Profile tab
      await navigateToTab(tester, 'Profile');
      await navigateToTab(tester, 'Perfil');
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreenshot(tester, '06_profile', '01_profile_view');

      // Try to tap edit button
      final editButtons = find.byWidgetPredicate(
        (w) => w is IconButton && w.icon == Icons.edit,
      );
      if (editButtons.evaluate().isNotEmpty) {
        await tester.tap(editButtons.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await captureScreenshot(tester, '06_profile', '02_edit_profile');
      }
    });

    testWidgets('FLOW 07: AI Chat & Voice', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for AI Chat navigation
      final chatNav = find.byWidgetPredicate(
        (w) => (w is NavigationDestination && 
               (w.label?.toLowerCase().contains('chat') == true ||
                w.label?.toLowerCase().contains('ai') == true ||
                w.label?.toLowerCase().contains('asistente') == true)) ||
              (w is Icon && (w.icon == Icons.chat ||
                             w.icon == Icons.chat_bubble_outline))
      );

      final chatIcons = find.byIcon(Icons.chat_bubble_outline);
      final aiIcons = find.byIcon(Icons.psychology_outlined);
      final voiceChatIcons = find.byWidgetPredicate(
        (w) => w is Icon && (w.icon == Icons.mic || w.icon == Icons.mic_none),
      );

      // Try to navigate to chat via known icons
      if (chatIcons.evaluate().isNotEmpty) {
        await tester.tap(chatIcons.first);
      } else if (aiIcons.evaluate().isNotEmpty) {
        await tester.tap(aiIcons.first);
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreenshot(tester, '07_chat', '01_chat_interface');

      // Check for voice input
      if (voiceChatIcons.evaluate().isNotEmpty) {
        await tester.tap(voiceChatIcons.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await captureScreenshot(tester, '07_chat', '02_voice_input');
      }

      // Type a message
      final chatField = find.byWidgetPredicate(
        (w) => w is TextField && 
               (w.decoration?.hintText?.toLowerCase().contains('message') == true ||
                w.decoration?.hintText?.toLowerCase().contains('escribe') == true),
      );
      if (chatField.evaluate().isNotEmpty) {
        await tester.enterText(chatField, '¿Cuáles son mis últimos resultados?');
        await tester.pumpAndSettle();
        await captureScreenshot(tester, '07_chat', '03_message_typed');
      }
    });

    testWidgets('FLOW 08: Medical Research & Standards', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Try to find medical research / standards
      final researchNav = find.text('Investigación');
      final standardsNav = find.text('Estándares');
      final medicalResearchNav = find.text('Medical Research');
      final icdNav = find.textContaining('ICD');
      final loincNav = find.textContaining('LOINC');

      if (researchNav.evaluate().isNotEmpty) {
        await tester.tap(researchNav);
      } else if (medicalResearchNav.evaluate().isNotEmpty) {
        await tester.tap(medicalResearchNav);
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreenshot(tester, '08_medical', '01_research_home');

      // Try to search
      final searchField = find.byWidgetPredicate(
        (w) => w is TextField && 
               (w.decoration?.hintText?.toLowerCase().contains('search') == true ||
                w.decoration?.hintText?.toLowerCase().contains('buscar') == true),
      );
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'diabetes');
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await captureScreenshot(tester, '08_medical', '02_search_results');
      }

      // Try to access standards viewer
      if (standardsNav.evaluate().isNotEmpty) {
        await tester.tap(standardsNav);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await captureScreenshot(tester, '08_medical', '03_standards_viewer');
      }

      if (icdNav.evaluate().isNotEmpty) {
        await tester.tap(icdNav);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await captureScreenshot(tester, '08_medical', '04_icd10_browser');
      }
    });

    testWidgets('FLOW 09: Medications', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Medications
      final medsNav = find.text('Medications');
      final medsNavEs = find.text('Medicamentos');
      final medsNavRx = find.text('Medicación');

      if (medsNav.evaluate().isNotEmpty) {
        await tester.tap(medsNav);
      } else if (medsNavEs.evaluate().isNotEmpty) {
        await tester.tap(medsNavEs);
      } else if (medsNavRx.evaluate().isNotEmpty) {
        await tester.tap(medsNavRx);
      } else {
        // Try to navigate via navigation bar
        final navBar = find.byType(NavigationBar);
        if (navBar.evaluate().isNotEmpty) {
          final destinations = navBar.evaluate().first.widget;
        }
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreenshot(tester, '09_medications', '01_medications_list');
    });

    testWidgets('FLOW 10: Appointments', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Appointments
      final apptNav = find.text('Appointments');
      final apptNavEs = find.text('Citas');
      final calendarIcon = find.byIcon(Icons.calendar_month);

      if (apptNav.evaluate().isNotEmpty) {
        await tester.tap(apptNav);
      } else if (apptNavEs.evaluate().isNotEmpty) {
        await tester.tap(apptNavEs);
      } else if (calendarIcon.evaluate().isNotEmpty) {
        await tester.tap(calendarIcon);
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreenshot(tester, '10_appointments', '01_appointments_view');
    });

    testWidgets('FLOW 11: Health Sharing & P2P', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for sharing options
      final shareText = find.textContaining('Compartir');
      final bluetoothIcon = find.byIcon(Icons.bluetooth);
      final nfcIcon = find.byIcon(Icons.nfc);
      final wifiIcon = find.byIcon(Icons.wifi);

      if (shareText.evaluate().isNotEmpty) {
        await tester.tap(shareText.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await captureScreenshot(tester, '11_sharing', '01_share_options');
      }

      if (bluetoothIcon.evaluate().isNotEmpty) {
        await captureScreenshot(tester, '11_sharing', '02_bluetooth_sharing');
      }
    });

    testWidgets('FLOW 12: Settings & LLM Config', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for settings
      final settingsIcon = find.byIcon(Icons.settings);
      final settingsText = find.text('Settings');
      final settingsTextEs = find.text('Ajustes');
      final configuracion = find.text('Configuración');

      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon);
      } else if (settingsText.evaluate().isNotEmpty) {
        await tester.tap(settingsText);
      } else if (settingsTextEs.evaluate().isNotEmpty) {
        await tester.tap(settingsTextEs);
      } else if (configuracion.evaluate().isNotEmpty) {
        await tester.tap(configuracion);
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreenshot(tester, '12_settings', '01_settings_menu');

      // Look for LLM settings
      final llmNav = find.textContaining('LLM');
      final llmNavEs = find.textContaining('Modelo');

      if (llmNav.evaluate().isNotEmpty) {
        await tester.tap(llmNav.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await captureScreenshot(tester, '12_settings', '02_llm_settings');
      }
    });

    testWidgets('FLOW 13: Vital Signs Monitor', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for vitals
      final vitalsText = find.textContaining('Vital');
      final vitalsIcon = find.byWidgetPredicate(
        (w) => w is Icon && (w.icon == Icons.favorite ||
                             w.icon == Icons.monitor_heart ||
                             w.icon == Icons.monitor_weight),
      );
      final heartIcon = find.byIcon(Icons.favorite);

      if (vitalsText.evaluate().isNotEmpty) {
        await tester.tap(vitalsText.first);
      } else if (heartIcon.evaluate().isNotEmpty) {
        await tester.tap(heartIcon.first);
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreenshot(tester, '13_vitals', '01_vitals_monitor');
    });

    testWidgets('FLOW 14: Network & Governance', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for governance / network
      final govNav = find.textContaining('Governance');
      final govNavEs = find.textContaining('Gobernanza');
      final networkNav = find.textContaining('Network');
      final incentivesNav = find.textContaining('Incentivos');
      final leaderboardNav = find.textContaining('Leaderboard');

      if (govNav.evaluate().isNotEmpty) {
        await tester.tap(govNav.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await captureScreenshot(tester, '14_network', '01_governance');
      } else if (govNavEs.evaluate().isNotEmpty) {
        await tester.tap(govNavEs.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await captureScreenshot(tester, '14_network', '01_governance');
      }

      if (incentivesNav.evaluate().isNotEmpty) {
        await tester.tap(incentivesNav.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await captureScreenshot(tester, '14_network', '02_incentives');
      }

      if (leaderboardNav.evaluate().isNotEmpty) {
        await tester.tap(leaderboardNav.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await captureScreenshot(tester, '14_network', '03_leaderboard');
      }
    });

    testWidgets('FLOW 15: Sync & FHIR Status', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for sync options
      final syncText = find.textContaining('Sync');
      final syncTextEs = find.textContaining('Sincronización');
      final syncIcon = find.byIcon(Icons.sync);

      if (syncText.evaluate().isNotEmpty) {
        await tester.tap(syncText.first);
      } else if (syncTextEs.evaluate().isNotEmpty) {
        await tester.tap(syncTextEs.first);
      } else if (syncIcon.evaluate().isNotEmpty) {
        await tester.tap(syncIcon.first);
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreenshot(tester, '15_sync', '01_sync_status');

      // Look for FHIR status
      final fhirText = find.textContaining('FHIR');
      if (fhirText.evaluate().isNotEmpty) {
        await captureScreenshot(tester, '15_sync', '02_fhir_status');
      }
    });

    testWidgets('FLOW 16: Full Navigation Tour', (tester) async {
      await di.getIt.reset();
      await di.configureDependencies();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Try to find and capture the bottom navigation bar
      final navBar = find.byType(NavigationBar);
      if (navBar.evaluate().isNotEmpty) {
        final destinations = find.byType(NavigationDestination);
        final count = destinations.evaluate().length;

        // Capture each tab
        for (int i = 0; i < count; i++) {
          await tester.tap(destinations.at(i));
          await tester.pumpAndSettle(const Duration(seconds: 3));
          
          // Try to get the label
          final dest = destinations.at(i).evaluate().first.widget as NavigationDestination;
          final label = dest.label ?? 'tab_$i';
          final safeLabel = label.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
          
          await captureScreenshot(tester, '16_navigation', '${i}_${safeLabel}');
        }
      } else {
        // Fallback: try to find any navigation (BottomNavigationBar, TabBar, etc.)
        await captureScreenshot(tester, '16_navigation', '01_current_state');
      }
    });
  });

  // Print summary after all tests
  tearDownAll(() {
    final elapsed = DateTime.now().difference(testStart);
    // ignore: avoid_print
    print('═══════════════════════════════════════');
    // ignore: avoid_print
    print('🏁 Screenshot Flow Test Complete');
    // ignore: avoid_print
    print('⏱️  Elapsed: ${elapsed.inSeconds}s');
    // ignore: avoid_print
    print('📸 Screenshots saved to: integration_test/screenshots/');
    // ignore: avoid_print
    print('═══════════════════════════════════════');
  });
}
