import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/app_logger.dart';
import '../domain/entities/eps_provider.dart';
import '../domain/entities/oauth_token.dart';
import '../domain/repositories/oauth_repository.dart';
import '../data/datasources/oauth_local_datasource.dart';

@LazySingleton(as: OAuthRepository)
class OAuthRepositoryImpl implements OAuthRepository {
  final OAuthLocalDataSource _localDataSource;
  final FlutterAppAuth _appAuth;
  final Dio _dio;

  OAuthRepositoryImpl(
    this._localDataSource,
    this._dio, {
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
        final currentRefreshToken = await _localDataSource.getRefreshToken(provider.id);
        final refreshToken = result.refreshToken ?? currentRefreshToken;

        final token = OAuthToken(
          accessToken: result.accessToken ?? '',
          idToken: result.idToken,
          refreshToken: refreshToken,
          expiresAt: result.accessTokenExpirationDateTime,
        );

        final patientId = result.authorizationAdditionalParameters?['patient'] as String?;

        await _localDataSource.saveTokensForProvider(
          provider.id,
          token.accessToken,
          token.idToken ?? '',
          refreshToken ?? '',
          expiresAt: token.expiresAt,
        );

        await _localDataSource.saveProviderData(provider.id, {
          'id': provider.id,
          'name': provider.name,
          'discoveryUrl': provider.discoveryUrl,
          'revocationUrl': provider.revocationUrl,
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
      throw OAuthException('Login failed: no response from provider');
    } catch (e) {
      if (e is OAuthException) rethrow;
      throw OAuthException('Login failed', e);
    }
  }

  @override
  Future<void> logout(String providerId) async {
    final provider = await getProviderDetails(providerId);
    final access = await _localDataSource.getAccessToken(providerId);
    final refresh = await _localDataSource.getRefreshToken(providerId);

    if (provider?.revocationUrl != null) {
      final url = provider!.revocationUrl!;

      if (access != null) {
        try {
          await _dio.post(
            url,
            data: {'token': access},
            options: Options(contentType: Headers.formUrlEncodedContentType),
          );
        } catch (e) {
          AppLogger.w('OAuthRepository', 'Access token revocation failed for $providerId: $e');
        }
      }

      if (refresh != null) {
        try {
          await _dio.post(
            url,
            data: {'token': refresh},
            options: Options(contentType: Headers.formUrlEncodedContentType),
          );
        } catch (e) {
          AppLogger.w('OAuthRepository', 'Refresh token revocation failed for $providerId: $e');
        }
      }
    }

    await _localDataSource.clearTokensForProvider(providerId);
  }

  @override
  Future<OAuthToken?> getToken(String providerId) async {
    final access = await _localDataSource.getAccessToken(providerId);
    final id = await _localDataSource.getIdToken(providerId);
    final refresh = await _localDataSource.getRefreshToken(providerId);
    final expiresAt = await _localDataSource.getExpiresAt(providerId);

    final token = OAuthToken(
      accessToken: access ?? '',
      idToken: id,
      refreshToken: refresh,
      expiresAt: expiresAt,
    );

    if (access == null || token.isExpired) {
      if (refresh != null && refresh.isNotEmpty) {
        final provider = await getProviderDetails(providerId);
        if (provider != null) {
          try {
            return await refreshToken(provider);
          } catch (e) {
            AppLogger.e('OAuthRepository', 'Automatic token refresh failed for $providerId', error: e);
          }
        }
      }
      if (access == null) return null;
    }

    return token;
  }

  @override
  Future<String?> getPatientId(String providerId) async {
    return _localDataSource.getPatientId(providerId);
  }

  @override
  Future<EPSProvider?> getProviderDetails(String providerId) async {
    try {
      final data = await _localDataSource.getProviderData(providerId);
      if (data == null) {
        AppLogger.d('OAuthRepository', 'No provider data found for $providerId');
        return null;
      }

      return EPSProvider(
        id: data['id'] as String,
        name: data['name'] as String,
        discoveryUrl: data['discoveryUrl'] as String,
        revocationUrl: data['revocationUrl'] as String?,
        clientId: data['clientId'] as String,
        redirectUrl: data['redirectUrl'] as String,
        scopes: (data['scopes'] as List).cast<String>(),
        type: EPSProviderType.values.firstWhere((e) => e.name == data['type']),
      );
    } catch (e) {
      AppLogger.e('OAuthRepository', 'Error getting provider details for $providerId', error: e);
      return null;
    }
  }

  @override
  Future<OAuthToken?> refreshToken(EPSProvider provider) async {
    try {
      final currentRefreshToken = await _localDataSource.getRefreshToken(provider.id);
      if (currentRefreshToken == null) {
        throw OAuthException('No refresh token available for provider: ${provider.id}');
      }

      final result = await _appAuth.token(
        TokenRequest(
          provider.clientId,
          provider.redirectUrl,
          discoveryUrl: provider.discoveryUrl,
          refreshToken: currentRefreshToken,
          scopes: provider.scopes,
        ),
      );

      if (result != null) {
        final newRefreshToken = result.refreshToken ?? currentRefreshToken;
        final token = OAuthToken(
          accessToken: result.accessToken ?? '',
          idToken: result.idToken,
          refreshToken: newRefreshToken,
          expiresAt: result.accessTokenExpirationDateTime,
        );

        await _localDataSource.saveTokensForProvider(
          provider.id,
          token.accessToken,
          token.idToken ?? '',
          newRefreshToken,
          expiresAt: token.expiresAt,
        );
        return token;
      }
      throw OAuthException('Token refresh failed: no response from provider');
    } catch (e) {
      if (e is OAuthException) rethrow;
      throw OAuthException('Token refresh failed', e);
    }
  }

  @override
  Future<List<String>> getConnectedProviders() async {
    return _localDataSource.getConnectedProviderIds();
  }
}
