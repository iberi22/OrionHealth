import 'package:flutter_appauth/flutter_appauth.dart';
import '../../domain/repositories/oauth_repository.dart';
import '../datasources/oauth_local_datasource.dart';

/// Data-layer implementation of [OAuthRepository].
///
/// Delegates OAuth 2.0 authorization code flow to [FlutterAppAuth]
/// and token persistence to [OAuthLocalDataSource] (FlutterSecureStorage).
class OAuthRepositoryImpl implements OAuthRepository {
  final OAuthLocalDataSource _localDataSource;
  final FlutterAppAuth _appAuth;

  final String _clientId;
  final String _redirectUrl;
  final String _discoveryUrl;
  final List<String> _scopes;

  OAuthRepositoryImpl(
    this._localDataSource, {
    FlutterAppAuth? appAuth,
    String clientId = 'orion-health-app',
    String redirectUrl = 'com.orionhealth.app://oauth-callback',
    String discoveryUrl = 'https://ihce.example.com/.well-known/openid-configuration',
    List<String> scopes = const ['openid', 'profile', 'email', 'patient/*.read'],
  })  : _appAuth = appAuth ?? const FlutterAppAuth(),
        _clientId = clientId,
        _redirectUrl = redirectUrl,
        _discoveryUrl = discoveryUrl,
        _scopes = scopes;

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
        await _localDataSource.saveTokens(
          result.accessToken ?? '',
          result.idToken ?? '',
          result.refreshToken ?? '',
        );
      }

      return result;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() => _localDataSource.clearTokens();

  @override
  Future<String?> getAccessToken() => _localDataSource.getAccessToken();

  @override
  Future<String?> getIdToken() => _localDataSource.getIdToken();

  @override
  Future<TokenResponse?> refreshToken() async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken();
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
        await _localDataSource.saveTokens(
          result.accessToken ?? '',
          result.idToken ?? '',
          result.refreshToken ?? '',
        );
      }

      return result;
    } catch (e) {
      return null;
    }
  }
}
