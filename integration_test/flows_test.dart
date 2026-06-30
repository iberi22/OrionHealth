import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/home/presentation/widgets/health_status_grid.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/pages/eps_connection_page.dart';
import 'package:orionhealth_health/features/auth/presentation/auth_gate.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.configureDependencies();
  });

  group('OrionHealth Critical User Flows', () {

    testWidgets('Auth & Onboarding Flow: New User Experience', (tester) async {
      // Start with a clean state
      SharedPreferences.setMockInitialValues({});
      final userRepo = di.getIt<UserProfileRepository>();
      await userRepo.deleteUserProfile();

      // Use AuthGate as it is the comprehensive entry point for auth/onboarding logic
      await tester.pumpWidget(MaterialApp(
        home: const AuthGate(),
        theme: ThemeData.dark(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await VideoRecorder.recordStep(tester, 'auth_onboarding', '01_auth_gate_start');

      // 1. Should show Onboarding because userProfile is null
      expect(find.text('Privacy First'), findsOneWidget); // Slide 1 of OnboardingWelcomePage

      // Navigate slides
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth_onboarding', '02_onboarding_profile');

      // Fill Profile (OnboardingProfilePage)
      await tester.enterText(find.widgetWithText(TextField, 'Full Name'), 'Test User');
      await tester.tap(find.text('Select Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Select Sex and Blood Type from dropdowns
      await tester.tap(find.text('Sex').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('M').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Blood Type').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('O+').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth_onboarding', '03_onboarding_vitals');

      // Vitals & Allergies (Simulated completion)
      await tester.tap(find.text('Next')); // Vitals
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next')); // Allergies
      await tester.pumpAndSettle();

      // Completion Step
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await VideoRecorder.recordStep(tester, 'auth_onboarding', '04_onboarding_finished');

      // 2. Auth Flow: pin Setup (should appear after onboarding profile is saved)
      // Re-pumping the gate to reflect saved profile
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Configurar pin'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Nuevo pin'), '1234');
      await tester.enterText(find.widgetWithText(TextField, 'Confirmar pin'), '1234');
      await tester.tap(find.text('Guardar pin'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth_onboarding', '05_pin_setup_complete');

      // 3. Dashboard Flow: Verified loading
      expect(find.text('ORION HEALTH'), findsOneWidget);
      expect(find.byType(HealthStatusGrid), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth_onboarding', '06_dashboard_verified');

      // 4. Auto-login on restart simulation
      // We re-pump the entire app. It should go straight to Dashboard now.
      await tester.pumpWidget(MaterialApp(home: const AuthGate()));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('ORION HEALTH'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth_onboarding', '07_auto_login_success');
    });

    testWidgets('Health Sharing Flow: Select and Start', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      expect(find.text('Compartir Datos'), findsOneWidget);

      // Select data category
      await tester.tap(find.text('Laboratorios'));
      await tester.pumpAndSettle();

      // Select transfer method
      await tester.tap(find.text('Bluetooth'));
      await tester.pumpAndSettle();

      // Execute share
      await tester.tap(find.text('Compartir'));
      await tester.pump(); // Trigger state change

      // Verify progress UI
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Buscando dispositivos...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'flows', '10_sharing_progress');

      // Cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Compartir'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'flows', '11_sharing_cancelled');
    });

    testWidgets('EPS Connection Flow: Entry and Interaction', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: EpsConnectionPage()));
      await tester.pumpAndSettle();

      expect(find.text('EPS Connections'), findsOneWidget);
      expect(find.text('Connect via QR Code'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'flows', '12_eps_connection');

      // Verify interaction
      await tester.tap(find.text('Connect via QR Code'));
      await tester.pump();
      expect(find.text('QR scanner coming soon'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'flows', '13_eps_qr_placeholder');
    });
  });
}
