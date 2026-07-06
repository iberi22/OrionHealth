abstract class AuthCredential {
  const AuthCredential();
}

class PinCredential extends AuthCredential {
  final String pin;

  const PinCredential(this.pin);
}

class BiometricCredential extends AuthCredential {
  const BiometricCredential();
}
