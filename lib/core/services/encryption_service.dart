import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyAlias = 'isar_encryption_key';

  /// Derives a 32-byte key from a PIN using PBKDF2 (100k iterations).
  Future<Uint8List> deriveKeyFromPin(String pin) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );

    // Using a static salt for local-only derivation as per simple setup.
    // In a more robust setup, salt would be stored alongside the key.
    final salt = utf8.encode('orionhealth_static_salt');

    final secretKey = await pbkdf2.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );

    return Uint8List.fromList(await secretKey.extractBytes());
  }

  /// Stores the derived key in secure storage.
  Future<void> storeKey(Uint8List key) async {
    await _secureStorage.write(
      key: _keyAlias,
      value: base64Encode(key),
    );
  }

  /// Retrieves the stored key from secure storage.
  Future<Uint8List?> getStoredKey() async {
    final storedValue = await _secureStorage.read(key: _keyAlias);
    if (storedValue == null) return null;
    return base64Decode(storedValue);
  }

  /// Clears the stored key.
  Future<void> clearKey() async {
    await _secureStorage.delete(key: _keyAlias);
  }
}
