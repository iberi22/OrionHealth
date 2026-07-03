import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/receive_page.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // We keep real DI but might need to mock SharingCubit for specific network behaviors
    await di.configureDependencies();
  });

  group('Health Sharing - Real UI Integration Tests', () {

    testWidgets('E2E: Share page selection and start', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      expect(find.text('Compartir Datos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '01_share_initial');

      // Select category
      await tester.tap(find.text('Laboratorios'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 categorías seleccionadas'), findsOneWidget);

      // Select method
      await tester.tap(find.text('Bluetooth'));
      await tester.pumpAndSettle();

      // Click share
      await tester.tap(find.text('Compartir'));
      await tester.pump();

      // Should show transferring UI (searching)
      expect(find.text('Buscando dispositivos...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '02_sharing_in_progress');

      // Cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Compartir'), findsOneWidget);
    });

    testWidgets('E2E: Receive page setup', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      expect(find.text('Recibir Datos'), findsOneWidget);
      expect(find.text('WiFi Direct'), findsOneWidget);
      expect(find.text('NFC'), findsOneWidget);
      expect(find.text('Bluetooth'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '03_receive_setup');

      // Select NFC
      await tester.tap(find.text('NFC'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Acerca los dispositivos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '04_waiting_nfc');
    });
  });
}
