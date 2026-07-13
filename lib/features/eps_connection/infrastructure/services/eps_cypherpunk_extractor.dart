import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/user_profile.dart';

class EpsCypherpunkExtractor {
  final FlutterSecureStorage _secureStorage;
  final String epsId;
  final String epsPortalUrl;
  final String epsName;

  HeadlessInAppWebView? _headlessWebView;
  final _progressController = StreamController<CypherpunkProgress>.broadcast();
  Stream<CypherpunkProgress> get progress => _progressController.stream;

  final Map<String, _InterceptedEndpoint> _discoveredEndpoints = {};
  final List<String> _interceptedCookies = [];
  String? _authToken;
  String? _rawProfileHtml;
  String? _rawClinicalHistoryHtml;
  Map<String, dynamic>? _rawApiProfile;
  bool _loginDetected = false;

  EpsCypherpunkExtractor({
    required FlutterSecureStorage secureStorage,
    required this.epsId,
    required this.epsPortalUrl,
    required this.epsName,
  }) : _secureStorage = secureStorage;

  Future<CypherpunkSession> startInteractiveCapture({
    required InAppWebViewController Function() onWebViewCreated,
  }) async {
    _report(CypherpunkProgress(
      phase: 'FASE 1/3',
      step: 'Reconocimiento',
      message: 'Iniciando sesion segura en $epsName...\n\n'
          'Se abrira el portal de tu EPS para que ingreses\n'
          'tus credenciales. OrionHealth interceptara\n'
          'unicamente tus datos de salud - nunca tu contrasena.',
      progress: 0.05,
    ));

    _headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(epsPortalUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        cacheEnabled: true,
        userAgent: _androidUserAgent(),
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        supportZoom: true,
        builtInZoomControls: true,
        displayZoomControls: false,
      ),
      shouldInterceptRequest: _onInterceptRequest,
      onLoadStop: _onPageLoadStop,
      onUpdateVisitedHistory: _onUrlChange,
    );

    await _headlessWebView!.platform.run();

    return CypherpunkSession(
      epsId: epsId,
      epsName: epsName,
      isAuthenticated: false,
    );
  }

  Future<WebResourceResponse?> _onInterceptRequest(
    InAppWebViewController controller,
    WebResourceRequest request,
  ) async {
    final url = request.url.toString();
    final reqMethod = request.method ?? 'GET';
    final headers = request.headers ?? {};

    if (_isLoginEndpoint(url, reqMethod)) {
      _discoveredEndpoints['login'] = _InterceptedEndpoint(
        url: url,
        method: reqMethod,
        headers: _extractAuthHeaders(headers),
        timestamp: DateTime.now(),
      );
    }

    final authHeaderVal =
        headers['authorization'] ?? headers['Authorization'] ?? '';
    if (authHeaderVal.isNotEmpty && _authToken == null) {
      _authToken = authHeaderVal;
    }

    if (_isPatientDataEndpoint(url)) {
      final category = _categorizeEndpoint(url);
      _discoveredEndpoints[category] = _InterceptedEndpoint(
        url: url,
        method: reqMethod,
        headers: _extractAuthHeaders(headers),
        timestamp: DateTime.now(),
      );
    }

    return null;
  }

  void _onPageLoadStop(InAppWebViewController controller, WebUri? url) async {
    if (url == null || _loginDetected) return;

    final urlStr = url.toString();

    if (_isPostLoginUrl(urlStr)) {
      _loginDetected = true;

      _report(CypherpunkProgress(
        phase: 'FASE 1/3',
        step: 'Sesion detectada',
        message: 'Login exitoso en $epsName.\n'
            'Capturando tu informacion de salud...',
        progress: 0.3,
      ));

      try {
        final cookieManager = CookieManager.instance();
        final cookies = await cookieManager.getCookies(url: url);
        for (final cookie in cookies) {
          final cookieStr = '${cookie.name}=${cookie.value}';
          _interceptedCookies.add(cookieStr);
        }
      } catch (_) {}

      await _extractPatientData(controller);
    }
  }

  void _onUrlChange(
      InAppWebViewController controller, WebUri? url, bool? isReload) {
    if (url == null) return;
  }

  Future<void> _extractPatientData(InAppWebViewController controller) async {
    _report(CypherpunkProgress(
      phase: 'FASE 2/3',
      step: 'Extrayendo datos',
      message: 'Descargando tu informacion clinica de $epsName...',
      progress: 0.4,
    ));

    final routesToTry = _guessPatientDataRoutes();

    for (int i = 0; i < routesToTry.length; i++) {
      final route = routesToTry[i];

      _report(CypherpunkProgress(
        phase: 'FASE 2/3',
        step: 'Consultando $route',
        message: 'Obteniendo ${_routeLabel(route)}...',
        progress: 0.4 + (0.35 * (i / routesToTry.length)),
      ));

      try {
        final result = await controller.evaluateJavascript(source: '''
          (async () => {
            try {
              const response = await fetch('$epsPortalUrl$route', {
                credentials: 'include',
                headers: {
                  'Accept': 'application/json, text/html, */*',
                  'X-Requested-With': 'XMLHttpRequest'
                }
              });
              const contentType = response.headers.get('content-type') || '';
              if (contentType.includes('json')) {
                return JSON.stringify({
                  route: '$route',
                  type: 'json',
                  data: await response.json()
                });
              } else {
                return JSON.stringify({
                  route: '$route',
                  type: 'html',
                  data: await response.text()
                });
              }
            } catch(e) {
              return JSON.stringify({
                route: '$route',
                type: 'error',
                error: e.toString()
              });
            }
          })();
        ''');

        if (result != null) _storeExtractedData(route, result);
      } catch (e) {
        debugPrint('Fetch fallo a $route: $e');
      }
    }

    _report(CypherpunkProgress(
      phase: 'FASE 2/3',
      step: 'Extraccion completada',
      message: 'Datos obtenidos. Procesando...',
      progress: 0.75,
    ));
  }

  List<String> _guessPatientDataRoutes() {
    return [
      '/api/afiliado/perfil',
      '/api/v1/paciente',
      '/api/beneficiario/datos',
      '/api/afiliado/consultar',
      '/api/patient/profile',
      '/api/user/profile',
      '/api/me',
      '/api/salud/historia-clinica',
      '/api/v1/historia-clinica',
      '/api/afiliado/historia',
      '/api/medical/history',
      '/api/citas/pendientes',
      '/api/salud/citas',
      '/api/v1/appointments',
      '/api/medicamentos',
      '/api/medications',
      '/api/afiliado/medicamentos',
      '/api/vacunas',
      '/api/immunizations',
      '/api/afiliado/vacunas',
      '/fhir/Patient',
      '/api/fhir/R4/Patient',
      '/fhir/R4/Patient',
    ];
  }

  Future<UserProfile> finalizeAndMapToProfile() async {
    _report(CypherpunkProgress(
      phase: 'FASE 3/3',
      step: 'Mapeando datos',
      message: 'Convirtiendo informacion al formato de OrionHealth...',
      progress: 0.8,
    ));

    String? name;
    String? documentId;
    DateTime? birthDate;
    String? sex;
    List<String> conditions = [];
    List<String> medications = [];
    List<String> allergies = [];

    if (_rawApiProfile != null) {
      final data = _rawApiProfile!;
      name ??= _jsonStr(data, [
        'nombre', 'name', 'nombreCompleto', 'fullName',
        'paciente', 'afiliado', 'patient',
      ]);
      documentId ??= _jsonStr(data, [
        'documento', 'cedula', 'identificacion', 'documentId', 'id', 'nroDocumento',
      ]);
      birthDate ??= _jsonDate(data, [
        'fechaNacimiento', 'birthDate', 'fecha_nacimiento', 'dob',
      ]);
      sex ??= _jsonStr(data, ['sexo', 'sex', 'genero', 'gender']);

      final condsList = _jsonList(data, [
        'diagnosticos', 'conditions', 'diagnoses', 'patologias', 'antecedentes',
      ]);
      if (condsList != null) conditions = condsList.map((c) => c.toString()).toList();

      final medsList = _jsonList(data, [
        'medicamentos', 'medications', 'medicines', 'tratamientos',
      ]);
      if (medsList != null) medications = medsList.map((m) => m.toString()).toList();

      final allList = _jsonList(data, [
        'alergias', 'allergies', 'intolerancias',
      ]);
      if (allList != null) allergies = allList.map((a) => a.toString()).toList();
    }

    if (name == null && _rawProfileHtml != null) {
      name = _htmlExtract(_rawProfileHtml!, [
        {'tag': 'h1', 'class': 'nombre'},
        {'tag': 'span', 'class': 'nombre-paciente'},
        {'tag': 'div', 'class': 'profile-name'},
      ]);
      documentId = _htmlExtract(_rawProfileHtml!, [
        {'tag': 'span', 'class': 'documento'},
        {'tag': 'div', 'id': 'cedula'},
      ]);
    }

    _report(CypherpunkProgress(
      phase: 'FASE 3/3',
      step: 'Destruyendo credenciales',
      message: 'Eliminando tokens y cookies de $epsName...\n'
          'Tus credenciales NUNCA salieron de tu dispositivo.',
      progress: 0.95,
    ));

    await _destroyAllCredentials();

    final now = DateTime.now();
    final profile = UserProfile(
      name: name,
      birthDate: birthDate,
      sex: _normalizeSex(sex),
      weightKg: null,
      heightCm: null,
      conditions: conditions,
      familyHistory: [],
      medications: medications,
      allergies: allergies,
      privacyConsent: false,
      createdAt: now,
      updatedAt: now,
      onboardingStep: _calculateStep(name, birthDate, conditions, medications),
      isEpsConnected: true,
      epsPatientId: documentId,
    );

    _report(CypherpunkProgress(
      phase: 'COMPLETADO',
      step: 'Perfil listo',
      message: 'Tu informacion de $epsName fue extraida.\n'
          'Nombre: ${name ?? 'No detectado'}\n'
          'Documento: ${documentId ?? 'No detectado'}\n'
          'Condiciones: ${conditions.length}\n'
          'Medicamentos: ${medications.length}',
      progress: 1.0,
    ));

    return profile;
  }

  Future<void> _destroyAllCredentials() async {
    await _headlessWebView?.platform.dispose();
    _headlessWebView = null;

    try {
      final cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();
    } catch (_) {}

    _authToken = null;
    _interceptedCookies.clear();
    _discoveredEndpoints.clear();
    _rawProfileHtml = null;
    _rawClinicalHistoryHtml = null;
    _rawApiProfile = null;
    await _secureStorage.deleteAll();
  }

  Future<void> dispose() async {
    await _destroyAllCredentials();
    await _progressController.close();
  }

  // ─── Detection ───

  bool _isLoginEndpoint(String url, String method) {
    final lower = url.toLowerCase();
    const patterns = [
      '/login', '/auth', '/signin', '/acceso', '/ingreso',
      '/autenticar', '/validar', '/api/auth', '/oauth',
      '/token', '/sesion', '/acceder',
    ];
    return method.toUpperCase() == 'POST' && patterns.any(lower.contains);
  }

  bool _isPatientDataEndpoint(String url) {
    final lower = url.toLowerCase();
    const patterns = [
      '/perfil', '/profile', '/paciente', '/patient',
      '/afiliado', '/beneficiario', '/api/me', '/api/user',
      '/citas', '/appointments', '/encounters',
      '/historia', '/history', '/clinica', '/clinical',
      '/medicamentos', '/medications', '/medicines',
      '/vacunas', '/immunizations', '/vaccines',
      '/diagnosticos', '/diagnoses', '/conditions',
      '/alergias', '/allergies', '/fhir/',
    ];
    return patterns.any(lower.contains);
  }

  String _categorizeEndpoint(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('perfil') || lower.contains('profile') ||
        (lower.contains('patient') && !lower.contains('history'))) return 'profile';
    if (lower.contains('historia') || lower.contains('history') ||
        lower.contains('clinical') || lower.contains('clinica')) return 'clinicalHistory';
    if (lower.contains('cita') || lower.contains('appointment') || lower.contains('encounter')) return 'appointments';
    if (lower.contains('medicamento') || lower.contains('medication') || lower.contains('dispense')) return 'medications';
    if (lower.contains('vacuna') || lower.contains('immunization') || lower.contains('vaccine')) return 'immunizations';
    if (lower.contains('diagnos') || lower.contains('condition') ||
        lower.contains('alergia') || lower.contains('allergy')) return 'conditions';
    if (lower.contains('fhir')) return 'fhir';
    return 'unknown';
  }

  bool _isPostLoginUrl(String url) {
    final lower = url.toLowerCase();
    const patterns = [
      '/dashboard', '/home', '/inicio', '/bienvenido',
      '/portal', '/afiliado', '/beneficiario', '/paciente',
      '/perfil', '/profile', '/app',
    ];
    return patterns.any(lower.contains);
  }

  String _routeLabel(String route) {
    if (route.contains('perfil') || route.contains('profile') || route.contains('me')) return 'Perfil';
    if (route.contains('historia') || route.contains('history') || route.contains('clinical')) return 'Historia Clinica';
    if (route.contains('cita') || route.contains('appointment')) return 'Citas';
    if (route.contains('medicamento') || route.contains('medication')) return 'Medicamentos';
    if (route.contains('vacuna') || route.contains('immunization')) return 'Vacunas';
    if (route.contains('fhir')) return 'Datos FHIR';
    return 'Datos';
  }

  // ─── Parsers ───

  void _storeExtractedData(String route, String result) {
    try {
      final parsed = jsonDecode(result);
      final type = parsed['type'] as String?;
      if (type == 'json' && parsed['data'] is Map<String, dynamic>) {
        final data = parsed['data'] as Map<String, dynamic>;
        if (_isProfileRoute(route)) _rawApiProfile ??= data;
      } else if (type == 'html' && parsed['data'] is String) {
        if (_isProfileRoute(route)) {
          _rawProfileHtml ??= parsed['data'] as String;
        } else if (_isHistoryRoute(route)) {
          _rawClinicalHistoryHtml ??= parsed['data'] as String;
        }
      }
    } catch (_) {}
  }

  bool _isProfileRoute(String r) =>
      r.contains('perfil') || r.contains('profile') || r.contains('me') ||
      r.contains('afiliado') || r.contains('paciente') || r.contains('Patient');

  bool _isHistoryRoute(String r) =>
      r.contains('historia') || r.contains('history') || r.contains('clinical');

  dynamic _json(Map<String, dynamic> data, List<String> paths) {
    for (final path in paths) {
      var value = data[path];
      if (value is Map<String, dynamic>) {
        value = value['valor'] ?? value['value'] ?? value['descripcion'] ?? value;
      }
      if (value != null && value.toString().isNotEmpty) return value;
    }
    return null;
  }

  String? _jsonStr(Map<String, dynamic> data, List<String> paths) =>
      _json(data, paths)?.toString();

  DateTime? _jsonDate(Map<String, dynamic> data, List<String> paths) {
    final v = _json(data, paths);
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      try {
        final parts = v.toString().split(RegExp(r'[/\-]'));
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2].length == 4 ? parts[2] : parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2].length == 4 ? parts[0] : parts[1]),
          );
        }
      } catch (_) {}
    }
    return null;
  }

  List<dynamic>? _jsonList(Map<String, dynamic> data, List<String> paths) {
    for (final path in paths) {
      final v = data[path];
      if (v is List) return v;
      if (v is Map<String, dynamic>) {
        final inner = v['data'] ?? v['items'] ?? v['results'] ?? v['entries'];
        if (inner is List) return inner;
      }
    }
    return null;
  }

  String? _htmlExtract(String html, List<Map<String, String>> selectors) {
    for (final sel in selectors) {
      final tag = sel['tag']!;
      String pattern;
      if (sel.containsKey('class')) {
        pattern = '<$tag[^>]*class="[^"]*${sel['class']}[^"]*"[^>]*>(.*?)</$tag>';
      } else if (sel.containsKey('id')) {
        pattern = '<$tag[^>]*id="${sel['id']}"[^>]*>(.*?)</$tag>';
      } else {
        pattern = '<$tag[^>]*data-field="${sel['data-field']}"[^>]*>(.*?)</$tag>';
      }
      final match = RegExp(pattern, caseSensitive: false).firstMatch(html);
      if (match != null) return _stripHtml(match.group(1) ?? '');
    }
    return null;
  }

  String _stripHtml(String h) =>
      h.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

  String _normalizeSex(String? v) {
    if (v == null) return 'O';
    switch (v.toLowerCase()) {
      case 'm': case 'masculino': case 'hombre': case 'male': return 'M';
      case 'f': case 'femenino': case 'mujer': case 'female': return 'F';
      default: return 'O';
    }
  }

  int _calculateStep(String? name, DateTime? bday, List<String> conds, List<String> meds) {
    if (name == null || bday == null) return 1;
    if (conds.isEmpty && meds.isEmpty) return 2;
    if (meds.isEmpty) return 3;
    return 4;
  }

  Map<String, String> _extractAuthHeaders(Map<String, String> headers) {
    final auth = <String, String>{};
    for (final k in [
      'authorization', 'Authorization',
      'x-api-key', 'X-API-Key',
      'x-auth-token', 'X-Auth-Token',
      'cookie', 'Cookie',
    ]) {
      if (headers.containsKey(k)) auth[k] = headers[k]!;
    }
    return auth;
  }

  String _androidUserAgent() =>
      'Mozilla/5.0 (Linux; Android 14; SM-S928B) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/125.0.6422.165 Mobile Safari/537.36';

  void _report(CypherpunkProgress p) => _progressController.add(p);
}

class CypherpunkSession {
  final String epsId;
  final String epsName;
  final bool isAuthenticated;
  final List<String> discoveredEndpoints;
  final DateTime startedAt;

  CypherpunkSession({
    required this.epsId,
    required this.epsName,
    required this.isAuthenticated,
    this.discoveredEndpoints = const [],
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();
}

class CypherpunkProgress {
  final String phase;
  final String step;
  final String message;
  final double progress;

  const CypherpunkProgress({
    required this.phase,
    required this.step,
    required this.message,
    required this.progress,
  });
}

class _InterceptedEndpoint {
  final String url;
  final String method;
  final Map<String, String> headers;
  final DateTime timestamp;

  const _InterceptedEndpoint({
    required this.url,
    required this.method,
    required this.headers,
    required this.timestamp,
  });
}
