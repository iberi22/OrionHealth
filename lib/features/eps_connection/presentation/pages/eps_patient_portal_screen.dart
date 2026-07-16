import 'dart:convert';

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
typedef WebViewBuilder = Widget Function(
  BuildContext context,
  InAppWebViewSettings settings,
  void Function(InAppWebViewController controller) onWebViewCreated,
  void Function(InAppWebViewController controller, WebUri? url) onLoadStop,
  void Function(InAppWebViewController controller, int progress) onProgressChanged,
  Future<NavigationActionPolicy?> Function(InAppWebViewController controller, NavigationAction navigationAction) shouldOverrideUrlLoading,
  Future<WebResourceResponse?> Function(InAppWebViewController controller, WebResourceRequest request) shouldInterceptRequest,
  void Function(InAppWebViewController controller, WebResourceRequest request, WebResourceError error) onReceivedError,
  String initialUrl,
);

class EpsPatientPortalScreen extends StatefulWidget {
  final EPSProvider provider;
  final bool autoConnect; // If true, try to restore session and skip login
  final FlutterSecureStorage? storage;
  final WebViewBuilder? webViewBuilder;

  const EpsPatientPortalScreen({
    super.key,
    required this.provider,
    this.autoConnect = false,
    this.storage,
    this.webViewBuilder,
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
    final storage = widget.storage ?? const FlutterSecureStorage();
    _sessionManager = EpsWebViewSession(
      storage: storage,
      epsId: widget.provider.id,
    );
    _endpointInterceptor = EpsEndpointInterceptor(
      epsId: widget.provider.id,
      epsPortalUrl: EpsProvidersCatalog.getLoginUrl(widget.provider.id) ?? EpsProvidersCatalog.getPortalUrl(widget.provider.id),
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

  /// Returns the login URL for the EPS if available, otherwise the portal URL.
  String get _portalUrl =>
      EpsProvidersCatalog.getLoginUrl(widget.provider.id) ??
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
    // Skip the login URL and portal URL itself
    final loginUrl = EpsProvidersCatalog.getLoginUrl(widget.provider.id);
    final portalUrl = EpsProvidersCatalog.getPortalUrl(widget.provider.id);
    if (lower == portalUrl.toLowerCase()) return false;
    if (loginUrl != null && lower == loginUrl.toLowerCase()) return false;

    const patterns = [
      '/dashboard', '/home', '/inicio', '/bienvenido',
      '/perfil', '/profile', '/afiliado', '/beneficiario',
      '/paciente', '/portal', '/app', '/servicios',
      '/miportal', '/misalud', '/micuenta',
    ];
    return patterns.any((p) => lower.contains(p));
  }

  // ─── Session-aware scraping ───

  /// Accumulated data from all pages visited during capture mode.
  final Map<String, dynamic> _accumulatedData = {};
  bool _captureMode = false;
  int _pagesScraped = 0;

  /// Enters capture mode: session is saved, then every page the user navigates
  /// to is automatically scraped. Much more reliable than auto-tour for SPAs.
  Future<void> _enterCaptureMode() async {
    if (_webViewController == null) return;
    await _sessionManager.captureSession(_webViewController!);
    await _sessionManager.saveLastUrl(_currentUrl);
    setState(() { _captureMode = true; _state = _PortalState.authenticated; });
    await _scrapeCurrentPage();
  }

  Future<void> _scrapeCurrentPage() async {
    if (_webViewController == null || !_captureMode) return;
    _pagesScraped++;
    setState(() => _scrapingStatus = 'Página $_pagesScraped escaneada');
    try {
      final r = await _scrapeDom();
      for (final e in r.entries) {
        if (e.value.isNotEmpty) _accumulatedData[e.key] = e.value;
      }
      if (_accumulatedData.containsKey('pageText')) {
        _extractFieldsFromText(_accumulatedData['pageText']!.toString(), _accumulatedData);
        _accumulatedData.remove('pageText');
      }
    } catch (_) {}
    setState(() {});
  }

  void _finishCapture() {
    setState(() { _captureMode = false; _state = _PortalState.scraping; });
    _endpointInterceptor.startInterception();
    _endpointInterceptor.probeDiscoveredEndpoints(_webViewController!).then((apiData) {
      _endpointsProbed = _endpointInterceptor.discoveredCount;
      _endpointInterceptor.stopInterception();
      _accumulatedData.addAll(apiData);
      if (mounted) Navigator.of(context).pop({..._accumulatedData,
        'epsProviderId': widget.provider.id,
        'epsProviderName': widget.provider.name,
        'endpointsDiscovered': _endpointsProbed,
      });
    });
  }

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

      // 3. DOM scraping + full page text analysis
      _setStatus('Extrayendo datos de la página...');
      final domResults = await _scrapeDom();
      patientData.addAll(domResults);

      // 4. Comprehensive regex extraction from page text (most reliable)
      if (patientData.containsKey('pageText')) {
        _extractFieldsFromText(patientData['pageText']!.toString(), patientData);
        // Don't store raw page text in final results
        patientData.remove('pageText');
      }

      // 5. Try auto-tour if still missing critical data
      final tourUrls = EpsProvidersCatalog.getTourUrls(widget.provider.id);
      if (tourUrls.isNotEmpty && _countMissingFields(patientData) > 3) {
        await _runAutoTour(_webViewController!, patientData, tourUrls);
      }

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

  /// Counts how many essential scalar fields are still missing from patientData.
  int _countMissingFields(Map<String, dynamic> data) {
    const essential = ['name', 'documentId', 'birthDate', 'sex', 'phone', 'email', 'address', 'bloodType'];
    return essential.where((k) {
      final v = data[k];
      return v == null || (v is String && v.isEmpty);
    }).length;
  }

  /// Auto-navigates through EPS portal data pages to extract maximum data.
  ///
  /// After login, the dashboard typically only shows a welcome message.
  /// This method uses TWO strategies:
  /// 1. URL navigation — for portals with server-side routing
  /// 2. SPA click navigation — injects JS to click menu links (works for Angular/React/Vue SPAs)
  Future<void> _runAutoTour(
    InAppWebViewController controller,
    Map<String, dynamic> patientData,
    List<String> tourUrls,
  ) async {
    // Strategy 1: URL navigation
    for (int i = 0; i < tourUrls.length; i++) {
      if (_countMissingFields(patientData) <= 2 &&
          patientData.containsKey('name') &&
          patientData.containsKey('documentId')) break;

      final url = tourUrls[i];
      _setStatus('Tour URL (${i + 1}/${tourUrls.length})...');

      try {
        final fullUrl = url.startsWith('http')
            ? url
            : '${Uri.parse(_currentUrl).origin}$url';
        await controller.loadUrl(urlRequest: URLRequest(url: WebUri(fullUrl)));
        await Future<void>.delayed(const Duration(seconds: 2));
        final pageResults = await _scrapeDom();
        for (final entry in pageResults.entries) {
          if (!patientData.containsKey(entry.key) ||
              (patientData[entry.key] is String && (patientData[entry.key] as String).isEmpty)) {
            patientData[entry.key] = entry.value;
          }
        }
      } catch (e) {
        debugPrint('Tour URL step failed: $e');
      }
    }

    // Strategy 2: SPA click navigation (for portals with client-side routing)
    if (_countMissingFields(patientData) > 3) {
      await _runSpaClickTour(controller, patientData);
    }
  }

  /// SPA-compatible auto-tour: injects JavaScript to find and click
  /// navigation links within the portal, then scrapes each resulting view.
  /// This works for Angular, React, Vue, and other SPA frameworks.
  Future<void> _runSpaClickTour(
    InAppWebViewController controller,
    Map<String, dynamic> patientData,
  ) async {
    _setStatus('Tour SPA: Buscando enlaces de datos...');

    // The JS snippet finds clickable elements whose text suggests they lead
    // to patient data pages, clicks each one, and returns scraped text.
    final spaResults = await controller.evaluateJavascript(source: '''
      (async function() {
        const results = {};
        // Keywords that indicate patient data pages
        const keywords = ['perfil', 'datos', 'historia', 'medicamentos',
          'citas', 'vacunas', 'información', 'mi cuenta', 'afiliado',
          'beneficiario', 'documento', 'personal'];

        // Find clickable elements with matching text
        const elements = [];
        const selectors = 'a, button, li, span, div[role="button"], div[onclick]';
        document.querySelectorAll(selectors).forEach(el => {
          const text = (el.textContent || '').toLowerCase().trim();
          const match = keywords.find(k => text.includes(k));
          if (match && text.length < 100 && el.offsetParent !== null) {
            elements.push({el: el, keyword: match});
          }
        });

        // Deduplicate by keyword, keep first visible
        const seen = new Set();
        const toClick = elements.filter(e => {
          if (seen.has(e.keyword)) return false;
          seen.add(e.keyword);
          return true;
        });

        for (let i = 0; i < toClick.length && i < 5; i++) {
          try {
            toClick[i].el.click();
            await new Promise(r => setTimeout(r, 2000));
            // Scrape visible text from the current view
            const body = document.body;
            if (body) {
              results[toClick[i].keyword] = body.innerText.substring(0, 3000);
            }
          } catch(e) {}
        }

        return JSON.stringify(results);
      })();
    ''');

    if (spaResults != null && spaResults.toString().isNotEmpty) {
      try {
        final parsed = Map<String, dynamic>.from(
          jsonDecode(spaResults.toString()) as Map,
        );
        // Parse each page's text for patient data fields
        for (final entry in parsed.entries) {
          final text = entry.value.toString();
          _extractFieldsFromText(text, patientData);
        }
      } catch (_) {}
    }

    _setStatus('Tour SPA completado');
  }

  /// Extracts patient data fields from raw page text using regex patterns.
  void _extractFieldsFromText(String text, Map<String, dynamic> data) {
    // Document ID patterns (Colombian CC: 6-10 digits)
    if (!data.containsKey('documentId')) {
      final docMatch = RegExp(r'(?:documento|cedula|identificación|CC|NIT)[:\s]*#?\s*(\d{6,12})', caseSensitive: false).firstMatch(text);
      if (docMatch != null) data['documentId'] = docMatch.group(1)!;
    }
    // Birth date patterns
    if (!data.containsKey('birthDate')) {
      final birthMatch = RegExp(r'(?:fecha\s*(?:de\s*)?nacimiento|nacimiento|nacido)[:\s]*(\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4})', caseSensitive: false).firstMatch(text);
      if (birthMatch != null) data['birthDate'] = birthMatch.group(1)!;
    }
    // Phone patterns
    if (!data.containsKey('phone')) {
      final phoneMatch = RegExp(r'(?:tel[eé]fono|celular|m[oó]vil|contacto)[:\s]*#?\s*([+\d]{7,15})', caseSensitive: false).firstMatch(text);
      if (phoneMatch != null) data['phone'] = phoneMatch.group(1)!;
    }
    // Email patterns
    if (!data.containsKey('email')) {
      final emailMatch = RegExp(r'[\w.-]+@[\w.-]+\.\w+').firstMatch(text);
      if (emailMatch != null) data['email'] = emailMatch.group(0)!;
    }
    // Sex/gender
    if (!data.containsKey('sex')) {
      final sexMatch = RegExp(r'(?:sexo|g[eé]nero)[:\s]*(masculino|femenino|M|F)', caseSensitive: false).firstMatch(text);
      if (sexMatch != null) data['sex'] = sexMatch.group(1)!;
    }
    // Blood type
    if (!data.containsKey('bloodType')) {
      final bloodMatch = RegExp(r'(?:grupo\s*sangu[ií]neo|tipo\s*de\s*sangre|RH)[:\s]*(O|A|B|AB)\s*[+\-]?', caseSensitive: false).firstMatch(text);
      if (bloodMatch != null) data['bloodType'] = bloodMatch.group(0)!.trim();
    }
  }

  /// Standard DOM scraping as fallback — enhanced with Sura-specific selectors
  /// and comprehensive field extraction.
  Future<Map<String, String>> _scrapeDom() async {
    final results = <String, String>{};

    const selectors = {
      'name': '''
        (function() {
          const sels = [
            '.nombre-paciente','.profile-name','.patient-name',
            '[data-field="nombre"]','.nombre','.name','#nombrePaciente',
            '#nombreCompleto','.bienvenido strong','.welcome-message',
            '.datos-afiliado .nombre','h1',
            '.nombre-afiliado','.full-name','.display-name','.user-display',
            '.MuiTypography-h5','.v-card-title','.card-title'];
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
            '[data-field="documento"]','.identificacion','.patient-id',
            '.id-number','.numero-documento','.doc-number'];
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
            '[data-field="fechaNacimiento"]','.dob','.birthdate','.fecha_nac'];
          for (const s of sels) {
            const el = document.querySelector(s);
            if (el && el.textContent.trim()) return el.textContent.trim();
          }
          return '';
        })()
      ''',
      'phone': '''
        (function() {
          const sels = ['.telefono','.phone','.celular','#telefono',
            '[data-field="telefono"]','.contact-phone','.mobile-number',
            '.numero-contacto'];
          for (const s of sels) {
            const el = document.querySelector(s);
            if (el && el.textContent.trim()) return el.textContent.trim().replace(/[^0-9+]/g,'');
          }
          return '';
        })()
      ''',
      'email': '''
        (function() {
          const sels = ['.email','.correo','#email','#correoElectronico',
            '[data-field="email"]','.contact-email','.correo-electronico'];
          for (const s of sels) {
            const el = document.querySelector(s);
            if (el && el.textContent.trim()) return el.textContent.trim();
          }
          return '';
        })()
      ''',
      'affiliationType': '''
        (function() {
          const sels = ['.tipo-afiliado','.regimen','.plan-type','.affiliation-type',
            '.tipo-afiliacion','.categoria','.tipo-usuario'];
          for (const s of sels) {
            const el = document.querySelector(s);
            if (el && el.textContent.trim()) return el.textContent.trim();
          }
          return '';
        })()
      ''',
      'bloodType': '''
        (function() {
          const sels = ['.grupo-sanguineo','.blood-type','.tipo-sangre',
            '#grupoSanguineo','.rh-factor','.blood-group'];
          for (const s of sels) {
            const el = document.querySelector(s);
            if (el && el.textContent.trim()) return el.textContent.trim();
          }
          return '';
        })()
      ''',
      'address': '''
        (function() {
          const sels = ['.direccion','.address','#direccion',
            '[data-field="direccion"]','.home-address','.residencia'];
          for (const s of sels) {
            const el = document.querySelector(s);
            if (el && el.textContent.trim()) return el.textContent.trim();
          }
          return '';
        })()
      ''',
      'sex': '''
        (function() {
          const sels = ['.sexo','.gender','#sexo','#genero',
            '[data-field="sexo"]','.genero','.sex'];
          for (const s of sels) {
            const el = document.querySelector(s);
            if (el && el.textContent.trim()) return el.textContent.trim();
          }
          return '';
        })()
      ''',
      // Sura-specific: try to extract from text labels
      'pageText': '''
        (function() {
          try {
            const body = document.body;
            if (!body) return '';
            // Get visible text content, limited to avoid overload
            const walker = document.createTreeWalker(body, NodeFilter.SHOW_TEXT);
            let text = '';
            let node;
            while (node = walker.nextNode()) {
              if (node.parentElement && node.parentElement.offsetParent !== null) {
                text += node.textContent + ' ';
              }
              if (text.length > 20000) break;
            }
            return text;
          } catch(e) { return ''; }
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

  // ─── WebView Callbacks Refactored ───

  Future<void> _handleWebViewCreated(InAppWebViewController controller) async {
    _webViewController = controller;
    if (widget.autoConnect) {
      final restored = await _sessionManager.restoreSession(controller);
      if (restored) {
        setState(() => _state = _PortalState.restoring);
        await _sessionManager.restoreLocalStorage(controller);
        _sessionRestored = true;
      }
    }
  }

  Future<void> _handleLoadStop(InAppWebViewController controller, WebUri? url) async {
    final urlStr = url?.toString() ?? '';
    _currentUrl = urlStr;

    _sessionManager.trackNavigation(urlStr);
    _sessionManager.saveLastUrl(urlStr);

    if (!_sessionRestored && widget.autoConnect) {
      await _sessionManager.restoreSession(controller);
      await _sessionManager.restoreLocalStorage(controller);
      _sessionRestored = true;
    }

    // Auto-scrape each page when in capture mode
    if (_captureMode) {
      await _scrapeCurrentPage();
    }

    if (_isPostLoginUrl(urlStr)) {
      setState(() => _state = _PortalState.authenticated);
    } else if (_state == _PortalState.loading || _state == _PortalState.restoring) {
      setState(() => _state = _PortalState.loginPage);
    }
  }

  void _handleProgressChanged(InAppWebViewController controller, int progress) {
    if (_state == _PortalState.loading || _state == _PortalState.restoring) {
      setState(() => _loadProgress = progress / 100.0);
    }
  }

  Future<NavigationActionPolicy?> _handleShouldOverrideUrlLoading(
      InAppWebViewController controller, NavigationAction navigationAction) async {
    final url = navigationAction.request.url.toString();

    if (!EpsUrlValidator.isUrlAllowed(url, widget.provider.id)) {
      debugPrint('BLOCKED: $url');
      return NavigationActionPolicy.CANCEL;
    }

    _redirectCount++;
    _redirectUrls.add(url);
    if (_redirectUrls.length > 20) {
      _redirectUrls.removeAt(0);
    }
    _currentUrl = url;

    _sessionManager.trackNavigation(url);
    _sessionManager.saveLastUrl(url);

    if (_isPostLoginUrl(url)) {
      setState(() => _state = _PortalState.authenticated);
    }

    return NavigationActionPolicy.ALLOW;
  }

  Future<WebResourceResponse?> _handleShouldInterceptRequest(
      InAppWebViewController controller, WebResourceRequest request) async {
    return _endpointInterceptor.interceptRequest(request);
  }

  void _handleReceivedError(
      InAppWebViewController controller, WebResourceRequest request, WebResourceError error) {
    debugPrint('WebView error: ${error.description} for ${request.url}');
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
                  child: _captureMode
                      ? ElevatedButton.icon(
                          onPressed: _finishCapture,
                          icon: const Icon(Icons.done, size: 18),
                          label: Text('Finalizar ($_pagesScraped pág)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _currentUrl.isNotEmpty && _isPostLoginUrl(_currentUrl)
                              ? _enterCaptureMode
                              : null,
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Iniciar captura'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
            if (widget.webViewBuilder != null) {
              return widget.webViewBuilder!(
                context,
                _endpointInterceptor.interceptionSettings,
                _handleWebViewCreated,
                _handleLoadStop,
                _handleProgressChanged,
                _handleShouldOverrideUrlLoading,
                _handleShouldInterceptRequest,
                _handleReceivedError,
                initialUrl,
              );
            }
            return InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
              initialSettings: _endpointInterceptor.interceptionSettings,
              shouldOverrideUrlLoading: _handleShouldOverrideUrlLoading,
              shouldInterceptRequest: _handleShouldInterceptRequest,
              onLoadStop: _handleLoadStop,
              onProgressChanged: _handleProgressChanged,
              onReceivedError: _handleReceivedError,
              onWebViewCreated: _handleWebViewCreated,
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
