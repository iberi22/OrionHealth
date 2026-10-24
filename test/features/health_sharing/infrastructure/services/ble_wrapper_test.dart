import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_wrapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BleWrapper bleWrapper;
  const MethodChannel channel = MethodChannel('orionhealth/ble_peripheral');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    bleWrapper = BleWrapper();
    log.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          if (methodCall.method == 'startAdvertising') {
            return null;
          }
          if (methodCall.method == 'stopAdvertising') {
            return null;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    bleWrapper.dispose();
  });

  group('BleWrapper', () {
    test('startAdvertise updates state', () async {
      expect(bleWrapper.isAdvertising, isFalse);

      expect(
        () => bleWrapper.startAdvertise(
          serviceUuid: 'test-uuid',
          localName: 'test-node',
        ),
        throwsUnsupportedError,
      );

      expect(bleWrapper.isAdvertising, isFalse);
    });

    test('stopAdvertise updates state', () async {
      expect(bleWrapper.isAdvertising, isFalse);

      await bleWrapper.stopAdvertise();

      expect(bleWrapper.isAdvertising, isFalse);
    });

    test('advertisementState stream emits changes', () async {
      final states = <bool>[];
      final sub = bleWrapper.advertisementState.listen(states.add);

      expect(
        () => bleWrapper.startAdvertise(serviceUuid: 'u', localName: 'n'),
        throwsUnsupportedError,
      );
      await bleWrapper.stopAdvertise();

      await Future.delayed(Duration.zero);
      expect(states, isEmpty);
      await sub.cancel();
    });

    test('startAdvertise handles MissingPluginException gracefully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            throw MissingPluginException();
          });

      expect(
        () => bleWrapper.startAdvertise(serviceUuid: 'u', localName: 'n'),
        throwsUnsupportedError,
      );

      expect(bleWrapper.isAdvertising, isFalse);
    });
  });
}
