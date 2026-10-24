import re

with open('test/features/health_sharing/infrastructure/wifi_direct_service_test.dart', 'r') as f:
    content = f.read()

# Make discoverDevices not time out by fixing the test block
test1_old = """    test('discoverDevices updates state and returns devices', () async {
      await service.initialize();

      expectLater(
        service.stateStream,
        emitsThrough(
          predicate((WifiSharingState s) => s.status == 'discovering'),
        ),
      );

      final devices = await service.discoverDevices(
        timeout: const Duration(milliseconds: 100),
      );
      expect(devices, isNotEmpty);
      expect(devices.any((d) => d.name.contains('OrionHealth')), isTrue);
    });"""

test1_new = """    test('discoverDevices updates state and returns devices', () {
      fakeAsync((async) {
        service.initialize();

        expectLater(
          service.stateStream,
          emitsThrough(
            predicate((WifiSharingState s) => s.status == 'discovering'),
          ),
        );

        final devicesFuture = service.discoverDevices(
          timeout: const Duration(milliseconds: 100),
        );

        // Advance to trigger timeout or discovery block
        async.elapse(const Duration(milliseconds: 100));

        final devices = async.run((_) => devicesFuture);

        // Mock handler actually receives 'discovery.start', but we have no way to cleanly push an event
        // wait, we can just let it time out and check devices?
        // No, expect(devices, isNotEmpty);
      });
    });"""

# We actually need to push an event. Let's see.
# Bonsoir uses an EventChannel called 'fr.skyost.bonsoir.discovery'.
# In the test we can mock it via TestDefaultBinaryMessengerBinding

test1_new2 = """    test('discoverDevices updates state and returns devices', () async {
      await service.initialize();

      expectLater(
        service.stateStream,
        emitsThrough(
          predicate((WifiSharingState s) => s.status == 'discovering'),
        ),
      );

      const channel = EventChannel('fr.skyost.bonsoir.discovery');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(channel, _MockStreamHandler());

      final devices = await service.discoverDevices(
        timeout: const Duration(milliseconds: 100),
      );
      expect(devices, isNotEmpty);
      expect(devices.any((d) => d.name.contains('OrionHealth')), isTrue);
    });"""

if test1_old in content:
    content = content.replace(test1_old, test1_new2)

mock_stream_handler = """
class _MockStreamHandler extends MockStreamHandler {
  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    events.success({
      'id': 'discovery',
      'event': 'discoveryServiceResolved',
      'service': {
        'service.name': 'OrionHealth Test Device',
        'service.type': '_orion-health._tcp',
        'service.host': '127.0.0.1',
        'service.port': 9124,
        'service.attributes': {},
      }
    });
  }

  @override
  void onCancel(Object? arguments) {}
}
"""

if "_MockStreamHandler" not in content:
    content = content + mock_stream_handler

with open('test/features/health_sharing/infrastructure/wifi_direct_service_test.dart', 'w') as f:
    f.write(content)
