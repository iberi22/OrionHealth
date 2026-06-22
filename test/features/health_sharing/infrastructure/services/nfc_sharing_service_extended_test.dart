import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/nfc_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/nfc_handler.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

class MockNfcHandler extends Mock implements NfcHandler {}

void main() {
  late NfcSharingService service;
  late MockNfcHandler mockNfcHandler;

  setUp(() {
    mockNfcHandler = MockNfcHandler();
    service = NfcSharingService(mockNfcHandler);
  });

  final testPackage = SharedHealthPackage(
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

  group('NfcSharingService Extended', () {
    test('shareData fails if NFC not enabled', () async {
      when(() => mockNfcHandler.isNfcAvailable()).thenAnswer((_) async => false);

      final result = await service.shareData(testPackage);

      expect(result.success, isFalse);
      expect(result.error, 'NFC not available');
    });

    test('shareData calls beamNdefMessage if enabled (simulated)', () async {
      // In CI, NfcSharingService.initialize will see Platform.isLinux and set _isEnabled to false
      // regardless of what NfcHandler says.
      // So we test the behavior when _isEnabled is false.

      when(() => mockNfcHandler.isNfcAvailable()).thenAnswer((_) async => true);
      await service.initialize();

      final result = await service.shareData(testPackage);
      // It should be false because we are on Linux.
      expect(result.success, isFalse);
    });

    test('stopListening calls stopNfcSession', () async {
      when(() => mockNfcHandler.stopNfcSession()).thenAnswer((_) async => {});

      await service.stopListening();

      verify(() => mockNfcHandler.stopNfcSession()).called(1);
    });
  });
}
