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
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/nfc_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';
import 'package:orionhealth_health/features/health_sharing/domain/usecases/start_sharing_usecase.dart';
import 'package:orionhealth_health/features/health_sharing/domain/usecases/start_listening_usecase.dart';
import 'package:orionhealth_health/features/health_sharing/domain/usecases/cancel_sharing_usecase.dart';
import 'package:health_wallet/health_wallet.dart' as wallet;
import 'utils/video_recorder.dart';

class MockBleSharingService extends Mock implements BleSharingService {}
class MockNfcSharingService extends Mock implements NfcSharingService {}
class MockWifiDirectService extends Mock implements WifiDirectService {}
class MockStartSharingUseCase extends Mock implements StartSharingUseCase {}
class MockStartListeningUseCase extends Mock implements StartListeningUseCase {}
class MockCancelSharingUseCase extends Mock implements CancelSharingUseCase {}
class MockWalletService extends Mock implements wallet.WalletService {}
class MockEncryptionService extends Mock implements wallet.EncryptionService {}

class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockBleSharingService mockBleService;
  late MockNfcSharingService mockNfcService;
  late MockWifiDirectService mockWifiService;
  late MockStartSharingUseCase mockStartSharingUseCase;
  late MockStartListeningUseCase mockStartListeningUseCase;
  late MockCancelSharingUseCase mockCancelSharingUseCase;
  late MockWalletService mockWalletService;
  late MockEncryptionService mockEncryptionService;

  late StreamController<BleSharingState> bleStateController;
  late StreamController<NfcSharingState> nfcStateController;
  late StreamController<WifiSharingState> wifiStateController;

  setUpAll(() async {
    await di.configureDependencies();
    registerFallbackValue(TransferMethod.nfc);
    registerFallbackValue(FakeSharedHealthPackage());
  });

  setUp(() {
    mockBleService = MockBleSharingService();
    mockNfcService = MockNfcSharingService();
    mockWifiService = MockWifiDirectService();
    mockStartSharingUseCase = MockStartSharingUseCase();
    mockStartListeningUseCase = MockStartListeningUseCase();
    mockCancelSharingUseCase = MockCancelSharingUseCase();
    mockWalletService = MockWalletService();
    mockEncryptionService = MockEncryptionService();

    bleStateController = StreamController<BleSharingState>.broadcast();
    nfcStateController = StreamController<NfcSharingState>.broadcast();
    wifiStateController = StreamController<WifiSharingState>.broadcast();

    when(() => mockBleService.initialize()).thenAnswer((_) async {});
    when(() => mockNfcService.initialize()).thenAnswer((_) async {});
    when(() => mockWifiService.initialize()).thenAnswer((_) async {});
    when(() => mockBleService.dispose()).thenAnswer((_) async {});
    when(() => mockNfcService.dispose()).thenAnswer((_) async {});
    when(() => mockWifiService.dispose()).thenAnswer((_) async {});

    when(() => mockBleService.stateStream).thenAnswer((_) => bleStateController.stream);
    when(() => mockNfcService.stateStream).thenAnswer((_) => nfcStateController.stream);
    when(() => mockWifiService.stateStream).thenAnswer((_) => wifiStateController.stream);

    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<BleSharingService>(mockBleService);
    di.getIt.registerSingleton<NfcSharingService>(mockNfcService);
    di.getIt.registerSingleton<WifiDirectService>(mockWifiService);
    di.getIt.registerSingleton<StartSharingUseCase>(mockStartSharingUseCase);
    di.getIt.registerSingleton<StartListeningUseCase>(mockStartListeningUseCase);
    di.getIt.registerSingleton<CancelSharingUseCase>(mockCancelSharingUseCase);
    di.getIt.registerSingleton<wallet.WalletService>(mockWalletService);
    di.getIt.registerSingleton<wallet.EncryptionService>(mockEncryptionService);
  });

  tearDown(() async {
    await bleStateController.close();
    await nfcStateController.close();
    await wifiStateController.close();
  });

  group('Health Sharing - True E2E UI Tests', () {
    testWidgets('E2E: Comprehensive Sharing Flow (BLE)', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      expect(find.text('Compartir Datos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '01_share_initial');

      await tester.tap(find.text('Laboratorios'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bluetooth'));
      await tester.pumpAndSettle();

      when(() => mockStartSharingUseCase(
        method: any(named: 'method'),
        package: any(named: 'package'),
        pin: any(named: 'pin'),
      )).thenAnswer((_) async {
        bleStateController.add(const BleSharingState(status: 'scanning'));
      });

      await tester.tap(find.text('Compartir'));
      await tester.pumpAndSettle();

      expect(find.text('Buscando dispositivos...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '02_sharing_scanning');

      // Simulate completion
      bleStateController.add(const BleSharingState(
        status: 'completed',
        bytesTransferred: 1024,
        transferTime: Duration(seconds: 2),
      ));
      await tester.pumpAndSettle();

      expect(find.text('¡Compartido exitosamente!'), findsOneWidget);
      expect(find.textContaining('1024 bytes transferidos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '03_share_success');

      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
    });

    testWidgets('E2E: Comprehensive Receiving Flow (NFC)', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      expect(find.text('Recibir Datos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '04_receive_initial');

      when(() => mockStartListeningUseCase(any(), pin: any(named: 'pin')))
          .thenAnswer((_) async {
        nfcStateController.add(const NfcSharingState(status: 'listening'));
      });

      await tester.tap(find.text('NFC'));
      await tester.pumpAndSettle();

      expect(find.text('Acerca los dispositivos para recibir...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '05_receive_waiting');

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

      nfcStateController.add(NfcSharingState(status: 'received', receivedPackage: mockPackage));
      await tester.pumpAndSettle();

      expect(find.text('Datos recibidos'), findsOneWidget);
      expect(find.text('De: Node-Alpha'), findsOneWidget);
      expect(find.text('• Laboratorios'), findsOneWidget);
      expect(find.text('• Signos Vitales'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '06_receive_preview');

      when(() => mockEncryptionService.decryptPayload(any(), any()))
          .thenAnswer((_) async => {'labs': []});
      when(() => mockWalletService.addLabResult(any())).thenAnswer((_) async => {});

      await tester.tap(find.text('Importar'));
      await tester.pump();

      nfcStateController.add(const NfcSharingState(
        status: 'completed',
        bytesTransferred: 512,
        transferTime: Duration(seconds: 1),
      ));
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

      when(() => mockStartSharingUseCase(
        method: any(named: 'method'),
        package: any(named: 'package'),
        pin: any(named: 'pin'),
      )).thenAnswer((_) async {
        bleStateController.add(const BleSharingState(status: 'scanning'));
      });

      await tester.tap(find.text('Laboratorios'));
      await tester.tap(find.text('Bluetooth'));
      await tester.tap(find.text('Compartir'));
      await tester.pumpAndSettle();

      expect(find.text('Buscando dispositivos...'), findsOneWidget);

      when(() => mockCancelSharingUseCase()).thenAnswer((_) async {});

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Compartir'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '08_share_cancelled');

      // Test Receive Rejection
      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      when(() => mockStartListeningUseCase(any(), pin: any(named: 'pin')))
          .thenAnswer((_) async {
        nfcStateController.add(const NfcSharingState(status: 'listening'));
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

      nfcStateController.add(NfcSharingState(status: 'received', receivedPackage: mockPackage));
      await tester.pumpAndSettle();

      expect(find.text('Datos recibidos'), findsOneWidget);

      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      expect(find.text('Datos recibidos'), findsNothing);
      expect(find.text('Acerca los dispositivos para recibir...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '09_receive_rejected');
    });
  });
}
