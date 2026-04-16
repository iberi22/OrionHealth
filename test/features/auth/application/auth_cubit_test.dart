import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'dart:async';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthCubit cubit;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    cubit = AuthCubit(mockAuthRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('AuthCubit', () {
    test('initial state should be AuthInitial', () {
      expect(cubit.state, AuthInitial());
    });

    test('checkAuthStatus should emit AuthNoPinSet when no credentials', () async {
      when(() => mockAuthRepository.getCredentials()).thenAnswer((_) async => null);

      final expectedStates = [
        AuthLoading(),
        AuthNoPinSet(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));
      await cubit.checkAuthStatus();
    });

    test('loginWithPin should emit AuthAuthenticated on success', () async {
      when(() => mockAuthRepository.verifyPin('1234')).thenAnswer((_) async => true);

      final expectedStates = [
        AuthLoading(),
        AuthAuthenticated(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));
      await cubit.loginWithPin('1234');
    });

    test('loginWithPin should emit AuthUnauthenticated on failure', () async {
      when(() => mockAuthRepository.verifyPin('wrong')).thenAnswer((_) async => false);
      when(() => mockAuthRepository.isLockedOut()).thenAnswer((_) async => false);
      when(() => mockAuthRepository.getCredentials()).thenAnswer((_) async => AuthCredentials());
      when(() => mockAuthRepository.isBiometricsAvailable()).thenAnswer((_) async => false);

      final expectedStates = [
        AuthLoading(),
        const AuthUnauthenticated(isBiometricsAvailable: false, error: 'PIN incorrecto'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));
      await cubit.loginWithPin('wrong');
    });
  });
}
