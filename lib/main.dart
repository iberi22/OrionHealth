// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'core/responsive/responsive_layout.dart';
import 'core/theme/cyber_theme.dart';
import 'core/widgets/floating_assistant_button.dart';
import 'features/health_record/presentation/pages/health_record_staging_page.dart';
import 'features/health_report/presentation/pages/reports_page.dart';
import 'features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';

// Placeholder pages
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home Page')));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<MemoryGraph>().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrionHealth',
      theme: CyberTheme.darkTheme,
      darkTheme: CyberTheme.darkTheme,
      themeMode: ThemeMode.dark,
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

  final List<({IconData icon, IconData activeIcon, String label})> _destinations = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Inicio'),
    (icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Citas'),
    (icon: Icons.folder_shared_outlined, activeIcon: Icons.folder_shared, label: 'Archivos'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
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
            items: _destinations.map((d) => BottomNavigationBarItem(
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
                destinations: _destinations.map((d) => NavigationRailDestination(
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
