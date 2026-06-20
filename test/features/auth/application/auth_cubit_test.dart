import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/application/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/auth_state.dart';
import 'package:orionhealth_health/features/auth/domain/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late AuthCubit authCubit;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authCubit = AuthCubit(mockAuthService);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state should be AuthStatus.initial', () {
      expect(authCubit.state.status, AuthStatus.initial);
    });

    group('checkAuth', () {
      test('emits loading and then unauthenticated when PIN is not set', () async {
        when(() => mockAuthService.isPinSet()).thenAnswer((_) async => false);
        when(() => mockAuthService.isBiometricAvailable()).thenAnswer((_) async => true);

        final expectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            predicate<AuthState>((s) => s.status == AuthStatus.loading),
            predicate<AuthState>((s) =>
                s.status == AuthStatus.unauthenticated &&
                s.isPinSet == false &&
                s.isBiometricAvailable == true),
          ]),
        );

        await authCubit.checkAuth();
        await expectation;
      });

      test('emits correct states when PIN is set and biometric succeeds', () async {
        when(() => mockAuthService.isPinSet()).thenAnswer((_) async => true);
        when(() => mockAuthService.isBiometricAvailable()).thenAnswer((_) async => true);
        when(() => mockAuthService.verifyBiometric()).thenAnswer((_) async => AuthResult(success: true, method: AuthMethod.biometric));

        final expectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            predicate<AuthState>((s) => s.status == AuthStatus.loading),
            predicate<AuthState>((s) => s.status == AuthStatus.pinRequired),
            predicate<AuthState>((s) => s.status == AuthStatus.biometricPrompt),
            predicate<AuthState>((s) => s.status == AuthStatus.authenticated),
          ]),
        );

        await authCubit.checkAuth();
        await expectation;
      });
    });

    group('submitPin', () {
      test('emits loading and then authenticated on success', () async {
        when(() => mockAuthService.verifyPin(any())).thenAnswer((_) async => AuthResult(success: true, method: AuthMethod.pin));

        final expectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            predicate<AuthState>((s) => s.status == AuthStatus.loading),
            predicate<AuthState>((s) => s.status == AuthStatus.authenticated && s.lastAuthTime != null),
          ]),
        );

        await authCubit.submitPin('1234');
        await expectation;
      });

      test('emits loading and then error on failure', () async {
        when(() => mockAuthService.verifyPin(any())).thenAnswer((_) async => AuthResult(success: false, error: 'Invalid', method: AuthMethod.pin));

        final expectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            predicate<AuthState>((s) => s.status == AuthStatus.loading),
            predicate<AuthState>((s) => s.status == AuthStatus.error && s.error == 'Invalid'),
          ]),
        );

        await authCubit.submitPin('1234');
        await expectation;
      });
    });

    group('setPin', () {
      test('emits loading and then authenticated on success', () async {
        when(() => mockAuthService.setPin(any())).thenAnswer((_) async => AuthResult(success: true, method: AuthMethod.pin));

        final expectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            predicate<AuthState>((s) => s.status == AuthStatus.loading),
            predicate<AuthState>((s) => s.status == AuthStatus.authenticated && s.isPinSet == true),
          ]),
        );

        await authCubit.setPin('1234');
        await expectation;
      });

      test('emits loading and then error on failure', () async {
        when(() => mockAuthService.setPin(any())).thenAnswer((_) async => AuthResult(success: false, error: 'Fail', method: AuthMethod.pin));

        final expectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            predicate<AuthState>((s) => s.status == AuthStatus.loading),
            predicate<AuthState>((s) => s.status == AuthStatus.error && s.error == 'Fail'),
          ]),
        );

        await authCubit.setPin('1234');
        await expectation;
      });
    });

    group('verifyBiometric', () {
      test('emits biometricPrompt and then authenticated on success', () async {
        when(() => mockAuthService.verifyBiometric()).thenAnswer((_) async => AuthResult(success: true, method: AuthMethod.biometric));

        final expectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            predicate<AuthState>((s) => s.status == AuthStatus.biometricPrompt),
            predicate<AuthState>((s) => s.status == AuthStatus.authenticated),
          ]),
        );

        await authCubit.verifyBiometric();
        await expectation;
      });

      test('emits biometricPrompt and then pinRequired on failure', () async {
        when(() => mockAuthService.verifyBiometric()).thenAnswer((_) async => AuthResult(success: false, method: AuthMethod.biometric));

        final expectation = expectLater(
          authCubit.stream,
          emitsInOrder([
            predicate<AuthState>((s) => s.status == AuthStatus.biometricPrompt),
            predicate<AuthState>((s) => s.status == AuthStatus.pinRequired),
          ]),
        );

        await authCubit.verifyBiometric();
        await expectation;
      });
    });

    test('logout emits unauthenticated', () async {
      final expectation = expectLater(
        authCubit.stream,
        emitsInOrder([
          predicate<AuthState>((s) => s.status == AuthStatus.unauthenticated),
        ]),
      );

      await authCubit.logout();
      await expectation;
    });

    test('clearAuth calls service and emits unauthenticated', () async {
      when(() => mockAuthService.clearAuth()).thenAnswer((_) async {});

      final expectation = expectLater(
        authCubit.stream,
        emitsInOrder([
          predicate<AuthState>((s) => s.status == AuthStatus.unauthenticated && s.isPinSet == false),
        ]),
      );

      await authCubit.clearAuth();
      await expectation;
      verify(() => mockAuthService.clearAuth()).called(1);
    });
  });
}
