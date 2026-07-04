import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
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

  group('User Profile Flow - E2E Tests', () {
    testWidgets('E2E: Update profile preferences and save', (WidgetTester tester) async {
      final repo = di.getIt<UserProfileRepository>();

      // Clean start for the test
      await repo.deleteUserProfile();

      await tester.pumpWidget(
        MaterialApp(
          home: const UserProfilePage(),
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

      // Wait for the profile to load
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'user_profile', '01_initial_view');

      // Verify initial state (assuming default allowCloudApi is true)
      final cloudApiSwitch = find.byType(Switch).at(2);
      expect(tester.widget<Switch>(cloudApiSwitch).value, isTrue);

      // 1. TOGGLE PREFERENCE
      await tester.tap(cloudApiSwitch);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'user_profile', '02_after_toggle');

      // Verify it toggled locally
      expect(tester.widget<Switch>(cloudApiSwitch).value, isFalse);

      // 2. SAVE CHANGES
      final saveButton = find.widgetWithText(ElevatedButton, 'Guardar Cambios');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'user_profile', '03_after_save');

      // Verify success message
      expect(find.text('Perfil guardado'), findsOneWidget);

      // 3. PERSISTENCE CHECK
      // Re-load the profile from repository to ensure it saved
      final savedProfile = await repo.getUserProfile();
      expect(savedProfile?.allowCloudApi, isFalse);
    });

    testWidgets('E2E: Navigate to Medications from Profile', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const UserProfilePage(),
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

      // Find "Medicamentos" section/tile
      final medicationsTile = find.text('Medicamentos');
      expect(medicationsTile, findsOneWidget);

      await tester.tap(medicationsTile);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'user_profile', '04_medications_page');

      // Verify we are on MedicationsPage (Checking AppBar title)
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Medicamentos')), findsOneWidget);
    });

    testWidgets('E2E: Navigate to Allergies from Profile', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const UserProfilePage(),
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

      // Find "Alergias" section/tile
      final allergiesTile = find.text('Alergias');
      expect(allergiesTile, findsOneWidget);

      await tester.tap(allergiesTile);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'user_profile', '05_allergies_page');

      // Verify we are on AllergiesPage
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Alergias')), findsOneWidget);
    });

    testWidgets('E2E: Navigate to Appointments from Profile', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const UserProfilePage(),
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

      // Find "Citas" section/tile
      final appointmentsTile = find.text('Citas');
      expect(appointmentsTile, findsOneWidget);

      await tester.tap(appointmentsTile);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'user_profile', '06_appointments_page');

      // Verify we are on AppointmentsPage
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Citas')), findsOneWidget);
    });
  });
}
