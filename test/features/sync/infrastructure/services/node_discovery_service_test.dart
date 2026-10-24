import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/node_discovery_service.dart';

class FakeBonsoirBroadcast extends BonsoirBroadcast {
  bool isInitialized = false;
  bool isStarted = false;

  FakeBonsoirBroadcast({required super.service});

  @override
  Future<void> initialize() async {
    isInitialized = true;
  }

  @override
  Future<void> start() async {
    isStarted = true;
  }
}

class FakeBonsoirDiscovery extends BonsoirDiscovery {
  bool isInitialized = false;
  bool isStarted = false;

  final StreamController<BonsoirDiscoveryEvent> _controller =
      StreamController<BonsoirDiscoveryEvent>.broadcast();

  FakeBonsoirDiscovery({required super.type});

  @override
  Future<void> initialize() async {
    isInitialized = true;
  }

  @override
  Future<void> start() async {
    isStarted = true;
  }

  @override
  Stream<BonsoirDiscoveryEvent>? get eventStream => _controller.stream;

  void simulateEvent(BonsoirDiscoveryEvent event) {
    _controller.add(event);
  }
}

void main() {
  late NodeDiscoveryService discoveryService;
  late FakeBonsoirBroadcast fakeBroadcast;
  late FakeBonsoirDiscovery fakeDiscovery;

  setUp(() {
    discoveryService = NodeDiscoveryService(
      broadcastFactory: (service) {
        fakeBroadcast = FakeBonsoirBroadcast(service: service);
        return fakeBroadcast;
      },
      discoveryFactory: (type) {
        fakeDiscovery = FakeBonsoirDiscovery(type: type);
        return fakeDiscovery;
      },
    );
  });

  test(
    'discovery service calls initialize before start for broadcast and discovery',
    () async {
      await discoveryService.start('test-node-id', 8080);

      expect(fakeBroadcast.isInitialized, isTrue);
      expect(fakeBroadcast.isStarted, isTrue);

      expect(fakeDiscovery.isInitialized, isTrue);
      expect(fakeDiscovery.isStarted, isTrue);
    },
  );

  test('discovery service adds and removes node on events', () async {
    await discoveryService.start('test-node-id', 8080);

    expect(discoveryService.currentNodes, isEmpty);

    // Simulate resolved event
    final mockService = BonsoirService(
      name: 'OrionNode-other-node',
      type: '_orion-sync._tcp',
      port: 8080,
      attributes: {'nodeId': 'other-node'},
    );

    fakeDiscovery.simulateEvent(
      BonsoirDiscoveryEvent(
        type: BonsoirDiscoveryEventType.discoveryServiceResolved,
        service: mockService,
      ),
    );

    await Future.delayed(Duration.zero);

    expect(discoveryService.currentNodes, hasLength(1));
    expect(discoveryService.currentNodes.first.id, 'other-node');
    expect(discoveryService.currentNodes.first.name, 'OrionNode-other-node');

    // Simulate lost event
    fakeDiscovery.simulateEvent(
      BonsoirDiscoveryEvent(
        type: BonsoirDiscoveryEventType.discoveryServiceLost,
        service: mockService,
      ),
    );

    await Future.delayed(Duration.zero);

    expect(discoveryService.currentNodes, isEmpty);
  });
}
