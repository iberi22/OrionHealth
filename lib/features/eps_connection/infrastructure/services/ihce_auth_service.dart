import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';

/// Gestiona autenticación OAuth2 Client Credentials contra Azure AD del IHCE Minsalud.
///
/// Endpoint: https://login.microsoftonline.com/{tenantId}/oauth2/v2.0/token
/// Scope: api://ca9a5155-3135-4e44-a644-b92175eb4d21/.default
///
/// Las credenciales (clientId, clientSecret) son asignadas por Minsalud
/// a cada prestador/EPS que se registra en el IHCE.
/// Para desarrollo, el sandbox usa credenciales públicas.
class IhceAuthService {
  static const String _tokenUrl = 'https://login.microsoftonline.com/{tenantId}/oauth2/v2.0/token';
  static const String _sandboxTenantId = '3d4b3d76-b910-426c-bd8f-bd964e3e1b53';
  static const String _scope = 'api://ca9a5155-3135-4e44-a644-b92175eb4d21/.default';

  final http.Client _client;
  final String _tenantId;
  final String _clientId;
  final String _clientSecret;

  IhceAuthService({
    required String clientId,
    required String clientSecret,
    http.Client? httpClient,
    String? tenantId,
  })  : _clientId = clientId,
        _clientSecret = clientSecret,
        _tenantId = tenantId ?? _sandboxTenantId,
        _client = httpClient ?? http.Client();

  /// Obtiene un token de acceso via Client Credentials flow (machine-to-machine).
  ///
  /// Este flow NO requiere interacción del usuario. Es el que usan
  /// los prestadores registrados en el IHCE.
  Future<OAuthToken> getClientCredentialsToken() async {
    final url = _tokenUrl.replaceFirst('{tenantId}', _tenantId);

    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'scope': _scope,
      },
    );

    if (response.statusCode != 200) {
      final body = response.body;
      throw IhceAuthException(
        'Error obteniendo token IHCE (${response.statusCode}): $body',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = data['access_token'] as String;
    final expiresIn = data['expires_in'] as int? ?? 3600;

    return OAuthToken(
      accessToken: accessToken,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  void dispose() => _client.close();
}

class IhceAuthException implements Exception {
  final String message;
  final int? statusCode;

  IhceAuthException(this.message, {this.statusCode});

  @override
  String toString() => 'IhceAuthException: $message';
}
