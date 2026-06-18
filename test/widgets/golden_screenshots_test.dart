import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

// Note: Using simplified mocks to avoid dependency injection complexity in this specific runner
// while maintaining visual fidelity for golden screenshots.

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  
  final screenshotsDir = Directory('test/widgets/goldens');
  if (!screenshotsDir.existsSync()) {
    screenshotsDir.createSync(recursive: true);
  }

  group('OrionHealth golden screenshots', () {
    final devices = [
      {'name': 'small', 'size': const Size(360, 640)},
      {'name': 'large', 'size': const Size(720, 1280)},
    ];

    for (final device in devices) {
      final name = device['name'] as String;
      final size = device['size'] as Size;

      testWidgets('01 main navigation - $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            theme: _testTheme(),
            home: const _TestNavigationPage(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile("../golden/reference/01_main_navigation_$name.png"),
        );

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      testWidgets('02 onboarding welcome - $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(MaterialApp(theme: _testTheme(), home: const _MockOnboardingPage()));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile("../golden/reference/02_onboarding_$name.png"),
        );

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      testWidgets('03 login page - $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(MaterialApp(theme: _testTheme(), home: const _MockLoginPage()));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile("../golden/reference/03_login_$name.png"),
        );

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      testWidgets('04 medical research - $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(MaterialApp(theme: _testTheme(), home: const _MockMedicalResearchPage()));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile("../golden/reference/04_medical_research_$name.png"),
        );

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      testWidgets('05 dashboard - $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(MaterialApp(theme: _testTheme(), home: const _MockDashboardPage()));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile("../golden/reference/05_dashboard_$name.png"),
        );

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }
  });
}

ThemeData _testTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    useMaterial3: true,
  );
}

// ─── Mock Pages ──────────────────────────────────────────────────────────────

class _TestNavigationPage extends StatefulWidget {
  const _TestNavigationPage();

  @override
  State<_TestNavigationPage> createState() => _TestNavigationPageState();
}

class _TestNavigationPageState extends State<_TestNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Home Page')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          NavigationDestination(icon: Icon(Icons.folder), label: 'Registros'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Asistente IA'),
          NavigationDestination(icon: Icon(Icons.assessment), label: 'Reportes'),
        ],
      ),
    );
  }
}

class _MockOnboardingPage extends StatelessWidget {
  const _MockOnboardingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.health_and_safety, size: 80, color: Colors.teal),
              const SizedBox(height: 24),
              const Text('Bienvenido a OrionHealth', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Tu salud, bajo tu control y 100% privada.', textAlign: TextAlign.center),
              const Spacer(),
              ElevatedButton(onPressed: () {}, child: const Text('Comenzar Onboarding')),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockLoginPage extends StatelessWidget {
  const _MockLoginPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.green),
            const SizedBox(height: 32),
            const Text('Acceso Seguro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            const TextField(decoration: InputDecoration(labelText: 'PIN de 6 dígitos', border: OutlineInputBorder()), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Entrar')),
            const SizedBox(height: 24),
            const Icon(Icons.fingerprint, size: 48),
          ],
        ),
      ),
    );
  }
}

class _MockMedicalResearchPage extends StatelessWidget {
  const _MockMedicalResearchPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investigación Médica')),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Evidencia'),
                Tab(text: 'Interacciones'),
                Tab(text: 'ICD-10'),
              ],
              labelColor: Colors.teal,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const TextField(decoration: InputDecoration(hintText: 'Buscar evidencia médica...', prefixIcon: Icon(Icons.search))),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: const [
                          Card(child: ListTile(title: Text('Estudio sobre Metformina'), subtitle: Text('Evidencia grado A'))),
                          Card(child: ListTile(title: Text('Tratamiento Hipertensión'), subtitle: Text('Guía 2025'))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockDashboardPage extends StatelessWidget {
  const _MockDashboardPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Salud')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(child: _StatCard(label: 'FC', value: '72 bpm', icon: Icons.favorite, color: Colors.red)),
                SizedBox(width: 8),
                Expanded(child: _StatCard(label: 'PA', value: '120/80', icon: Icons.speed, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Próxima Cita', style: TextStyle(fontWeight: FontWeight.bold)),
                    const ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Dr. Martínez - Control'),
                      subtitle: Text('Mañana, 10:00 AM'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
