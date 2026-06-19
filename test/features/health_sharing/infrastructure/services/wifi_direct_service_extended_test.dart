import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WifiDirectService service;
  const MethodChannel channel = MethodChannel('orionhealth/wifi_p2p');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    service = WifiDirectService();
    log.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'mdnsDiscover') {
        return [
          {'name': 'Device 1', 'address': '192.168.1.10:9124'},
        ];
      }
      return null;
    });
  });

  tearDown(() async {
    await service.stop();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('WifiDirectService Extended', () {
    test('discoverDevices calls mdnsDiscover on fallback', () async {
      // In CI (Linux), Platform.isAndroid/iOS is false, so it falls back to mDNS.
      final devices = await service.discoverDevices(
        timeout: const Duration(milliseconds: 100),
      );

      expect(devices, isNotEmpty);
      expect(devices.first.name, 'Device 1');
      expect(log.any((call) => call.method == 'mdnsDiscover'), isTrue);
    });

    test('startServer and stop lifecycle', () async {
      await service.startServer(port: 0);
      expect(service.serverAddress, isNotNull);

      await service.stop();
      expect(service.serverAddress, isNull);
    });

    test('initialize emits ready state', () async {
      final states = <WifiSharingState>[];
      final sub = service.stateStream.listen(states.add);

      await service.initialize();

      await Future.delayed(Duration.zero);
      expect(states.any((s) => s.status == 'ready'), isTrue);
      await sub.cancel();
    });
  });
}
