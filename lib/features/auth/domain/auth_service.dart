import 'dart:convert';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:flutter/services.dart';
import '../infrastructure/services/encryption_service.dart';

enum AuthMethod { pin, biometric, none }

class AuthResult {
  final bool success;
  final String? error;
  final AuthMethod method;

  AuthResult({required this.success, this.error, required this.method});
}

abstract class AuthService {
  Future<bool> isPinSet();
  Future<AuthResult> setPin(String pin);
  Future<AuthResult> verifyPin(String pin);
  Future<AuthResult> verifyBiometric();
  Future<bool> isBiometricAvailable();
  Future<void> clearAuth();
}

@LazySingleton(as: AuthService)
class AuthServiceImpl implements AuthService {
  static const _pinKey = 'auth_pin_hash';
  static const _pinSaltKey = 'auth_pin_salt';

  final EncryptionService _encryptionService;
  
  String? _cachedPinHash;
  String? _cachedPinSalt;
  bool _biometricAvailable = false;

  AuthServiceImpl(this._encryptionService);

  @override
  Future<bool> isPinSet() async {
    _cachedPinHash = await _getStoredPinHash();
    return _cachedPinHash != null;
  }

  @override
  Future<AuthResult> setPin(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      return AuthResult(
        success: false,
        error: 'PIN must be 4-6 digits',
        method: AuthMethod.pin,
      );
    }

    final salt = await _encryptionService.generatePinSalt();
    final hash = await _encryptionService.hashPin(pin, salt);

    await _storePinHash(hash);
    _cachedPinHash = hash;
    _cachedPinSalt = salt;
    
    return AuthResult(success: true, method: AuthMethod.pin);
  }

  @override
  Future<AuthResult> verifyPin(String pin) async {
    final storedHash = _cachedPinHash ?? await _getStoredPinHash();
    final salt = _cachedPinSalt ?? await _encryptionService.generatePinSalt();
    
    if (storedHash == null) {
      return AuthResult(
        success: false,
        error: 'PIN not set',
        method: AuthMethod.pin,
      );
    }

    final isValid = await _encryptionService.verifyPin(pin, storedHash, salt);
    if (isValid) {
      return AuthResult(success: true, method: AuthMethod.pin);
    }

    return AuthResult(
      success: false,
      error: 'Invalid PIN',
      method: AuthMethod.pin,
    );
  }

  @override
  Future<AuthResult> verifyBiometric() async {
    if (!_biometricAvailable) {
      return AuthResult(
        success: false,
        error: 'Biometric not available',
        method: AuthMethod.biometric,
      );
    }

    try {
      final result = await Future.delayed(
        const Duration(milliseconds: 500),
        () => true,
      );
      
      return AuthResult(
        success: result,
        method: AuthMethod.biometric,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: e.toString(),
        method: AuthMethod.biometric,
      );
    }
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      const channel = MethodChannel('local_auth');
      final available = await channel.invokeMethod<bool>('isDeviceSupported');
      _biometricAvailable = available ?? false;
      return _biometricAvailable;
    } catch (e) {
      _biometricAvailable = false;
      return false;
    }
  }

  @override
  Future<void> clearAuth() async {
    _cachedPinHash = null;
    await _clearStoredData();
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> _getStoredPinHash() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return null;
  }

  Future<void> _storePinHash(String hash) async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> _clearStoredData() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}
