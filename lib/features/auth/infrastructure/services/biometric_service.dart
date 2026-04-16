import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

@lazySingleton
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo tiene hardware biométrico disponible
  Future<bool> isBiometricsAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Verifica si hay biometría configurada (huellas o caras registradas)
  Future<bool> hasBiometricsConfigured() async {
    final List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  }

  /// Realiza la autenticación biométrica
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Autentícate para acceder a tus datos de salud',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Autenticación Biométrica',
            cancelButton: 'Cancelar',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      // Manejar errores específicos si es necesario
      print('Error en autenticación biométrica: $e');
      return false;
    }
  }
}
