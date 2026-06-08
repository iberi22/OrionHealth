import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class OAuthRepository {
  Future<AuthorizationTokenResponse?> login();
  Future<void> logout();
  Future<String?> getAccessToken();
  Future<String?> getIdToken();
  Future<TokenResponse?> refreshToken();
}

@LazySingleton(as: OAuthRepository)
class OAuthRepositoryImpl implements OAuthRepository {
  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _secureStorage;

  OAuthRepositoryImpl({
    FlutterAppAuth appAuth = const FlutterAppAuth(),
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  })  : _appAuth = appAuth,
        _secureStorage = secureStorage;

  static const String _clientId = 'orion-health-app';
  static const String _redirectUrl = 'com.orionhealth.app://oauth-callback';
  static const String _discoveryUrl = 'https://ihce.example.com/.well-known/openid-configuration';
  static const List<String> _scopes = ['openid', 'profile', 'email', 'patient/*.read'];

  static const String _accessTokenKey = 'oauth_access_token';
  static const String _idTokenKey = 'oauth_id_token';
  static const String _refreshTokenKey = 'oauth_refresh_token';

  @override
  Future<AuthorizationTokenResponse?> login() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          discoveryUrl: _discoveryUrl,
          scopes: _scopes,
        ),
      );

      if (result != null) {
        await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
        await _secureStorage.write(key: _idTokenKey, value: result.idToken);
        await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);
      }

      return result;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _idTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getIdToken() async {
    return await _secureStorage.read(key: _idTokenKey);
  }

  @override
  Future<TokenResponse?> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) return null;

      final result = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUrl,
          discoveryUrl: _discoveryUrl,
          refreshToken: refreshToken,
          scopes: _scopes,
        ),
      );

      if (result != null) {
        await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
        await _secureStorage.write(key: _idTokenKey, value: result.idToken);
        await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);
      }

      return result;
    } catch (e) {
      return null;
    }
  }
}
