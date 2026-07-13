import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';

/// 🚀 SMART on FHIR Client — estándar internacional para apps de salud.
///
/// Implementa el flujo OAuth2 Authorization Code + PKCE que permite a un
/// PACIENTE (no prestador) autorizar a OrionHealth a acceder a sus datos
/// clínicos en la EPS.
///
/// Este es el MISMO estándar que usan:
/// - Apple Health (HealthKit)
/// - Google Health Connect
/// - MyChart (Epic)
/// - NHS App (Reino Unido)
/// - Doctolib (Europa)
///
/// Flujo:
/// 1. Generar code_verifier + code_challenge (PKCE)
/// 2. Abrir navegador → portal EPS (authorize endpoint)
/// 3. Paciente se loguea con sus credenciales de la EPS
/// 4. EPS redirige a OrionHealth con un authorization code
/// 5. OrionHealth intercambia el code por un access_token
/// 6. OrionHealth consulta FHIR API con el token
///
/// El paciente NUNCA comparte su contraseña con OrionHealth.
/// OrionHealth nunca ve las credenciales del paciente.
/// La EPS controla exactamente qué datos comparte (scopes).
class SmartOnFhirClient {
  final http.Client _httpClient;

  /// URL base del FHIR server de la EPS.
  /// Ej: https://fhir.sura.com/R4 para SURA
  final String fhirBaseUrl;

  /// Token endpoint de OAuth2.
  /// Ej: https://auth.sura.com/oauth2/token
  final String tokenEndpoint;

  /// Authorize endpoint para abrir en navegador.
  /// Ej: https://auth.sura.com/oauth2/authorize
  final String authorizeEndpoint;

  /// Client ID registrado. Para desarrollo usamos un redirect URI local.
  /// En producción, cada EPS asigna un client_id.
  final String clientId;

  /// URI a la que la EPS redirige después del login del paciente.
  /// En Android/iOS se usa un custom scheme: orionhealth://callback
  /// En desarrollo: http://localhost:8080/callback
  final String redirectUri;

  /// Scopes FHIR solicitados:
  /// - patient/*.read: datos demográficos
  /// - observation/*.read: signos vitales, labs
  /// - medicationrequest/*.read: medicamentos
  /// - immunization/*.read: vacunas
  /// - condition/*.read: diagnósticos
  /// - allergyintolerance/*.read: alergias
  /// - documentreference/*.read: documentos clínicos
  final List<String> scopes;

  SmartOnFhirClient({
    http.Client? httpClient,
    required this.fhirBaseUrl,
    required this.tokenEndpoint,
    required this.authorizeEndpoint,
    required this.clientId,
    required this.redirectUri,
    this.scopes = const [
      'patient/*.read',
      'observation/*.read',
      'medicationrequest/*.read',
      'immunization/*.read',
      'condition/*.read',
      'allergyintolerance/*.read',
      'documentreference/*.read',
      'encounter/*.read',
      'procedure/*.read',
      'diagnosticreport/*.read',
    ],
  }) : _httpClient = httpClient ?? http.Client();

  // ─── PKCE (Proof Key for Code Exchange) ────────────

  String? _codeVerifier;
  String? _codeChallenge;
  String? _state;

  /// Genera un code_verifier aleatorio de 128 bytes (spec: 43-128 chars).
  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Genera el code_challenge = base64url(sha256(code_verifier))
  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  // ─── FLUJO PRINCIPAL ──────────────────────────────

  /// Inicia el flujo SMART on FHIR.
  ///
  /// 1. Genera PKCE params
  /// 2. Construye la URL de autorización
  /// 3. Abre el navegador del dispositivo
  /// 4. Espera el callback con el authorization code
  /// 5. Intercambia code por token
  ///
  /// Retorna el [SmartOnFhirAuthUrl] con la URL que se debe abrir.
  /// Después de que el paciente se autentica, llamar [handleCallback].
  SmartOnFhirAuthUrl startAuthorization() {
    _codeVerifier = _generateCodeVerifier();
    _codeChallenge = _generateCodeChallenge(_codeVerifier!);
    _state = base64Url.encode(List<int>.generate(16, (_) => Random().nextInt(256)));

    final params = {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes.join(' '),
      'state': _state!,
      'code_challenge': _codeChallenge!,
      'code_challenge_method': 'S256',
      'aud': fhirBaseUrl,
    };

    final uri = Uri.parse(authorizeEndpoint).replace(queryParameters: params);

    return SmartOnFhirAuthUrl(
      url: uri.toString(),
      state: _state!,
      codeVerifier: _codeVerifier!,
    );
  }

  /// Abre el navegador del dispositivo con la URL de autorización.
  Future<void> openAuthorizationPage(SmartOnFhirAuthUrl authUrl) async {
    final uri = Uri.parse(authUrl.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw SmartOnFhirException('No se pudo abrir el navegador para autenticación');
    }
  }

  /// Procesa el callback de la EPS después del login del paciente.
  ///
  /// Recibe la URL completa de redirección (incluyendo ?code=...&state=...).
  /// Verifica el state (anti-CSRF) e intercambia el code por un token.
  Future<OAuthToken> handleCallback(String callbackUrl) async {
    final uri = Uri.parse(callbackUrl);
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    final error = uri.queryParameters['error'];

    if (error != null) {
      throw SmartOnFhirException('EPS rechazó la autorización: $error');
    }

    if (code == null) {
      throw SmartOnFhirException('No se recibió authorization code en el callback');
    }

    if (state != _state) {
      throw SmartOnFhirException(
        'State mismatch — posible ataque CSRF. Esperado: $_state, Recibido: $state',
      );
    }

    if (_codeVerifier == null) {
      throw SmartOnFhirException('No hay code_verifier. Llamá startAuthorization() primero.');
    }

    return _exchangeCodeForToken(code);
  }

  /// Intercambia el authorization code por un access_token.
  Future<OAuthToken> _exchangeCodeForToken(String code) async {
    final response = await _httpClient.post(
      Uri.parse(tokenEndpoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'code_verifier': _codeVerifier!,
      },
    );

    if (response.statusCode != 200) {
      final errorBody = response.body;
      String errorMsg = 'Error al intercambiar código por token';
      try {
        final json = jsonDecode(errorBody);
        errorMsg = json['error_description'] ?? json['error'] ?? errorMsg;
      } catch (_) {}
      throw SmartOnFhirException('$errorMsg (HTTP ${response.statusCode})');
    }

    final data = jsonDecode(response.body);

    // Limpiar datos sensibles de memoria
    _codeVerifier = null;
    _codeChallenge = null;
    _state = null;

    return OAuthToken(
      accessToken: data['access_token'] ?? '',
      refreshToken: data['refresh_token'],
      expiresAt: data['expires_in'] != null
          ? DateTime.now().add(Duration(seconds: data['expires_in']))
          : null,
      idToken: data['id_token'],
      // SMART on FHIR puede incluir patient_id directamente
    );
  }

  /// Refresca el token usando refresh_token (si está disponible).
  Future<OAuthToken> refreshToken(String refreshToken) async {
    final response = await _httpClient.post(
      Uri.parse(tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': clientId,
      },
    );

    if (response.statusCode != 200) {
      throw SmartOnFhirException(
        'Error al refrescar token: HTTP ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);
    return OAuthToken(
      accessToken: data['access_token'] ?? '',
      refreshToken: data['refresh_token'] ?? refreshToken,
      expiresAt: data['expires_in'] != null
          ? DateTime.now().add(Duration(seconds: data['expires_in']))
          : null,
      idToken: data['id_token'],
    );
  }

  // ─── FHIR API Requests ───────────────────────────

  /// GET request al FHIR server de la EPS.
  Future<Map<String, dynamic>> fhirGet(String path, OAuthToken token) async {
    final url = Uri.parse('$fhirBaseUrl/$path');
    final response = await _httpClient.get(
      url,
      headers: _fhirHeaders(token),
    );

    if (response.statusCode == 401) {
      throw SmartOnFhirException('Token expirado — necesita refresh');
    }
    if (response.statusCode != 200) {
      throw SmartOnFhirException('FHIR API error: HTTP ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  /// Buscar paciente por identificador (número de documento).
  Future<Map<String, dynamic>> findPatient({
    required String system,   // Ej: 'CO-CC' para cédula colombiana
    required String value,    // Ej: '123456789'
    required OAuthToken token,
  }) async {
    return fhirGet('Patient?identifier=$system|$value', token);
  }

  /// Obtener todas las condiciones (diagnósticos) del paciente.
  Future<Map<String, dynamic>> getConditions({
    required String patientId,
    required OAuthToken token,
  }) async {
    return fhirGet('Condition?patient=$patientId&clinical-status=active', token);
  }

  /// Obtener todas las alergias del paciente.
  Future<Map<String, dynamic>> getAllergies({
    required String patientId,
    required OAuthToken token,
  }) async {
    return fhirGet('AllergyIntolerance?patient=$patientId', token);
  }

  /// Obtener medicamentos activos.
  Future<Map<String, dynamic>> getMedications({
    required String patientId,
    required OAuthToken token,
  }) async {
    return fhirGet('MedicationRequest?patient=$patientId&status=active', token);
  }

  /// Obtener vacunas.
  Future<Map<String, dynamic>> getImmunizations({
    required String patientId,
    required OAuthToken token,
  }) async {
    return fhirGet('Immunization?patient=$patientId', token);
  }

  /// Obtener observaciones recientes (signos vitales, labs).
  Future<Map<String, dynamic>> getObservations({
    required String patientId,
    required OAuthToken token,
    String? category, // 'vital-signs', 'laboratory', etc.
  }) async {
    var path = 'Observation?patient=$patientId';
    if (category != null) path += '&category=$category';
    return fhirGet(path, token);
  }

  /// Obtener encuentros (citas, hospitalizaciones).
  Future<Map<String, dynamic>> getEncounters({
    required String patientId,
    required OAuthToken token,
  }) async {
    return fhirGet('Encounter?patient=$patientId', token);
  }

  /// Auto-descubrir el FHIR server de una EPS desde su .well-known/smart-configuration.
  ///
  /// El estándar SMART on FHIR define que cada FHIR server expone:
  /// GET {fhirBaseUrl}/.well-known/smart-configuration
  ///
  /// Esto devuelve:
  /// - authorization_endpoint
  /// - token_endpoint
  /// - scopes_supported
  /// - capabilities
  static Future<SmartOnFhirConfig?> discoverConfig(String fhirBaseUrl) async {
    try {
      final client = http.Client();
      final url = Uri.parse('$fhirBaseUrl/.well-known/smart-configuration');
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        client.close();
        return SmartOnFhirConfig(
          authorizeEndpoint: data['authorization_endpoint'] ?? '',
          tokenEndpoint: data['token_endpoint'] ?? '',
          scopesSupported: List<String>.from(data['scopes_supported'] ?? []),
          capabilities: List<String>.from(data['capabilities'] ?? []),
        );
      }
      client.close();
    } catch (_) {}
    return null;
  }

  Map<String, String> _fhirHeaders(OAuthToken token) => {
        'Authorization': 'Bearer ${token.accessToken}',
        'Accept': 'application/fhir+json',
        'Content-Type': 'application/fhir+json',
      };

  void dispose() {
    _httpClient.close();
  }
}

/// Configuración SMART on FHIR descubierta del servidor de la EPS.
class SmartOnFhirConfig {
  final String authorizeEndpoint;
  final String tokenEndpoint;
  final List<String> scopesSupported;
  final List<String> capabilities;

  const SmartOnFhirConfig({
    required this.authorizeEndpoint,
    required this.tokenEndpoint,
    required this.scopesSupported,
    required this.capabilities,
  });

  bool get supportsPkce => true; // Requerido por SMART on FHIR v2
}

/// URL de autorización generada para abrir en el navegador.
class SmartOnFhirAuthUrl {
  final String url;
  final String state;
  final String codeVerifier;

  const SmartOnFhirAuthUrl({
    required this.url,
    required this.state,
    required this.codeVerifier,
  });
}

class SmartOnFhirException implements Exception {
  final String message;
  const SmartOnFhirException(this.message);

  @override
  String toString() => 'SmartOnFhirException: $message';
}
