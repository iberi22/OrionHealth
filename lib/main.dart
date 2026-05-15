// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/di/injection.dart';
import 'core/responsive/responsive_layout.dart';
import 'core/theme/app_theme.dart';

import 'core/widgets/floating_assistant_button.dart';
import 'core/widgets/page_header.dart';
import 'features/health_record/presentation/pages/health_record_staging_page.dart';
import 'features/reports/presentation/pages/reports_page.dart';
import 'features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'features/local_agent/infrastructure/services/medical_indexing_service.dart';

// Placeholder pages
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              PageHeader(
                title: l10n.homeTitle,
                subtitle: l10n.homeSubtitle,
              ),
              // More content can be added here
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<MemoryGraph>().initialize();

  // Index medical standards and patient context at startup
  unawaited(getIt<MedicalIndexingService>().indexAll());

  runApp(const MyApp());
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
      (icon: Icons.home_outlined, activeIcon: Icons.home, label: l10n.navHome),
      (icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: l10n.navAppointments),
      (icon: Icons.folder_shared_outlined, activeIcon: Icons.folder_shared, label: l10n.navFiles),
      (icon: Icons.person_outline, activeIcon: Icons.person, label: l10n.navProfile),
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
        desktop: Scaffold(
          body: Row(
            children: [
              NavigationRail(
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


