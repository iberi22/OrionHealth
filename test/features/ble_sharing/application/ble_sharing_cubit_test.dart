import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/ble_sharing/application/ble_sharing_cubit.dart';
import 'package:orionhealth_health/features/ble_sharing/domain/ble_sharing_service.dart';
import 'package:orionhealth_health/features/ble_sharing/infrastructure/nfc_sharing_service.dart';
import 'package:orionhealth_health/features/ble_sharing/infrastructure/wifi_direct_service.dart';

class MockBleSharingService extends Mock implements BleSharingService {}
class MockNfcSharingService extends Mock implements NfcSharingService {}
class MockWifiDirectService extends Mock implements WifiDirectService {}

void main() {
  late BleSharingCubit cubit;
  late MockBleSharingService mockBleService;
  late MockNfcSharingService mockNfcService;
  late MockWifiDirectService mockWifiService;

  final bleStateController = StreamController<BleServiceState>.broadcast();
  final nfcStateController = StreamController<NfcSharingState>.broadcast();
  final wifiStateController = StreamController<WifiServiceState>.broadcast();

  setUp(() {
    mockBleService = MockBleSharingService();
    mockNfcService = MockNfcSharingService();
    mockWifiService = MockWifiDirectService();

    when(() => mockBleService.initialize()).thenAnswer((_) async => {});
    when(() => mockNfcService.initialize()).thenAnswer((_) async => {});
    when(() => mockWifiService.initialize()).thenAnswer((_) async => {});

    when(() => mockBleService.stateStream).thenAnswer((_) => bleStateController.stream);
    when(() => mockNfcService.stateStream).thenAnswer((_) => nfcStateController.stream);
    when(() => mockWifiService.stateStream).thenAnswer((_) => wifiStateController.stream);

    when(() => mockBleService.dispose()).thenReturn(null);
    when(() => mockNfcService.dispose()).thenReturn(null);
    when(() => mockWifiService.dispose()).thenReturn(null);

    cubit = BleSharingCubit(
      bleService: mockBleService,
      nfcService: mockNfcService,
      wifiService: mockWifiService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('BleSharingCubit', () {
    test('initial state is BleSharingInitial', () {
      expect(cubit.state, BleSharingInitial());
    });

    test('initialize emits BleSharingReady', () async {
      await cubit.initialize();
      expect(cubit.state, BleSharingReady());
    });

    test('handle BLE scanning state', () async {
      await cubit.initialize();
      bleStateController.add(BleServiceState.scanning());

      await expectLater(
        cubit.stream,
        emits(const BleSharingScanning(MedicalTransferMethod.ble)),
      );
    });

    test('handle BLE connected state', () async {
      await cubit.initialize();
      bleStateController.add(BleServiceState.connected('device-123'));

      await expectLater(
        cubit.stream,
        emits(const BleSharingConnected(MedicalTransferMethod.ble, 'device-123')),
      );
    });

    test('handle BLE error state', () async {
      await cubit.initialize();
      bleStateController.add(BleServiceState.error('Failed to connect'));

      await expectLater(
        cubit.stream,
        emits(const BleSharingError('Failed to connect')),
      );
    });

    test('startSharing via BLE calls startAdvertising', () async {
      final package = MedicalSharePackage(
        id: '1',
        senderNodeId: 's',
        recipientNodeId: 'r',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now(),
        payload: const EncryptedMedicalPayload(cipherText: '', iv: '', authTag: ''),
        metadata: const MedicalShareMetadata(packageType: 'm', consentVerified: true, includedCategories: {}, appVersion: '1'),
        signature: '',
      );

      when(() => mockBleService.startAdvertising(any())).thenAnswer((_) async => {});

      await cubit.startSharing(method: MedicalTransferMethod.ble, package: package);

      verify(() => mockBleService.startAdvertising('r')).called(1);
    });

    test('cancelSharing stops all services', () async {
      when(() => mockBleService.disconnect()).thenAnswer((_) async => {});
      when(() => mockBleService.stopAdvertising()).thenAnswer((_) async => {});
      when(() => mockNfcService.stopListening()).thenAnswer((_) async => {});
      when(() => mockWifiService.stop()).thenAnswer((_) async => {});

      await cubit.cancelSharing();

      verify(() => mockBleService.disconnect()).called(1);
      verify(() => mockBleService.stopAdvertising()).called(1);
      verify(() => mockNfcService.stopListening()).called(1);
      verify(() => mockWifiService.stop()).called(1);
      expect(cubit.state, BleSharingReady());
    });
  });
}
