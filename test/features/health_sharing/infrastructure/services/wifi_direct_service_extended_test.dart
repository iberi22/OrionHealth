import 'package:flutter/services.dart';
import 'package:fake_async/fake_async.dart';
import 'dart:async';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';

class FakeBonsoirDiscovery extends BonsoirDiscovery {
  final _eventController = StreamController<BonsoirDiscoveryEvent>.broadcast();
  bool initializeCalled = false;
  bool startCalled = false;
  bool stopCalled = false;

  FakeBonsoirDiscovery({required super.type});

  @override
  Stream<BonsoirDiscoveryEvent>? get eventStream => _eventController.stream;

  @override
  Future<void> initialize() async {
    initializeCalled = true;
  }

  @override
  Future<void> start() async {
    startCalled = true;
    _eventController.add(
      BonsoirDiscoveryServiceResolvedEvent(
        service: BonsoirService(
          name: 'Device 1',
          type: type,
          port: 9124,
          attributes: {'hostname': '192.168.1.10'},
        ),
      ),
    );
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
    _eventController.close();
  }
}

class FakeBonsoirBroadcast extends BonsoirBroadcast {
  bool initializeCalled = false;
  bool startCalled = false;
  bool stopCalled = false;

  FakeBonsoirBroadcast({required super.service});

  @override
  Future<void> initialize() async {
    initializeCalled = true;
  }

  @override
  Future<void> start() async {
    startCalled = true;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WifiDirectService service;
  const MethodChannel channel = MethodChannel('orionhealth/wifi_p2p');
  final List<MethodCall> log = <MethodCall>[];
  late FakeBonsoirDiscovery fakeDiscovery;
  late FakeBonsoirBroadcast fakeBroadcast;

  setUp(() {
    const bonsoirChannel = MethodChannel('fr.skyost.bonsoir');
    service = WifiDirectService(
      discoveryFactory: (type) {
        fakeDiscovery = FakeBonsoirDiscovery(type: type);
        return fakeDiscovery;
      },
      broadcastFactory: (s) {
        fakeBroadcast = FakeBonsoirBroadcast(service: s);
        return fakeBroadcast;
      },
    );
    log.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(bonsoirChannel, (
          MethodCall methodCall,
        ) async {
          log.add(methodCall);
          if (methodCall.method == 'BonsoirDiscoveryAction.initialize') {
            final id = methodCall.arguments['id'];
            final eventChannelName =
                'fr.skyost.bonsoir.BonsoirDiscoveryAction.$id';
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
                .setMockMethodCallHandler(MethodChannel(eventChannelName), (
                  MethodCall eventCall,
                ) async {
                  if (eventCall.method == 'listen') {
                    TestDefaultBinaryMessengerBinding
                        .instance
                        .defaultBinaryMessenger
                        .handlePlatformMessage(
                          eventChannelName,
                          const StandardMethodCodec().encodeSuccessEnvelope({
                            'id': 'discoveryServiceResolved',
                            'service': {
                              'service.name': 'Device 1',
                              'service.type': '_orion-health._tcp',
                              'service.port': 9124,
                              'service.hostname': '192.168.1.10',
                              'service.attributes': <String, dynamic>{},
                            },
                          }),
                          (ByteData? data) {},
                        );
                  }
                  return null;
                });
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('fr.skyost.bonsoir'),
          null,
        );
    await service.stop();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('WifiDirectService Extended', () {
    test('discoverDevices calls mdnsDiscover on fallback', () {
      fakeAsync((async) {
        List<WifiDirectDevice>? devices;

        service
            .discoverDevices(timeout: const Duration(milliseconds: 100))
            .then((v) => devices = v);

        async.elapse(const Duration(milliseconds: 150));

        expect(devices, isNotNull);
        expect(devices, isNotEmpty);
        expect(devices!.first.name, 'Device 1');
        expect(fakeDiscovery.initializeCalled, isTrue);
        expect(fakeDiscovery.startCalled, isTrue);
      });
    });

    test('startServer and stop lifecycle', () async {
      await service.startServer(port: 0);
      expect(service.serverAddress, isNotNull);
      expect(fakeBroadcast.initializeCalled, isTrue);
      expect(fakeBroadcast.startCalled, isTrue);

      await service.stop();
      expect(service.serverAddress, isNull);
      expect(fakeBroadcast.stopCalled, isTrue);
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
