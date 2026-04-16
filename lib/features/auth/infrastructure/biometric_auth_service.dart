import 'package:flutter/services.dart';

enum BiometricType { fingerprint, face, iris, none }

class BiometricAuthResult {
  final bool success;
  final String? error;
  final BiometricType type;

  BiometricAuthResult({
    required this.success,
    this.error,
    this.type = BiometricType.none,
  });
}

abstract class BiometricAuthService {
  Future<bool> isAvailable();
  Future<BiometricType> getAvailableType();
  Future<BiometricAuthResult> authenticate({String reason = 'Authenticate to continue'});
}

class BiometricAuthServiceImpl implements BiometricAuthService {
  static const _channel = MethodChannel('local_auth');

  @override
  Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDeviceSupported');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<BiometricType> getAvailableType() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getAvailableBiometrics');
      if (result == null || result.isEmpty) return BiometricType.none;

      for (final type in result) {
        final typeStr = type.toString().toLowerCase();
        if (typeStr.contains('face')) return BiometricType.face;
        if (typeStr.contains('fingerprint')) return BiometricType.fingerprint;
        if (typeStr.contains('iris')) return BiometricType.iris;
      }
      return BiometricType.fingerprint;
    } on PlatformException {
      return BiometricType.none;
    }
  }

  @override
  Future<BiometricAuthResult> authenticate({
    String reason = 'Authenticate to continue',
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'authenticate',
        {'reason': reason},
      );

      final type = await getAvailableType();

      return BiometricAuthResult(
        success: result ?? false,
        type: type,
      );
    } on PlatformException catch (e) {
      return BiometricAuthResult(
        success: false,
        error: e.message ?? 'Authentication failed',
      );
    }
  }
}
