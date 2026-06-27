import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Note: tests marked with // NETWORK require actual WiFi Direct hardware
  // Run with --exclude-tags=network to skip.
  // Two tests below (transfer tests) are tagged 'network'.

  late WifiDirectService service;
  const channel = MethodChannel('orionhealth/wifi_p2p');

  setUp(() {
    service = WifiDirectService();

    const bonsoirChannel = MethodChannel('fr.skyost.bonsoir');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(bonsoirChannel, (methodCall) async {
      switch (methodCall.method) {
        case 'discovery.initialize':
        case 'discovery.start':
        case 'discovery.stop':
        case 'broadcast.initialize':
        case 'broadcast.start':
        case 'broadcast.stop':
          return null;
        default:
          return null;
      }
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      if (methodCall.method == 'mdnsDiscover') {
        return [
          {'name': 'OrionHealth Test Device', 'address': '127.0.0.1:9124'},
        ];
      }
      return null;
    });
  });

  tearDown(() async {
    try {
      await service.stop();
    } catch (_) {}
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('fr.skyost.bonsoir'), null);
  });

  group('WifiDirectService', () {
    setUpAll(() {
      HttpOverrides.global = null;
    });

    test('initial state is ready', () async {
      expectLater(
        service.stateStream,
        emits(predicate((WifiSharingState s) => s.status == 'ready')),
      );
      await service.initialize();
    });

    test('discoverDevices updates state and returns devices', () async {
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
    });

    test('startServer updates state to hosting and uses IP', () async {
      await service.initialize();

      expectLater(
        service.stateStream,
        emitsThrough(
          predicate(
            (WifiSharingState s) => s.status == 'hosting' && s.address != null,
          ),
        ),
      );

      await service.startServer(port: 0);
      expect(service.serverAddress, isNotNull);
    });

    test(
      'full transfer with PIN verification success',
      () async {
        // Requires real network — skip in CI mode
        // Run with `flutter test` to execute
        await service.initialize();
        const pin = '1234';

        // Start server with PIN
        await service.startServer(port: 0);
        final address = service.serverAddress!;

        final package = SharedHealthPackage(
          id: 'test',
          senderNodeId: 'sender',
          recipientNodeId: 'recipient',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          payload: const EncryptedPayload(
            encryptedData: 'data',
            iv: 'iv',
            ephemeralPublicKey: 'key',
          ),
          metadata: PackageMetadata(
            packageType: 'full',
            consentVerified: true,
            includedCategories: {DataCategory.vitalSigns},
            appVersion: '1.0.0',
            pinHash: SharedHealthPackage.hashPin(pin),
          ),
          signature: 'sig',
        );

        // We expect the data to be received
        final dataFuture = service.incomingData.first;

        // Send data to self
        final result = await service.sendData(address, package);

        expect(result.success, isTrue);
        final receivedPackage = await dataFuture;
        expect(receivedPackage.id, 'test');
      },
    );

    test(
      'transfer with expired package failure',
      () async {
        await service.initialize();

        await service.startServer(port: 0);
        final address = service.serverAddress!;

        final package = SharedHealthPackage(
          id: 'test',
          senderNodeId: 'sender',
          recipientNodeId: 'recipient',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          expiresAt: DateTime.now().subtract(
            const Duration(minutes: 5),
          ), // Expired
          payload: const EncryptedPayload(
            encryptedData: 'data',
            iv: 'iv',
            ephemeralPublicKey: 'key',
          ),
          metadata: PackageMetadata(
            packageType: 'full',
            consentVerified: true,
            includedCategories: {DataCategory.vitalSigns},
            appVersion: '1.0.0',
          ),
          signature: 'sig',
        );

        final result = await service.sendData(address, package);

        expect(result.success, isFalse);
        expect(result.error, contains('410'));
      },
    );

    test('stop() resets state correctly', () async {
      await service.initialize();
      await service.startServer(port: 0);
      expect(service.serverAddress, isNotNull);

      await service.stop();
      expect(service.serverAddress, isNull);

      // Should be able to start again
      await service.startServer(port: 0);
      expect(service.serverAddress, isNotNull);
    });
  });
}
