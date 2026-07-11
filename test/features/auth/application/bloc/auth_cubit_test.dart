import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/biometric_service.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_session.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/login_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/logout_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/validate_session_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/set_pin_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/check_session_timeout.dart';

import 'auth_cubit_test.mocks.dart';

@GenerateMocks([
  AuthRepository,
  BiometricService,
  LoginUseCase,
  LogoutUseCase,
  ValidateSessionUseCase,
  SetPinUseCase,
  CheckSessionTimeoutUseCase,
])
void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockRepository;
  late MockBiometricService mockBiometric;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockValidateSessionUseCase mockValidateSessionUseCase;
  late MockSetPinUseCase mockSetPinUseCase;
  late MockCheckSessionTimeoutUseCase mockCheckSessionTimeoutUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockBiometric = MockBiometricService();
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockValidateSessionUseCase = MockValidateSessionUseCase();
    mockSetPinUseCase = MockSetPinUseCase();
    mockCheckSessionTimeoutUseCase = MockCheckSessionTimeoutUseCase();

    authCubit = AuthCubit(
      mockRepository,
      mockBiometric,
      mockLoginUseCase,
      mockLogoutUseCase,
      mockValidateSessionUseCase,
      mockSetPinUseCase,
      mockCheckSessionTimeoutUseCase,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state should be AuthInitial', () {
      expect(authCubit.state, equals(AuthInitial()));
    });

    test('checkStatus should emit AuthNotSetup when no credentials exist', () async {
      when(mockCheckSessionTimeoutUseCase()).thenAnswer((_) async => false);
      when(mockValidateSessionUseCase()).thenAnswer((_) async => null);
      when(mockRepository.getCredentials()).thenAnswer((_) async => null);

      await authCubit.checkStatus();

      expect(authCubit.state, equals(AuthNotSetup()));
    });

    test('loginWithPin should emit AuthAuthenticated on success', () async {
      final session = AuthSession(token: 'token', expiresAt: DateTime.now().add(const Duration(minutes: 15)));

      when(mockLoginUseCase(any)).thenAnswer((_) async => session);

      await authCubit.loginWithPin('1234');

      expect(authCubit.state, isA<AuthAuthenticated>());
    });

    test('loginWithPin should emit AuthUnauthenticated on failure', () async {
       final credentials = AuthCredentials()
        ..hashedPin = 'hashed'
        ..salt = 'salt';

      when(mockLoginUseCase(any)).thenAnswer((_) async => null);
      when(mockRepository.getCredentials()).thenAnswer((_) async => credentials);

      await authCubit.loginWithPin('1111');

      expect(authCubit.state, isA<AuthUnauthenticated>());
      final unauth = authCubit.state as AuthUnauthenticated;
      expect(unauth.failedAttempts, 0);
    });

    group('Lockout', () {
      test('should emit AuthLocked after 5 failed attempts', () async {
        final credentials = AuthCredentials()
          ..hashedPin = 'hashed'
          ..salt = 'salt'
          ..failedAttempts = 5
          ..lastLockoutTime = DateTime.now();

        when(mockLoginUseCase(any)).thenAnswer((_) async => null);
        when(mockRepository.getCredentials()).thenAnswer((_) async => credentials);

        await authCubit.loginWithPin('1111');

        expect(authCubit.state, isA<AuthLocked>());
      });
    });

    test('setupPin should call setPinUseCase and emit AuthAuthenticated on success', () async {
      final session = AuthSession(token: 'token', expiresAt: DateTime.now().add(const Duration(minutes: 15)));
      when(mockSetPinUseCase(any)).thenAnswer((_) async => true);
      when(mockLoginUseCase(any)).thenAnswer((_) async => session);

      await authCubit.setupPin('1234');

      verify(mockSetPinUseCase('1234')).called(1);
      expect(authCubit.state, isA<AuthAuthenticated>());
    });

    test('loginWithBiometrics should authenticate and emit AuthAuthenticated', () async {
      final session = AuthSession(token: 'token', expiresAt: DateTime.now().add(const Duration(minutes: 15)));
      when(mockLoginUseCase(any)).thenAnswer((_) async => session);

      await authCubit.loginWithBiometrics();

      expect(authCubit.state, isA<AuthAuthenticated>());
    });

    test('toggleBiometrics should update repository', () async {
      final credentials = AuthCredentials()..biometricEnabled = false;
      when(mockRepository.getCredentials()).thenAnswer((_) async => credentials);
      when(mockBiometric.authenticate(localizedReason: anyNamed('localizedReason')))
          .thenAnswer((_) async => true);
      when(mockRepository.saveCredentials(any)).thenAnswer((_) async {});

      await authCubit.toggleBiometrics(true);

      expect(credentials.biometricEnabled, isTrue);
      verify(mockRepository.saveCredentials(credentials)).called(1);
    });

    test('logout should call logoutUseCase and emit AuthUnauthenticated', () async {
      when(mockLogoutUseCase()).thenAnswer((_) async {});

      await authCubit.logout();

      verify(mockLogoutUseCase()).called(1);
      expect(authCubit.state, equals(const AuthUnauthenticated()));
    });
  });
}
