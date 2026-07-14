import 'dart:convert';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/eps_connection/domain/repositories/oauth_repository.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/ihce_auth_service.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/ihce_api_client.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/local_fhir_engine.dart';

/// Implementación del OAuthRepository que usa el Local FHIR Engine
/// para conectar con el IHCE de Minsalud.
@LazySingleton(as: OAuthRepository, env: ['development', 'staging', 'test'])
class LocalFhirOAuthRepository implements OAuthRepository {
  static const String _sandboxClientId = 'fhir-client';
  static const String _sandboxClientSecret = 'fhir-secret';

  LocalFhirEngine? _engine;
  final Map<String, OAuthToken> _tokens = {};
  final List<String> _connectedProviderIds = [];

  LocalFhirEngine get engine {
    _engine ??= LocalFhirEngine(
      authService: IhceAuthService(
        clientId: _sandboxClientId,
        clientSecret: _sandboxClientSecret,
      ),
      apiClient: IhceApiClient(
        authService: IhceAuthService(
          clientId: _sandboxClientId,
          clientSecret: _sandboxClientSecret,
        ),
      ),
    );
    return _engine!;
  }

  @override
  Future<OAuthLoginResult?> login(EPSProvider provider) async {
    try {
      final token = await engine.authenticate();
      _tokens[provider.id] = token;
      _connectedProviderIds.add(provider.id);
      return OAuthLoginResult(token: token);
    } catch (e) {
      throw OAuthException('Failed to login to ${provider.name}: $e', e);
    }
  }

  @override
  Future<void> logout(String providerId) async {
    _tokens.remove(providerId);
    _connectedProviderIds.remove(providerId);
    await _deletePersistedToken(providerId);
  }

  @override
  Future<OAuthToken?> getToken(String providerId) async {
    if (_tokens.containsKey(providerId)) {
      final token = _tokens[providerId]!;
      if (!token.isExpired) return token;
    }
    // Intentar cargar de disco
    return _loadPersistedToken(providerId);
  }

  @override
  Future<String?> getPatientId(String providerId) async {
    final file = await _getTokenFile(providerId);
    if (!await file.exists()) return null;
    try {
      final data = jsonDecode(await file.readAsString());
      return data['patientId'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<OAuthToken?> refreshToken(EPSProvider provider) async {
    try {
      final token = await engine.authenticate();
      _tokens[provider.id] = token;
      await _persistToken(provider.id, token);
      return token;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getConnectedProviders() async {
    // Cargar IDs conectados del disco
    if (_connectedProviderIds.isEmpty) {
      final dir = await _getTokensDir();
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.json')) {
            final id = entity.path.split('\\').last.replaceAll('.json', '');
            _connectedProviderIds.add(id);
          }
        }
      }
    }
    return List.unmodifiable(_connectedProviderIds);
  }

  @override
  Future<EPSProvider?> getProviderDetails(String providerId) async {
    // Buscar en el catálogo
    try {
      final catalog = await _loadCatalog();
      if (catalog != null) {
        for (final provider in catalog) {
          if (provider['id'] == providerId) {
            return EPSProvider(
              id: provider['id'],
              name: provider['name'],
              discoveryUrl: provider['discoveryUrl'] ?? '',
              clientId: provider['clientId'] ?? '',
              redirectUrl: provider['redirectUrl'] ?? '',
              scopes: List<String>.from(provider['scopes'] ?? []),
            );
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // ─── FHIR Engine helpers ─────────────────────────────

  Future<LocalFhirEngine> getEngine() async {
    return engine;
  }

  // ─── PERSISTENCIA LOCAL ──────────────────────────────

  Future<Directory> _getTokensDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final fhirDir = Directory('${dir.path}/fhir/tokens');
    if (!await fhirDir.exists()) {
      await fhirDir.create(recursive: true);
    }
    return fhirDir;
  }

  Future<File> _getTokenFile(String providerId) async {
    final dir = await _getTokensDir();
    return File('${dir.path}/$providerId.json');
  }

  Future<void> _persistToken(String providerId, OAuthToken token) async {
    final file = await _getTokenFile(providerId);
    final data = {
      'accessToken': token.accessToken,
      'refreshToken': token.refreshToken,
      'expiresAt': token.expiresAt?.toIso8601String(),
      'idToken': token.idToken,
    };
    await file.writeAsString(jsonEncode(data));
  }

  Future<OAuthToken?> _loadPersistedToken(String providerId) async {
    try {
      final file = await _getTokenFile(providerId);
      if (!await file.exists()) return null;
      final data = jsonDecode(await file.readAsString());
      return OAuthToken(
        accessToken: data['accessToken'] as String? ?? '',
        refreshToken: data['refreshToken'] as String?,
        expiresAt: data['expiresAt'] != null
            ? DateTime.tryParse(data['expiresAt'])
            : null,
        idToken: data['idToken'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _deletePersistedToken(String providerId) async {
    final file = await _getTokenFile(providerId);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<Map<String, dynamic>>?> _loadCatalog() async {
    // Placeholder — en producción vendría de Isar o del catálogo estático
    return null;
  }

  void dispose() {
    _engine?.dispose();
  }
}
