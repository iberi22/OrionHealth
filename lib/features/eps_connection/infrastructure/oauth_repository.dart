import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/eps_provider.dart';
import '../domain/entities/oauth_token.dart';
import '../domain/repositories/oauth_repository.dart';
import '../data/datasources/oauth_local_datasource.dart';

@LazySingleton(as: OAuthRepository)
class OAuthRepositoryImpl implements OAuthRepository {
  final OAuthLocalDataSource _localDataSource;
  final FlutterAppAuth _appAuth;

  OAuthRepositoryImpl(
    this._localDataSource, {
    FlutterAppAuth appAuth = const FlutterAppAuth(),
  }) : _appAuth = appAuth;

  @override
  Future<OAuthLoginResult?> login(EPSProvider provider) async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          provider.clientId,
          provider.redirectUrl,
          discoveryUrl: provider.discoveryUrl,
          scopes: provider.scopes,
        ),
      );

      if (result != null) {
        final token = OAuthToken(
          accessToken: result.accessToken ?? '',
          idToken: result.idToken,
          refreshToken: result.refreshToken,
          expiresAt: result.accessTokenExpirationDateTime,
        );

        final patientId = result.authorizationAdditionalParameters?['patient'] as String?;

        await _localDataSource.saveTokensForProvider(
          provider.id,
          token.accessToken,
          token.idToken ?? '',
          token.refreshToken ?? '',
        );

        await _localDataSource.saveProviderData(provider.id, {
          'id': provider.id,
          'name': provider.name,
          'discoveryUrl': provider.discoveryUrl,
          'clientId': provider.clientId,
          'redirectUrl': provider.redirectUrl,
          'scopes': provider.scopes,
          'type': provider.type.name,
        });

        if (patientId != null) {
          await _localDataSource.savePatientId(provider.id, patientId);
        }

        return OAuthLoginResult(token: token, patientId: patientId);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout(String providerId) async {
    await _localDataSource.clearTokensForProvider(providerId);
  }

  @override
  Future<OAuthToken?> getToken(String providerId) async {
    final access = await _localDataSource.getAccessToken(providerId);
    final id = await _localDataSource.getIdToken(providerId);
    final refresh = await _localDataSource.getRefreshToken(providerId);

    if (access == null) return null;

    return OAuthToken(
      accessToken: access,
      idToken: id,
      refreshToken: refresh,
    );
  }

  @override
  Future<String?> getPatientId(String providerId) async {
    return _localDataSource.getPatientId(providerId);
  }

  @override
  Future<EPSProvider?> getProviderDetails(String providerId) async {
    final data = await _localDataSource.getProviderData(providerId);
    if (data == null) return null;

    return EPSProvider(
      id: data['id'] as String,
      name: data['name'] as String,
      discoveryUrl: data['discoveryUrl'] as String,
      clientId: data['clientId'] as String,
      redirectUrl: data['redirectUrl'] as String,
      scopes: (data['scopes'] as List).cast<String>(),
      type: EPSProviderType.values.firstWhere((e) => e.name == data['type']),
    );
  }

  @override
  Future<OAuthToken?> refreshToken(EPSProvider provider) async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken(provider.id);
      if (refreshToken == null) return null;

      final result = await _appAuth.token(
        TokenRequest(
          provider.clientId,
          provider.redirectUrl,
          discoveryUrl: provider.discoveryUrl,
          refreshToken: refreshToken,
          scopes: provider.scopes,
        ),
      );

      if (result != null) {
        final token = OAuthToken(
          accessToken: result.accessToken ?? '',
          idToken: result.idToken,
          refreshToken: result.refreshToken,
          expiresAt: result.accessTokenExpirationDateTime,
        );

        await _localDataSource.saveTokensForProvider(
          provider.id,
          token.accessToken,
          token.idToken ?? '',
          token.refreshToken ?? '',
        );
        return token;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<String>> getConnectedProviders() async {
    return _localDataSource.getConnectedProviderIds();
  }
}
