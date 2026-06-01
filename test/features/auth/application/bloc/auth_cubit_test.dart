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
  });
}
