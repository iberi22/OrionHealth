import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection.dart';
import 'core/theme/cyber_theme.dart';
import 'features/appointments/presentation/pages/appointments_page.dart';
import 'features/health_record/presentation/pages/health_record_staging_page.dart';
import 'features/health_report/presentation/pages/reports_page.dart';
import 'features/user_profile/presentation/pages/user_profile_page.dart';
import 'features/onboarding/presentation/pages/onboarding_main_page.dart';
import 'features/user_profile/domain/repositories/user_profile_repository.dart';
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
  await initializeDateFormatting('es', null);
  await configureDependencies();
  await getIt<MemoryGraph>().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final repository = getIt<UserProfileRepository>();
    final profile = await repository.getUserProfile();
    setState(() {
      _onboardingCompleted = profile?.onboardingCompleted ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingCompleted == null) {
      return MaterialApp(
        theme: CyberTheme.darkTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'OrionHealth',
      theme: CyberTheme.darkTheme,
      darkTheme: CyberTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: _onboardingCompleted!
          ? const MainNavigationPage()
          : OnboardingMainPage(
              onFinish: () {
                setState(() {
                  _onboardingCompleted = true;
                });
              },
            ),
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
    const HomePage(),
    const AppointmentsPage(),
    const HealthRecordStagingPage(),
    const UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            activeIcon: Icon(Icons.folder_shared),
            label: 'Archivos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
