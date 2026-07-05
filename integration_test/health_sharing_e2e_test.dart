import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/receive_page.dart';
import 'utils/video_recorder.dart';

class MockSharingCubit extends Mock implements SharingCubit {}

class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}
class FakeSharingResult extends Fake implements SharingResult {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSharingCubit mockSharingCubit;
  late StreamController<SharingState> stateController;

  setUpAll(() async {
    await di.configureDependencies();
    registerFallbackValue(TransferMethod.nfc);
    registerFallbackValue(FakeSharedHealthPackage());
    registerFallbackValue(FakeSharingResult());
  });

  setUp(() {
    mockSharingCubit = MockSharingCubit();
    stateController = StreamController<SharingState>.broadcast();

    when(() => mockSharingCubit.state).thenReturn(const SharingInitial());
    when(() => mockSharingCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockSharingCubit.initialize()).thenAnswer((_) async {
      stateController.add(const SharingReady());
    });
    when(() => mockSharingCubit.close()).thenAnswer((_) async {
      await stateController.close();
    });

    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<SharingCubit>(mockSharingCubit);
  });

  group('Health Sharing - E2E UI Tests', () {
    testWidgets('E2E: Comprehensive Sharing Flow', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      expect(find.text('Compartir Datos'), findsOneWidget);
      expect(find.text('Selecciona datos a compartir'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '01_share_initial');

      // Select category and method
      await tester.tap(find.text('Laboratorios'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bluetooth'));
      await tester.pumpAndSettle();

      // Start sharing
      when(() => mockSharingCubit.startSharing(
        method: any(named: 'method'),
        package: any(named: 'package'),
        pin: any(named: 'pin'),
      )).thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.ble));
      });

      await tester.tap(find.text('Compartir'));
      await tester.pumpAndSettle();

      expect(find.text('Buscando dispositivos...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '02_sharing_scanning');

      // Simulate completion
      stateController.add(const SharingComplete(
        SharingResult(success: true, bytesTransferred: 1024, transferTime: Duration(seconds: 2)),
        TransferMethod.ble,
      ));
      await tester.pumpAndSettle();

      expect(find.text('¡Compartido exitosamente!'), findsOneWidget);
      expect(find.textContaining('1024 bytes transferidos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '03_share_success');

      // Close dialog
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
      expect(find.text('¡Compartido exitosamente!'), findsNothing);
    });

    testWidgets('E2E: Comprehensive Receiving Flow', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      expect(find.text('Recibir Datos'), findsOneWidget);
      expect(find.text('Configurar recepción'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '04_receive_initial');

      // Select NFC
      when(() => mockSharingCubit.startListening(any(), pin: any(named: 'pin')))
          .thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.nfc));
      });

      await tester.tap(find.text('NFC'));
      await tester.pumpAndSettle();

      expect(find.text('Acerca los dispositivos para recibir...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '05_receive_waiting');

      // Simulate receiving package
      final mockPackage = SharedHealthPackage(
        id: 'pkg-123',
        senderNodeId: 'Node-Alpha',
        recipientNodeId: 'MyNode',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(encryptedData: 'data', iv: 'iv', ephemeralPublicKey: 'key'),
        metadata: const PackageMetadata(
          packageType: 'selective',
          consentVerified: true,
          includedCategories: {DataCategory.labResults, DataCategory.vitalSigns},
          appVersion: '1.0.0',
        ),
        signature: 'sig',
      );

      stateController.add(SharingReceiving(package: mockPackage, method: TransferMethod.nfc));
      await tester.pumpAndSettle();

      expect(find.text('Datos recibidos'), findsOneWidget);
      expect(find.text('De: Node-Alpha'), findsOneWidget);
      expect(find.text('• Laboratorios'), findsOneWidget);
      expect(find.text('• Signos Vitales'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '06_receive_preview');

      // Accept and complete
      when(() => mockSharingCubit.acceptIncomingPackage()).thenAnswer((_) async {
        stateController.add(const SharingComplete(
          SharingResult(success: true, bytesTransferred: 512, transferTime: Duration(seconds: 1)),
          TransferMethod.nfc,
        ));
      });

      await tester.tap(find.text('Importar'));
      await tester.pumpAndSettle();

      expect(find.text('¡Importación completa!'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '07_receive_success');

      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
    });

    testWidgets('E2E: Cancellation and Rejection', (tester) async {
      // Test Share Cancellation
      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      when(() => mockSharingCubit.startSharing(
        method: any(named: 'method'),
        package: any(named: 'package'),
        pin: any(named: 'pin'),
      )).thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.ble));
      });

      await tester.tap(find.text('Laboratorios'));
      await tester.tap(find.text('Bluetooth'));
      await tester.tap(find.text('Compartir'));
      await tester.pumpAndSettle();

      expect(find.text('Buscando dispositivos...'), findsOneWidget);

      when(() => mockSharingCubit.cancelSharing()).thenAnswer((_) async {
        stateController.add(const SharingReady());
      });

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Compartir'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '08_share_cancelled');

      // Test Receive Rejection
      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      when(() => mockSharingCubit.startListening(any(), pin: any(named: 'pin')))
          .thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.nfc));
      });

      await tester.tap(find.text('NFC'));
      await tester.pumpAndSettle();

      final mockPackage = SharedHealthPackage(
        id: 'pkg-123',
        senderNodeId: 'Node-Alpha',
        recipientNodeId: 'MyNode',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(encryptedData: 'data', iv: 'iv', ephemeralPublicKey: 'key'),
        metadata: const PackageMetadata(
          packageType: 'selective',
          consentVerified: true,
          includedCategories: {DataCategory.labResults},
          appVersion: '1.0.0',
        ),
        signature: 'sig',
      );

      stateController.add(SharingReceiving(package: mockPackage, method: TransferMethod.nfc));
      await tester.pumpAndSettle();

      expect(find.text('Datos recibidos'), findsOneWidget);

      when(() => mockSharingCubit.rejectIncomingPackage()).thenReturn(null);

      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      expect(find.text('Datos recibidos'), findsNothing);
      expect(find.text('Acerca los dispositivos para recibir...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '09_receive_rejected');
    });
  });
}
