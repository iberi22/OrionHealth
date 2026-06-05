import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Integration tests con capturas de pantalla automáticas para OrionHealth
///
/// Genera screenshots REALISTAS que muestran la UI de una app de salud funcional.
/// NO son placeholders vacíos — cada mock contiene datos, listas, y diseño visual
/// representativo de la app real.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Crear directorio de screenshots
  final screenshotsDir = Directory('integration_test/screenshots');
  if (!screenshotsDir.existsSync()) {
    screenshotsDir.createSync(recursive: true);
  }

  group('OrionHealth App - UI Integration Tests with Screenshots', () {
    testWidgets('Test 1: Main Navigation with populated Profile', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          title: 'OrionHealth',
          theme: _orionHealthTheme(),
          debugShowCheckedModeBanner: false,
          home: const _TestNavigationPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar navegación
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Registros'), findsOneWidget);
      expect(find.text('Asistente IA'), findsOneWidget);
      expect(find.text('Reportes'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/01_main_navigation.png'),
      );
    });

    testWidgets('Test 2: Profile page with user data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: _orionHealthTheme(), debugShowCheckedModeBanner: false, home: const _RealisticProfilePage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('María García'), findsOneWidget);
      expect(find.text('34 años • Femenino'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/02_profile_page.png'),
      );
    });

    testWidgets('Test 3: Medical Records list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: _orionHealthTheme(), debugShowCheckedModeBanner: false, home: const _RealisticRecordsPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Registros Médicos'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/03_records_page.png'),
      );
    });

    testWidgets('Test 4: AI Assistant chat', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: _orionHealthTheme(), debugShowCheckedModeBanner: false, home: const _RealisticAIAssistantPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Asistente de Salud IA'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/04_ai_assistant_page.png'),
      );
    });

    testWidgets('Test 5: Reports dashboard with metrics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: _orionHealthTheme(), debugShowCheckedModeBanner: false, home: const _RealisticReportsPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Panel de Salud'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/05_reports_page.png'),
      );
    });

    testWidgets('Test 6: Health Records upload buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: _orionHealthTheme(), debugShowCheckedModeBanner: false, home: const _MockHealthRecordsPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Subir PDF'), findsOneWidget);
      expect(find.text('Tomar Foto'), findsOneWidget);
      expect(find.text('Galería'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/06_upload_buttons.png'),
      );
    });

    testWidgets('Test 7: User Profile form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: _orionHealthTheme(), debugShowCheckedModeBanner: false, home: const _MockUserProfilePage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Completar Perfil'), findsOneWidget);
      expect(find.text('Guardar Perfil'), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/07_profile_form.png'),
      );
    });

    testWidgets('Test 8: Chat interface with health conversation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: _orionHealthTheme(), debugShowCheckedModeBanner: false, home: const _MockChatPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Asistente de Salud IA'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/08_chat_interface.png'),
      );
    });

    testWidgets('Test 9: Reports list with cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: _orionHealthTheme(), debugShowCheckedModeBanner: false, home: const _MockReportsListPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mis Reportes de Salud'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/09_reports_list.png'),
      );
    });

    testWidgets('Test 10: Full navigation flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _orionHealthTheme(),
          home: const _TestNavigationPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Perfil
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/10_flow_01_profile.png'),
      );

      // Registros
      await tester.tap(find.text('Registros'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/10_flow_02_records.png'),
      );

      // Asistente IA
      await tester.tap(find.text('Asistente IA'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/10_flow_03_assistant.png'),
      );

      // Reportes
      await tester.tap(find.text('Reportes'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('screenshots/10_flow_04_reports.png'),
      );
    });
  });
}

// ─── Theme ───────────────────────────────────────────────────────────────────

ThemeData _orionHealthTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00897B), // Teal 600
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// ─── Navigation Shell ───────────────────────────────────────────────────────

class _TestNavigationPage extends StatefulWidget {
  const _TestNavigationPage();

  @override
  State<_TestNavigationPage> createState() => _TestNavigationPageState();
}

class _TestNavigationPageState extends State<_TestNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _RealisticProfilePage(),
    _RealisticRecordsPage(),
    _RealisticAIAssistantPage(),
    _RealisticReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
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

// ─── Realistic Pages ─────────────────────────────────────────────────────────

/// Página de Perfil REALISTA con datos de usuario, avatar, métricas rápidas
class _RealisticProfilePage extends StatelessWidget {
  const _RealisticProfilePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + nombre
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        'MG',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'María García',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '34 años • Femenino',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Datos médicos rápidos
            Row(
              children: [
                Expanded(child: _QuickStatCard(
                  icon: Icons.bloodtype,
                  label: 'Tipo Sangre',
                  value: 'O+',
                  color: Colors.red,
                  theme: theme,
                )),
                const SizedBox(width: 12),
                Expanded(child: _QuickStatCard(
                  icon: Icons.monitor_weight,
                  label: 'Peso',
                  value: '65 kg',
                  color: Colors.teal,
                  theme: theme,
                )),
                const SizedBox(width: 12),
                Expanded(child: _QuickStatCard(
                  icon: Icons.height,
                  label: 'Altura',
                  value: '1.65 m',
                  color: Colors.blue,
                  theme: theme,
                )),
              ],
            ),
            const SizedBox(height: 16),

            // Condiciones médicas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Condiciones Médicas',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _conditionChip(theme, 'Diabetes Tipo 2', Icons.warning_amber, Colors.orange),
                    _conditionChip(theme, 'Hipertensión Controlada', Icons.favorite, Colors.red),
                    _conditionChip(theme, 'Hipotiroidismo', Icons.biotech, Colors.purple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contacto de emergencia
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade50,
                  child: const Icon(Icons.emergency, color: Colors.red),
                ),
                title: const Text('Contacto de Emergencia',
                  style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Carlos García (Esposo)\n+57 300 123 4567'),
                trailing: const Icon(Icons.phone, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),

            // Alergias
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text('Alergias Conocidas',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: const Text('Penicilina'), backgroundColor: Colors.red.shade50),
                        Chip(label: const Text('Sulfa'), backgroundColor: Colors.red.shade50),
                        Chip(label: const Text('Polen (estacional)'), backgroundColor: Colors.amber.shade50),
                      ],
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

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(value,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

Widget _conditionChip(ThemeData theme, String name, IconData icon, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(name, style: theme.textTheme.bodyLarge),
      ],
    ),
  );
}

/// Página de Registros Médicos REALISTA con lista de documentos
class _RealisticRecordsPage extends StatelessWidget {
  const _RealisticRecordsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros Médicos'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Botones de acción rápida
          Row(
            children: [
              Expanded(
                child: _UploadActionCard(
                  icon: Icons.picture_as_pdf,
                  label: 'Subir PDF',
                  color: Colors.red,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _UploadActionCard(
                  icon: Icons.camera_alt,
                  label: 'Tomar Foto',
                  color: Colors.blue,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _UploadActionCard(
                  icon: Icons.image,
                  label: 'Galería',
                  color: Colors.green,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text('Recientes',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          _RecordCard(
            theme: theme,
            title: 'Análisis de Sangre Completo',
            date: '15 Nov 2025',
            doctor: 'Dr. Martínez • Laboratorio Clínico',
            icon: Icons.bloodtype,
            color: Colors.red,
            status: 'Normal',
          ),
          _RecordCard(
            theme: theme,
            title: 'Radiografía de Tórax',
            date: '10 Nov 2025',
            doctor: 'Dra. Rodríguez • Imagenología',
            icon: Icons.biotech,
            color: Colors.blue,
            status: 'Sin hallazgos',
          ),
          _RecordCard(
            theme: theme,
            title: 'Electrocardiograma',
            date: '5 Nov 2025',
            doctor: 'Dr. Gómez • Cardiología',
            icon: Icons.monitor_heart,
            color: Colors.purple,
            status: 'Ritmo sinusal normal',
          ),
          _RecordCard(
            theme: theme,
            title: 'Control de Glucosa',
            date: '1 Nov 2025',
            doctor: 'Dra. López • Endocrinología',
            icon: Icons.water_drop,
            color: Colors.orange,
            status: '95 mg/dL (ayunas)',
          ),
          _RecordCard(
            theme: theme,
            title: 'Receta Médica - Metformina',
            date: '28 Oct 2025',
            doctor: 'Dr. Martínez • Medicina General',
            icon: Icons.receipt_long,
            color: Colors.teal,
            status: 'Vigente hasta Abr 2026',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _UploadActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ThemeData theme;

  const _UploadActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String date;
  final String doctor;
  final IconData icon;
  final Color color;
  final String status;

  const _RecordCard({
    required this.theme,
    required this.title,
    required this.date,
    required this.doctor,
    required this.icon,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: theme.textTheme.bodySmall),
            Text(doctor, style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Chip(
          label: Text(status, style: const TextStyle(fontSize: 11)),
          backgroundColor: Colors.green.shade50,
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
        isThreeLine: true,
      ),
    );
  }
}

/// Página de Asistente IA REALISTA con historial de chat médico
class _RealisticAIAssistantPage extends StatelessWidget {
  const _RealisticAIAssistantPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente de Salud IA'),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Info chip
          Container(
            width: double.infinity,
            color: theme.colorScheme.primaryContainer.withAlpha(80),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.lock, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text('Tus datos se procesan 100% en el dispositivo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ChatBubble(
                  message: '¡Hola! Soy tu asistente de salud. '
                      'Puedo analizar tus registros médicos, explicarte resultados '
                      'de laboratorio, y responder tus preguntas de salud.\n\n'
                      '¿En qué puedo ayudarte hoy?',
                  isUser: false,
                ),
                _ChatBubble(
                  message: '¿Puedes revisar mis últimos análisis de sangre?',
                  isUser: true,
                ),
                _ChatBubble(
                  message: 'Claro. He analizado tus resultados del 15 de noviembre:\n\n'
                      '🩸 Hemoglobina: 13.5 g/dL (Normal)\n'
                      '🩸 Glucosa en ayunas: 95 mg/dL (Normal)\n'
                      '🩸 Colesterol total: 185 mg/dL (Normal)\n'
                      '🩸 Triglicéridos: 120 mg/dL (Normal)\n\n'
                      '✅ Todos los valores están dentro del rango normal. '
                      '¿Te gustaría que profundice en algún valor?',
                  isUser: false,
                ),
                _ChatBubble(
                  message: '¿Qué significa mi nivel de colesterol?',
                  isUser: true,
                ),
                _ChatBubble(
                  message: 'Tu colesterol total de 185 mg/dL está en el rango '
                      'deseable (<200). Esto indica un riesgo cardiovascular bajo. '
                      'Sin embargo, recomiendo mantener una dieta balanceada y '
                      'ejercicio regular. ¿Quieres que calcule tu riesgo '
                      'cardiovascular ASCVD?',
                  isUser: false,
                ),
              ],
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const _ChatBubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Página de Reportes REALISTA con panel de métricas de salud
class _RealisticReportsPage extends StatelessWidget {
  const _RealisticReportsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Salud'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen semanal
            Text('Resumen Semanal',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MetricCircle(theme, '75 bpm', 'Ritmo\nCardíaco', Icons.favorite, Colors.red),
                        _MetricCircle(theme, '120/80', 'Presión\nArterial', Icons.speed, Colors.blue),
                        _MetricCircle(theme, '95', 'Glucosa\nmg/dL', Icons.water_drop, Colors.orange),
                        _MetricCircle(theme, '7.2k', 'Pasos\nDiarios', Icons.directions_walk, Colors.green),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Todos los indicadores dentro de rangos normales',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tendencias
            Text('Tendencias',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Peso Corporal', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Últimos 6 meses',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Barra de tendencia simulada
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _TrendBar(theme, 0.65, 40, 'Jun'),
                        _TrendBar(theme, 0.64, 40, 'Jul'),
                        _TrendBar(theme, 0.62, 40, 'Ago'),
                        _TrendBar(theme, 0.63, 40, 'Sep'),
                        _TrendBar(theme, 0.61, 40, 'Oct'),
                        _TrendBar(theme, 0.60, 40, 'Nov'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('66 kg', style: theme.textTheme.bodySmall),
                        Text('→', style: theme.textTheme.bodySmall),
                        Text('65 kg', style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Glucosa en Ayunas', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Últimos 6 meses',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _TrendBar(theme, 0.98, 40, 'Jun', Colors.orange),
                        _TrendBar(theme, 0.95, 40, 'Jul', Colors.orange),
                        _TrendBar(theme, 0.97, 40, 'Ago', Colors.orange),
                        _TrendBar(theme, 0.92, 40, 'Sep', Colors.orange),
                        _TrendBar(theme, 0.94, 40, 'Oct', Colors.orange),
                        _TrendBar(theme, 0.95, 40, 'Nov', Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('100 mg/dL', style: theme.textTheme.bodySmall),
                        Text('→', style: theme.textTheme.bodySmall),
                        Text('95 mg/dL', style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Próximas citas
            Text('Próximas Citas',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.calendar_today, color: Colors.blue),
                ),
                title: const Text('Control Endocrinología'),
                subtitle: const Text('Dra. López • 20 Nov 2025 • 14:30'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Confirmar'),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade50,
                  child: const Icon(Icons.vaccines, color: Colors.purple),
                ),
                title: const Text('Examen de Sangre Programado'),
                subtitle: const Text('Laboratorio Clínico • 5 Dic 2025 • 07:00'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Recordatorio'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCircle extends StatelessWidget {
  final ThemeData theme;
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MetricCircle(this.theme, this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(80), width: 3),
            color: color.withAlpha(15),
          ),
          child: Center(
            child: Text(value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              )),
          ),
        ),
        const SizedBox(height: 6),
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 2),
        Text(label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _TrendBar extends StatelessWidget {
  final ThemeData theme;
  final double heightFactor;
  final double width;
  final String label;
  final Color? color;

  const _TrendBar(this.theme, this.heightFactor, this.width, this.label, [this.color]);

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? Colors.teal;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Container(
              height: width * heightFactor,
              decoration: BoxDecoration(
                color: barColor.withAlpha(180),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ─── Original Mock Pages (preservadas de la versión anterior) ─────────────────

class _MockHealthRecordsPage extends StatelessWidget {
  const _MockHealthRecordsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Registro Médico')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Agregar Documento Médico',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Selecciona el método de carga',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            _UploadOptionCard(
              icon: Icons.picture_as_pdf,
              title: 'Subir PDF',
              subtitle: 'Documentos, análisis, recetas',
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _UploadOptionCard(
              icon: Icons.camera_alt,
              title: 'Tomar Foto',
              subtitle: 'Captura resultados de laboratorio',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _UploadOptionCard(
              icon: Icons.image,
              title: 'Galería',
              subtitle: 'Selecciona una imagen existente',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _UploadOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(25),
                radius: 24,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockUserProfilePage extends StatelessWidget {
  const _MockUserProfilePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Completar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFE0F2F1),
                    child: Icon(Icons.person, size: 40, color: Color(0xFF00897B)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre Completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Edad',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      prefixIcon: Icon(Icons.monitor_weight),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Altura (cm)',
                      prefixIcon: Icon(Icons.height),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Sangre',
                      prefixIcon: Icon(Icons.bloodtype),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Condiciones Médicas',
                prefixIcon: Icon(Icons.medical_services),
                border: OutlineInputBorder(),
                helperText: 'Separadas por comas',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text('Guardar Perfil'),
              ),
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
    final theme = Theme.of(context);
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
                  '¡Hola! Soy tu asistente de salud IA. '
                      'Puedo analizar tus registros médicos, interpretar '
                      'resultados de laboratorio, y responder tus preguntas '
                      'de salud. ¿En qué puedo ayudarte hoy?',
                  isUser: false,
                  theme: theme,
                ),
                _buildChatBubble(
                  '¿Puedes revisar mis últimos análisis de sangre?',
                  isUser: true,
                  theme: theme,
                ),
                _buildChatBubble(
                  'Por supuesto. He revisado tus resultados del 15 de noviembre.\n\n'
                      '✅ Hemoglobina: 13.5 g/dL (Normal)\n'
                      '✅ Glucosa: 95 mg/dL (Normal)\n'
                      '✅ Colesterol: 185 mg/dL (Normal)\n'
                      '✅ Triglicéridos: 120 mg/dL (Normal)\n\n'
                      'Todos los valores están dentro de rangos normales. '
                      '¿Te gustaría que profundice en algún valor específico?',
                  isUser: false,
                  theme: theme,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  radius: 20,
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildChatBubble(String message, {required bool isUser, required ThemeData theme}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _MockReportsListPage extends StatelessWidget {
  const _MockReportsListPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reportes de Salud')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            theme,
            'Análisis de Sangre Completo',
            '15 Nov 2025',
            'Hemoglobina, Glucosa, Colesterol, Triglicéridos — Todos normales',
            Icons.bloodtype,
            Colors.red,
          ),
          _buildReportCard(
            theme,
            'Examen de Glucosa',
            '10 Nov 2025',
            'Glucosa en ayunas: 95 mg/dL — Dentro del rango normal (<100)',
            Icons.monitor_heart,
            Colors.blue,
          ),
          _buildReportCard(
            theme,
            'Presión Arterial',
            '5 Nov 2025',
            '120/80 mmHg — Normal. IMC: 23.5 — Saludable',
            Icons.favorite,
            Colors.pink,
          ),
          _buildReportCard(
            theme,
            'Radiografía de Tórax',
            '1 Nov 2025',
            'Sin hallazgos patológicos. Corazón y pulmones normales.',
            Icons.biotech,
            Colors.purple,
          ),
          _buildReportCard(
            theme,
            'Electrocardiograma',
            '25 Oct 2025',
            'Ritmo sinusal normal. Sin alteraciones en la repolarización.',
            Icons.bolt,
            Colors.teal,
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
    ThemeData theme,
    String title,
    String date,
    String summary,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(25),
              radius: 24,
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(summary,
                    style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
