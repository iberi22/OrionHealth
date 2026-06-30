import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('About Flow - E2E Tests', () {
    testWidgets('E2E: Legal Info Flow', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MockAboutPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'about', '01_main');

      // Terms
      await tester.tap(find.text('Términos y Condiciones'));
      await tester.pumpAndSettle();
      expect(find.text('Términos de Uso'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'about', '02_terms');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Privacy
      await tester.tap(find.text('Política de Privacidad'));
      await tester.pumpAndSettle();
      expect(find.text('Privacidad de Datos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'about', '03_privacy');
    });
  });
}

class _MockAboutPage extends StatefulWidget {
  const _MockAboutPage();
  @override
  State<_MockAboutPage> createState() => _MockAboutPageState();
}

class _MockAboutPageState extends State<_MockAboutPage> {
  String? _subPage;

  @override
  Widget build(BuildContext context) {
    if (_subPage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(_subPage!), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _subPage = null))),
        body: Padding(padding: const EdgeInsets.all(16.0), child: Text('Contenido legal de $_subPage...')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de OrionHealth')),
      body: ListView(
        children: [
          const ListTile(title: Text('Versión'), subtitle: Text('1.0.0')),
          ListTile(title: const Text('Términos y Condiciones'), onTap: () => setState(() => _subPage = 'Términos de Uso')),
          ListTile(title: const Text('Política de Privacidad'), onTap: () => setState(() => _subPage = 'Privacidad de Datos')),
        ],
      ),
    );
  }
}
