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
  final String _clientId;
  final String _redirectUrl;
  final String _discoveryUrl;
  final List<String> _scopes;
  final String _accessTokenKey;
  final String _idTokenKey;
  final String _refreshTokenKey;

  OAuthRepositoryImpl({
    FlutterAppAuth appAuth = const FlutterAppAuth(),
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
    String clientId = 'orion-health-app',
    String redirectUrl = 'com.orionhealth.app://oauth-callback',
    String discoveryUrl = 'https://ihce.example.com/.well-known/openid-configuration',
    List<String> scopes = const ['openid', 'profile', 'email', 'patient/*.read'],
    String accessTokenKey = 'oauth_access_token',
    String idTokenKey = 'oauth_id_token',
    String refreshTokenKey = 'oauth_refresh_token',
  })  : _appAuth = appAuth,
        _secureStorage = secureStorage,
        _clientId = clientId,
        _redirectUrl = redirectUrl,
        _discoveryUrl = discoveryUrl,
        _scopes = scopes,
        _accessTokenKey = accessTokenKey,
        _idTokenKey = idTokenKey,
        _refreshTokenKey = refreshTokenKey;

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

      await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
      await _secureStorage.write(key: _idTokenKey, value: result.idToken);
      await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);

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

      await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
      await _secureStorage.write(key: _idTokenKey, value: result.idToken);
      await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);

      return result;
    } catch (e) {
      return null;
    }
  }
}
