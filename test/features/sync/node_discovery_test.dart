import 'package:flutter_test/flutter_test.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/infrastructure/repositories/node_discovery_service.dart';

class MockBonsoirBroadcast extends Mock implements BonsoirBroadcast {}
class MockBonsoirDiscovery extends Mock implements BonsoirDiscovery {}

void main() {
  late NodeDiscoveryService discoveryService;

  setUp(() {
    discoveryService = NodeDiscoveryService();
  });

  test('discovery service initializes correctly', () {
    expect(discoveryService.currentNodes, isEmpty);
  });

  // Note: Testing actual mDNS on CI/headless environment is complex
  // as it requires a real network stack.
  // Here we verify the logic and service structure.
}
