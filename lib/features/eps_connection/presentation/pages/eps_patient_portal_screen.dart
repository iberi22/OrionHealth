import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/eps_provider.dart';
import '../../domain/entities/eps_providers_catalog.dart';
import '../../infrastructure/services/eps_url_validator.dart';
import '../../infrastructure/services/eps_webview_session.dart';
import '../../infrastructure/services/eps_endpoint_interceptor.dart';
import '../../../../core/theme/app_colors.dart';

/// EPS Patient Portal Login Screen v2
///
/// Enhanced WebView with:
/// - Session persistence (cookies + localStorage saved/restored)
/// - Navigation history tracking (every URL visited)
/// - Deep-link re-entry: on re-open with active session, goes directly to dashboard
/// - Endpoint-aware scraping: intercepts XHR/fetch, catalogs APIs, probes endpoints
///
/// Flow:
/// 1. If active session exists → restore cookies, go directly to dashboard
/// 2. If no session → load EPS portal login page
/// 3. User manually authenticates with EPS credentials
/// 4. On login detection: session captured + endpoint interception starts
/// 5. After scraping: returns patient data to previous screen
class EpsPatientPortalScreen extends StatefulWidget {
  final EPSProvider provider;
  final bool autoConnect; // If true, try to restore session and skip login

  const EpsPatientPortalScreen({
    super.key,
    required this.provider,
    this.autoConnect = false,
  });

  @override
  State<EpsPatientPortalScreen> createState() => _EpsPatientPortalScreenState();
}

enum _PortalState { loading, loginPage, authenticated, scraping, restoring, error }

class _EpsPatientPortalScreenState extends State<EpsPatientPortalScreen> {
  InAppWebViewController? _webViewController;
  _PortalState _state = _PortalState.loading;
  String? _errorMessage;
  double _loadProgress = 0.0;
  String _currentUrl = '';
  int _redirectCount = 0;
  final _redirectUrls = <String>[];

  late final EpsWebViewSession _sessionManager;
  late final EpsEndpointInterceptor _endpointInterceptor;
  bool _sessionRestored = false;
  String? _scrapingStatus;
  final _discoveredEndpoints = <String>[];
  int _endpointsProbed = 0;

  @override
  void initState() {
    super.initState();
    const storage = FlutterSecureStorage();
    _sessionManager = EpsWebViewSession(
      storage: storage,
      epsId: widget.provider.id,
    );
    _endpointInterceptor = EpsEndpointInterceptor(
      epsId: widget.provider.id,
      epsPortalUrl: EpsProvidersCatalog.getPortalUrl(widget.provider.id),
    );

    // Listen for discovered endpoints
    _endpointInterceptor.onEndpointDiscovered.listen((ep) {
      setState(() {
        _discoveredEndpoints.add('${ep.method} ${ep.category}/${_shortUrl(ep.url)}');
        if (_discoveredEndpoints.length > 10) {
          _discoveredEndpoints.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _endpointInterceptor.dispose();
    _webViewController = null;
    super.dispose();
  }

  String get _portalUrl =>
      EpsProvidersCatalog.getPortalUrl(widget.provider.id);

  // ─── Session-aware URL loading ───

  /// Gets the initial URL to load. If an active session exists and autoConnect
  /// is true, returns the last known URL (dashboard). Otherwise returns the
  /// portal login URL.
  Future<String> _resolveInitialUrl() async {
    final hasSession = await _sessionManager.hasActiveSession();
    if (hasSession && widget.autoConnect) {
      final lastUrl = await _sessionManager.getLastUrl();
      if (lastUrl != null && lastUrl.isNotEmpty) {
        debugPrint('Resuming EPS session: $lastUrl');
        return lastUrl;
      }
    }
    return _portalUrl;
  }

  // ─── Post-login URL detection ───

  bool _isPostLoginUrl(String url) {
    final lower = url.toLowerCase();
    // Skip the portal URL itself
    if (lower == _portalUrl.toLowerCase()) return false;

    const patterns = [
      '/dashboard', '/home', '/inicio', '/bienvenido',
      '/perfil', '/profile', '/afiliado', '/beneficiario',
      '/paciente', '/portal', '/app', '/servicios',
      '/miportal', '/misalud', '/micuenta',
    ];
    return patterns.any((p) => lower.contains(p));
  }

  // ─── Session-aware scraping ───

  Future<void> _startScraping() async {
    if (_webViewController == null) return;

    setState(() => _state = _PortalState.scraping);

    try {
      // 1. Capture the session so user can re-enter later without login
      _setStatus('Guardando sesión...');
      await _sessionManager.captureSession(_webViewController!);
      await _sessionManager.saveLastUrl(_currentUrl);

      // 2. Start endpoint interception and active probing
      _setStatus('Descubriendo endpoints de ${widget.provider.name}...');
      _endpointInterceptor.startInterception();

      final patientData = await _endpointInterceptor.probeDiscoveredEndpoints(
        _webViewController!,
      );
      _endpointsProbed = _endpointInterceptor.discoveredCount;

      _endpointInterceptor.stopInterception();

      // 3. Fallback: standard DOM scraping if endpoint probing didn't get everything
      if (!patientData.containsKey('name') || !patientData.containsKey('documentId')) {
        _setStatus('Extrayendo datos del portal...');
        final domResults = await _scrapeDom();
        patientData.addAll(domResults);
      }

      // 4. Clean up credentials from memory
      _setStatus('Eliminando credenciales temporales...');
      // (Cookies and localStorage are already in secure storage via _sessionManager)

      // 5. Return data
      if (mounted) {
        Navigator.of(context).pop({
          ...patientData,
          'epsProviderId': widget.provider.id,
          'epsProviderName': widget.provider.name,
          'endpointsDiscovered': _endpointsProbed,
        });
      }
    } catch (e) {
      debugPrint('Scraping error: $e');
      if (mounted) {
        setState(() {
          _state = _PortalState.error;
          _errorMessage = 'Error al extraer datos: $e';
        });
      }
    }
  }

  void _setStatus(String status) {
    setState(() => _scrapingStatus = status);
  }

  /// Standard DOM scraping as fallback.
  Future<Map<String, String>> _scrapeDom() async {
    final results = <String, String>{};

    const selectors = {
      'name': '''
        (function() {
          const sels = ['.nombre-paciente','.profile-name','.patient-name',
            '[data-field="nombre"]','.nombre','.name','#nombrePaciente',
            '#nombreCompleto','.bienvenido strong','.welcome-message',
            '.datos-afiliado .nombre','h1'];
          for (const s of sels) {
            const el = document.querySelector(s);
            if (el && el.textContent.trim()) return el.textContent.trim();
          }
          return '';
        })()
      ''',
      'documentId': '''
        (function() {
          const sels = ['.documento','.cedula','#nroDocumento',
            '[data-field="documento"]','.identificacion','.patient-id','.id-number'];
          for (const s of sels) {
            const el = document.querySelector(s);
            if (el && el.textContent.trim()) return el.textContent.trim().replace(/[^0-9]/g,'');
          }
          return '';
        })()
      ''',
      'birthDate': '''
        (function() {
          const sels = ['.fecha-nacimiento','.birth-date','#fechaNacimiento',
            '[data-field="fechaNacimiento"]','.dob','.birthdate'];
          for (const s of sels) {
            const el = document.querySelector(s);
            if (el && el.textContent.trim()) return el.textContent.trim();
          }
          return '';
        })()
      ''',
    };

    for (final entry in selectors.entries) {
      try {
        final result = await _webViewController!
            .evaluateJavascript(source: entry.value);
        if (result != null && result.toString().isNotEmpty) {
          results[entry.key] = result.toString().trim();
        }
      } catch (_) {}
    }

    return results;
  }

  /// Fetches common API endpoints as fallback.
  Future<Map<String, String>> _tryApiEndpoints() async {
    final results = <String, String>{};
    final routes = [
      '/api/afiliado/perfil',
      '/api/v1/paciente',
      '/api/beneficiario/datos',
      '/api/me',
      '/api/user/profile',
    ];

    for (final route in routes) {
      try {
        final json = await _webViewController!.evaluateJavascript(source: '''
          (async () => {
            try {
              const r = await fetch('$route', { credentials: 'include' });
              if (r.ok) {
                const d = await r.json();
                return JSON.stringify(d);
              }
              return '';
            } catch(e) { return ''; }
          })()
        ''');

        if (json != null && json.toString().isNotEmpty) {
          results['api_$route'] = json.toString();
        }
      } catch (_) {}
    }

    return results;
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/orion_logo.png',
              height: 24,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.health_and_safety,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.provider.name,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        actions: _state == _PortalState.loginPage || _state == _PortalState.authenticated
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    onPressed: _currentUrl.isNotEmpty &&
                            _isPostLoginUrl(_currentUrl)
                        ? _startScraping
                        : null,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Ya inicié sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            if (_state == _PortalState.loading ||
                _state == _PortalState.restoring)
              LinearProgressIndicator(
                value: _loadProgress,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary),
              ),
            // Security banner
            _buildSecurityBanner(),
            // WebView
            Expanded(child: _buildWebView()),
            // Bottom instructions
            if (_state == _PortalState.loginPage) _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white.withValues(alpha: 0.05),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Colors.green, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _sessionRestored
                  ? 'Sesión restaurada — ${widget.provider.name}'
                  : 'Portal seguro de ${widget.provider.name} — '
                      'Tus credenciales nunca salen de tu dispositivo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ),
          if (_redirectCount > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_redirectCount nav',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
          if (_discoveredEndpoints.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_endpointInterceptor.discoveredCount} APIs',
                style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        // Use FutureBuilder to resolve initial URL (session-aware)
        FutureBuilder<String>(
          future: _resolveInitialUrl(),
          builder: (context, snapshot) {
            final initialUrl = snapshot.data ?? _portalUrl;
            return InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
              initialSettings: _endpointInterceptor.interceptionSettings,
              shouldOverrideUrlLoading:
                  (controller, navigationAction) async {
                final url =
                    navigationAction.request.url.toString();

                // Security: block unauthorized URLs
                if (!EpsUrlValidator.isUrlAllowed(
                    url, widget.provider.id)) {
                  debugPrint('BLOCKED: $url');
                  return NavigationActionPolicy.CANCEL;
                }

                _redirectCount++;
                _redirectUrls.add(url);
                if (_redirectUrls.length > 20) {
                  _redirectUrls.removeAt(0);
                }
                _currentUrl = url;

                // Track navigation in session history
                _sessionManager.trackNavigation(url);
                _sessionManager.saveLastUrl(url);

                // Detect post-login navigation
                if (_isPostLoginUrl(url)) {
                  setState(() {
                    _state = _PortalState.authenticated;
                  });
                }

                return NavigationActionPolicy.ALLOW;
              },
              shouldInterceptRequest:
                  (controller, request) async {
                // Pass through endpoint interceptor for cataloging
                return _endpointInterceptor.interceptRequest(request);
              },
              onLoadStop: (controller, url) async {
                final urlStr = url?.toString() ?? '';
                _currentUrl = urlStr;

                // Track navigation
                _sessionManager.trackNavigation(urlStr);
                _sessionManager.saveLastUrl(urlStr);

                // If this is the first load and we have a session, try restoring
                if (!_sessionRestored && widget.autoConnect) {
                  await _sessionManager.restoreSession(controller);
                  await _sessionManager.restoreLocalStorage(controller);
                  _sessionRestored = true;
                }

                if (_isPostLoginUrl(urlStr)) {
                  setState(() => _state = _PortalState.authenticated);
                } else if (_state == _PortalState.loading ||
                    _state == _PortalState.restoring) {
                  setState(() => _state = _PortalState.loginPage);
                }
              },
              onProgressChanged: (controller, progress) {
                if (_state == _PortalState.loading ||
                    _state == _PortalState.restoring) {
                  setState(
                      () => _loadProgress = progress / 100.0);
                }
              },
              onReceivedError:
                  (controller, request, error) {
                debugPrint(
                    'WebView error: ${error.description} for ${request.url}');
              },
              onWebViewCreated: (controller) async {
                _webViewController = controller;

                // Restore cookies + localStorage if we have a session
                if (widget.autoConnect) {
                  final restored = await _sessionManager.restoreSession(controller);
                  if (restored) {
                    setState(() => _state = _PortalState.restoring);
                    await _sessionManager.restoreLocalStorage(controller);
                    _sessionRestored = true;
                  }
                }
              },
            );
          },
        ),
        // Error state
        if (_state == _PortalState.error) _buildErrorOverlay(),
        // Scraping overlay
        if (_state == _PortalState.scraping) _buildScrapingOverlay(),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentUrl.isNotEmpty && _isPostLoginUrl(_currentUrl)
                      ? '¡Sesión detectada! Toca "Ya inicié sesión" para importar tus datos.'
                      : 'Ingresa con tu documento y contraseña de ${widget.provider.name}. '
                          'Cuando veas tu portal, toca "Ya inicié sesión".',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_redirectCount > 0)
            Text(
              _currentUrl.length > 80
                  ? '...${_currentUrl.substring(_currentUrl.length - 77)}'
                  : _currentUrl,
              style: const TextStyle(color: Colors.white30, fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildScrapingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                _scrapingStatus ?? 'Extrayendo tus datos de salud...',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tus datos nunca salen de tu dispositivo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12),
              ),
              if (_discoveredEndpoints.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Endpoints descubiertos (${_endpointInterceptor.discoveredCount}):',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        ..._discoveredEndpoints
                            .map((e) => Text(
                                  e,
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 9),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Error desconocido',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _state = _PortalState.loginPage;
                    _errorMessage = null;
                  });
                  _webViewController?.reload();
                },
                child: const Text('Reintentar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortUrl(String url) {
    if (url.length <= 50) return url;
    return '${url.substring(0, 25)}...${url.substring(url.length - 22)}';
  }
}
