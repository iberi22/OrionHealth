import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

/// Resultado de autenticación biométrica
enum BiometricResult {
  success,
  failed,
  notAvailable,
  notEnrolled,
  lockedOut,
  cancelled,
  error,
}

/// Servicio para autenticación biométrica (huella digital, Face ID)
@lazySingleton
class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService() : _localAuth = LocalAuthentication();

  /// Verifica si el dispositivo soporta autenticación biométrica
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Verifica si hay biométricos configurados en el dispositivo
  Future<bool> hasBiometricsEnrolled() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Obtiene los tipos de biométricos disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Verifica si Face ID está disponible (iOS)
  Future<bool> hasFaceId() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Verifica si huella digital está disponible
  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// Realiza autenticación biométrica
  Future<BiometricResult> authenticate({
    String reason = 'Autentícate para acceder a tus datos médicos',
    bool biometricOnly = false,
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return BiometricResult.notAvailable;
      }

      final hasEnrolled = await hasBiometricsEnrolled();
      if (!hasEnrolled) {
        return BiometricResult.notEnrolled;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      return didAuthenticate ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    }
  }

  /// Cancela autenticación en progreso
  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on PlatformException {
      // Ignorar errores al cancelar
    }
  }

  BiometricResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return BiometricResult.notAvailable;
      case 'NotEnrolled':
        return BiometricResult.notEnrolled;
      case 'LockedOut':
      case 'PermanentlyLockedOut':
        return BiometricResult.lockedOut;
      case 'UserCanceled':
        return BiometricResult.cancelled;
      default:
        return BiometricResult.error;
    }
  }

  /// Obtiene una descripción amigable del tipo de biométrico disponible
  Future<String> getBiometricTypeDescription() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Huella digital';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Escaneo de iris';
    } else if (biometrics.contains(BiometricType.strong)) {
      return 'Biométrico seguro';
    } else if (biometrics.contains(BiometricType.weak)) {
      return 'Biométrico';
    }
    return 'Biométrico';
  }
}
