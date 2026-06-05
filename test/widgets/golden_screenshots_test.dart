import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Golden screenshot tests — run separately with:
//   flutter test test/widgets/golden_screenshots_test.dart
void main() {
  final screenshotsDir = Directory('integration_test/screenshots/actual');
  if (!screenshotsDir.existsSync()) {
    screenshotsDir.createSync(recursive: true);
  }

  group('OrionHealth golden screenshots', () {
    testWidgets('01 main navigation', (WidgetTester tester) async {
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

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Registros'), findsOneWidget);
      expect(find.text('Asistente IA'), findsOneWidget);
      expect(find.text('Reportes'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/01_main_navigation.png',
        ),
      );
    });

    testWidgets('02 profile page', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const _TestNavigationPage()));
      await tester.pumpAndSettle();

      expect(find.text('Página de Perfil'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/02_profile_page.png',
        ),
      );
    });

    testWidgets('03 records page', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const _TestNavigationPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registros'));
      await tester.pumpAndSettle();

      expect(find.text('Página de Registros'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/03_records_page.png',
        ),
      );
    });

    testWidgets('04 ai assistant page', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const _TestNavigationPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Asistente IA'));
      await tester.pumpAndSettle();

      expect(find.text('Página de Asistente IA'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/04_ai_assistant_page.png',
        ),
      );
    });

    testWidgets('05 reports page', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const _TestNavigationPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reportes'));
      await tester.pumpAndSettle();

      expect(find.text('Página de Reportes'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/05_reports_page.png',
        ),
      );
    });

    testWidgets('06 upload buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const _MockHealthRecordsPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Subir PDF'), findsOneWidget);
      expect(find.text('Tomar Foto'), findsOneWidget);
      expect(find.text('Galería'), findsOneWidget);

      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.image), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/06_upload_buttons.png',
        ),
      );
    });

    testWidgets('07 profile form', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const _MockUserProfilePage()));
      await tester.pumpAndSettle();

      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Edad'), findsOneWidget);
      expect(find.text('Peso (kg)'), findsOneWidget);
      expect(find.text('Altura (cm)'), findsOneWidget);
      expect(find.text('Tipo de Sangre'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/07_profile_form.png',
        ),
      );
    });

    testWidgets('08 chat interface', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const _MockChatPage()));
      await tester.pumpAndSettle();

      expect(find.text('Asistente de Salud IA'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/08_chat_interface.png',
        ),
      );
    });

    testWidgets('09 reports list', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const _MockReportsListPage()));
      await tester.pumpAndSettle();

      expect(find.text('Mis Reportes de Salud'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/09_reports_list.png',
        ),
      );
    });

    testWidgets('10 flow screenshots', (WidgetTester tester) async {
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

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/10_flow_01_profile.png',
        ),
      );

      await tester.tap(find.text('Registros'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/10_flow_02_records.png',
        ),
      );

      await tester.tap(find.text('Asistente IA'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/10_flow_03_assistant.png',
        ),
      );

      await tester.tap(find.text('Reportes'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../integration_test/screenshots/actual/10_flow_04_reports.png',
        ),
      );
    });
  });
}

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
                  color: Colors.black.withValues(alpha: 0.1),
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
          backgroundColor: color.withValues(alpha: 0.2),
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
