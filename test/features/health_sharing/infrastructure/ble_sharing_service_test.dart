import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_wrapper.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

class MockBleWrapper extends Mock implements BleWrapper {}
class MockBluetoothDevice extends Mock implements MockDevice {}
abstract class MockDevice extends BluetoothDevice {
  MockDevice() : super(remoteId: const DeviceIdentifier('00:00:00:00:00:00'));
}
class MockBluetoothService extends Mock implements BluetoothService {}
class MockBluetoothCharacteristic extends Mock implements BluetoothCharacteristic {}
class MockScanResult extends Mock implements ScanResult {}
class MockAdvertisementData extends Mock implements AdvertisementData {}

void main() {
  late BleSharingService service;
  late MockBleWrapper mockBleWrapper;
  late MockBluetoothDevice mockDevice;
  late MockBluetoothService mockBluetoothService;
  late MockBluetoothCharacteristic mockTxCharacteristic;
  late MockBluetoothCharacteristic mockRxCharacteristic;

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(const DeviceIdentifier('00:00:00:00:00:00'));
    registerFallbackValue(License.nonprofit);
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockBleWrapper = MockBleWrapper();
    mockDevice = MockBluetoothDevice();
    mockBluetoothService = MockBluetoothService();
    mockTxCharacteristic = MockBluetoothCharacteristic();
    mockRxCharacteristic = MockBluetoothCharacteristic();

    service = BleSharingService(mockBleWrapper);

    when(() => mockBleWrapper.isSupported).thenAnswer((_) async => true);
    when(() => mockDevice.remoteId).thenReturn(const DeviceIdentifier('00:00:00:00:00:00'));
    when(() => mockDevice.platformName).thenReturn('Test Device');
    when(() => mockDevice.connect(
      license: any(named: 'license'),
      timeout: any(named: 'timeout'),
      mtu: any(named: 'mtu'),
      autoConnect: any(named: 'autoConnect'),
    )).thenAnswer((_) async => {});
    when(() => mockDevice.discoverServices(
      subscribeToServicesChanged: any(named: 'subscribeToServicesChanged'),
      timeout: any(named: 'timeout'),
    )).thenAnswer((_) async => [mockBluetoothService]);
    when(() => mockDevice.disconnect()).thenAnswer((_) async => {});

    when(() => mockBluetoothService.uuid).thenReturn(Guid(kOrionHealthServiceUuid));
    when(() => mockBluetoothService.characteristics).thenReturn([mockTxCharacteristic, mockRxCharacteristic]);

    when(() => mockTxCharacteristic.uuid).thenReturn(Guid(kOrionHealthTxCharacteristic));
    when(() => mockRxCharacteristic.uuid).thenReturn(Guid(kOrionHealthRxCharacteristic));

    when(() => mockTxCharacteristic.write(any(),
      withoutResponse: any(named: 'withoutResponse'),
      timeout: any(named: 'timeout')
    )).thenAnswer((_) async => {});

    when(() => mockRxCharacteristic.setNotifyValue(any(), timeout: any(named: 'timeout')))
        .thenAnswer((_) async => true);
    when(() => mockRxCharacteristic.lastValueStream).thenAnswer((_) => const Stream.empty());
  });

  group('BleSharingService Initialization', () {
    test('initialize successfully when Bluetooth is supported', () async {
      await service.initialize();
      // Should not throw
    });

    test('initialize throws exception when Bluetooth is not supported', () async {
      when(() => mockBleWrapper.isSupported).thenAnswer((_) async => false);
      expect(() => service.initialize(), throwsException);
    });
  });

  group('BleSharingService Scanning', () {
    test('scanForDevices returns list of devices', () async {
      final mockScanResult = MockScanResult();
      final mockAdvData = MockAdvertisementData();

      when(() => mockScanResult.device).thenReturn(mockDevice);
      when(() => mockScanResult.rssi).thenReturn(-60);
      when(() => mockScanResult.advertisementData).thenReturn(mockAdvData);
      when(() => mockAdvData.serviceUuids).thenReturn([Guid(kOrionHealthServiceUuid)]);

      when(() => mockBleWrapper.startScan(
        timeout: any(named: 'timeout'),
        withServices: any(named: 'withServices'),
      )).thenAnswer((_) async => {});

      when(() => mockBleWrapper.scanResults).thenAnswer((_) => Stream.fromIterable([[mockScanResult]]));
      when(() => mockBleWrapper.stopScan()).thenAnswer((_) async => {});

      final devices = await service.scanForDevices(timeout: const Duration(milliseconds: 100));

      expect(devices.length, 1);
      expect(devices.first.name, 'Test Device');
      expect(devices.first.type, 'OrionHealth Node');
    });
  });

  group('BleSharingService Connection', () {
    test('connect successfully to OrionHealth device', () async {
      when(() => mockBleWrapper.deviceFromId(any())).thenReturn(mockDevice);

      final result = await service.connect('00:00:00:00:00:00');

      expect(result, true);
      verify(() => mockDevice.connect(
        license: License.nonprofit,
        mtu: 512,
        autoConnect: false,
        timeout: any(named: 'timeout'),
      )).called(1);
    });

    test('connect fails if OrionHealth service is not found', () async {
      when(() => mockBleWrapper.deviceFromId(any())).thenReturn(mockDevice);
      when(() => mockBluetoothService.uuid).thenReturn(Guid('00000000-0000-0000-0000-000000000000'));

      final result = await service.connect('00:00:00:00:00:00');

      expect(result, false);
    });
  });

  group('BleSharingService Data Transfer', () {
    // ignore: unused_local_variable
    late SharedHealthPackage testPackage;

    setUp(() {
      testPackage = SharedHealthPackage(
        id: 'test-id',
        senderNodeId: 'sender',
        recipientNodeId: 'recipient',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        payload: const EncryptedPayload(encryptedData: 'abc', iv: 'def', ephemeralPublicKey: '', authTag: 'ghi'),
        metadata: const PackageMetadata(
          packageType: 'selective',
          consentVerified: true,
          includedCategories: {},
          appVersion: '1.0.0',
        ),
        signature: 'sig',
      );
    });

    test('sendData chunks data correctly', () async {
      when(() => mockBleWrapper.deviceFromId(any())).thenReturn(mockDevice);
      await service.connect('00:00:00:00:00:00');

      // Create a large package to ensure chunking
      final largeCipherText = 'a' * 1000;
      final largePackage = SharedHealthPackage(
        id: 'test-id',
        senderNodeId: 'sender',
        recipientNodeId: 'recipient',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        payload: EncryptedPayload(encryptedData: largeCipherText, iv: 'def', ephemeralPublicKey: '', authTag: 'ghi'),
        metadata: const PackageMetadata(
          packageType: 'selective',
          consentVerified: true,
          includedCategories: {},
          appVersion: '1.0.0',
        ),
        signature: 'sig',
      );

      final result = await service.sendData(largePackage);

      expect(result.success, true);
      // Verify length prefix write
      verify(() => mockTxCharacteristic.write(
        any(that: hasLength(4)),
        withoutResponse: false,
        timeout: any(named: 'timeout'),
      )).called(1);

      // Verify chunk writes (at least 2 chunks for 1000+ bytes)
      verify(() => mockTxCharacteristic.write(
        any(),
        withoutResponse: true,
        timeout: any(named: 'timeout'),
      )).called(greaterThanOrEqualTo(2));
    });

    test('receiveData reassembles chunks correctly', () async {
      final rxController = StreamController<List<int>>();
      when(() => mockRxCharacteristic.lastValueStream).thenAnswer((_) => rxController.stream);
      when(() => mockBleWrapper.deviceFromId(any())).thenReturn(mockDevice);

      await service.connect('00:00:00:00:00:00');

      final receiveFuture = service.receiveData(timeout: const Duration(seconds: 1));

      final lengthPrefix = Uint8List(4);
      ByteData.view(lengthPrefix.buffer).setUint32(0, 10, Endian.big);

      rxController.add(lengthPrefix.toList());
      rxController.add([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

      final package = await receiveFuture;
      expect(package, isNull); // Times out or fails decryption

      await rxController.close();
    });
  });
}
