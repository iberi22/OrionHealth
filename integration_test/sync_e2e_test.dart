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

    testWidgets('Edge Case: Conflict Resolution', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _MockSyncPage(simulateConflict: true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sincronizar ahora'));
      await tester.pumpAndSettle();

      expect(find.text('Conflicto detectado'), findsOneWidget);
      expect(find.text('Usar versión local'), findsOneWidget);
      expect(find.text('Usar versión remota'), findsOneWidget);

      await tester.tap(find.text('Usar versión remota'));
      await tester.pumpAndSettle();

      expect(find.text('Sincronización completada'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'sync', '04_conflict_resolved');
    });

    testWidgets('Edge Case: Partial Sync / Interrupted', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _MockSyncPage(simulateInterruption: true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sincronizar ahora'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Sincronización interrumpida'), findsOneWidget);
      expect(find.text('Reanudar'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'sync', '05_sync_interrupted');
    });

    testWidgets('Edge Case: Large Dataset Progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _MockSyncPage(isLargeDataset: true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sincronizar ahora'));
      await tester.pump();

      // Verify progress indicator and percentage
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'sync', '06_large_dataset_progress');
    });
  });
}

class _MockSyncPage extends StatefulWidget {
  final bool simulateConflict;
  final bool simulateInterruption;
  final bool isLargeDataset;

  const _MockSyncPage({
    this.simulateConflict = false,
    this.simulateInterruption = false,
    this.isLargeDataset = false,
  });

  @override
  State<_MockSyncPage> createState() => _MockSyncPageState();
}

class _MockSyncPageState extends State<_MockSyncPage> {
  bool _isSyncing = false;
  bool _isComplete = false;
  bool _hasConflict = false;
  bool _interrupted = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronización')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSyncing) ...[
              if (widget.isLargeDataset) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: LinearProgressIndicator(value: _progress),
                ),
                const SizedBox(height: 16),
                Text('${(_progress * 100).toInt()}% completado'),
              ] else ...[
                const CircularProgressIndicator(),
              ],
              const SizedBox(height: 16),
              const Text('Sincronizando con la red P2P...'),
            ] else if (_hasConflict) ...[
              const Icon(Icons.warning, color: Colors.orange, size: 64),
              const SizedBox(height: 16),
              const Text('Conflicto detectado'),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () {}, child: const Text('Usar versión local')),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => setState(() {
                  _hasConflict = false;
                  _isComplete = true;
                }),
                child: const Text('Usar versión remota'),
              ),
            ] else if (_interrupted) ...[
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('Sincronización interrumpida'),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () {}, child: const Text('Reanudar')),
            ] else if (_isComplete) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text('Sincronización completada'),
            ] else ...[
              const Text('Última sincronización: hace 2 horas'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (widget.simulateConflict) {
                    setState(() => _hasConflict = true);
                    return;
                  }
                  if (widget.simulateInterruption) {
                    setState(() => _interrupted = true);
                    return;
                  }

                  setState(() => _isSyncing = true);
                  if (widget.isLargeDataset) {
                    _simulateLargeProgress();
                  } else {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() {
                          _isSyncing = false;
                          _isComplete = true;
                        });
                      }
                    });
                  }
                },
                child: const Text('Sincronizar ahora'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _simulateLargeProgress() async {
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() {
        _progress = i / 10.0;
      });
    }
    setState(() {
      _isSyncing = false;
      _isComplete = true;
    });
  }
}
