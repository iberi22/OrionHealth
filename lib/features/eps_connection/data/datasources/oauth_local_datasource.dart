import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class OAuthLocalDataSource {
  final FlutterSecureStorage _storage;
  OAuthLocalDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> getAccessToken() => _storage.read(key: 'oauth_access_token');
  Future<String?> getIdToken() => _storage.read(key: 'oauth_id_token');
  Future<String?> getRefreshToken() => _storage.read(key: 'oauth_refresh_token');
  Future<void> saveTokens(String access, String id, String refresh) async {
    await _storage.write(key: 'oauth_access_token', value: access);
    await _storage.write(key: 'oauth_id_token', value: id);
    await _storage.write(key: 'oauth_refresh_token', value: refresh);
  }
  Future<void> clearTokens() async {
    await _storage.delete(key: 'oauth_access_token');
    await _storage.delete(key: 'oauth_id_token');
    await _storage.delete(key: 'oauth_refresh_token');
  }
}
