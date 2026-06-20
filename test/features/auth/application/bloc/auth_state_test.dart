import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';

void main() {
  group('AuthState (bloc)', () {
    test('AuthInitial supports value equality', () {
      expect(const AuthInitial(), const AuthInitial());
    });

    test('AuthNotSetup supports value equality', () {
      expect(const AuthNotSetup(), const AuthNotSetup());
    });

    test('AuthLocked supports value equality', () {
      final now = DateTime.now();
      expect(AuthLocked(now), AuthLocked(now));
      expect(AuthLocked(now), isNot(AuthLocked(now.add(const Duration(seconds: 1)))));
    });

    test('AuthUnauthenticated supports value equality', () {
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

    test('AuthAuthenticated supports value equality', () {
      final now = DateTime.now();
      expect(AuthAuthenticated(now), AuthAuthenticated(now));
      expect(
        AuthAuthenticated(now),
        isNot(AuthAuthenticated(now.add(const Duration(seconds: 1)))),
      );
    });

    test('AuthLoading supports value equality', () {
      expect(const AuthLoading(), const AuthLoading());
    });
  });
}
