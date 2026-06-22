import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class OAuthLocalDataSource {
  final FlutterSecureStorage _storage;
  OAuthLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  String _accessKey(String id) => 'oauth_access_token_$id';
  String _idKey(String id) => 'oauth_id_token_$id';
  String _refreshKey(String id) => 'oauth_refresh_token_$id';
  String _expiresKey(String id) => 'oauth_expires_at_$id';
  String _providerKey(String id) => 'oauth_provider_data_$id';
  String _patientKey(String id) => 'oauth_patient_id_$id';

  Future<String?> getAccessToken(String id) => _storage.read(key: _accessKey(id));
  Future<String?> getIdToken(String id) => _storage.read(key: _idKey(id));
  Future<String?> getRefreshToken(String id) => _storage.read(key: _refreshKey(id));
  Future<String?> getPatientId(String id) => _storage.read(key: _patientKey(id));

  Future<DateTime?> getExpiresAt(String id) async {
    final raw = await _storage.read(key: _expiresKey(id));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> savePatientId(String providerId, String patientId) async {
    await _storage.write(key: _patientKey(providerId), value: patientId);
  }

  Future<void> saveProviderData(String id, Map<String, dynamic> data) async {
    await _storage.write(key: _providerKey(id), value: jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getProviderData(String id) async {
    final raw = await _storage.read(key: _providerKey(id));
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveTokensForProvider(String id, String access, String idToken, String refresh, {DateTime? expiresAt}) async {
    await _storage.write(key: _accessKey(id), value: access);
    await _storage.write(key: _idKey(id), value: idToken);
    await _storage.write(key: _refreshKey(id), value: refresh);
    if (expiresAt != null) {
      await _storage.write(key: _expiresKey(id), value: expiresAt.toIso8601String());
    } else {
      await _storage.delete(key: _expiresKey(id));
    }

    // Track connected providers
    final providers = await getConnectedProviderIds();
    if (!providers.contains(id)) {
      providers.add(id);
      await _storage.write(key: 'connected_providers', value: providers.join(','));
    }
  }

  Future<void> clearTokensForProvider(String id) async {
    await _storage.delete(key: _accessKey(id));
    await _storage.delete(key: _idKey(id));
    await _storage.delete(key: _refreshKey(id));
    await _storage.delete(key: _expiresKey(id));
    await _storage.delete(key: _providerKey(id));
    await _storage.delete(key: _patientKey(id));

    final providers = await getConnectedProviderIds();
    if (providers.contains(id)) {
      providers.remove(id);
      await _storage.write(key: 'connected_providers', value: providers.join(','));
    }
  }

  Future<List<String>> getConnectedProviderIds() async {
    final raw = await _storage.read(key: 'connected_providers');
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',');
  }
}
