// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart' show sha256;

/// Abstract secure storage service for sensitive data.
///
/// Provides a platform-independent interface backed by
/// `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences
/// on Android, CredentialManager on Windows/macOS).
abstract class SecureStorageService {
  /// Write a plaintext [value] under [key].
  Future<void> write(String key, String value);

  /// Read the value stored under [key]; `null` if absent.
  Future<String?> read(String key);

  /// Delete the entry under [key].
  Future<void> delete(String key);

  /// Delete all stored entries.
  Future<void> deleteAll();

  /// Check whether an entry exists under [key].
  Future<bool> containsKey(String key);

  /// Store a sensitive value using an app-specific derived key.
  /// The [namespace] groups related secrets (e.g. `auth`, `fhir`).
  Future<void> writeSecure(String namespace, String key, String value);

  /// Read a value previously stored via [writeSecure].
  Future<String?> readSecure(String namespace, String key);

  /// Store a JSON-serializable object.
  Future<void> writeJson(String key, Map<String, dynamic> value);

  /// Read and decode a JSON object.
  Future<Map<String, dynamic>?> readJson(String key);
}

/// Default implementation backed by [FlutterSecureStorage].
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;
  final String _appKeySeed;

  SecureStorageServiceImpl({
    FlutterSecureStorage? storage,
    String appKeySeed = 'orionhealth_v1',
  })  : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        ),
        _appKeySeed = appKeySeed;

  // ── Basic operations ──────────────────────────────────────

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

  // ── Namespaced secure operations ──────────────────────────

  @override
  Future<void> writeSecure(String namespace, String key, String value) async {
    final derivedKey = _deriveKey(namespace, key);
    await _storage.write(key: derivedKey, value: value);
  }

  @override
  Future<String?> readSecure(String namespace, String key) async {
    final derivedKey = _deriveKey(namespace, key);
    return await _storage.read(key: derivedKey);
  }

  // ── JSON helpers ──────────────────────────────────────────

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await write(key, jsonEncode(value));
  }

  @override
  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = await read(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ── Internal ──────────────────────────────────────────────

  /// Derives a deterministic storage key from a namespace + user key,
  /// prefixed with the app seed to avoid collisions with other apps.
  String _deriveKey(String namespace, String key) {
    final bytes = utf8.encode('$_appKeySeed/$namespace/$key');
    final hash = sha256.convert(bytes).toString();
    return '$namespace:$hash';
  }
}
