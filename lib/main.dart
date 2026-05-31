// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'core/di/injection.dart';
import 'core/responsive/responsive_layout.dart';
import 'core/theme/app_theme.dart';

import 'core/widgets/floating_assistant_button.dart';
import 'core/widgets/glassmorphic_card.dart';
import 'core/widgets/page_header.dart';
import 'features/health_record/presentation/pages/health_record_staging_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/medical_assistant/presentation/pages/medical_assistant_page.dart';
import 'features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'features/local_agent/infrastructure/services/medical_indexing_service.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/application/onboarding_cubit.dart';
import 'features/home/application/home_cubit.dart';
import 'features/home/application/home_state.dart';
import 'features/vitals/domain/repositories/vital_sign_repository.dart';
import 'features/vitals/domain/entities/vital_sign.dart';
import 'features/vitals/presentation/pages/vitals_monitor_page.dart';
import 'features/medical_assistant/domain/services/medical_analysis_service.dart';
import 'features/medical_assistant/domain/entities/medical_insight.dart';
import 'features/user_profile/domain/repositories/user_profile_repository.dart';

// ─────────────────────────────────────────────
// HOME PAGE
// ─────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => HomeCubit(
        getIt<VitalSignRepository>(),
        getIt<MedicalIndexingService>(),
        getIt<MedicalAnalysisService>(),
        getIt<UserProfileRepository>(),
      ),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: l10n.homeTitle,
                  subtitle: l10n.homeSubtitle,
                ),
                const IndexingStatusBanner(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const _HealthStatusGrid(),
                      const SizedBox(height: 24),
                      const _RecentInsightsSection(),
                      const SizedBox(height: 24),
                      const _LocalAgentPromo(),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INDEXING STATUS BANNER
// ─────────────────────────────────────────────

class IndexingStatusBanner extends StatefulWidget {
  const IndexingStatusBanner({super.key});

  @override
  State<IndexingStatusBanner> createState() => _IndexingStatusBannerState();
}

class _IndexingStatusBannerState extends State<IndexingStatusBanner> {
  bool _showSuccess = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (prev, curr) => prev.isIndexing != curr.isIndexing,
      listener: (context, state) {
        if (!state.isIndexing && !state.indexingError) {
          setState(() => _showSuccess = true);
          _hideTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) setState(() => _showSuccess = false);
          });
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          if (state.isIndexing) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.blue.withValues(alpha: 0.1),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                  ),
                  SizedBox(width: 12),
                  Text(
                    l10n.syncingStandards,
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            );
          }

          if (state.indexingError) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.red.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.syncError,
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<HomeCubit>().retryIndexing(),
                    child: Text(l10n.retry, style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }

          if (_showSuccess) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.green.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 12),
                  Text(
                    l10n.syncCompleted,
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEALTH STATUS GRID (conectado a datos reales)
// ─────────────────────────────────────────────

class _HealthStatusGrid extends StatelessWidget {
  const _HealthStatusGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final vitals = state.latestVitals;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _StatusCard(
              icon: Icons.favorite,
              label: l10n.heartRate,
              value: vitals[VitalSignType.heartRate]?.formattedValue ?? l10n.noData,
              color: Colors.redAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VitalsMonitorPage()),
              ),
            ),
            _StatusCard(
              icon: Icons.bloodtype,
              label: l10n.bloodPressure,
              value: _formatBloodPressure(
                vitals[VitalSignType.bloodPressureSystolic],
                vitals[VitalSignType.bloodPressureDiastolic],
                l10n,
              ),
              color: Colors.blueAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VitalsMonitorPage()),
              ),
            ),
            _StatusCard(
              icon: Icons.thermostat,
              label: l10n.temperature,
              value: vitals[VitalSignType.temperature]?.formattedValue ?? l10n.noData,
              color: Colors.orangeAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VitalsMonitorPage()),
              ),
            ),
            _StatusCard(
              icon: Icons.water_drop,
              label: l10n.oxygenSaturation,
              value: vitals[VitalSignType.oxygenSaturation]?.formattedValue ?? l10n.noData,
              color: Colors.cyanAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VitalsMonitorPage()),
              ),
            ),
          ],
        );
      },
    );
  }

    String _formatBloodPressure(VitalSign? systolic, VitalSign? diastolic, AppLocalizations l10n) {
    if (systolic == null || diastolic == null) return l10n.noData;
    return '${systolic.value?.toInt()}/${diastolic.value?.toInt()}';
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (value.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(Icons.add_circle_outline, size: 14, color: color.withValues(alpha: 0.5)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RECENT INSIGHTS
// ─────────────────────────────────────────────

class _RecentInsightsSection extends StatelessWidget {
  const _RecentInsightsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.recentInsights,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (state.recentInsights.isEmpty)
              _buildFallbackInsight(state.isLoadingVitals, l10n)
            else
              _buildInsightCard(state.recentInsights.first),
          ],
        );
      },
    );
  }

  Widget _buildInsightCard(MedicalInsight insight) {
    Color severityColor;
    IconData severityIcon;

    switch (insight.severity) {
      case InsightSeverity.critical:
        severityColor = Colors.redAccent;
        severityIcon = Icons.warning_rounded;
        break;
      case InsightSeverity.alert:
        severityColor = Colors.orangeAccent;
        severityIcon = Icons.priority_high_rounded;
        break;
      case InsightSeverity.warning:
        severityColor = Colors.yellowAccent;
        severityIcon = Icons.info_outline_rounded;
        break;
      case InsightSeverity.info:
      default:
        severityColor = Colors.greenAccent;
        severityIcon = Icons.auto_awesome;
        break;
    }

    return GlassmorphicCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(severityIcon, color: severityColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(insight.description,
                    style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackInsight(bool isLoading, AppLocalizations l10n) {
    return GlassmorphicCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.info_outline, color: Colors.blueAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading ? l10n.analyzingData : l10n.noAnomaliesDetected,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading
                      ? l10n.waitProcessing
                      : l10n.recordMoreVitals,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOCAL AGENT PROMO
// ─────────────────────────────────────────────

class _LocalAgentPromo extends StatelessWidget {
  const _LocalAgentPromo();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.darkTheme.primaryColor.withValues(alpha: 0.2), Colors.transparent]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(l10n.privacy100Local, style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.consultAssistant, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.assistantDescription, style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedicalAssistantPage()),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(l10n.startConsultation),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkTheme.primaryColor, foregroundColor: Colors.black),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN ENTRY POINT
// ─────────────────────────────────────────────

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Global error handlers
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    try {
      await configureDependencies();
      await getIt<MemoryGraph>().initialize();

      // Index medical standards and patient context at startup
      unawaited(getIt<MedicalIndexingService>().indexAll());

      runApp(const MyApp());
    } catch (e, stack) {
      _logError(e, stack);
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Error de Inicializaci\u00f3n',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hubo un problema al iniciar OrionHealth. Por favor, intenta reiniciar la aplicaci\u00f3n.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.black,
        ),
      ));
    }
  }, (error, stack) {
    _logError(error, stack);
  });
}

void _logError(Object error, StackTrace? stack) {
  // ignore: avoid_print
  print('--- FATAL ERROR ---');
  // ignore: avoid_print
  print(error);
  // ignore: avoid_print
  print(stack);
}

// ─────────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es', ''), // Force Spanish for now as requested
      home: const _StartupRouter(),
    );
  }
}

// ─────────────────────────────────────────────
// STARTUP ROUTER — checks onboarding flag
// ─────────────────────────────────────────────

class _StartupRouter extends StatelessWidget {
  const _StartupRouter();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance()
          .then((p) => p.getBool('onboarding_completed') ?? false),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.data == true) {
          return const MainNavigationPage();
        }
        return BlocProvider(
          create: (_) => getIt<OnboardingCubit>(),
          child: const OnboardingPage(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// MAIN NAVIGATION
// ─────────────────────────────────────────────

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  final _fabController = FloatingAssistantButtonController();

  final List<Widget> _pages = [
    const HomePage(),
    const ReportsPage(),
    const HealthRecordStagingPage(),
    const UserProfilePage(),
  ];

  List<({IconData icon, IconData activeIcon, String label})> _getDestinations(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      (icon: Icons.home_outlined, activeIcon: Icons.home, label: l10n.home),
      (icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: l10n.reports),
      (icon: Icons.folder_shared_outlined, activeIcon: Icons.folder_shared, label: l10n.records),
      (icon: Icons.person_outline, activeIcon: Icons.person, label: l10n.profile),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _getDestinations(context);
    return FloatingAssistantButtonScope(
      notifier: _fabController,
      child: ResponsiveLayout(
        mobile: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: destinations.map((d) => BottomNavigationBarItem(
              icon: Icon(d.icon),
              activeIcon: Icon(d.activeIcon),
              label: d.label,
            )).toList(),
          ),
          floatingActionButton: FloatingAssistantButton(
            hasNotification: _fabController.hasNotification,
            badgeCount: _fabController.badgeCount,
          ),
        ),
        tablet: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: MediaQuery.of(context).size.width > 900,
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                labelType: MediaQuery.of(context).size.width > 900 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                destinations: destinations.map((d) => NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: Text(d.label),
                )).toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingAssistantButton(
            hasNotification: _fabController.hasNotification,
            badgeCount: _fabController.badgeCount,
          ),
        ),
        desktop: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: true,
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                destinations: destinations.map((d) => NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: Text(d.label),
                )).toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: IndexedStack(
                      index: _currentIndex,
                      children: _pages,
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingAssistantButton(
            hasNotification: _fabController.hasNotification,
            badgeCount: _fabController.badgeCount,
          ),
        ),
      ),
    );
  }
}







