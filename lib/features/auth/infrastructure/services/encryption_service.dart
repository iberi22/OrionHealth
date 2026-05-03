import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:injectable/injectable.dart';

abstract class EncryptionService {
  Future<Uint8List> encrypt(String plaintext, String key);
  Future<String> decrypt(Uint8List ciphertext, String key);
}

@LazySingleton(as: EncryptionService)
class EncryptionServiceImpl implements EncryptionService {
  final _algorithm = AesGcm.with256bits();
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  @override
  Future<Uint8List> encrypt(String plaintext, String key) async {
    // 1. Generate a random salt for key derivation
    final salt = Uint8List(16);
    final random = Random.secure();
    for (var i = 0; i < salt.length; i++) {
      salt[i] = random.nextInt(256);
    }

    // 2. Derive the secret key using PBKDF2
    final secretKey = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(key)),
      nonce: salt,
    );

    // 3. Encrypt the plaintext
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
    );

    // 4. Combine salt + nonce + ciphertext + mac
    // secretBox.concatenation() returns nonce + ciphertext + mac
    final encryptedContent = secretBox.concatenation();
    final result = Uint8List(salt.length + encryptedContent.length);
    result.setRange(0, salt.length, salt);
    result.setRange(salt.length, result.length, encryptedContent);

    return result;
  }

  @override
  Future<String> decrypt(Uint8List ciphertext, String key) async {
    if (ciphertext.length < 16 + 12 + 16) {
      throw Exception('Invalid ciphertext');
    }

    // 1. Extract the salt (first 16 bytes)
    final salt = ciphertext.sublist(0, 16);
    final encryptedPart = ciphertext.sublist(16);

    // 2. Derive the same secret key
    final secretKey = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(key)),
      nonce: salt,
    );

    // 3. Reconstruct the SecretBox
    // AES-GCM default nonce length is 12 bytes, MAC length is 16 bytes
    final secretBox = SecretBox.fromConcatenation(
      encryptedPart,
      nonceLength: 12,
      macLength: 16,
    );

    // 4. Decrypt
    final clearText = await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(clearText);
  }
}
