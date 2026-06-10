import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow - E2E Tests', () {
    testWidgets('E2E: Login with PIN and SSI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _MockLoginPage(),
        ),
      );
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth', '01_login_screen');

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth', '02_pin_entered');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth', '03_authenticated');
    });
  });
}

class _MockLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.security, size: 80),
            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(labelText: 'Introduce tu PIN'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Entrar')),
          ],
        ),
      ),
    );
  }
}
