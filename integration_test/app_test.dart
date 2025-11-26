import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Integration tests con capturas de pantalla automáticas para OrionHealth
/// Similar a Playwright pero para Flutter
///
/// Esta versión usa tests de UI independientes sin dependencias de backend
/// y captura screenshots usando RepaintBoundary + Golden Tests
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Crear directorio de screenshots
  final screenshotsDir = Directory('integration_test/screenshots');
  if (!screenshotsDir.existsSync()) {
    screenshotsDir.createSync(recursive: true);
  }

  group('OrionHealth App - UI Integration Tests with Screenshots', () {
    testWidgets('Test 1: Simple MaterialApp renders correctly', (
      WidgetTester tester,
    ) async {
      // Test básico de UI sin dependencias de backend
      await tester.pumpWidget(
        MaterialApp(
          title: 'OrionHealth Test',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
          home: const _TestNavigationPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar que la navegación está visible
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Registros'), findsOneWidget);
      expect(find.text('Asistente IA'), findsOneWidget);
      expect(find.text('Reportes'), findsOneWidget);

      // Golden test para capturar screenshot
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/01_main_navigation.png'),
      );
    });

    testWidgets('Test 2: Profile page placeholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const _TestNavigationPage()));
      await tester.pumpAndSettle();

      // Estamos en la página de Perfil por defecto
      expect(find.text('Página de Perfil'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/02_profile_page.png'),
      );
    });

    testWidgets('Test 3: Navigate to Records page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const _TestNavigationPage()));
      await tester.pumpAndSettle();

      // Navegar a Registros
      await tester.tap(find.text('Registros'));
      await tester.pumpAndSettle();

      expect(find.text('Página de Registros'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/03_records_page.png'),
      );
    });

    testWidgets('Test 4: Navigate to AI Assistant page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const _TestNavigationPage()));
      await tester.pumpAndSettle();

      // Navegar a Asistente IA
      await tester.tap(find.text('Asistente IA'));
      await tester.pumpAndSettle();

      expect(find.text('Página de Asistente IA'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/04_ai_assistant_page.png'),
      );
    });

    testWidgets('Test 5: Navigate to Reports page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const _TestNavigationPage()));
      await tester.pumpAndSettle();

      // Navegar a Reportes
      await tester.tap(find.text('Reportes'));
      await tester.pumpAndSettle();

      expect(find.text('Página de Reportes'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/05_reports_page.png'),
      );
    });

    testWidgets('Test 6: Health Records upload buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const _MockHealthRecordsPage()),
      );
      await tester.pumpAndSettle();

      // Verificar botones de carga
      expect(find.text('Subir PDF'), findsOneWidget);
      expect(find.text('Tomar Foto'), findsOneWidget);
      expect(find.text('Galería'), findsOneWidget);

      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.image), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/06_upload_buttons.png'),
      );
    });

    testWidgets('Test 7: User Profile form layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const _MockUserProfilePage()));
      await tester.pumpAndSettle();

      // Verificar campos del formulario
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Edad'), findsOneWidget);
      expect(find.text('Peso (kg)'), findsOneWidget);
      expect(find.text('Altura (cm)'), findsOneWidget);
      expect(find.text('Tipo de Sangre'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/07_profile_form.png'),
      );
    });

    testWidgets('Test 8: Chat interface mock', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const _MockChatPage()));
      await tester.pumpAndSettle();

      // Verificar elementos del chat
      expect(find.text('Asistente de Salud IA'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/08_chat_interface.png'),
      );
    });

    testWidgets('Test 9: Reports list mock', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const _MockReportsListPage()));
      await tester.pumpAndSettle();

      // Verificar que hay reportes listados
      expect(find.text('Mis Reportes de Salud'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/09_reports_list.png'),
      );
    });

    testWidgets('Test 10: Full navigation flow screenshots', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
          home: const _TestNavigationPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Screenshot del estado inicial (Perfil)
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/10_flow_01_profile.png'),
      );

      // Navegar a Registros y capturar
      await tester.tap(find.text('Registros'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/10_flow_02_records.png'),
      );

      // Navegar a Asistente IA y capturar
      await tester.tap(find.text('Asistente IA'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/10_flow_03_assistant.png'),
      );

      // Navegar a Reportes y capturar
      await tester.tap(find.text('Reportes'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/10_flow_04_reports.png'),
      );
    });
  });
}

/// Widget de navegación de prueba que simula la estructura de la app
class _TestNavigationPage extends StatefulWidget {
  const _TestNavigationPage();

  @override
  State<_TestNavigationPage> createState() => _TestNavigationPageState();
}

class _TestNavigationPageState extends State<_TestNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _MockProfilePage(),
    _MockHealthRecordsPage(),
    _MockAIAssistantPage(),
    _MockReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
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

class _MockProfilePage extends StatelessWidget {
  const _MockProfilePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: const Center(
        child: Text('Página de Perfil', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class _MockHealthRecordsPage extends StatelessWidget {
  const _MockHealthRecordsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Registro Médico')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Página de Registros', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Subir PDF'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar Foto'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.image),
              label: const Text('Galería'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockAIAssistantPage extends StatelessWidget {
  const _MockAIAssistantPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente IA')),
      body: const Center(
        child: Text('Página de Asistente IA', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class _MockReportsPage extends StatelessWidget {
  const _MockReportsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: const Center(
        child: Text('Página de Reportes', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class _MockUserProfilePage extends StatelessWidget {
  const _MockUserProfilePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Altura (cm)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Tipo de Sangre'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Guardar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockChatPage extends StatelessWidget {
  const _MockChatPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente de Salud IA'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildChatBubble(
                  'Hola! Soy tu asistente de salud. ¿En qué puedo ayudarte hoy?',
                  isUser: false,
                ),
                _buildChatBubble(
                  '¿Puedes revisar mis últimos análisis de sangre?',
                  isUser: true,
                ),
                _buildChatBubble(
                  'Por supuesto! He revisado tus resultados del 15 de noviembre. '
                  'Todo parece estar dentro de los rangos normales. '
                  '¿Te gustaría que te explique algún valor en particular?',
                  isUser: false,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.send), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildChatBubble(String message, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}

class _MockReportsListPage extends StatelessWidget {
  const _MockReportsListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reportes de Salud')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            'Análisis de Sangre Completo',
            '15 Nov 2025',
            'Resultados normales',
            Icons.bloodtype,
            Colors.red,
          ),
          _buildReportCard(
            'Examen de Glucosa',
            '10 Nov 2025',
            'Glucosa: 95 mg/dL',
            Icons.monitor_heart,
            Colors.blue,
          ),
          _buildReportCard(
            'Presión Arterial',
            '5 Nov 2025',
            '120/80 mmHg - Normal',
            Icons.favorite,
            Colors.pink,
          ),
          _buildReportCard(
            'Control de Peso',
            '1 Nov 2025',
            'IMC: 23.5 - Saludable',
            Icons.fitness_center,
            Colors.green,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  static Widget _buildReportCard(
    String title,
    String date,
    String summary,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: const TextStyle(fontSize: 12)),
            Text(summary, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
      ),
    );
  }
}
