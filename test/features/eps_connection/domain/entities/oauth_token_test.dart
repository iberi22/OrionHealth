import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';

void main() {
  group('OAuthToken', () {
    test('isExpired returns true when expiresAt is in the past', () {
      final token = OAuthToken(
        accessToken: 'access',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(token.isExpired, true);
    });

    test('isExpired returns false when expiresAt is in the future', () {
      final token = OAuthToken(
        accessToken: 'access',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );
      expect(token.isExpired, false);
    });

    test('isExpired returns false when expiresAt is null', () {
      final token = const OAuthToken(accessToken: 'access');
      expect(token.isExpired, false);
    });

    test('supports value equality', () {
      final expiresAt = DateTime.now();
      final t1 = OAuthToken(accessToken: 'a', idToken: 'i', refreshToken: 'r', expiresAt: expiresAt);
      final t2 = OAuthToken(accessToken: 'a', idToken: 'i', refreshToken: 'r', expiresAt: expiresAt);
      expect(t1, t2);
    });
  });
}
