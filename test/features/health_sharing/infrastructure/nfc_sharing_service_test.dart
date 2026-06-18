import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/nfc_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NfcSharingService service;
  const MethodChannel channel = MethodChannel('orionhealth/nfc');

  setUp(() {
    service = NfcSharingService();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isNfcAvailable') {
            return true;
          }
          if (methodCall.method == 'startNfcSession') {
            return null;
          }
          if (methodCall.method == 'stopNfcSession') {
            return null;
          }
          return null;
        });
  });

  group('NfcSharingService', () {
    test('initialize checks for NFC availability', () async {
      await service.initialize();
      expect(await service.isAvailable(), isFalse);
    });

    test('handleReceivedData emits received state and package', () async {
      await service.initialize();

      final package = SharedHealthPackage(
        id: 'id',
        senderNodeId: 's',
        recipientNodeId: 'r',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: const EncryptedPayload(
          encryptedData: '',
          iv: '',
          ephemeralPublicKey: '',
        ),
        metadata: const PackageMetadata(
          packageType: 'full',
          consentVerified: true,
          includedCategories: {},
          appVersion: '1.0.0',
        ),
        signature: '',
      );

      final encoded = package.encode();

      expectLater(
        service.stateStream,
        emits(
          predicate(
            (NfcSharingState s) =>
                s.status == 'received' && s.receivedPackage?.id == 'id',
          ),
        ),
      );
      expectLater(
        service.incomingData,
        emits(predicate((SharedHealthPackage p) => p.id == 'id')),
      );

      service.handleReceivedData(encoded);
    });

    test('handleReceivedData handles expired package', () async {
      await service.initialize();

      final package = SharedHealthPackage(
        id: 'id',
        senderNodeId: 's',
        recipientNodeId: 'r',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        payload: const EncryptedPayload(
          encryptedData: '',
          iv: '',
          ephemeralPublicKey: '',
        ),
        metadata: const PackageMetadata(
          packageType: 'full',
          consentVerified: true,
          includedCategories: {},
          appVersion: '1.0.0',
        ),
        signature: '',
      );

      final encoded = package.encode();

      expectLater(
        service.stateStream,
        emits(
          predicate(
            (NfcSharingState s) =>
                s.status == 'error' && s.message!.contains('expired'),
          ),
        ),
      );

      service.handleReceivedData(encoded);
    });
  });
}
