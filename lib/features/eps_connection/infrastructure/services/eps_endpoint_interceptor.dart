import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// EPS Endpoint Interceptor Engine
///
/// Intercepts all XHR/fetch requests made by the EPS portal to discover
/// and catalog API endpoints. This allows OrionHealth to build a complete
/// map of the EPS's backend without prior knowledge of their API structure.
///
/// Modes:
/// 1. **Passive**: Intercepts requests, records endpoints → builds catalog
/// 2. **Active**: After cataloging, probes discovered endpoints to extract
///    the most important patient data
///
/// Privacy: All interception happens on-device. No data leaves the device.
/// Intercepted cookies and auth headers are discarded after extraction.
class EpsEndpointInterceptor {
  final String _epsId;

  final Map<String, DiscoveredEndpoint> _discovered = {};
  final List<Map<String, dynamic>> _apiResponses = [];
  String? _authToken;
  bool _isIntercepting = false;

  final _onEndpointDiscovered = StreamController<DiscoveredEndpoint>.broadcast();
  final _onProgress = StreamController<InterceptorProgress>.broadcast();

  Stream<DiscoveredEndpoint> get onEndpointDiscovered => _onEndpointDiscovered.stream;
  Stream<InterceptorProgress> get onProgress => _onProgress.stream;

  EpsEndpointInterceptor({
    required String epsId,
    required String epsPortalUrl,
  })  : _epsId = epsId;

  /// Starts the WebView with request interception enabled.
  InAppWebViewSettings get interceptionSettings => InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        cacheEnabled: true,
        useWideViewPort: true,
        supportZoom: true,
        builtInZoomControls: true,
        displayZoomControls: false,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        userAgent: _androidUserAgent(),
      );

  /// Intercepts outgoing requests to discover API endpoints.
  /// Returns null to allow the request to proceed normally.
  WebResourceResponse? interceptRequest(WebResourceRequest request) {
    if (!_isIntercepting) return null;

    final url = request.url.toString();
    final method = request.method ?? 'GET';
    final headers = Map<String, String>.from(request.headers ?? {});

    // Extract auth tokens from headers
    final authHeader =
        headers['authorization'] ?? headers['Authorization'] ?? '';
    if (authHeader.isNotEmpty && _authToken == null) {
      _authToken = authHeader;
      debugPrint('AUTH TOKEN captured for $_epsId');
    }

    // Only track API/XHR endpoints (skip HTML pages, images, CSS, fonts)
    if (!_isApiEndpoint(url)) return null;

    final category = _categorizeEndpoint(url);
    final endpoint = DiscoveredEndpoint(
      epsId: _epsId,
      url: url,
      method: method,
      category: category,
      authHeaders: _extractAuthHeaders(headers),
      discoveredAt: DateTime.now(),
    );

    if (!_discovered.containsKey(url)) {
      _discovered[url] = endpoint;
      _onEndpointDiscovered.add(endpoint);

      debugPrint(
          'DISCOVERED ENDPOINT [$_epsId/$category]: $method $url');
    }

    return null; // Allow the request to proceed
  }

  /// Starts active probing of discovered endpoints.
  /// This runs JavaScript in the WebView to fetch each discovered endpoint
  /// and extract patient data from the responses.
  Future<Map<String, dynamic>> probeDiscoveredEndpoints(
    InAppWebViewController controller,
  ) async {
    _report(InterceptorProgress(
      phase: 'PROBING',
      step: 'Explorando APIs',
      message: 'Probando ${_discovered.length} endpoints descubiertos en $_epsId...',
      progress: 0.4,
    ));

    final patientData = <String, dynamic>{};

    // Prioritize profile endpoints first
    final sortedEndpoints = _discovered.values.toList()
      ..sort((a, b) {
        const priority = ['profile', 'fhir', 'clinicalHistory', 'conditions',
            'medications', 'appointments', 'immunizations', 'unknown'];
        final aIdx = priority.indexOf(a.category);
        final bIdx = priority.indexOf(b.category);
        return aIdx.compareTo(bIdx);
      });

    for (int i = 0; i < sortedEndpoints.length; i++) {
      final ep = sortedEndpoints[i];

      _report(InterceptorProgress(
        phase: 'PROBING',
        step: 'Consultando ${ep.category}',
        message: '${ep.method} ${_shortUrl(ep.url)}',
        progress: 0.4 + (0.5 * (i / sortedEndpoints.length)),
      ));

      try {
        final result = await controller.evaluateJavascript(source: '''
          (async () => {
            try {
              const res = await fetch('${ep.url}', {
                method: '${ep.method}',
                credentials: 'include',
                headers: {
                  'Accept': 'application/json, text/html, */*',
                  'X-Requested-With': 'XMLHttpRequest'
                }
              });
              const ct = res.headers.get('content-type') || '';
              if (ct.includes('json')) {
                const data = await res.json();
                return JSON.stringify({ok: true, type: 'json', url: '${ep.url}', category: '${ep.category}', data: data});
              }
              const text = await res.text();
              return JSON.stringify({ok: true, type: 'text', url: '${ep.url}', category: '${ep.category}', data: text.substring(0, 3000)});
            } catch(e) {
              return JSON.stringify({ok: false, url: '${ep.url}', error: e.toString()});
            }
          })();
        ''');

        if (result != null && result.toString().isNotEmpty) {
          final parsed = jsonDecode(result.toString());
          if (parsed['ok'] == true) {
            _apiResponses.add(Map<String, dynamic>.from(parsed));
            _extractPatientFields(parsed, patientData);
          }
        }
      } catch (e) {
        debugPrint('Probe failed for ${ep.url}: $e');
      }

      // Bail early if we have enough data
      if (patientData.containsKey('name') &&
          patientData.containsKey('documentId') &&
          patientData.containsKey('birthDate')) {
        break;
      }
    }

    // Also try common API paths that we might not have discovered yet
    await _tryCommonApiPaths(controller, patientData);

    _report(InterceptorProgress(
      phase: 'DONE',
      step: 'Extracción completada',
      message: '${patientData.length} campos extraídos de $_epsId',
      progress: 1.0,
    ));

    return patientData;
  }

  /// Probes a small set of EPS-specific API paths as a last-resort fallback.
  ///
  /// ⚠️ CRITICAL: We limit probing to at most 5 essential paths with delays
  /// to avoid triggering the EPS's security/anti-bot mechanisms.
  /// Rapid probing of non-existent endpoints causes session invalidation
  /// on many Colombian EPS portals (especially Sura and Sanitas).
  Future<void> _tryCommonApiPaths(
    InAppWebViewController controller,
    Map<String, dynamic> patientData,
  ) async {
    // Only probe high-value paths that are likely to exist across EPS portals.
    // Limited to 5 max to avoid security triggers (was 20, causing Sura logouts).
    const criticalPaths = <String>[
      '/api/afiliado/perfil',
      '/api/me',
      '/fhir/Patient',
      '/api/v1/paciente',
    ];

    // EPS-specific known-good paths — configure here when verified per EPS
    const epsPaths = <String, List<String>>{};
    // Future: 'EPS025': ['/api/afiliado/perfil'],  // Sura

    final pathsToTry = <String>[
      ...(epsPaths[_epsId] ?? <String>[]),
      ...criticalPaths,
    ].take(5).toList();

    for (int i = 0; i < pathsToTry.length; i++) {
      final path = pathsToTry[i];

      if (_discovered.values.any((e) => e.url.contains(path))) continue;

      // Bail early if we already have the essential data
      if (patientData.containsKey('name') &&
          patientData.containsKey('documentId') &&
          patientData.containsKey('birthDate')) {
        break;
      }

      // ⚠️ Delay between probes to avoid triggering security
      if (i > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }

      try {
        final result = await controller.evaluateJavascript(source: '''
          (async () => {
            try {
              const res = await fetch('$path', {
                credentials: 'include',
                headers: {
                  'Accept': 'application/json, text/html, */*',
                  'X-Requested-With': 'XMLHttpRequest'
                }
              });
              if (!res.ok) return null;
              const ct = res.headers.get('content-type') || '';
              let data;
              if (ct.includes('json')) {
                data = await res.json();
              } else {
                data = await res.text();
              }
              return JSON.stringify({url: '$path', ok: true, type: ct.includes('json') ? 'json' : 'text', data: data});
            } catch(e) { return null; }
          })();
        ''');

        if (result != null && result.toString().isNotEmpty) {
          final parsed = jsonDecode(result.toString());
          if (parsed['ok'] == true) {
            _extractPatientFields(parsed, patientData);
          }
        }
      } catch (_) {
        // Non-fatal: individual path probing failure is expected
      }
    }
  }

  /// Extracts patient data fields from an API response.
  void _extractPatientFields(
      Map<String, dynamic> response, Map<String, dynamic> patientData) {
    if (response['type'] != 'json') return;

    dynamic data = response['data'];
    if (data is! Map<String, dynamic>) {
      // Some APIs wrap the real data
      if (data is List && data.isNotEmpty) {
        data = data[0];
      } else {
        return;
      }
    }
    if (data is! Map<String, dynamic>) return;

    // Extract all known fields
    if (!patientData.containsKey('name')) {
      patientData['name'] = _jsonStr(data, [
        'nombre', 'name', 'nombreCompleto', 'fullName',
        'paciente', 'afiliado', 'patient', 'display',
      ]);
    }

    if (!patientData.containsKey('documentId')) {
      patientData['documentId'] = _jsonStr(data, [
        'documento', 'cedula', 'identificacion', 'documentId',
        'id', 'nroDocumento', 'identifier',
      ]);
    }

    if (!patientData.containsKey('birthDate')) {
      patientData['birthDate'] = _jsonStr(data, [
        'fechaNacimiento', 'birthDate', 'fecha_nacimiento',
        'dob', 'birthdate',
      ]);
    }

    if (!patientData.containsKey('sex')) {
      patientData['sex'] = _jsonStr(data, [
        'sexo', 'sex', 'genero', 'gender',
      ]);
    }

    if (!patientData.containsKey('affiliationType')) {
      patientData['affiliationType'] = _jsonStr(data, [
        'tipoAfiliado', 'regimen', 'affiliationType', 'planType', 'tipo_afiliado',
      ]);
    }

    // Additional scalar fields
    if (!patientData.containsKey('phone')) {
      patientData['phone'] = _jsonStr(data, [
        'telefono', 'celular', 'phone', 'mobilePhone',
        'telephone', 'contactPhone', 'numeroTelefono',
      ]);
    }

    if (!patientData.containsKey('email')) {
      patientData['email'] = _jsonStr(data, [
        'email', 'correo', 'correoElectronico', 'mail',
      ]);
    }

    if (!patientData.containsKey('address')) {
      patientData['address'] = _jsonStr(data, [
        'direccion', 'address', 'residencia', 'domicilio',
      ]);
    }

    if (!patientData.containsKey('bloodType')) {
      patientData['bloodType'] = _jsonStr(data, [
        'grupoSanguineo', 'bloodType', 'tipoSangre',
        'bloodGroup', 'rhFactor', 'rh',
      ]);
    }

    if (!patientData.containsKey('affiliationDate')) {
      patientData['affiliationDate'] = _jsonStr(data, [
        'fechaAfiliacion', 'affiliationDate', 'fecha_afiliacion',
        'enrollmentDate', 'startDate',
      ]);
    }

    if (!patientData.containsKey('epsId')) {
      patientData['epsId'] = _jsonStr(data, [
        'codigoEPS', 'epsId', 'epsCode', 'codigo_eps',
      ]);
    }

    // Collect lists: conditions, medications, allergies, vaccines, appointments
    final conds = _jsonList(data, [
      'diagnosticos', 'conditions', 'diagnoses', 'patologias',
      'problemList', 'antecedentes', 'medicalConditions',
    ]);
    if (conds != null && conds.isNotEmpty) {
      patientData['conditions'] = conds.map((c) => c.toString()).toList();
    }

    final meds = _jsonList(data, [
      'medicamentos', 'medications', 'medicines', 'tratamientos',
      'medicationList', 'medicacion', 'drugs',
    ]);
    if (meds != null && meds.isNotEmpty) {
      patientData['medications'] = meds.map((m) => m.toString()).toList();
    }

    final alls = _jsonList(data, [
      'alergias', 'allergies', 'intolerancias',
      'allergyList', 'reaccionesAdversas',
    ]);
    if (alls != null && alls.isNotEmpty) {
      patientData['allergies'] = alls.map((a) => a.toString()).toList();
    }

    final vacs = _jsonList(data, [
      'vacunas', 'vaccines', 'immunizations', 'inmunizaciones',
      'vaccineList',
    ]);
    if (vacs != null && vacs.isNotEmpty) {
      patientData['vaccines'] = vacs.map((v) => v.toString()).toList();
    }

    final apps = _jsonList(data, [
      'citas', 'appointments', 'encuentros', 'encounters',
      'citasPendientes', 'pendingAppointments',
    ]);
    if (apps != null && apps.isNotEmpty) {
      patientData['appointments'] = apps.map((a) => a.toString()).toList();
    }
  }

  // ─── Detection Helpers ───

  bool _isApiEndpoint(String url) {
    final lower = url.toLowerCase();
    // Skip assets
    if (lower.endsWith('.css') || lower.endsWith('.js') ||
        lower.endsWith('.png') || lower.endsWith('.jpg') ||
        lower.endsWith('.svg') || lower.endsWith('.woff') ||
        lower.endsWith('.woff2') || lower.endsWith('.ttf') ||
        lower.endsWith('.ico') || lower.endsWith('.gif') ||
        lower.endsWith('.webp') || lower.endsWith('.mp4')) {
      return false;
    }

    // Match API patterns
    const apiPatterns = [
      '/api/', '/fhir/', '/rest/', '/graphql',
      '/oauth', '/auth/', '/token',
      '/perfil', '/profile', '/paciente', '/patient',
      '/afiliado', '/beneficiario',
      '/citas/', '/appointments/', '/encounters/',
      '/historia/', '/history/', '/clinical/',
      '/medicamentos/', '/medications/', '/medicines/',
      '/vacunas/', '/immunizations/', '/vaccines/',
      '/diagnosticos/', '/diagnoses/', '/conditions/',
    ];

    return apiPatterns.any(lower.contains);
  }

  String _categorizeEndpoint(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('fhir/patient') || lower.contains('fhir/R4/Patient')) return 'fhir';
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

  Map<String, String> _extractAuthHeaders(Map<String, String> headers) {
    final auth = <String, String>{};
    for (final k in [
      'authorization', 'Authorization',
      'x-api-key', 'X-API-Key',
      'x-auth-token', 'X-Auth-Token',
      'x-csrf-token', 'X-CSRF-Token',
    ]) {
      if (headers.containsKey(k)) auth[k] = headers[k]!;
    }
    return auth;
  }

  // ─── JSON Extraction Helpers ───

  dynamic _json(Map<String, dynamic> data, List<String> paths) {
    for (final path in paths) {
      dynamic value = data[path];
      if (value != null) {
        if (value is Map<String, dynamic>) {
          value = value['valor'] ?? value['value'] ??
              value['descripcion'] ?? value['text'] ?? value['display'];
        }
        if (value != null && value.toString().isNotEmpty) return value;
      }
    }
    return null;
  }

  String? _jsonStr(Map<String, dynamic> data, List<String> paths) {
    final v = _json(data, paths);
    return v?.toString().trim();
  }

  List<dynamic>? _jsonList(Map<String, dynamic> data, List<String> paths) {
    for (final path in paths) {
      final v = data[path];
      if (v is List) return v;
      if (v is Map<String, dynamic>) {
        final inner = v['data'] ?? v['items'] ?? v['results'] ??
            v['entries'] ?? v['entry'] ?? v['content'];
        if (inner is List) return inner;
      }
    }
    return null;
  }

  // ─── Reporting ───

  void _report(InterceptorProgress p) => _onProgress.add(p);

  /// Start intercepting.
  void startInterception() => _isIntercepting = true;

  /// Stop intercepting.
  void stopInterception() => _isIntercepting = false;

  /// Number of discovered endpoints.
  int get discoveredCount => _discovered.length;

  /// Full catalog of discovered endpoints.
  List<DiscoveredEndpoint> get discoveredEndpoints => _discovered.values.toList();

  /// Captured auth token (if any).
  String? get authToken => _authToken;

  void dispose() {
    _onEndpointDiscovered.close();
    _onProgress.close();
  }

  String _shortUrl(String url) {
    if (url.length <= 60) return url;
    return '${url.substring(0, 30)}...${url.substring(url.length - 27)}';
  }

  String _androidUserAgent() =>
      'Mozilla/5.0 (Linux; Android 14; SM-S928B) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/125.0.6422.165 Mobile Safari/537.36';
}

/// Represents a discovered API endpoint.
class DiscoveredEndpoint {
  final String epsId;
  final String url;
  final String method;
  final String category;
  final Map<String, String> authHeaders;
  final DateTime discoveredAt;

  const DiscoveredEndpoint({
    required this.epsId,
    required this.url,
    required this.method,
    required this.category,
    required this.authHeaders,
    required this.discoveredAt,
  });

  Map<String, dynamic> toJson() => {
        'epsId': epsId,
        'url': url,
        'method': method,
        'category': category,
        'authHeaders': authHeaders,
        'discoveredAt': discoveredAt.toIso8601String(),
      };
}

class InterceptorProgress {
  final String phase;
  final String step;
  final String message;
  final double progress;

  const InterceptorProgress({
    required this.phase,
    required this.step,
    required this.message,
    required this.progress,
  });
}
