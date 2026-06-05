import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';

void main() {
  late WifiDirectService service;

  setUp(() {
    service = WifiDirectService();
  });

  group('WifiDirectService', () {
    test('initial state is ready', () async {
      expectLater(service.stateStream, emits(predicate((WifiSharingState s) => s.status == 'ready')));
      await service.initialize();
    });

    test('discoverDevices updates state', () async {
      await service.initialize();

      expectLater(service.stateStream, emits(predicate((WifiSharingState s) => s.status == 'discovering')));

      service.discoverDevices(timeout: const Duration(milliseconds: 100));
    });

    test('startServer updates state to hosting', () async {
      await service.initialize();

      expectLater(service.stateStream, emitsThrough(predicate((WifiSharingState s) =>
        s.status == 'hosting' && s.address != null)));

      // Using a random high port to avoid conflicts
      await service.startServer(port: 0);
    });
  });
}
