import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import 'package:orionhealth_health/features/allergies/presentation/pages/allergies_page.dart';
import 'package:orionhealth_health/features/appointments/presentation/pages/appointments_page.dart';
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

      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      // Verify initial state (assuming default allowCloudApi is true)
      // Switch at index 2 is "Allow Cloud API"
      final cloudApiSwitch = find.byType(Switch).at(2);
      expect(tester.widget<Switch>(cloudApiSwitch).value, isTrue);

      // 1. TOGGLE PREFERENCE
      await tester.tap(cloudApiSwitch);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'user_profile', '02_after_toggle');

      // Verify it toggled locally
      expect(tester.widget<Switch>(cloudApiSwitch).value, isFalse);

      // 2. SAVE CHANGES
      final saveButton = find.widgetWithText(ElevatedButton, l10n.saveChanges);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'user_profile', '03_after_save');

      // Verify success message
      expect(find.text(l10n.profileSaved), findsOneWidget);

      // 3. PERSISTENCE CHECK
      final savedProfile = await repo.getUserProfile();
      expect(savedProfile?.allowCloudApi, isFalse);
    });

    testWidgets('E2E: Navigation from User Profile', (WidgetTester tester) async {
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
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      // 1. Navigate to Medications
      await tester.tap(find.text(l10n.medications));
      await tester.pumpAndSettle();
      expect(find.byType(MedicationsPage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'user_profile', '04_medications_page');
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 2. Navigate to Allergies
      await tester.tap(find.text(l10n.allergies));
      await tester.pumpAndSettle();
      expect(find.byType(AllergiesPage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'user_profile', '05_allergies_page');
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 3. Navigate to Appointments
      await tester.tap(find.text(l10n.appointments));
      await tester.pumpAndSettle();
      expect(find.byType(AppointmentsPage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'user_profile', '06_appointments_page');
      await tester.pageBack();
      await tester.pumpAndSettle();
    });
  });
}
