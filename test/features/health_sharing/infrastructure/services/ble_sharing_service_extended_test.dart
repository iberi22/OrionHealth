import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_wrapper.dart';

class MockBleWrapper extends Mock implements BleWrapper {}

void main() {
  late BleSharingService service;
  late MockBleWrapper mockBleWrapper;

  setUp(() {
    mockBleWrapper = MockBleWrapper();
    service = BleSharingService(mockBleWrapper);
  });

  group('BleSharingService Extended', () {
    test('startAdvertising initializes and calls wrapper', () async {
      when(() => mockBleWrapper.isSupported).thenAnswer((_) async => true);
      when(() => mockBleWrapper.startAdvertise(
            serviceUuid: any(named: 'serviceUuid'),
            localName: any(named: 'localName'),
            includePowerLevel: any(named: 'includePowerLevel'),
          )).thenAnswer((_) async => {});

      await service.startAdvertising('test-node');

      verify(() => mockBleWrapper.startAdvertise(
            serviceUuid: kOrionHealthServiceUuid,
            localName: 'test-node',
            includePowerLevel: true,
          )).called(1);
    });

    test('stopAdvertising calls wrapper', () async {
      when(() => mockBleWrapper.stopAdvertise()).thenAnswer((_) async => {});

      await service.stopAdvertising();

      verify(() => mockBleWrapper.stopAdvertise()).called(1);
    });
  });
}
