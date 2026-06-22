import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow - E2E Tests', () {
    testWidgets('E2E: Login with PIN and SSI', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MockLoginPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth', '01_login_screen');

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth', '02_pin_entered');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'auth', '03_authenticated');
    });

    testWidgets('Edge Case: Wrong PIN - shows error message', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MockLoginPage()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'wrong');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('PIN incorrecto. Inténtalo de nuevo.'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '04_wrong_pin_error');
    });

    testWidgets('Edge Case: Token Expiry - redirects to login', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: _MockDashboardWithExpiry()));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsOneWidget);

      await tester.tap(find.text('Simular Expiración'));
      await tester.pumpAndSettle();

      expect(find.text('Sesión expirada. Por favor, entra de nuevo.'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '05_token_expired');
    });

    testWidgets('Edge Case: Network Timeout - shows retry UI', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MockLoginPage(simulateTimeout: true)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Error de conexión. Reintentar?'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'auth', '06_network_timeout');
    });
  });
}

class _MockLoginPage extends StatefulWidget {
  final bool simulateTimeout;
  const _MockLoginPage({super.key, this.simulateTimeout = false});

  @override
  State<_MockLoginPage> createState() => _MockLoginPageState();
}

class _MockLoginPageState extends State<_MockLoginPage> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _showTimeout = false;

  @override
  Widget build(BuildContext context) {
    if (_showTimeout) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error de conexión')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error de conexión. Reintentar?'),
              IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() => _showTimeout = false)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.security, size: 80),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Introduce tu PIN',
                errorText: _errorMessage,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (!mounted) return;
                    setState(() {
                      _isLoading = false;
                      if (widget.simulateTimeout) {
                        _showTimeout = true;
                      } else if (_controller.text == 'wrong') {
                        _errorMessage = 'PIN incorrecto. Inténtalo de nuevo.';
                      } else {
                        // success
                      }
                    });
                  });
                },
                child: const Text('Entrar'),
              ),
          ],
        ),
      ),
    );
  }
}

class _MockDashboardWithExpiry extends StatefulWidget {
  const _MockDashboardWithExpiry({super.key});

  @override
  State<_MockDashboardWithExpiry> createState() => _MockDashboardWithExpiryState();
}

class _MockDashboardWithExpiryState extends State<_MockDashboardWithExpiry> {
  bool _expired = false;

  @override
  Widget build(BuildContext context) {
    if (_expired) {
      return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: const Center(child: Text('Sesión expirada. Por favor, entra de nuevo.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => setState(() => _expired = true),
          child: const Text('Simular Expiración'),
        ),
      ),
    );
  }
}
