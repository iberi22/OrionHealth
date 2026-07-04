import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/receive_page.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockSharingCubit extends Mock implements SharingCubit {}

class FakeSharingState extends Fake implements SharingState {}

class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}

class FakeSharingResult extends Fake implements SharingResult {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSharingCubit mockCubit;
  late StreamController<SharingState> stateController;

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;

    registerFallbackValue(FakeSharingState());
    registerFallbackValue(TransferMethod.ble);
    registerFallbackValue(FakeSharedHealthPackage());
    registerFallbackValue(FakeSharingResult());
  });

  setUp(() {
    mockCubit = MockSharingCubit();
    stateController = StreamController<SharingState>.broadcast();

    when(() => mockCubit.initialize()).thenAnswer((_) async {});
    when(() => mockCubit.state).thenReturn(const SharingReady());
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.close()).thenAnswer((_) async {});

    di.getIt.registerSingleton<SharingCubit>(mockCubit);
  });

  tearDown(() {
    stateController.close();
    di.getIt.unregister<SharingCubit>();
  });

  group('Health Sharing E2E Tests', () {
    testWidgets('E2E: Full Share Flow', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      expect(find.text('Compartir Datos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '01_share_initial');

      // Select category
      await tester.tap(find.text('Laboratorios'));
      await tester.pumpAndSettle();

      // Select method
      await tester.tap(find.text('Bluetooth'));
      await tester.pumpAndSettle();

      // Mock start sharing transition
      when(() => mockCubit.startSharing(
            method: any(named: 'method'),
            package: any(named: 'package'),
            pin: any(named: 'pin'),
          )).thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.ble));
      });

      // Click share
      await tester.tap(find.text('Compartir'));
      await tester.pump();

      // Should show scanning UI
      expect(find.text('Buscando dispositivos...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '02_sharing_scanning');

      // Mock completion
      const result = SharingResult(
        success: true,
        bytesTransferred: 1024,
        transferTime: Duration(seconds: 2),
      );
      stateController.add(const SharingComplete(result, TransferMethod.ble));
      await tester.pumpAndSettle();

      // Success dialog
      expect(find.text('¡Compartido exitosamente!'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '03_share_success');

      // Close dialog
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
    });

    testWidgets('E2E: Full Receive Flow', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
      await tester.pumpAndSettle();

      expect(find.text('Recibir Datos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '04_receive_initial');

      // Select NFC
      when(() => mockCubit.startListening(any(), pin: any(named: 'pin')))
          .thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.nfc));
      });

      await tester.tap(find.text('NFC'));
      await tester.pumpAndSettle();

      // Waiting UI
      expect(find.text('Acerca los dispositivos para recibir...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '05_receive_waiting');

      // Mock receiving package
      final package = SharedHealthPackage(
        id: 'test-id',
        senderNodeId: 'sender-node',
        recipientNodeId: 'my-node',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(
          encryptedData: 'data',
          iv: 'iv',
          ephemeralPublicKey: 'key',
        ),
        metadata: const PackageMetadata(
          packageType: 'selective',
          consentVerified: true,
          includedCategories: {DataCategory.labResults},
          appVersion: '1.0.0',
        ),
        signature: 'sig',
      );

      stateController.add(SharingReceiving(package: package, method: TransferMethod.nfc));
      await tester.pumpAndSettle();

      // Preview dialog
      expect(find.text('Datos recibidos'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '06_receive_preview');

      // Import
      when(() => mockCubit.acceptIncomingPackage()).thenAnswer((_) async {
        const result = SharingResult(
          success: true,
          bytesTransferred: 512,
          transferTime: Duration(seconds: 1),
        );
        stateController.add(const SharingComplete(result, TransferMethod.nfc));
      });

      await tester.tap(find.text('Importar'));
      await tester.pumpAndSettle();

      // Success dialog
      expect(find.text('¡Importación completa!'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_sharing', '07_receive_success');

      // Close dialog
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
    });
  group('Navigation Edge Cases', () {
    testWidgets('E2E: Cancel sharing while scanning', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SharePage()));
      await tester.pumpAndSettle();

      // Start scanning
      when(() => mockCubit.startSharing(
            method: any(named: 'method'),
            package: any(named: 'package'),
            pin: any(named: 'pin'),
          )).thenAnswer((_) async {
        stateController.add(const SharingScanning(TransferMethod.ble));
      });

      await tester.tap(find.text('Laboratorios'));
      await tester.tap(find.text('Bluetooth'));
      await tester.tap(find.text('Compartir'));
      await tester.pump();

      expect(find.text('Buscando dispositivos...'), findsOneWidget);

      // Cancel
      when(() => mockCubit.cancelSharing()).thenAnswer((_) async {
        stateController.add(const SharingReady());
      });

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Compartir'), findsOneWidget);
    });
  });
  });
}
