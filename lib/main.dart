import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/health_record/presentation/pages/health_record_staging_page.dart';
import 'features/local_agent/infrastructure/llm_service.dart';
import 'features/local_agent/presentation/chat_page.dart';
import 'features/user_profile/presentation/pages/user_profile_page.dart';
import 'features/health_report/presentation/pages/reports_page.dart';

import 'package:isar_agent_memory/isar_agent_memory.dart';

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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

  final List<Widget> _pages = [
    const UserProfilePage(),
    const HealthRecordStagingPage(),
    // We need to inject LlmService here.
    // Ideally ChatPage should use a Cubit/Bloc and get LlmService from GetIt internally,
    // but the current implementation takes it in constructor.
    // We'll use GetIt to resolve it.
    ChatPage(llmService: getIt<LlmService>()),
    const ReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open),
            selectedIcon: Icon(Icons.folder),
            label: 'Registros',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Asistente IA',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }
}
