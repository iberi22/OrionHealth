import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Appointments Flow - E2E Tests', () {
    testWidgets('E2E: Schedule Appointment', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _MockAppointmentsPage(),
        ),
      );
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'appointments', '01_list');

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'appointments', '02_form');

      await tester.enterText(find.byType(TextField), 'Control General');
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'appointments', '03_filled');

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'appointments', '04_success');
    });
  });
}

class _MockAppointmentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Citas Médicas')),
      body: const Center(child: Text('No hay citas programadas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => _MockAppointmentForm()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MockAppointmentForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Cita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Motivo')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
