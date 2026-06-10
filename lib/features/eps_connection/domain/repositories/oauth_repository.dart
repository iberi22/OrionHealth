import 'package:flutter_appauth/flutter_appauth.dart';

abstract class OAuthRepository {
  Future<AuthorizationTokenResponse?> login();
  Future<void> logout();
  Future<String?> getAccessToken();
  Future<String?> getIdToken();
  Future<TokenResponse?> refreshToken();
}
