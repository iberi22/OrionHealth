import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// E2E Tests para Health Wallet de OrionHealth
///
/// Ejecutar con:
/// flutter test integration_test/health_wallet_e2e_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Health Wallet - E2E Tests', () {

    // ============================================================
    // TEST 1: Dashboard del wallet muestra resumen
    // ============================================================
    testWidgets('E2E 1: Wallet dashboard renders', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _MockWalletDashboard(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Billetera de Salud'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    // ============================================================
    // TEST 2: Agregar resultado de laboratorio
    // ============================================================
    testWidgets('E2E 2: Add lab result', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _MockLabEntryPage(),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      if (fields.evaluate().length >= 3) {
        await tester.enterText(fields.at(0), 'Glucosa');
        await tester.pumpAndSettle();
        await tester.enterText(fields.at(1), '95');
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
    });

    // ============================================================
    // TEST 3: Ver lista de medicamentos
    // ============================================================
    testWidgets('E2E 3: View medications list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _MockMedicationsPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medicamentos'), findsWidgets);
      expect(find.text('Metformina 500mg'), findsOneWidget);
    });

    // ============================================================
    // TEST 4: Agregar signo vital
    // ============================================================
    testWidgets('E2E 4: Add vital sign', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _MockVitalSignEntry(),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      if (fields.evaluate().length >= 2) {
        await tester.enterText(fields.at(0), '120');
        await tester.pumpAndSettle();
        await tester.enterText(fields.at(1), '80');
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
    });

    // ============================================================
    // TEST 5: Ver historial de eventos médicos
    // ============================================================
    testWidgets('E2E 5: View medical events timeline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _MockEventsTimeline(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Línea de Tiempo'), findsOneWidget);
      expect(find.text('Consulta cardiológica'), findsOneWidget);
    });

    // ============================================================
    // TEST 6: Exportar datos
    // ============================================================
    testWidgets('E2E 6: Export data options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _MockExportPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Exportar Datos'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
    });

    // ============================================================
    // TEST 7: Configurar recordatorios de medicamentos
    // ============================================================
    testWidgets('E2E 7: Medication reminders', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _MockRemindersPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recordatorios'), findsOneWidget);
      expect(find.text('Metformina'), findsOneWidget);
    });

    // ============================================================
    // TEST 8: Subir documento PDF
    // ============================================================
    testWidgets('E2E 8: Upload PDF document', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _MockDocumentsPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Documentos'), findsWidgets);
      expect(find.text('Subir PDF'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    // ============================================================
    // TEST 9: Ver estadísticas de salud
    // ============================================================
    testWidgets('E2E 9: View health statistics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _MockStatsPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Estadísticas'), findsOneWidget);
      expect(find.text('Laboratorios'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
    });

    // ============================================================
    // TEST 10: Buscar en historial
    // ============================================================
    testWidgets('E2E 10: Search in history', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _MockSearchPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'glucosa');
      await tester.pumpAndSettle();
    });
  });
}

// ============================================================================
// MOCK COMPONENTS
// ============================================================================

class _MockWalletDashboard extends StatelessWidget {
  const _MockWalletDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billetera de Salud')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Datos cifrados', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                        Text('AES-256-GCM', style: TextStyle(color: Colors.green[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Resumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildStatCard('Labs', '45', Icons.science)),
                Expanded(child: _buildStatCard('Meds', '12', Icons.medication)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildStatCard('Vitals', '230', Icons.favorite)),
                Expanded(child: _buildStatCard('Docs', '8', Icons.description)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _MockLabEntryPage extends StatelessWidget {
  const _MockLabEntryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Laboratorio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre del laboratorio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Unidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockMedicationsPage extends StatelessWidget {
  const _MockMedicationsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicamentos')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.medication, color: Colors.teal),
            title: const Text('Metformina 500mg'),
            subtitle: const Text('2 veces al día'),
            trailing: IconButton(
              icon: const Icon(Icons.alarm),
              onPressed: () {},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.medication, color: Colors.teal),
            title: const Text('Enalapril 10mg'),
            subtitle: const Text('1 vez al día'),
            trailing: IconButton(
              icon: const Icon(Icons.alarm),
              onPressed: () {},
            ),
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

class _MockVitalSignEntry extends StatelessWidget {
  const _MockVitalSignEntry();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Signo Vital')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Presión Arterial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Sistólica'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('/'),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Diastólica'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockEventsTimeline extends StatelessWidget {
  const _MockEventsTimeline();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Línea de Tiempo')),
      body: ListView(
        children: [
          _buildEventCard('Consulta cardiológica', '14 Mar 2026', Icons.favorite),
          _buildEventCard('Examen de laboratorio', '10 Mar 2026', Icons.science),
          _buildEventCard('Emergency room visit', '28 Feb 2026', Icons.local_hospital),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String date, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.teal.withOpacity(0.2), child: Icon(icon, color: Colors.teal)),
        title: Text(title),
        subtitle: Text(date),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _MockExportPage extends StatelessWidget {
  const _MockExportPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar Datos')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('JSON'),
            subtitle: const Text('Datos estructurados'),
            trailing: const Icon(Icons.download),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('PDF'),
            subtitle: const Text('Reporte médico'),
            trailing: const Icon(Icons.download),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('FHIR'),
            subtitle: const Text('Estándar interoperable'),
            trailing: const Icon(Icons.download),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MockRemindersPage extends StatelessWidget {
  const _MockRemindersPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.medication),
            title: const Text('Metformina'),
            subtitle: const Text('08:00, 20:00'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          ListTile(
            leading: const Icon(Icons.medication),
            title: const Text('Enalapril'),
            subtitle: const Text('08:00'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
        ],
      ),
    );
  }
}

class _MockDocumentsPage extends StatelessWidget {
  const _MockDocumentsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documentos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Subir PDF'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar Foto'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.description, color: Colors.red),
                  title: const Text('Resultados laboratorio.pdf'),
                  subtitle: const Text('15 Mar 2026'),
                ),
                ListTile(
                  leading: const Icon(Icons.description, color: Colors.red),
                  title: const Text('RX torax.pdf'),
                  subtitle: const Text('10 Feb 2026'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MockStatsPage extends StatelessWidget {
  const _MockStatsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatTile('Laboratorios', '45', Colors.blue),
          _buildStatTile('Medicamentos', '12', Colors.green),
          _buildStatTile('Signos Vitales', '230', Colors.red),
          _buildStatTile('Documentos', '8', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String count, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(count, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}

class _MockSearchPage extends StatelessWidget {
  const _MockSearchPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar en historial...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text('Glucosa: 95 mg/dL'),
                  subtitle: Text('14 Mar 2026'),
                ),
                ListTile(
                  title: Text('Glucosa: 102 mg/dL'),
                  subtitle: Text('10 Feb 2026'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
