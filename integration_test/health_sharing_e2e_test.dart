import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/receive_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockSharingCubit extends Mock implements SharingCubit {}

class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSharingCubit mockSharingCubit;
  late StreamController<SharingState> stateController;

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;
    registerFallbackValue(TransferMethod.ble);
    registerFallbackValue(FakeSharedHealthPackage());
  });

  setUp(() {
    mockSharingCubit = MockSharingCubit();
    stateController = StreamController<SharingState>.broadcast();

    // Actually we need a way to get current state or just mock the stream
    when(() => mockSharingCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockSharingCubit.state).thenReturn(const SharingInitial());
    when(() => mockSharingCubit.initialize()).thenAnswer((_) async {});
    when(() => mockSharingCubit.close()).thenAnswer((_) async {});

    di.getIt.registerSingleton<SharingCubit>(mockSharingCubit);
  });

  tearDown(() {
    stateController.close();
  });

  group('Health Sharing - E2E Tests', () {

    testWidgets('E2E: Share flow from selection to completion', (tester) async {
      when(() => mockSharingCubit.state).thenReturn(const SharingReady());
      stateController.add(const SharingReady());

      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      expect(find.text('Compartir Datos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '01_share_initial');

      // Select category (Laboratorios is hardcoded in DataCategory.labResults)
      await tester.tap(find.text('Laboratorios'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 categorías seleccionadas'), findsOneWidget);

      // Select method (Bluetooth is TransferMethod.ble)
      await tester.tap(find.text('Bluetooth'));
      await tester.pumpAndSettle();

      // Mock startSharing
      when(() => mockSharingCubit.startSharing(
        method: any(named: 'method'),
        package: any(named: 'package'),
        pin: any(named: 'pin'),
      )).thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.ble));
      });

      // Click share
      await tester.tap(find.text('Compartir'));

      // Manually emit state since we mocked the call
      stateController.add(const SharingScanning(TransferMethod.ble));
      when(() => mockSharingCubit.state).thenReturn(const SharingScanning(TransferMethod.ble));
      await tester.pump();

      expect(find.text('Buscando dispositivos...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '02_sharing_scanning');

      // Transition to transferring
      stateController.add(const SharingTransferring(
        method: TransferMethod.ble,
        progress: 0.5,
        message: 'Enviando datos...',
      ));
      when(() => mockSharingCubit.state).thenReturn(const SharingTransferring(
        method: TransferMethod.ble,
        progress: 0.5,
        message: 'Enviando datos...',
      ));
      await tester.pump();
      expect(find.text('Enviando datos...'), findsOneWidget);

      // Complete
      final result = const SharingResult(success: true, bytesTransferred: 1024, transferTime: Duration(seconds: 2));
      stateController.add(SharingComplete(result, TransferMethod.ble));
      when(() => mockSharingCubit.state).thenReturn(SharingComplete(result, TransferMethod.ble));
      await tester.pumpAndSettle();

      expect(find.text('¡Compartido exitosamente!'), findsOneWidget);
      expect(find.textContaining('1024 bytes transferidos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '03_share_complete');

      // Close dialog
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
    });

    testWidgets('E2E: Share flow cancellation', (tester) async {
      when(() => mockSharingCubit.state).thenReturn(const SharingReady());
      stateController.add(const SharingReady());

      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Laboratorios'));
      await tester.pumpAndSettle();

      when(() => mockSharingCubit.startSharing(
        method: any(named: 'method'),
        package: any(named: 'package'),
        pin: any(named: 'pin'),
      )).thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.nfc));
      });

      await tester.tap(find.text('Compartir'));

      stateController.add(const SharingScanning(TransferMethod.nfc));
      when(() => mockSharingCubit.state).thenReturn(const SharingScanning(TransferMethod.nfc));
      await tester.pump();

      expect(find.text('Buscando dispositivos...'), findsOneWidget);

      // Cancel
      when(() => mockSharingCubit.cancelSharing()).thenAnswer((_) async {
        stateController.add(const SharingReady());
      });

      await tester.tap(find.text('Cancelar'));

      stateController.add(const SharingReady());
      when(() => mockSharingCubit.state).thenReturn(const SharingReady());
      await tester.pumpAndSettle();

      expect(find.text('Compartir'), findsOneWidget);
    });

    testWidgets('E2E: Receive flow from setup to import', (tester) async {
      when(() => mockSharingCubit.state).thenReturn(const SharingReady());
      stateController.add(const SharingReady());

      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      expect(find.text('Recibir Datos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '04_receive_setup');

      // Start listening via NFC
      when(() => mockSharingCubit.startListening(TransferMethod.nfc, pin: any(named: 'pin')))
          .thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.nfc));
      });

      await tester.tap(find.text('NFC'));

      stateController.add(const SharingScanning(TransferMethod.nfc));
      when(() => mockSharingCubit.state).thenReturn(const SharingScanning(TransferMethod.nfc));
      await tester.pumpAndSettle();

      expect(find.textContaining('Acerca los dispositivos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '05_waiting_nfc');

      // Simulate receiving a package
      final package = SharedHealthPackage(
        id: 'test-id',
        senderNodeId: 'remote-node',
        recipientNodeId: 'my-node',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(encryptedData: 'abc', iv: 'iv', ephemeralPublicKey: 'pk'),
        metadata: const PackageMetadata(
          packageType: 'selective',
          consentVerified: true,
          includedCategories: {DataCategory.labResults},
          appVersion: '1.0.0',
        ),
        signature: 'sig',
      );

      stateController.add(SharingReceiving(package: package, method: TransferMethod.nfc));
      when(() => mockSharingCubit.state).thenReturn(SharingReceiving(package: package, method: TransferMethod.nfc));
      await tester.pumpAndSettle();

      expect(find.text('Datos recibidos'), findsOneWidget);
      expect(find.text('• Laboratorios'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '06_receive_preview');

      // Accept package
      when(() => mockSharingCubit.acceptIncomingPackage()).thenAnswer((_) async {
        stateController.add(SharingComplete(
          const SharingResult(success: true, bytesTransferred: 3, transferTime: Duration(seconds: 1)),
          TransferMethod.nfc,
        ));
      });

      await tester.tap(find.text('Importar'));

      stateController.add(SharingComplete(
        const SharingResult(success: true, bytesTransferred: 3, transferTime: Duration(seconds: 1)),
        TransferMethod.nfc,
      ));
      when(() => mockSharingCubit.state).thenReturn(SharingComplete(
        const SharingResult(success: true, bytesTransferred: 3, transferTime: Duration(seconds: 1)),
        TransferMethod.nfc,
      ));
      await tester.pumpAndSettle();

      expect(find.text('¡Importación completa!'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '07_receive_complete');

      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
    });

    testWidgets('E2E: Receive flow rejection', (tester) async {
      when(() => mockSharingCubit.state).thenReturn(const SharingReady());
      stateController.add(const SharingReady());

      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      when(() => mockSharingCubit.startListening(TransferMethod.ble, pin: any(named: 'pin')))
          .thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.ble));
      });

      await tester.tap(find.text('Bluetooth'));

      stateController.add(const SharingScanning(TransferMethod.ble));
      when(() => mockSharingCubit.state).thenReturn(const SharingScanning(TransferMethod.ble));
      await tester.pumpAndSettle();

      final package = SharedHealthPackage(
        id: 'test-id',
        senderNodeId: 'remote-node',
        recipientNodeId: 'my-node',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(encryptedData: 'abc', iv: 'iv', ephemeralPublicKey: 'pk'),
        metadata: const PackageMetadata(
          packageType: 'selective',
          consentVerified: true,
          includedCategories: {DataCategory.medications},
          appVersion: '1.0.0',
        ),
        signature: 'sig',
      );

      stateController.add(SharingReceiving(package: package, method: TransferMethod.ble));
      when(() => mockSharingCubit.state).thenReturn(SharingReceiving(package: package, method: TransferMethod.ble));
      await tester.pumpAndSettle();

      expect(find.text('Datos recibidos'), findsOneWidget);

      // Reject package
      when(() => mockSharingCubit.rejectIncomingPackage()).thenReturn(null);
      // SharingCubit.rejectIncomingPackage() emits SharingReady()

      await tester.tap(find.text('Rechazar'));

      stateController.add(const SharingReady());
      when(() => mockSharingCubit.state).thenReturn(const SharingReady());
      await tester.pumpAndSettle();

      expect(find.text('Recibir Datos'), findsOneWidget);
    });
  });
}
