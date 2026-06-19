import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/receive_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:flutter/services.dart';
import '../../../../core/golden_test_utils.dart';

class MockSharingCubit extends Mock implements SharingCubit {}

class FakeSharedHealthPackage extends Fake implements SharedHealthPackage {}

void main() {
  late MockSharingCubit mockCubit;
  late StreamController<SharingState> stateController;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });

    registerFallbackValue(TransferMethod.nfc);
    registerFallbackValue(FakeSharedHealthPackage());
  });

  setUp(() async {
    GetIt.instance.reset();
    mockCubit = MockSharingCubit();
    stateController = StreamController<SharingState>.broadcast();

    // Register the mock using getIt from injection.dart
    getIt.registerSingleton<SharingCubit>(mockCubit);

    when(() => mockCubit.initialize()).thenAnswer((_) async => {});
    when(() => mockCubit.close()).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.state).thenReturn(SharingReady());
  });

  tearDown(() {
    stateController.close();
  });

  final testPackage = SharedHealthPackage(
    id: 'test-id',
    senderNodeId: 'sender-001',
    recipientNodeId: 'recipient-002',
    createdAt: DateTime(2024, 1, 1),
    expiresAt: DateTime(2024, 1, 1).add(const Duration(minutes: 5)),
    payload: const EncryptedPayload(
      encryptedData: 'data',
      iv: 'iv',
      ephemeralPublicKey: 'key',
    ),
    metadata: const PackageMetadata(
      packageType: 'selective',
      consentVerified: true,
      includedCategories: {DataCategory.labResults, DataCategory.vitalSigns},
      appVersion: '1.0.0',
    ),
    signature: 'sig',
  );

  group('Health Sharing Golden Tests', () {
    testWidgets('SharePage - Initial State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(SharingReady());

      await tester.pumpWidget(wrapWithMaterial(const SharePage()));
      await tester.pump();

      await expectLater(
        find.byType(SharePage),
        matchesGoldenFile("goldens/share_page_initial.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('SharePage - Scanning BLE', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const SharingScanning(TransferMethod.ble));

      await tester.pumpWidget(wrapWithMaterial(const SharePage()));
      await tester.pump();

      await expectLater(
        find.byType(SharePage),
        matchesGoldenFile("goldens/share_page_scanning_ble.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('SharePage - WiFi Discovery', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const SharingScanning(
        TransferMethod.wifi,
        devices: [
          WifiDirectDevice(name: 'Device A', address: '192.168.1.10'),
          WifiDirectDevice(name: 'Device B', address: '192.168.1.11'),
        ],
      ));

      await tester.pumpWidget(wrapWithMaterial(const SharePage()));
      await tester.pump();

      await expectLater(
        find.byType(SharePage),
        matchesGoldenFile("goldens/share_page_wifi_discovery.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('SharePage - Transferring', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const SharingTransferring(
        method: TransferMethod.wifi,
        progress: 0.6,
        message: 'Enviando registros médicos...',
      ));

      await tester.pumpWidget(wrapWithMaterial(const SharePage()));
      await tester.pump();

      await expectLater(
        find.byType(SharePage),
        matchesGoldenFile("goldens/share_page_transferring.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ReceivePage - Setup UI', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(SharingReady());

      await tester.pumpWidget(wrapWithMaterial(const ReceivePage()));
      await tester.pump();

      await expectLater(
        find.byType(ReceivePage),
        matchesGoldenFile("goldens/receive_page_setup.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ReceivePage - Waiting NFC', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const SharingScanning(TransferMethod.nfc));

      await tester.pumpWidget(wrapWithMaterial(const ReceivePage()));
      await tester.pump();

      if (find.text('NFC').evaluate().isNotEmpty) {
        await tester.tap(find.text('NFC'));
        await tester.pump();
      }

      await expectLater(
        find.byType(ReceivePage),
        matchesGoldenFile("goldens/receive_page_waiting_nfc.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ReceivePage - Data Preview Dialog', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(SharingReady());
      await tester.pumpWidget(wrapWithMaterial(const ReceivePage()));
      await tester.pump();

      final receivingState = SharingReceiving(
        package: testPackage,
        method: TransferMethod.wifi,
      );
      when(() => mockCubit.state).thenReturn(receivingState);
      stateController.add(receivingState);

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await expectLater(
        find.byType(AlertDialog),
        matchesGoldenFile("goldens/receive_page_data_preview.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
