import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../domain/entities/eps_provider.dart';
import '../../domain/entities/eps_providers_catalog.dart';
import '../../infrastructure/services/eps_url_validator.dart';
import '../../../../core/theme/app_colors.dart';

/// EPS Patient Portal Login Screen
///
/// Opens the real EPS patient portal in a secure embedded WebView.
/// The patient authenticates manually using their existing EPS credentials.
/// After login, OrionHealth scrapes health data from the authenticated session.
///
/// Flow:
/// 1. WebView loads EPS portal login page (e.g., epssura.com)
/// 2. User manually enters credentials (document + password)
/// 3. User taps "Ya inicié sesión" button after successful login
/// 4. OrionHealth scrapes: name, document, birth date, conditions, medications
/// 5. Data is saved locally and never leaves the device
class EpsPatientPortalScreen extends StatefulWidget {
  final EPSProvider provider;

  const EpsPatientPortalScreen({super.key, required this.provider});

  @override
  State<EpsPatientPortalScreen> createState() => _EpsPatientPortalScreenState();
}

enum _PortalState { loading, loginPage, authenticated, scraping, error }

class _EpsPatientPortalScreenState extends State<EpsPatientPortalScreen> {
  InAppWebViewController? _webViewController;
  _PortalState _state = _PortalState.loading;
  String? _errorMessage;
  double _loadProgress = 0.0;
  String _currentUrl = '';
  int _redirectCount = 0;
  final _redirectUrls = <String>[];

  /// EPS-specific scraping selectors.
  /// Each EPS portal has different HTML structure — these are the most common patterns.
  static const _patientDataSelectors = <String, String>{
    'name': '''
      (function() {
        const selectors = [
          'h1.nombre-paciente', '.profile-name', '.patient-name',
          '[data-field="nombre"]', '.nombre', '.name',
          '#nombrePaciente', '.bienvenido strong', '.welcome-message'
        ];
        for (const sel of selectors) {
          const el = document.querySelector(sel);
          if (el) return el.textContent.trim();
        }
        return '';
      })()
    ''',
    'document': '''
      (function() {
        const selectors = [
          '.documento', '.cedula', '#nroDocumento',
          '[data-field="documento"]', '.identificacion',
          '.patient-id', '.id-number'
        ];
        for (const sel of selectors) {
          const el = document.querySelector(sel);
          if (el) return el.textContent.trim().replace(/[^0-9]/g, '');
        }
        return '';
      })()
    ''',
    'birthDate': '''
      (function() {
        const selectors = [
          '.fecha-nacimiento', '.birth-date', '#fechaNacimiento',
          '[data-field="fechaNacimiento"]', '.dob', '.birthdate'
        ];
        for (const sel of selectors) {
          const el = document.querySelector(sel);
          if (el) return el.textContent.trim();
        }
        return '';
      })()
    ''',
    'allPageText': '''
      (function() {
        return document.body ? document.body.innerText.substring(0, 3000) : '';
      })()
    ''',
  };

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }

  String get _portalUrl =>
      EpsProvidersCatalog.getPortalUrl(widget.provider.id);

  // Common post-login URL patterns that indicate authentication success
  bool _isPostLoginUrl(String url) {
    final lower = url.toLowerCase();
    const patterns = [
      '/dashboard', '/home', '/inicio', '/bienvenido',
      '/perfil', '/profile', '/afiliado', '/beneficiario',
      '/paciente', '/portal', '/app', '/servicios',
      '/miportal', '/misalud', '/micuenta',
    ];
    // Only match if URL has changed from the initial portal,
    // avoiding false positives on the login page itself
    if (lower == _portalUrl.toLowerCase()) return false;
    return patterns.any((p) => lower.contains(p));
  }

  Future<void> _startScraping() async {
    if (_webViewController == null) return;

    setState(() => _state = _PortalState.scraping);

    try {
      final results = <String, String>{};

      // Execute all scraping selectors
      for (final entry in _patientDataSelectors.entries) {
        try {
          final result = await _webViewController!
              .evaluateJavascript(source: entry.value);
          if (result != null && result.toString().isNotEmpty) {
            results[entry.key] = result.toString().trim();
          }
        } catch (_) {
          // Skip individual scraping failures
        }
      }

      // If we got basic data, we're done
      if (results['name'] != null && results['name']!.isNotEmpty) {
        // Return extracted data to previous screen
        if (mounted) {
          Navigator.of(context).pop(results);
        }
        return;
      }

      // Try fetching from common API endpoints as fallback
      final apiResults = await _tryApiEndpoints();
      if (apiResults.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pop(apiResults);
        }
        return;
      }

      // Last resort: return page text for manual parsing
      if (mounted) {
        Navigator.of(context).pop({
          'rawText': results['allPageText'] ?? '',
          'name': results['name'] ?? '',
          'document': results['document'] ?? '',
          'birthDate': results['birthDate'] ?? '',
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _PortalState.error;
          _errorMessage = 'Error al extraer datos: $e';
        });
      }
    }
  }

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: _state == _PortalState.loginPage
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    onPressed: _currentUrl.isNotEmpty && _isPostLoginUrl(_currentUrl)
                        ? _startScraping
                        : null,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Ya inicié sesión'),
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
            if (_state == _PortalState.loading)
              LinearProgressIndicator(
                value: _loadProgress,
                backgroundColor: Colors.white12,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            // Security notice
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
              'Portal seguro de ${widget.provider.name} — '
              'Tus credenciales nunca salen de tu dispositivo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ),
          if (_redirectCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_redirectCount navegaciones',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_portalUrl)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            cacheEnabled: true,
            useWideViewPort: true,
            supportZoom: true,
            builtInZoomControls: true,
            displayZoomControls: false,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            userAgent:
                'Mozilla/5.0 (Linux; Android 14; SM-S928B) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/125.0.6422.165 Mobile Safari/537.36',
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url.toString();

            // Security: block unauthorized URLs
            if (!EpsUrlValidator.isUrlAllowed(url, widget.provider.id)) {
              debugPrint('BLOCKED: $url');
              return NavigationActionPolicy.CANCEL;
            }

            _redirectCount++;
            _redirectUrls.add(url);
            if (_redirectUrls.length > 20) {
              _redirectUrls.removeAt(0);
            }

            // Detect post-login navigation
            if (_isPostLoginUrl(url)) {
              setState(() {
                _state = _PortalState.authenticated;
                _currentUrl = url;
              });
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) async {
            final urlStr = url?.toString() ?? '';
            _currentUrl = urlStr;

            if (_isPostLoginUrl(urlStr)) {
              setState(() => _state = _PortalState.authenticated);
            } else if (_state == _PortalState.loading) {
              setState(() => _state = _PortalState.loginPage);
            }
          },
          onProgressChanged: (controller, progress) {
            if (_state == _PortalState.loading) {
              setState(() => _loadProgress = progress / 100.0);
            }
          },
          onReceivedError: (controller, request, error) {
            // Non-fatal: page resources may fail but the login page can still work
            debugPrint('WebView error: ${error.description} for ${request.url}');
          },
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
        ),
        // Error state
        if (_state == _PortalState.error) _buildErrorOverlay(),
        // Scraping indicator
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
              const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentUrl.isNotEmpty && _isPostLoginUrl(_currentUrl)
                      ? '¡Sesión detectada! Toca "Ya inicié sesión" para importar tus datos.'
                      : 'Ingresa con tu documento y contraseña de ${widget.provider.name}. '
                          'Cuando veas tu portal, toca "Ya inicié sesión".',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Quick debug: show current URL
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
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Extrayendo tus datos de salud...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Esto puede tomar unos segundos.\nTus datos nunca salen de tu dispositivo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white30, fontSize: 12),
            ),
          ],
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
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
