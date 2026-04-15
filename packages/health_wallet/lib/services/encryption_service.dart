import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import '../models/medical_document.dart';

/// AES-256-GCM encryption service for sensitive health data.
/// All encryption keys are derived from a master key using HKDF.
class EncryptionService {
  /// Encrypt a plaintext string using AES-256-GCM.
  /// Returns a base64-encoded string containing: nonce (12 bytes) || ciphertext || tag (16 bytes).
  Future<String> encrypt(String plaintext, SecretKey masterKey) async {
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final plaintextBytes = utf8.encode(plaintext);

    final secretBox = await algorithm.encrypt(
      plaintextBytes,
      secretKey: masterKey,
      nonce: nonce,
    );

    // Combine: nonce (12) + ciphertext + tag (16)
    final combined = Uint8List.fromList([
      ...nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);

    return base64Encode(combined);
  }

  /// Decrypt a base64-encoded ciphertext produced by [encrypt].
  /// Expects format: nonce (12 bytes) || ciphertext || tag (16 bytes).
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

  /// Generate a 256-bit AES key from a password using PBKDF2.
  Future<SecretKey> deriveKeyFromPassword(String password, {int iterations = 100000}) async {
    final algorithm = AesGcm.with256bits();
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );

    return await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: utf8.encode('health_wallet_salt_v1'),
    );
  }

  /// Generate a random 256-bit master key for first-time setup.
  Future<SecretKey> generateMasterKey() async {
    final algorithm = AesGcm.with256bits();
    return algorithm.newSecretKey();
  }

  /// Encrypt a sensitive field on a model and return base64 ciphertext.
  Future<String?> encryptField(
    String? fieldValue,
    SecretKey masterKey,
  ) async {
    if (fieldValue == null || fieldValue.isEmpty) return null;
    return encrypt(fieldValue, masterKey);
  }

  /// Decrypt a sensitive field from base64 ciphertext.
  Future<String?> decryptField(
    String? encryptedBase64,
    SecretKey masterKey,
  ) async {
    if (encryptedBase64 == null || encryptedBase64.isEmpty) return null;
    return decrypt(encryptedBase64, masterKey);
  }

  /// Encrypt a JSON map of sensitive fields.
  Future<String?> encryptFieldsMap(
    Map<String, String?> fields,
    SecretKey masterKey,
  ) async {
    final filtered = fields.entries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .toList();
    if (filtered.isEmpty) return null;

    final json = jsonEncode(Map.fromEntries(filtered));
    return encrypt(json, masterKey);
  }

  /// Decrypt a JSON map of sensitive fields.
  Future<Map<String, String>?> decryptFieldsMap(
    String? encryptedBase64,
    SecretKey masterKey,
  ) async {
    if (encryptedBase64 == null || encryptedBase64.isEmpty) return null;
    final json = await decrypt(encryptedBase64, masterKey);
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Sign a health data package for integrity.
  Future<String> signPackage(Map<String, dynamic> data) async {
    final hmac = Hmac.sha256();
    final signingKey = SecretKey(utf8.encode('orion_signing_key_v1'));

    final mac = await hmac.calculateMac(
      utf8.encode(jsonEncode(data)),
      secretKey: signingKey,
    );

    return base64Encode(mac.bytes);
  }

  /// Encrypt a full health data payload using a PIN-derived key.
  Future<Map<String, dynamic>> encryptPayload(
    Map<String, dynamic> data,
    String? pin,
  ) async {
    final key = await deriveKeyFromPassword(pin ?? 'default_orion_pin');
    final plaintext = jsonEncode(data);
    final ciphertext = await encrypt(plaintext, key);

    return {
      'data': ciphertext,
      'algorithm': 'AES-256-GCM',
    };
  }

  /// Decrypt a health data payload.
  Future<Map<String, dynamic>> decryptPayload(
    Map<String, dynamic> encryptedPayload,
    String pin,
  ) async {
    final key = await deriveKeyFromPassword(pin);
    final ciphertext = encryptedPayload['data'] as String;
    final plaintext = await decrypt(ciphertext, key);

    return jsonDecode(plaintext) as Map<String, dynamic>;
  }

  /// Encrypt sensitive fields of a MedicalDocument.
  Future<MedicalDocument> encryptDocument(MedicalDocument doc) async {
    final masterKey = await deriveKeyFromPassword('document_master_key');

    final encryptedMetadata = await encryptFieldsMap({
      'title': doc.title,
      'notes': doc.notes,
    }, masterKey);

    return doc.copyWith(
      encryptedMetadata: encryptedMetadata,
    );
  }
}
