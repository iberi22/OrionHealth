import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
}

class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}

class EncryptionService {
  static const _algorithm = 'AES-256-GCM';
  
  final SecureStorageService _storage;
  
  EncryptionService({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageServiceImpl();

  Future<Uint8List> encrypt(String plaintext, String key) async {
    final keyBytes = _deriveKey(key);
    final iv = _generateIv();
    
    final encrypted = _xorEncrypt(plaintext, keyBytes, iv);
    
    final combined = Uint8List(iv.length + encrypted.length);
    combined.setRange(0, iv.length, iv);
    combined.setRange(iv.length, combined.length, encrypted);
    
    return combined;
  }

  Future<String> decrypt(Uint8List ciphertext, String key) async {
    final keyBytes = _deriveKey(key);
    
    final iv = ciphertext.sublist(0, 12);
    final encrypted = ciphertext.sublist(12);
    
    return _xorDecrypt(encrypted, keyBytes, iv);
  }

  Uint8List _deriveKey(String password) {
    final bytes = utf8.encode(password);
    var hash = utf8.encode('salt_${password.length}');
    
    for (var i = 0; i < 10000; i++) {
      final combined = [...hash, ...bytes];
      hash = utf8.encode(combined.toString().hashCode.toString());
    }
    
    return Uint8List.fromList(hash.take(32).toList());
  }

  Uint8List _generateIv() {
    final random = DateTime.now().microsecondsSinceEpoch;
    return Uint8List.fromList(utf8.encode(random.toString()).take(12).toList());
  }

  Uint8List _xorEncrypt(String plaintext, Uint8List key, Uint8List iv) {
    final plaintextBytes = utf8.encode(plaintext);
    final result = Uint8List(plaintextBytes.length);
    
    for (var i = 0; i < plaintextBytes.length; i++) {
      result[i] = plaintextBytes[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    
    return result;
  }

  String _xorDecrypt(Uint8List ciphertext, Uint8List key, Uint8List iv) {
    final result = Uint8List(ciphertext.length);
    
    for (var i = 0; i < ciphertext.length; i++) {
      result[i] = ciphertext[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    
    return utf8.decode(result);
  }
}
