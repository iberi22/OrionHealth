import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Servicio de encriptación para datos médicos sensibles
/// Utiliza AES-256-GCM para encriptación y almacenamiento seguro de claves
@lazySingleton
class EncryptionService {
  static const _masterKeyAlias = 'orionhealth_master_key';
  static const _pinSaltAlias = 'orionhealth_pin_salt';

  final FlutterSecureStorage _secureStorage;
  final AesGcm _aesGcm;

  SecretKey? _cachedMasterKey;

  EncryptionService()
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
      _aesGcm = AesGcm.with256bits();

  /// Inicializa o recupera la clave maestra de encriptación
  Future<void> initialize() async {
    final existingKey = await _secureStorage.read(key: _masterKeyAlias);
    if (existingKey == null) {
      // Generar nueva clave maestra
      final newKey = await _aesGcm.newSecretKey();
      final keyBytes = await newKey.extractBytes();
      await _secureStorage.write(
        key: _masterKeyAlias,
        value: base64Encode(keyBytes),
      );
      _cachedMasterKey = newKey;
    } else {
      // Recuperar clave existente
      final keyBytes = base64Decode(existingKey);
      _cachedMasterKey = SecretKey(keyBytes);
    }
  }

  /// Obtiene la clave maestra (inicializando si es necesario)
  Future<SecretKey> _getMasterKey() async {
    if (_cachedMasterKey == null) {
      await initialize();
    }
    return _cachedMasterKey!;
  }

  /// Encripta texto plano usando AES-256-GCM
  /// Retorna: nonce (12 bytes) + ciphertext + mac (16 bytes) en base64
  Future<String> encrypt(String plaintext) async {
    final key = await _getMasterKey();
    final nonce = _aesGcm.newNonce();

    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );

    // Concatenar: nonce + ciphertext + mac
    final combined = Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);

    return base64Encode(combined);
  }

  /// Desencripta datos encriptados con encrypt()
  Future<String> decrypt(String encryptedData) async {
    final key = await _getMasterKey();
    final combined = base64Decode(encryptedData);

    // Extraer componentes: nonce (12) + ciphertext + mac (16)
    final nonce = combined.sublist(0, 12);
    final mac = combined.sublist(combined.length - 16);
    final ciphertext = combined.sublist(12, combined.length - 16);

    final secretBox = SecretBox(ciphertext, nonce: nonce, mac: Mac(mac));

    final decrypted = await _aesGcm.decrypt(secretBox, secretKey: key);
    return utf8.decode(decrypted);
  }

  /// Encripta datos binarios (para archivos médicos)
  Future<Uint8List> encryptBytes(Uint8List data) async {
    final key = await _getMasterKey();
    final nonce = _aesGcm.newNonce();

    final secretBox = await _aesGcm.encrypt(data, secretKey: key, nonce: nonce);

    return Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
  }

  /// Desencripta datos binarios
  Future<Uint8List> decryptBytes(Uint8List encryptedData) async {
    final key = await _getMasterKey();

    final nonce = encryptedData.sublist(0, 12);
    final mac = encryptedData.sublist(encryptedData.length - 16);
    final ciphertext = encryptedData.sublist(12, encryptedData.length - 16);

    final secretBox = SecretBox(ciphertext, nonce: nonce, mac: Mac(mac));

    final decrypted = await _aesGcm.decrypt(secretBox, secretKey: key);
    return Uint8List.fromList(decrypted);
  }

  // ============ PIN Hashing ============

  /// Genera un salt aleatorio para el hash del PIN
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

  /// Recupera el salt del PIN guardado
  Future<String?> getPinSalt() async {
    return _secureStorage.read(key: _pinSaltAlias);
  }

  /// Hashea un PIN con salt usando Argon2id
  /// Devuelve el hash en base64
  Future<String> hashPin(String pin, String salt) async {
    final algorithm = Argon2id(
      memory: 65536, // 64 MB
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

  /// Verifica un PIN contra un hash guardado
  Future<bool> verifyPin(String pin, String storedHash, String salt) async {
    final inputHash = await hashPin(pin, salt);
    return _constantTimeCompare(inputHash, storedHash);
  }

  /// Comparación en tiempo constante para prevenir timing attacks
  bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // ============ Secure Storage Helpers ============

  /// Guarda un valor de forma segura
  Future<void> secureWrite(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Lee un valor seguro
  Future<String?> secureRead(String key) async {
    return _secureStorage.read(key: key);
  }

  /// Elimina un valor seguro
  Future<void> secureDelete(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Elimina todos los datos seguros (logout completo)
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
    _cachedMasterKey = null;
  }

  // ============ Data Sharing Encryption ============

  /// Genera una clave de sesión temporal para compartir datos
  /// Esta clave se intercambia con el receptor vía QR o Bluetooth
  Future<String> generateShareSessionKey() async {
    final sessionKey = await _aesGcm.newSecretKey();
    final keyBytes = await sessionKey.extractBytes();
    return base64Encode(keyBytes);
  }

  /// Encripta datos para compartir con una clave de sesión específica
  Future<String> encryptForSharing(String data, String sessionKeyBase64) async {
    final keyBytes = base64Decode(sessionKeyBase64);
    final sessionKey = SecretKey(keyBytes);
    final nonce = _aesGcm.newNonce();

    final secretBox = await _aesGcm.encrypt(
      utf8.encode(data),
      secretKey: sessionKey,
      nonce: nonce,
    );

    final combined = Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);

    return base64Encode(combined);
  }

  /// Desencripta datos recibidos con una clave de sesión
  Future<String> decryptSharedData(
    String encryptedData,
    String sessionKeyBase64,
  ) async {
    final keyBytes = base64Decode(sessionKeyBase64);
    final sessionKey = SecretKey(keyBytes);
    final combined = base64Decode(encryptedData);

    final nonce = combined.sublist(0, 12);
    final mac = combined.sublist(combined.length - 16);
    final ciphertext = combined.sublist(12, combined.length - 16);

    final secretBox = SecretBox(ciphertext, nonce: nonce, mac: Mac(mac));

    final decrypted = await _aesGcm.decrypt(secretBox, secretKey: sessionKey);
    return utf8.decode(decrypted);
  }
}
