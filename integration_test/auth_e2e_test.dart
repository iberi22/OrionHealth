import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/auth/presentation/auth_gate.dart';
import 'package:orionhealth_health/features/auth/presentation/login_page.dart';
import 'package:orionhealth_health/features/auth/presentation/setup_pin_page.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.configureDependencies();
  });

  group('Auth Flow - Real Integration Tests', () {
    testWidgets('E2E: PIN Setup and Login flow', (WidgetTester tester) async {
      // 1. Setup: Ensure a user profile exists but no PIN is set
      final userRepo = di.getIt<UserProfileRepository>();
      await userRepo.saveUserProfile(UserProfile(
        name: 'Test User',
        birthDate: DateTime(1990, 1, 1),
        sex: 'M',
        bloodType: 'O+',
      )..id = 1);

      // Reset Auth state by re-registering or clearing data if necessary.
      // For this test, we'll pump AuthGate which will drive the flow.
      await tester.pumpWidget(MaterialApp(
        home: const AuthGate(),
        theme: ThemeData.dark(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth', '01_auth_gate_start');

      // 2. Should be at SetupPinPage since it's a new profile
      expect(find.byType(SetupPinPage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '02_setup_pin');

      await tester.enterText(find.widgetWithText(TextField, 'Nuevo PIN'), '1234');
      await tester.enterText(find.widgetWithText(TextField, 'Confirmar PIN'), '1234');
      await tester.tap(find.text('Guardar PIN'));
      await tester.pumpAndSettle();

      // 3. After setup, it should go to MainNavigationPage (Dashboard)
      // Note: In real app, AuthAuthenticated state leads to MainNavigationPage
      expect(find.text('ORION HEALTH'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '03_dashboard_after_setup');

      // 4. Simulate Logout/Restart and Login
      // We manually pump LoginPage to test the login flow specifically
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider.value(
          value: di.getIt<AuthCubit>()..checkStatus(),
          child: const LoginPage(),
        ),
        theme: ThemeData.dark(),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '04_login_page');

      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Should be authenticated now. Since we are just pumping LoginPage,
      // we might need to check if it tried to navigate or if state changed.
      // In a full app test, we'd use AuthGate again.
    });

    testWidgets('E2E: Wrong PIN shows error', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider.value(
          value: di.getIt<AuthCubit>()..checkStatus(),
          child: const LoginPage(),
        ),
        theme: ThemeData.dark(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '9999');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('PIN incorrecto'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '05_wrong_pin');
    });
  });
}
