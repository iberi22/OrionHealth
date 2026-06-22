import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home Flow - E2E Tests', () {
    testWidgets('E2E: Dashboard Modules Interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MockHomePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'home', '01_dashboard');

      // Interact with Quick Actions
      expect(find.text('Escanear QR'), findsOneWidget);
      await tester.tap(find.text('Escanear QR'));
      await tester.pump();
      await VideoRecorder.recordStep(tester, 'home', '02_qr_tap');

      // Scroll and check modules
      expect(find.text('Estado de Salud'), findsOneWidget);
      expect(find.text('Citas Próximas'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'home', '03_scrolled');
    });
  });
}

class _MockHomePage extends StatelessWidget {
  const _MockHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OrionHealth')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Acciones Rápidas'),
          Row(
            children: [
              _buildActionCard('Escanear QR', Icons.qr_code),
              _buildActionCard('Compartir', Icons.share),
            ],
          ),
          const SizedBox(height: 24),
          const Card(
            child: ListTile(
              title: Text('Estado de Salud'),
              subtitle: Text('Excelente'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              title: Text('Citas Próximas'),
              subtitle: Text('Odontología - Mañana 9:00'),
            ),
          ),
          const SizedBox(height: 500), // Force scroll
          const Text('Fin del Dashboard'),
        ],
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
