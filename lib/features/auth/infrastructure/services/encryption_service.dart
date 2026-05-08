import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class EncryptionService {
  Future<void> initialize();
  Future<Uint8List> encrypt(String plaintext);
  Future<String> decrypt(Uint8List ciphertext);
  Future<Uint8List> encryptBytes(Uint8List data);
  Future<Uint8List> decryptBytes(Uint8List encryptedData);
  Future<String> hashPin(String pin, String salt);
  Future<bool> verifyPin(String pin, String storedHash, String salt);
  Future<String> generatePinSalt();
  Future<SecretKey> getMasterKey();
  Future<List<int>> getDatabaseKey();
}

@LazySingleton(as: EncryptionService)
class EncryptionServiceImpl implements EncryptionService {
  static const _masterKeyAlias = 'orionhealth_master_key';
  static const _databaseKeyAlias = 'orionhealth_db_key';
  static const _pinSaltAlias = 'orionhealth_pin_salt';
  static const _deviceSaltAlias = 'orionhealth_device_salt';

  final FlutterSecureStorage _secureStorage;
  final AesGcm _aesGcm;
  final DeviceInfoPlugin _deviceInfo;

  SecretKey? _cachedMasterKey;

  EncryptionServiceImpl()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
            sharedPreferencesName: 'orionhealth_secure_prefs',
            preferencesKeyPrefix: 'orionhealth_',
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
            accountName: 'OrionHealth',
          ),
        ),
        _aesGcm = AesGcm.with256bits(),
        _deviceInfo = DeviceInfoPlugin();

  @override
  Future<void> initialize() async {
    final existingKey = await _secureStorage.read(key: _masterKeyAlias);
    if (existingKey == null) {
      // Derive master key from device hash
      final deviceHash = await _getDeviceHash();
      var deviceSalt = await _secureStorage.read(key: _deviceSaltAlias);
      if (deviceSalt == null) {
        final saltBytes = Uint8List(32);
        final random = SecureRandom.fast;
        for (var i = 0; i < 32; i++) {
          saltBytes[i] = random.nextInt(256);
        }
        deviceSalt = base64Encode(saltBytes);
        await _secureStorage.write(key: _deviceSaltAlias, value: deviceSalt);
      }

      final algorithm = Argon2id(
        memory: 65536, // 64 MB
        parallelism: 4,
        iterations: 3,
        hashLength: 32,
      );

      final derivedKey = await algorithm.deriveKey(
        secretKey: SecretKey(utf8.encode(deviceHash)),
        nonce: base64Decode(deviceSalt),
      );

      final keyBytes = await derivedKey.extractBytes();
      await _secureStorage.write(
        key: _masterKeyAlias,
        value: base64Encode(keyBytes),
      );
      _cachedMasterKey = derivedKey;
    } else {
      final keyBytes = base64Decode(existingKey);
      _cachedMasterKey = SecretKey(keyBytes);
    }
  }

  Future<String> _getDeviceHash() async {
    String deviceId = 'unknown';
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      deviceId = androidInfo.id; // Hardware ID or similar
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
    }
    return deviceId;
  }

  @override
  Future<SecretKey> getMasterKey() async {
    if (_cachedMasterKey == null) {
      await initialize();
    }
    return _cachedMasterKey!;
  }

  @override
  Future<List<int>> getDatabaseKey() async {
    final existingDbKey = await _secureStorage.read(key: _databaseKeyAlias);
    if (existingDbKey != null) {
      return base64Decode(existingDbKey);
    }

    // Generate a new key for Isar (encryption at rest)
    // Isar requires a 32-byte key
    final randomBytes = Uint8List(32);
    final random = SecureRandom.fast;
    for (var i = 0; i < 32; i++) {
      randomBytes[i] = random.nextInt(256);
    }

    await _secureStorage.write(
      key: _databaseKeyAlias,
      value: base64Encode(randomBytes),
    );

    return randomBytes;
  }

  @override
  Future<Uint8List> encrypt(String plaintext) async {
    return encryptBytes(Uint8List.fromList(utf8.encode(plaintext)));
  }

  @override
  Future<String> decrypt(Uint8List ciphertext) async {
    final decrypted = await decryptBytes(ciphertext);
    return utf8.decode(decrypted);
  }

  @override
  Future<Uint8List> encryptBytes(Uint8List data) async {
    final key = await getMasterKey();
    final nonce = _aesGcm.newNonce();

    final secretBox = await _aesGcm.encrypt(
      data,
      secretKey: key,
      nonce: nonce,
    );

    final combined = Uint8List(nonce.length + secretBox.cipherText.length + secretBox.mac.bytes.length);
    combined.setRange(0, nonce.length, nonce);
    combined.setRange(nonce.length, nonce.length + secretBox.cipherText.length, secretBox.cipherText);
    combined.setRange(nonce.length + secretBox.cipherText.length, combined.length, secretBox.mac.bytes);

    return combined;
  }

  @override
  Future<Uint8List> decryptBytes(Uint8List encryptedData) async {
    final key = await getMasterKey();

    // Nonce is 12 bytes for AES-GCM
    final nonce = encryptedData.sublist(0, 12);
    // MAC is usually 16 bytes
    final mac = encryptedData.sublist(encryptedData.length - 16);
    final ciphertext = encryptedData.sublist(12, encryptedData.length - 16);

    final secretBox = SecretBox(ciphertext, nonce: nonce, mac: Mac(mac));

    final decrypted = await _aesGcm.decrypt(secretBox, secretKey: key);
    return Uint8List.fromList(decrypted);
  }

  @override
  Future<String> hashPin(String pin, String salt) async {
    final algorithm = Argon2id(
      memory: 65536,
      parallelism: 4,
      iterations: 3,
      hashLength: 32,
    );

    final hash = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: base64Decode(salt),
    );

    final hashBytes = await hash.extractBytes();
    return base64Encode(hashBytes);
  }

  @override
  Future<bool> verifyPin(String pin, String storedHash, String salt) async {
    final inputHash = await hashPin(pin, salt);
    return _constantTimeCompare(inputHash, storedHash);
  }

  bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  @override
  Future<String> generatePinSalt() async {
    final saltBytes = Uint8List(32);
    final random = SecureRandom.fast;
    for (var i = 0; i < 32; i++) {
      saltBytes[i] = random.nextInt(256);
    }
    final salt = base64Encode(saltBytes);
    await _secureStorage.write(key: _pinSaltAlias, value: salt);
    return salt;
  }
}
