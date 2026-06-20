import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/application/auth_event.dart';

void main() {
  group('AuthEvent', () {
    test('AuthCheckRequested supports value equality', () {
      expect(AuthCheckRequested(), AuthCheckRequested());
    });

    test('AuthPinSubmitted supports value equality', () {
      expect(const AuthPinSubmitted('1234'), const AuthPinSubmitted('1234'));
      expect(const AuthPinSubmitted('1234'), isNot(const AuthPinSubmitted('4321')));
    });

    test('AuthPinSetRequested supports value equality', () {
      expect(const AuthPinSetRequested('1234'), const AuthPinSetRequested('1234'));
      expect(const AuthPinSetRequested('1234'), isNot(const AuthPinSetRequested('4321')));
    });

    test('AuthBiometricRequested supports value equality', () {
      expect(AuthBiometricRequested(), AuthBiometricRequested());
    });

    test('AuthLogoutRequested supports value equality', () {
      expect(AuthLogoutRequested(), AuthLogoutRequested());
    });

    test('AuthClearRequested supports value equality', () {
      expect(AuthClearRequested(), AuthClearRequested());
    });
  });
}
