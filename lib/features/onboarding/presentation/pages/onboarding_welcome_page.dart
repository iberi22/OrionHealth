import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../eps_connection/domain/entities/eps_providers_catalog.dart';
import '../../../eps_connection/domain/entities/eps_provider.dart';
import '../../../eps_connection/infrastructure/services/eps_webview_session.dart';
import '../../../eps_connection/presentation/pages/eps_patient_portal_screen.dart';
import '../../infrastructure/services/country_detector.dart';
import '../widgets/eps_info_modal.dart';
import '../widgets/health_data_sources_sheet.dart';
import '../../domain/entities/health_data_source.dart';

/// Onboarding Welcome Page v2
///
/// Privacy-first slides with:
/// - Country detection: EPS option only shown for Colombian users
/// - EPS connection with help icon explaining the logic
/// - Health/fitness data source sync (Strava, Google Fit, Apple Health, etc.)
///
/// Flow:
/// 1. User sees 3 privacy slides (Privacy First, Local AI, Own Your Data)
/// 2. After slides: EPS connection chips (Colombia only) + Data Sync option
/// 3. If user connects EPS → data auto-fills onboarding profile
/// 4. If user connects health sources → settings saved
/// 5. If user skips → proceeds to manual onboarding
class OnboardingWelcomePage extends StatefulWidget {
  final VoidCallback onNext;
  final void Function(Map<String, dynamic> epsData) onEpsDataReceived;
  final void Function(Set<String> connectedSources)? onHealthSourcesConnected;

  const OnboardingWelcomePage({
    super.key,
    required this.onNext,
    required this.onEpsDataReceived,
    this.onHealthSourcesConnected,
  });

  @override
  State<OnboardingWelcomePage> createState() => _OnboardingWelcomePageState();
}

class _OnboardingWelcomePageState extends State<OnboardingWelcomePage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // EPS connection state
  String? _epsName;
  Map<String, dynamic>? _epsData;

  // Country detection
  bool _isColombia = false;
  bool _countryChecked = false;

  // Health sources
  Set<String> _connectedSources = {};

  final List<Map<String, String>> _slides = [
    {
      'title': 'Privacy First',
      'description':
          'Your health data is encrypted and stored only on your device. '
          'We don\'t have access to it.',
      'icon': 'lock',
    },
    {
      'title': 'Local AI',
      'description':
          'Processing happens locally. Your private information never leaves your phone.',
      'icon': 'memory',
    },
    {
      'title': 'Own Your Data',
      'description':
          'You have full control. Export or delete your data at any time.',
      'icon': 'person',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkCountry();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkCountry() async {
    final detector = CountryDetector();
    final isColombia = await detector.isColombia();
    detector.dispose();
    if (mounted) {
      setState(() {
        _isColombia = isColombia;
        _countryChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // === Slide content ===
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIcon(slide['icon']!),
                          size: 80,
                          color: CyberTheme.primary,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide['title']!,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: CyberTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['description']!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Colors.white70,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // === Page indicators ===
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _currentPage == index
                        ? CyberTheme.primary
                        : Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // === Conditional content (only on last slide) ===
            if (_currentPage == _slides.length - 1) ...[
              // EPS import success banner
              if (_epsData != null && _epsData!.isNotEmpty) _buildSuccessBanner(),

              // EPS quick-connect chips (Colombia only, no data yet)
              if (_countryChecked &&
                  _isColombia &&
                  (_epsData == null || _epsData!.isEmpty))
                _buildEpsSection(),

              // Health data sync section (always shown on last slide)
              _buildHealthDataSection(),

              const SizedBox(height: 16),
            ],

            // === Action buttons ===
            _buildActionButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // EPS Section
  // ──────────────────────────────────────────

  Widget _buildEpsSection() {
    final topEps = [
      EpsProvidersCatalog.byId('EPS005'), // Sanitas
      EpsProvidersCatalog.byId('EPS025'), // Sura
      EpsProvidersCatalog.byId('EPS037'), // Nueva EPS
      EpsProvidersCatalog.byId('EPS008'), // Compensar
    ].whereType<EPSProvider>().take(4).toList();

    return Column(
      children: [
        // Title row with help icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Conectá tu EPS para importar tus datos',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => EpsInfoModal.show(context),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CyberTheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.help_outline,
                  size: 14,
                  color: Color(0xFF00D4FF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            ...topEps.map((eps) => _chip(eps.name, () => _openEpsPortal(eps))),
            _chip('Otra EPS', _navigateToEpsPortal, highlight: true),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // Health Data Sync Section
  // ──────────────────────────────────────────

  Widget _buildHealthDataSection() {
    final hasConnections = _connectedSources.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        top: (_isColombia &&
                (_epsData == null || _epsData!.isEmpty))
            ? 16
            : 4,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sync,
                size: 16,
                color: hasConnections
                    ? CyberTheme.success
                    : Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 6),
              Text(
                hasConnections
                    ? '${_connectedSources.length} fuente(s) de datos conectadas'
                    : 'Sincronizá tus apps de salud y deporte',
                style: TextStyle(
                  color: hasConnections
                      ? CyberTheme.success.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 220,
            child: OutlinedButton.icon(
              onPressed: _openHealthSources,
              icon: Icon(
                hasConnections ? Icons.check_circle : Icons.add_circle_outline,
                size: 18,
                color: hasConnections
                    ? CyberTheme.success
                    : CyberTheme.primary,
              ),
              label: Text(
                hasConnections ? 'Gestionar fuentes' : 'Conectar apps',
                style: TextStyle(
                  color: hasConnections
                      ? CyberTheme.success
                      : CyberTheme.primary,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: (hasConnections
                          ? CyberTheme.success
                          : CyberTheme.primary)
                      .withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // EPS Success Banner
  // ──────────────────────────────────────────

  Widget _buildSuccessBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CyberTheme.success.withValues(alpha: 0.15),
              CyberTheme.success.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CyberTheme.success.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: CyberTheme.success, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Datos importados desde $_epsName!',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_epsData!.length} campos extraídos de tu portal EPS.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // EPS Quick-connect Chips
  // ──────────────────────────────────────────

  Widget _chip(String label, VoidCallback onTap, {bool highlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: highlight
              ? CyberTheme.primary.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlight
                ? CyberTheme.primary.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              highlight ? Icons.search : Icons.account_balance,
              size: 16,
              color: highlight
                  ? CyberTheme.primary
                  : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label.length > 16 ? '${label.substring(0, 15)}…' : label,
              style: TextStyle(
                color: highlight ? CyberTheme.primary : Colors.white70,
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // Action Button (bottom)
  // ──────────────────────────────────────────

  Widget _buildActionButton() {
    // Not on last slide → "Next" button
    if (_currentPage < _slides.length - 1) {
      return ElevatedButton(
        onPressed: () {
          _controller.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        style: _buttonStyle(),
        child: const Text('Siguiente'),
      );
    }

    // On last slide — EPS data already received
    if (_epsData != null && _epsData!.isNotEmpty) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.onEpsDataReceived(_epsData!),
              icon: const Icon(Icons.check_circle_outline),
              label: Text('Continuar con $_epsName'),
              style: _buttonStyle(CyberTheme.success),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _navigateToEpsPortal,
            child: Text(
              'Cambiar de EPS',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    }

    // On last slide — no EPS data
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Pass connected health sources if any
              if (_connectedSources.isNotEmpty) {
                widget.onHealthSourcesConnected?.call(_connectedSources);
              }
              widget.onNext();
            },
            style: _buttonStyle(),
            child: const Text('Continuar sin EPS'),
          ),
        ),
        if (_countryChecked && _isColombia) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _navigateToEpsPortal,
              icon: Icon(Icons.account_balance, color: CyberTheme.primary),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Conectar con mi EPS',
                    style: TextStyle(color: CyberTheme.primary),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => EpsInfoModal.show(context),
                    child: Icon(
                      Icons.help_outline,
                      size: 16,
                      color: CyberTheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: CyberTheme.primary.withValues(alpha: 0.3),
                ),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ──────────────────────────────────────────
  // EPS Portal Navigation
  // ──────────────────────────────────────────

  void _navigateToEpsPortal() async {
    final provider = await _showEpsPicker();
    if (provider != null && mounted) {
      _openEpsPortal(provider);
    }
  }

  Future<EPSProvider?> _showEpsPicker() async {
    return showModalBottomSheet<EPSProvider>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _EpsPickerSheet(),
    );
  }

  void _openEpsPortal(EPSProvider provider) async {
    const storage = FlutterSecureStorage();
    final sessionMgr = EpsWebViewSession(
      storage: storage,
      epsId: provider.id,
    );
    final hasActiveSession = await sessionMgr.hasActiveSession();

    if (!mounted) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EpsPatientPortalScreen(
          provider: provider,
          autoConnect: hasActiveSession,
        ),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _epsData = result;
        _epsName = '${result['epsProviderName'] ?? provider.name}';
      });

      widget.onEpsDataReceived(result);
    }
  }

  // ──────────────────────────────────────────
  // Health Data Sources
  // ──────────────────────────────────────────

  void _openHealthSources() async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HealthDataSourcesSheet(
        onSourceConnected: (source) {
          // Individual source connected
        },
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _connectedSources = result;
      });
      widget.onHealthSourcesConnected?.call(_connectedSources);
    }
  }

  // ──────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────

  ButtonStyle _buttonStyle([Color? bgColor]) {
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor ?? CyberTheme.primary,
      foregroundColor: CyberTheme.backgroundDark,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'lock':
        return Icons.lock_outline;
      case 'memory':
        return Icons.memory;
      case 'person':
        return Icons.person_outline;
      default:
        return Icons.help_outline;
    }
  }
}

/// Bottom sheet EPS picker for onboarding flow.
class _EpsPickerSheet extends StatefulWidget {
  const _EpsPickerSheet();

  @override
  State<_EpsPickerSheet> createState() => _EpsPickerSheetState();
}

class _EpsPickerSheetState extends State<_EpsPickerSheet> {
  final _searchCtl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = _filtered();
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E21),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Seleccioná tu EPS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar EPS...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: providers.length,
              itemBuilder: (ctx, i) {
                final p = providers[i];
                return ListTile(
                  leading:
                      const Icon(Icons.account_balance, color: Colors.white54),
                  title:
                      Text(p.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(p.id,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12)),
                  onTap: () => Navigator.pop(context, p),
                );
              },
            ),
          ),
          // Close
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white54)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<EPSProvider> _filtered() {
    final all = EpsProvidersCatalog.activeProviders;
    if (_query.isEmpty) return all;
    return all
        .where((p) =>
            p.name.toLowerCase().contains(_query.toLowerCase()) ||
            p.id.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }
}
