import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings Flow - E2E Tests', () {
    testWidgets('E2E: Settings Interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MockSettingsPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'settings', '01_main');

      // Theme toggle
      await tester.tap(find.text('Modo Oscuro'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'settings', '02_theme_toggled');

      // Language selection
      await tester.tap(find.text('Idioma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Language'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'settings', '03_language_changed');

      // Notifications
      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'settings', '04_notifications_toggled');
    });
  });
}

class _MockSettingsPage extends StatefulWidget {
  const _MockSettingsPage({super.key});
  @override
  State<_MockSettingsPage> createState() => _MockSettingsPageState();
}

class _MockSettingsPageState extends State<_MockSettingsPage> {
  bool _dark = false;
  bool _en = false;
  bool _notifs = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _dark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(title: Text(_en ? 'Settings' : 'Configuración')),
        body: ListView(
          children: [
            SwitchListTile(
              title: Text(_en ? 'Dark Mode' : 'Modo Oscuro'),
              value: _dark,
              onChanged: (v) => setState(() => _dark = v),
            ),
            ListTile(
              title: Text(_en ? 'Language' : 'Idioma'),
              subtitle: Text(_en ? 'English' : 'Español'),
              onTap: () => _showLangPicker(),
            ),
            SwitchListTile(
              title: Text(_en ? 'Notifications' : 'Notificaciones'),
              value: _notifs,
              onChanged: (v) => setState(() => _notifs = v),
            ),
          ],
        ),
      ),
    );
  }

  void _showLangPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text('Español'), onTap: () { setState(() => _en = false); Navigator.pop(context); }),
          ListTile(title: const Text('English'), onTap: () { setState(() => _en = true); Navigator.pop(context); }),
        ],
      ),
    );
  }
}
