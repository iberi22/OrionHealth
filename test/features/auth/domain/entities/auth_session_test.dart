import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_session.dart';

void main() {
  group('AuthSession', () {
    test('should create AuthSession with correct values', () {
      final expiresAt = DateTime.now().add(const Duration(hours: 1));
      final session = AuthSession(
        token: 'token123',
        expiresAt: expiresAt,
      );

      expect(session.token, 'token123');
      expect(session.expiresAt, expiresAt);
    });

    test('isExpired should return true when session is expired', () {
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 1));
      final session = AuthSession(
        token: 'token123',
        expiresAt: expiresAt,
      );

      expect(session.isExpired, isTrue);
    });

    test('isExpired should return false when session is not expired', () {
      final expiresAt = DateTime.now().add(const Duration(minutes: 1));
      final session = AuthSession(
        token: 'token123',
        expiresAt: expiresAt,
      );

      expect(session.isExpired, isFalse);
    });

    test('toString should return correct string representation', () {
      final expiresAt = DateTime.now();
      final session = AuthSession(
        token: 'token123',
        expiresAt: expiresAt,
      );

      expect(session.toString(), 'AuthSession(token: token123, expiresAt: $expiresAt)');
    });
  });
}
