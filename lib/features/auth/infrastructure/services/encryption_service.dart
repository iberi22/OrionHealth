import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:argon2/argon2.dart';
import 'package:injectable/injectable.dart';
import 'package:hex/hex.dart';

@lazySingleton
class EncryptionService {
  final _algorithm = AesGcm.with256bits();

  /// Hashes a pin using Argon2id
  Future<String> hashPin(String pin, String salt) async {
    final parameters = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      Uint8List.fromList(utf8.encode(salt)),
      version: Argon2Parameters.ARGON2_VERSION_13,
      iterations: 3,
      memory: 65536,
      lanes: 4,
    );

    final generator = Argon2BytesGenerator();
    generator.init(parameters);

    final result = Uint8List(32);
    generator.generateBytesFromString(pin, result);

    return HEX.encode(result);
  }

  late String _sessionKey;

  Future<void> initialize() async {
    _sessionKey = 'orion_ble_session_static_key_v1';
  }

  Future<Uint8List> encryptBytes(Uint8List plainBytes) async {
    final secretKey = await _algorithm.newSecretKeyFromBytes(
      Uint8List.fromList(utf8.encode(_sessionKey.padRight(32).substring(0, 32))),
    );
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      plainBytes,
      secretKey: secretKey,
      nonce: nonce,
    );

    final combined = Uint8List(nonce.length + secretBox.cipherText.length + secretBox.mac.bytes.length);
    combined.setRange(0, nonce.length, nonce);
    combined.setRange(nonce.length, nonce.length + secretBox.cipherText.length, secretBox.cipherText);
    combined.setRange(nonce.length + secretBox.cipherText.length, combined.length, secretBox.mac.bytes);

    return combined;
  }

  Future<Uint8List> decryptBytes(Uint8List encryptedBytes) async {
    final combined = encryptedBytes;
    final nonce = combined.sublist(0, 12);
    final macBytes = combined.sublist(combined.length - 16);
    final cipherText = combined.sublist(12, combined.length - 16);

    final secretKey = await _algorithm.newSecretKeyFromBytes(
      Uint8List.fromList(utf8.encode(_sessionKey.padRight(32).substring(0, 32))),
    );

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final clearText = await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return Uint8List.fromList(clearText);
  }

  /// Encrypts data using AES-256-GCM.
  /// If [key] is omitted, encrypts with the session key and returns a Uint8List.
  /// If [key] is provided, encrypts with the key and returns a base64 encoded String.
  Future<dynamic> encrypt(String data, [String? key]) async {
    if (key == null) {
      return encryptBytes(Uint8List.fromList(utf8.encode(data)));
    }
    final secretKey = await _algorithm.newSecretKeyFromBytes(
      Uint8List.fromList(utf8.encode(key.padRight(32).substring(0, 32))),
    );
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      utf8.encode(data),
      secretKey: secretKey,
      nonce: nonce,
    );

    final combined = Uint8List(nonce.length + secretBox.cipherText.length + secretBox.mac.bytes.length);
    combined.setRange(0, nonce.length, nonce);
    combined.setRange(nonce.length, nonce.length + secretBox.cipherText.length, secretBox.cipherText);
    combined.setRange(nonce.length + secretBox.cipherText.length, combined.length, secretBox.mac.bytes);

    return base64.encode(combined);
  }

  /// Decrypts data using AES-256-GCM
  Future<String> decrypt(String encryptedData, String key) async {
    final combined = base64.decode(encryptedData);
    final nonce = combined.sublist(0, 12);
    final macBytes = combined.sublist(combined.length - 16);
    final cipherText = combined.sublist(12, combined.length - 16);

    final secretKey = await _algorithm.newSecretKeyFromBytes(
      Uint8List.fromList(utf8.encode(key.padRight(32).substring(0, 32))),
    );

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final clearText = await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(clearText);
  }

  /// Generate a random pin salt as a hex string
  Future<String> generatePinSalt() async {
    final rand = Random.secure();
    final bytes = Uint8List.fromList(List<int>.generate(16, (i) => rand.nextInt(256)));
    return HEX.encode(bytes);
  }

  /// Verify a pin against a stored hash and salt
  Future<bool> verifyPin(String pin, String storedHash, String salt) async {
    final hash = await hashPin(pin, salt);
    return hash == storedHash;
  }
}
