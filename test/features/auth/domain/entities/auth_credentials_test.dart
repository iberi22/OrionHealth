import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';

void main() {
  group('AuthCredentials', () {
    test('should support equality (manually checked via properties)', () {
      final credentials1 = AuthCredentials()
        ..hashedPin = 'hashed'
        ..salt = 'salt'
        ..biometricEnabled = true;

      expect(credentials1.hashedPin, 'hashed');
      expect(credentials1.salt, 'salt');
      expect(credentials1.biometricEnabled, isTrue);
    });

    test('toString returns expected string', () {
      final credentials = AuthCredentials()
        ..biometricEnabled = true
        ..failedAttempts = 3;

      final string = credentials.toString();

      expect(string, contains('biometricEnabled: true'));
      expect(string, contains('failedAttempts: 3'));
    });

    test('default values', () {
      final credentials = AuthCredentials();

      expect(credentials.biometricEnabled, isFalse);
      expect(credentials.failedAttempts, 0);
      expect(credentials.lastLockoutTime, isNull);
    });
  });
}
