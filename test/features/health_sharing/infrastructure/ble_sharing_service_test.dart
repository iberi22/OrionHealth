import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

void main() {
  late BleSharingService service;

  setUp(() {
    service = BleSharingService();
  });

  group('BleSharingService', () {
    test('initial state is not advertising or scanning', () async {
      expectLater(service.stateStream, emits(predicate((BleSharingState s) => s.status == 'ready')));
      await service.initialize();
    });

    test('startAdvertising updates state', () async {
      await service.initialize();

      expectLater(service.stateStream, emits(predicate((BleSharingState s) =>
        s.status == 'advertising' && s.deviceId == 'test-node')));

      service.startAdvertising('test-node');
    });

    test('connect updates state to connecting then connected', () async {
      await service.initialize();

      expectLater(service.stateStream, emitsThrough(predicate((BleSharingState s) =>
        s.status == 'connected' && s.deviceId == 'device-123')));

      service.connect('device-123');
    });

    test('sendData handles not connected state', () async {
      final package = SharedHealthPackage(
        id: 'id',
        senderNodeId: 's',
        recipientNodeId: 'r',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(encryptedData: '', iv: '', ephemeralPublicKey: ''),
        metadata: const PackageMetadata(
          packageType: 'full',
          consentVerified: true,
          includedCategories: {},
          appVersion: '1.0.0',
        ),
        signature: '',
      );

      final result = await service.sendData(package);
      expect(result.success, isFalse);
      expect(result.error, contains('Not connected'));
    });
  });
}
