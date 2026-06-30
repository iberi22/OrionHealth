import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/auth/presentation/login_page.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'utils/video_recorder.dart';

class MockAuthCubit extends Mock implements AuthCubit {
  @override
  Future<void> close() async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthCubit mockCubit;

  setUp(() {
    mockCubit = MockAuthCubit();
    GetIt.I.registerSingleton<AuthCubit>(mockCubit);

    when(() => mockCubit.loginWithBiometrics()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    GetIt.I.unregister<AuthCubit>();
  });

  group('Auth Flow - E2E Tests', () {
    testWidgets('E2E: Login with pin', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const AuthUnauthenticated());
      when(() => mockCubit.loginWithPin(any())).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AuthCubit>.value(value: mockCubit, child: const LoginPage()),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth', '01_login_screen');

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.loginWithPin('123456')).called(1);
      await VideoRecorder.recordStep(tester, 'auth', '02_pin_entered');
    });

    testWidgets('Edge Case: Wrong pin - shows error message', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const AuthUnauthenticated(errorMessage: 'pin incorrecto. Inténtalo de nuevo.'));

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AuthCubit>.value(value: mockCubit, child: const LoginPage()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('pin incorrecto. Inténtalo de nuevo.'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '04_wrong_pin_error');
    });

    testWidgets('Edge Case: Auth Locked Out', (WidgetTester tester) async {
      final lockoutTime = DateTime.now().add(const Duration(minutes: 5));
      when(() => mockCubit.state).thenReturn(AuthLocked(lockoutTime));

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AuthCubit>.value(value: mockCubit, child: const LoginPage()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Acceso Bloqueado'), findsOneWidget);
      expect(find.textContaining('Inténtalo de nuevo a las'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '05_locked_out');
    });

    testWidgets('Edge Case: Biometry Failure Simulation', (WidgetTester tester) async {
      final stateController = StreamController<AuthState>.broadcast();
      when(() => mockCubit.state).thenReturn(const AuthUnauthenticated());
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AuthCubit>.value(value: mockCubit, child: const LoginPage()),
      ));
      await tester.pumpAndSettle();

      // Simulate biometry failure resulting in unauthenticated with message
      stateController.add(const AuthUnauthenticated(errorMessage: 'Biometría fallida. Usa tu pin.'));
      await tester.pump();

      expect(find.text('Biometría fallida. Usa tu pin.'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '06_biometry_failure');
    });

    testWidgets('Edge Case: Token Expiry Recovery Simulation', (WidgetTester tester) async {
      // In this app, token expiry typically leads to being unauthenticated.
      // We simulate arriving at the login page because of an expiry (externally triggered).
      when(() => mockCubit.state).thenReturn(const AuthUnauthenticated(errorMessage: 'Sesión expirada. Por favor, entra de nuevo.'));

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AuthCubit>.value(value: mockCubit, child: const LoginPage()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sesión expirada. Por favor, entra de nuevo.'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '07_token_expired');
    });
  });
}
