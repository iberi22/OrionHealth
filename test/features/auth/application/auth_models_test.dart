import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/application/auth_event.dart';
import 'package:orionhealth_health/features/auth/application/auth_state.dart';

void main() {
  group('AuthEvent', () {
    test('AuthCheckRequested support value equality', () {
      expect(AuthCheckRequested(), AuthCheckRequested());
    });

    test('AuthPinSubmitted support value equality', () {
      expect(const AuthPinSubmitted('1234'), const AuthPinSubmitted('1234'));
      expect(const AuthPinSubmitted('1234'), isNot(const AuthPinSubmitted('4321')));
    });

    test('AuthPinSetRequested support value equality', () {
      expect(const AuthPinSetRequested('1234'), const AuthPinSetRequested('1234'));
    });

    test('AuthBiometricRequested support value equality', () {
      expect(AuthBiometricRequested(), AuthBiometricRequested());
    });

    test('AuthLogoutRequested support value equality', () {
      expect(AuthLogoutRequested(), AuthLogoutRequested());
    });

    test('AuthClearRequested support value equality', () {
      expect(AuthClearRequested(), AuthClearRequested());
    });
  });

  group('AuthState', () {
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

    test('copyWith clears error when new error is null (if implementation allows it, but here it seems it just overwrites)', () {
      const state = AuthState(status: AuthStatus.error, error: 'Some error');
      final updated = state.copyWith(status: AuthStatus.initial, error: null);

      expect(updated.error, isNull);
    });
  });
}
