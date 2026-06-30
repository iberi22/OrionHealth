import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Meditation Flow - E2E Tests', () {
    testWidgets('E2E: Start Session and Complete', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MockMeditationPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'meditation', '01_list');

      // Select Session
      await tester.tap(find.text('Relajación Profunda'));
      await tester.pumpAndSettle();
      expect(find.text('00:05'), findsOneWidget); // Simulated short session
      await VideoRecorder.recordStep(tester, 'meditation', '02_timer_start');

      // Complete
      await tester.pumpAndSettle(const Duration(seconds: 6));
      expect(find.text('¡Sesión Completada!'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'meditation', '03_completed');

      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(find.text('Sesiones de Meditación'), findsOneWidget);
    });
  });
}

class _MockMeditationPage extends StatefulWidget {
  const _MockMeditationPage();
  @override
  State<_MockMeditationPage> createState() => _MockMeditationPageState();
}

class _MockMeditationPageState extends State<_MockMeditationPage> {
  bool _isPlaying = false;
  bool _isFinished = false;
  int _secondsRemaining = 5;

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _isPlaying = false;
          _isFinished = true;
        }
      });
      return _secondsRemaining > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.spa, color: Colors.green, size: 64),
              const Text('¡Sesión Completada!', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => setState(() { _isFinished = false; _secondsRemaining = 5; }), child: const Text('Cerrar')),
            ],
          ),
        ),
      );
    }

    if (_isPlaying) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meditando')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('00:0${_secondsRemaining.clamp(0, 9)}', style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sesiones de Meditación')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Relajación Profunda'),
            subtitle: const Text('5 minutos'),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {
              setState(() => _isPlaying = true);
              _startTimer();
            },
          ),
          const ListTile(title: Text('Manejo de Estrés'), subtitle: Text('10 minutos')),
        ],
      ),
    );
  }
}
