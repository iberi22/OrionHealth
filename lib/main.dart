// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'l10n/app_localizations.dart';
import 'core/di/injection.dart';
import 'core/responsive/responsive_layout.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/glassmorphic_card.dart';

import 'core/widgets/floating_assistant_button.dart';
import 'core/widgets/page_header.dart';
import 'features/health_record/presentation/pages/health_record_staging_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'features/local_agent/infrastructure/services/medical_indexing_service.dart';
import 'features/home/application/home_cubit.dart';
import 'features/home/application/home_state.dart';
import 'features/vitals/domain/entities/vital_sign.dart';
import 'features/vitals/domain/repositories/vital_sign_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        getIt<VitalSignRepository>(),
        getIt<MedicalIndexingService>(),
      ),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatelessWidget {
  const _HomePageView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
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
    );
  }
}

class IndexingStatusBanner extends StatefulWidget {
  const IndexingStatusBanner({super.key});

  @override
  State<IndexingStatusBanner> createState() => _IndexingStatusBannerState();
}

class _IndexingStatusBannerState extends State<IndexingStatusBanner> {
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) => previous.isIndexing && !current.isIndexing,
      listener: (context, state) {
        setState(() => _showSuccess = true);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showSuccess = false);
        });
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.isIndexing) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.withValues(alpha: 0.1),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Sincronizando estándares médicos...',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            );
          }

          if (state.indexingError) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Error sincronizando estándares médicos',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<HomeCubit>().retryIndexing(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Reintentar', style: TextStyle(fontSize: 12)),
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
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 12),
                  Text(
                    'Sincronización completada',
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

class _HealthStatusGrid extends StatelessWidget {
  const _HealthStatusGrid();

  @override
  Widget build(BuildContext context) {
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
              label: 'Ritmo Cardíaco',
              value: vitals[VitalSignType.heartRate]?.formattedValue ?? 'Sin datos',
              color: Colors.redAccent,
              onTap: () {
                // Navigate to vitals or add vital
              },
            ),
            _StatusCard(
              icon: Icons.bloodtype,
              label: 'Presión Arterial',
              value: _formatBloodPressure(
                vitals[VitalSignType.bloodPressureSystolic],
                vitals[VitalSignType.bloodPressureDiastolic],
              ),
              color: Colors.blueAccent,
            ),
            _StatusCard(
              icon: Icons.thermostat,
              label: 'Temperatura',
              value: vitals[VitalSignType.temperature]?.formattedValue ?? 'Sin datos',
              color: Colors.orangeAccent,
            ),
            _StatusCard(
              icon: Icons.water_drop,
              label: 'Oxígeno (SpO2)',
              value: vitals[VitalSignType.oxygenSaturation]?.formattedValue ?? 'Sin datos',
              color: Colors.cyanAccent,
            ),
          ],
        );
      },
    );
  }

  String _formatBloodPressure(VitalSign? systolic, VitalSign? diastolic) {
    if (systolic == null || diastolic == null) return 'Sin datos';
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
              fontSize: value == 'Sin datos' ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: value == 'Sin datos' ? Colors.white38 : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (value == 'Sin datos')
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
                child: Icon(Icons.add_circle_outline, size: 14, color: color.withValues(alpha: 0.5)),
            ),
        ],
      ),
    );
  }
}

class _RecentInsightsSection extends StatelessWidget {
  const _RecentInsightsSection();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Insights Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GlassmorphicCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.5), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: Colors.greenAccent),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu salud cardiovascular está estable', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Tus últimos 5 registros de presión arterial están dentro del rango normal.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocalAgentPromo extends StatelessWidget {
  const _LocalAgentPromo();
  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: [
              Icon(Icons.security, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('Privacidad 100% Local', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Consulta a tu Asistente Orion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pregúntame cualquier cosa sobre tus registros médicos. No salen de tu dispositivo.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Iniciar Consulta'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkTheme.primaryColor, foregroundColor: Colors.black),
          ),
        ],
      ),
    );
  }
}

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

      // Index medical standards and patient context at startup (Jules' Addition)
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
                    'Error de Inicialización',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hubo un problema al iniciar OrionHealth. Por favor, intenta reiniciar la aplicación.',
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
      home: const MainNavigationPage(),
    );
  }
}

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
      (icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Citas'),
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
