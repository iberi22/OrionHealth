import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sync Flow - E2E Tests', () {
    testWidgets('E2E: Sync data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _MockSyncPage(),
        ),
      );
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'sync', '01_initial');

      await tester.tap(find.text('Sincronizar ahora'));
      await tester.pump(); // Start sync
      await VideoRecorder.recordStep(tester, 'sync', '02_syncing');

      await tester.pumpAndSettle(const Duration(seconds: 1));
      await VideoRecorder.recordStep(tester, 'sync', '03_complete');
    });
  });
}

class _MockSyncPage extends StatefulWidget {
  @override
  State<_MockSyncPage> createState() => _MockSyncPageState();
}

class _MockSyncPageState extends State<_MockSyncPage> {
  bool _isSyncing = false;
  bool _isComplete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronización')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSyncing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Sincronizando con la red P2P...'),
            ] else if (_isComplete) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text('Sincronización completada'),
            ] else ...[
              const Text('Última sincronización: hace 2 horas'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isSyncing = true);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      setState(() {
                        _isSyncing = false;
                        _isComplete = true;
                      });
                    }
                  });
                },
                child: const Text('Sincronizar ahora'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
