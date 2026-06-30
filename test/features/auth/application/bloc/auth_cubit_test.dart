import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/biometric_service.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';

import 'auth_cubit_test.mocks.dart';

@GenerateMocks([AuthRepository, EncryptionService, BiometricService])
void main() {
  late AuthCubit authCubit;
  late MockAuthRepository mockRepository;
  late MockEncryptionService mockEncryption;
  late MockBiometricService mockBiometric;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockEncryption = MockEncryptionService();
    mockBiometric = MockBiometricService();
    authCubit = AuthCubit(mockRepository, mockEncryption, mockBiometric);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state should be AuthInitial', () {
      expect(authCubit.state, equals(AuthInitial()));
    });

    test('checkStatus should emit AuthNotSetup when no credentials exist', () async {
      when(mockRepository.getCredentials()).thenAnswer((_) async => null);

      await authCubit.checkStatus();

      expect(authCubit.state, equals(AuthNotSetup()));
    });

    test('loginWithPin should emit AuthAuthenticated on success', () async {
      final credentials = AuthCredentials()
        ..hashedPin = 'hashed'
        ..salt = 'salt';

      when(mockRepository.getCredentials()).thenAnswer((_) async => credentials);
      when(mockEncryption.hashPin('1234', 'salt')).thenAnswer((_) async => 'hashed');

      await authCubit.loginWithPin('1234');

      expect(authCubit.state, isA<AuthAuthenticated>());
      verify(mockRepository.saveCredentials(any)).called(1);
    });

    test('loginWithPin should emit AuthUnauthenticated on failure', () async {
       final credentials = AuthCredentials()
        ..hashedPin = 'hashed'
        ..salt = 'salt';

      when(mockRepository.getCredentials()).thenAnswer((_) async => credentials);
      when(mockEncryption.hashPin('1111', 'salt')).thenAnswer((_) async => 'wrong');

      await authCubit.loginWithPin('1111');

      expect(authCubit.state, isA<AuthUnauthenticated>());
      final unauth = authCubit.state as AuthUnauthenticated;
      expect(unauth.failedAttempts, 1);
    });
    group('Lockout', () {
      test('should emit AuthLocked after 5 failed attempts', () async {
        final credentials = AuthCredentials()
          ..hashedPin = 'hashed'
          ..salt = 'salt'
          ..failedAttempts = 4;

        when(mockRepository.getCredentials()).thenAnswer((_) async => credentials);
        when(mockEncryption.hashPin('1111', 'salt')).thenAnswer((_) async => 'wrong');

        await authCubit.loginWithPin('1111');

        expect(authCubit.state, isA<AuthLocked>());
      });
    });

    test('setupPin should save credentials and emit AuthAuthenticated', () async {
      when(mockEncryption.hashPin(any, any)).thenAnswer((_) async => 'hashed');
      when(mockRepository.saveCredentials(any)).thenAnswer((_) async {
        return;
      });

      await authCubit.setupPin('1234');

      verify(mockRepository.saveCredentials(any)).called(1);
      expect(authCubit.state, isA<AuthAuthenticated>());
    });

    test('loginWithBiometrics should authenticate and emit AuthAuthenticated', () async {
      final credentials = AuthCredentials()..biometricEnabled = true;
      when(mockRepository.getCredentials()).thenAnswer((_) async => credentials);
      when(mockBiometric.authenticate(localizedReason: anyNamed('localizedReason')))
          .thenAnswer((_) async => true);

      await authCubit.loginWithBiometrics();

      expect(authCubit.state, isA<AuthAuthenticated>());
    });

    test('toggleBiometrics should update repository', () async {
      final credentials = AuthCredentials()..biometricEnabled = false;
      when(mockRepository.getCredentials()).thenAnswer((_) async => credentials);
      when(mockBiometric.authenticate(localizedReason: anyNamed('localizedReason')))
          .thenAnswer((_) async => true);
      when(mockRepository.saveCredentials(any)).thenAnswer((_) async {
        return;
      });

      await authCubit.toggleBiometrics(true);

      expect(credentials.biometricEnabled, isTrue);
      verify(mockRepository.saveCredentials(credentials)).called(1);
    });

    test('logout should cancel timer and emit AuthUnauthenticated', () async {
      // First authenticate to start session
      when(mockEncryption.hashPin(any, any)).thenAnswer((_) async => 'hashed');
      await authCubit.setupPin('1234');
      expect(authCubit.state, isA<AuthAuthenticated>());

      authCubit.logout();

      expect(authCubit.state, equals(const AuthUnauthenticated()));
    });
  });
}
