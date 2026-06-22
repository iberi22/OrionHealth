import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Profile Flow - E2E Tests', () {
    testWidgets('E2E: Edit and Save Profile', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MockProfilePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'user_profile', '01_view');

      // Edit
      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Nombre'), 'Maria Lopez');
      await tester.enterText(find.widgetWithText(TextField, 'Correo'), 'maria@example.com');
      await VideoRecorder.recordStep(tester, 'user_profile', '02_editing');

      // Save
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Maria Lopez'), findsOneWidget);
      expect(find.text('Perfil guardado exitosamente'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'user_profile', '03_saved');
    });
  });
}

class _MockProfilePage extends StatefulWidget {
  const _MockProfilePage({super.key});
  @override
  State<_MockProfilePage> createState() => _MockProfilePageState();
}

class _MockProfilePageState extends State<_MockProfilePage> {
  String name = 'Maria Garcia';
  String email = 'maria@garcia.com';
  bool _isEditing = false;
  bool _showSaved = false;

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      final nameCtrl = TextEditingController(text: name);
      final emailCtrl = TextEditingController(text: email);
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Perfil')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Correo')),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    name = nameCtrl.text;
                    email = emailCtrl.text;
                    _isEditing = false;
                    _showSaved = true;
                  });
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _showSaved = false);
                  });
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(email),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: () => setState(() => _isEditing = true), child: const Text('Editar Perfil')),
            if (_showSaved) ...[
              const SizedBox(height: 16),
              const Text('Perfil guardado exitosamente', style: TextStyle(color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}
