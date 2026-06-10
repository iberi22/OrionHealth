import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

void main() {
  // Note: tests marked with // NETWORK require actual WiFi Direct hardware
  // Run with --exclude-tags=network to skip.
  // Two tests below (transfer tests) are tagged 'network'.

  late WifiDirectService service;

  setUp(() {
    service = WifiDirectService();
  });

  tearDown(() async {
    await service.stop();
  });

  group('WifiDirectService', () {
    test('initial state is ready', () async {
      expectLater(service.stateStream, emits(predicate((WifiSharingState s) => s.status == 'ready')));
      await service.initialize();
    });

    test('discoverDevices updates state and returns devices', () async {
      await service.initialize();

      expectLater(service.stateStream, emitsThrough(predicate((WifiSharingState s) => s.status == 'discovering')));

      final devices = await service.discoverDevices(timeout: const Duration(milliseconds: 100));
      expect(devices, isNotEmpty);
      expect(devices.any((d) => d.name.contains('OrionHealth')), isTrue);
    });

    test('startServer updates state to hosting and uses IP', () async {
      await service.initialize();

      expectLater(service.stateStream, emitsThrough(predicate((WifiSharingState s) =>
        s.status == 'hosting' && s.address != null)));

      await service.startServer(port: 0);
      expect(service.serverAddress, isNotNull);
    });

    test('full transfer with PIN verification success', () async {
      // Requires real network
      await service.initialize();
      const pin = '1234';

      // Start server with PIN
      await service.startServer(port: 0, expectedPin: pin);
      final address = service.serverAddress!;

      final package = SharedHealthPackage(
        id: 'test',
        senderNodeId: 'sender',
        recipientNodeId: 'recipient',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(encryptedData: 'data', iv: 'iv', ephemeralPublicKey: 'key'),
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
    });

    test('transfer with PIN verification failure', () async {
      // Requires real network
      await service.initialize();

      // Start server with one PIN
      await service.startServer(port: 0, expectedPin: '1234');
      final address = service.serverAddress!;

      final package = SharedHealthPackage(
        id: 'test',
        senderNodeId: 'sender',
        recipientNodeId: 'recipient',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(encryptedData: 'data', iv: 'iv', ephemeralPublicKey: 'key'),
        metadata: PackageMetadata(
          packageType: 'full',
          consentVerified: true,
          includedCategories: {DataCategory.vitalSigns},
          appVersion: '1.0.0',
          pinHash: SharedHealthPackage.hashPin('9999'), // Wrong PIN
        ),
        signature: 'sig',
      );

      final result = await service.sendData(address, package);

      expect(result.success, isFalse);
      expect(result.error, contains('401'));
    });

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
