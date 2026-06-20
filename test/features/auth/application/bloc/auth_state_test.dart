import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';

void main() {
  group('AuthState (Sealed)', () {
    test('AuthInitial support value equality', () {
      expect(const AuthInitial(), const AuthInitial());
    });

    test('AuthNotSetup support value equality', () {
      expect(const AuthNotSetup(), const AuthNotSetup());
    });

    test('AuthLocked support value equality', () {
      final now = DateTime.now();
      expect(AuthLocked(now), AuthLocked(now));
      expect(AuthLocked(now), isNot(AuthLocked(now.add(const Duration(seconds: 1)))));
    });

    test('AuthUnauthenticated support value equality', () {
      expect(const AuthUnauthenticated(), const AuthUnauthenticated());
      expect(
        const AuthUnauthenticated(failedAttempts: 1, errorMessage: 'Error'),
        const AuthUnauthenticated(failedAttempts: 1, errorMessage: 'Error'),
      );
      expect(
        const AuthUnauthenticated(failedAttempts: 1),
        isNot(const AuthUnauthenticated(failedAttempts: 2)),
      );
    });

    test('AuthAuthenticated support value equality', () {
      final expiry = DateTime.now();
      expect(AuthAuthenticated(expiry), AuthAuthenticated(expiry));
      expect(
        AuthAuthenticated(expiry),
        isNot(AuthAuthenticated(expiry.add(const Duration(seconds: 1)))),
      );
    });

    test('AuthLoading support value equality', () {
      expect(const AuthLoading(), const AuthLoading());
    });
  });
}
