import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// AES-256-GCM encryption service for sensitive health data.
/// Keys are derived from a master key using HKDF.
class EncryptionService {
  /// Encrypt a plaintext string using AES-256-GCM.
  /// Returns base64: nonce (12 bytes) || ciphertext || tag (16 bytes).
  Future<String> encrypt(String plaintext, SecretKey masterKey) async {
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final plaintextBytes = utf8.encode(plaintext);

    final secretBox = await algorithm.encrypt(
      plaintextBytes,
      secretKey: masterKey,
      nonce: nonce,
    );

    final combined = Uint8List.fromList([
      ...nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);

    return base64Encode(combined);
  }

  /// Decrypt a base64 ciphertext produced by [encrypt].
  Future<String> decrypt(String encryptedBase64, SecretKey masterKey) async {
    final algorithm = AesGcm.with256bits();
    final combined = base64Decode(encryptedBase64);

    if (combined.length < 28) {
      throw FormatException('Encrypted data too short: ${combined.length} bytes');
    }

    final nonce = combined.sublist(0, 12);
    final cipherText = combined.sublist(12, combined.length - 16);
    final macBytes = combined.sublist(combined.length - 16);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final plaintextBytes = await algorithm.decrypt(
      secretBox,
      secretKey: masterKey,
    );

    return utf8.decode(plaintextBytes);
  }

  /// Generate a random 256-bit master key for first-time setup.
  Future<SecretKey> generateMasterKey() async {
    final algorithm = AesGcm.with256bits();
    return algorithm.newSecretKey();
  }

  /// Encrypt a JSON-serializable map of fields for transfer.
  Future<Map<String, dynamic>> encryptPayload(
    Map<String, dynamic> data,
    String? pin,
  ) async {
    if (pin == null) return {'pinProtected': false, 'data': data};

    final masterKey = await _deriveKeyFromPin(pin);
    final json = jsonEncode(data);
    final encrypted = await encrypt(json, masterKey);

    return {'pinProtected': true, 'encryptedData': encrypted};
  }

  /// Decrypt a payload produced by [encryptPayload].
  Future<Map<String, dynamic>> decryptPayload(
    Map<String, dynamic> payload,
    String pin,
  ) async {
    if (payload['pinProtected'] == false) {
      return payload['data'] as Map<String, dynamic>;
    }

    final masterKey = await _deriveKeyFromPin(pin);
    final encrypted = payload['encryptedData'] as String;
    final json = await decrypt(encrypted, masterKey);

    return jsonDecode(json) as Map<String, dynamic>;
  }

  /// Sign a health data package for integrity verification.
  /// Returns a hex-encoded HMAC-SHA256 signature.
  Future<String> signPackage(Map<String, dynamic> data) async {
    final algorithm = Hmac.sha256();
    final json = jsonEncode(data);
    final key = SecretKey(utf8.encode('orion_health_integrity_key_v1'));
    final mac = await algorithm.calculateMac(
      utf8.encode(json),
      secretKey: key,
    );
    return hexEncode(mac.bytes);
  }

  /// Verify a signature produced by [signPackage].
  Future<bool> verifySignature(
    Map<String, dynamic> data,
    String signatureHex,
  ) async {
    try {
      final algorithm = Hmac.sha256();
      final json = jsonEncode(data);
      final key = SecretKey(utf8.encode('orion_health_integrity_key_v1'));
      final expected = await algorithm.calculateMac(
        utf8.encode(json),
        secretKey: key,
      );
      return hexEncode(expected.bytes) == signatureHex;
    } catch (_) {
      return false;
    }
  }

  /// Encrypt a map of sensitive fields into a single base64 blob.
  Future<String> encryptFieldsMap(
    Map<String, String> fields,
    SecretKey masterKey,
  ) async {
    final json = jsonEncode(fields);
    return encrypt(json, masterKey);
  }

  /// Decrypt a bundle produced by [encryptFieldsMap].
  Future<Map<String, String>> decryptFieldsMap(
    String encryptedBase64,
    SecretKey masterKey,
  ) async {
    final json = await decrypt(encryptedBase64, masterKey);
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Encrypt document binary data (PDF, images).
  Future<String> encryptDocumentBytes(Uint8List bytes, SecretKey masterKey) async {
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(bytes, secretKey: masterKey, nonce: nonce);
    final combined = Uint8List.fromList([...nonce, ...secretBox.cipherText, ...secretBox.mac.bytes]);
    return base64Encode(combined);
  }

  /// Decrypt document binary data.
  Future<Uint8List> decryptDocumentBytes(String encryptedBase64, SecretKey masterKey) async {
    final algorithm = AesGcm.with256bits();
    final combined = base64Decode(encryptedBase64);
    final nonce = combined.sublist(0, 12);
    final cipherText = combined.sublist(12, combined.length - 16);
    final macBytes = combined.sublist(combined.length - 16);
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));
    final plaintext = await algorithm.decrypt(secretBox, secretKey: masterKey);
    return Uint8List.fromList(plaintext);
  }

  // ─── Internal helpers ─────────────────────────────────────────────────────

  Future<SecretKey> _deriveKeyFromPin(String pin) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: utf8.encode('health_wallet_salt_v1'),
    );
  }

  String hexEncode(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
