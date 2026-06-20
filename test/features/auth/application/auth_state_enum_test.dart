import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/application/auth_state.dart';

void main() {
  group('AuthState (Enum-based)', () {
    test('support value equality', () {
      final now = DateTime.now();
      expect(
        AuthState(status: AuthStatus.authenticated, lastAuthTime: now),
        AuthState(status: AuthStatus.authenticated, lastAuthTime: now),
      );
    });

    test('copyWith works correctly', () {
      const state = AuthState(status: AuthStatus.initial);
      final updated = state.copyWith(status: AuthStatus.loading, isPinSet: true);

      expect(updated.status, AuthStatus.loading);
      expect(updated.isPinSet, isTrue);
      expect(updated.isBiometricAvailable, isFalse);
    });

    test('copyWith preserves values when null is passed', () {
      const state = AuthState(status: AuthStatus.pinRequired, isPinSet: true);
      final updated = state.copyWith();

      expect(updated, state);
    });

    test('copyWith clears error when new error is null', () {
      const state = AuthState(status: AuthStatus.error, error: 'Some error');
      final updated = state.copyWith(status: AuthStatus.initial, error: null);

      expect(updated.error, isNull);
    });
  });
}
