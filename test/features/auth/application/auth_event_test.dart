import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/application/auth_event.dart';

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
      expect(const AuthPinSetRequested('1234'), isNot(const AuthPinSetRequested('4321')));
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
}
