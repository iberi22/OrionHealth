import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/application/auth_state.dart';

void main() {
  group('AuthState', () {
    test('supports value equality', () {
      expect(
        const AuthState(),
        const AuthState(),
      );
    });

    test('props are correct', () {
      final now = DateTime.now();
      final state = AuthState(
        status: AuthStatus.authenticated,
        error: 'error',
        isPinSet: true,
        isBiometricAvailable: true,
        lastAuthTime: now,
      );

      expect(
        state.props,
        [AuthStatus.authenticated, 'error', true, true, now],
      );
    });

    test('copyWith works correctly', () {
      final now = DateTime.now();
      const state = AuthState();
      final newState = state.copyWith(
        status: AuthStatus.authenticated,
        error: 'error',
        isPinSet: true,
        isBiometricAvailable: true,
        lastAuthTime: now,
      );

      expect(newState.status, AuthStatus.authenticated);
      expect(newState.error, 'error');
      expect(newState.isPinSet, true);
      expect(newState.isBiometricAvailable, true);
      expect(newState.lastAuthTime, now);
    });

    test('copyWith null values doesn\'t change state if not specified', () {
      const state = AuthState(status: AuthStatus.authenticated, isPinSet: true);
      final newState = state.copyWith();

      expect(newState.status, AuthStatus.authenticated);
      expect(newState.isPinSet, true);
    });
  });
}
