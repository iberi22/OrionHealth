import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

void main() {
  group('SharedHealthPackage', () {
    late SharedHealthPackage testPackage;
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 1));

    setUp(() {
      testPackage = SharedHealthPackage(
        id: 'pkg-1',
        senderNodeId: 'node-1',
        recipientNodeId: 'node-2',
        createdAt: now,
        expiresAt: expiresAt,
        payload: EncryptedPayload(
          encryptedData: 'encrypted',
          iv: 'iv',
          ephemeralPublicKey: 'pubkey',
          authTag: 'auth',
        ),
        metadata: PackageMetadata(
          packageType: 'full',
          consentVerified: true,
          includedCategories: {DataCategory.labResults, DataCategory.vitalSigns},
          appVersion: '2.1.0',
        ),
        signature: 'sig123',
      );
    });

    test('supports value equality', () {
      final pkg2 = SharedHealthPackage(
        id: 'pkg-1',
        senderNodeId: 'node-1',
        recipientNodeId: 'node-2',
        createdAt: now,
        expiresAt: expiresAt,
        payload: testPackage.payload,
        metadata: testPackage.metadata,
        signature: 'sig123',
      );
      expect(testPackage, equals(pkg2));
    });

    test('props are correct', () {
      expect(testPackage.props, [
        'pkg-1', 'node-1', 'node-2', now, expiresAt,
        testPackage.payload, testPackage.metadata, 'sig123',
      ]);
    });

    test('isExpired returns false for future expiry', () {
      expect(testPackage.isExpired, isFalse);
    });

    test('isExpired returns true for past expiry', () {
      final expired = SharedHealthPackage(
        id: 'pkg-2',
        senderNodeId: 'node-1',
        recipientNodeId: 'node-2',
        createdAt: now.subtract(const Duration(days: 2)),
        expiresAt: now.subtract(const Duration(hours: 1)),
        payload: testPackage.payload,
        metadata: testPackage.metadata,
        signature: 'sig123',
      );
      expect(expired.isExpired, isTrue);
    });

    test('canShare returns true when not expired and consent verified', () {
      expect(testPackage.canShare, isTrue);
    });

    test('canShare returns false when expired', () {
      final expired = SharedHealthPackage(
        id: 'pkg-3',
        senderNodeId: 'node-1',
        recipientNodeId: 'node-2',
        createdAt: now.subtract(const Duration(days: 2)),
        expiresAt: now.subtract(const Duration(hours: 1)),
        payload: testPackage.payload,
        metadata: testPackage.metadata,
        signature: 'sig123',
      );
      expect(expired.canShare, isFalse);
    });

    test('canShare returns false without consent', () {
      final noConsent = SharedHealthPackage(
        id: 'pkg-4',
        senderNodeId: 'node-1',
        recipientNodeId: 'node-2',
        createdAt: now,
        expiresAt: expiresAt,
        payload: testPackage.payload,
        metadata: const PackageMetadata(
          packageType: 'selective',
          consentVerified: false,
          includedCategories: {DataCategory.medications},
          appVersion: '2.1.0',
        ),
        signature: 'sig123',
      );
      expect(noConsent.canShare, isFalse);
    });

    test('timeRemaining returns positive duration', () {
      expect(testPackage.timeRemaining.inSeconds, greaterThan(0));
    });

    test('timeRemaining returns zero for expired package', () {
      final expired = SharedHealthPackage(
        id: 'pkg-5',
        senderNodeId: 'node-1',
        recipientNodeId: 'node-2',
        createdAt: now.subtract(const Duration(days: 2)),
        expiresAt: now.subtract(const Duration(hours: 1)),
        payload: testPackage.payload,
        metadata: testPackage.metadata,
        signature: 'sig123',
      );
      expect(expired.timeRemaining, Duration.zero);
    });

    test('toJson and fromJson round-trip', () {
      final json = testPackage.toJson();
      final decoded = SharedHealthPackage.fromJson(json);
      expect(decoded, equals(testPackage));
    });

    test('encode/decode round-trip', () {
      final encoded = testPackage.encode();
      final decoded = SharedHealthPackage.decode(encoded);
      expect(decoded, equals(testPackage));
    });

    test('hashPin produces consistent results', () {
      final hash1 = SharedHealthPackage.hashPin('1234');
      final hash2 = SharedHealthPackage.hashPin('1234');
      expect(hash1, equals(hash2));
    });

    test('hashPin produces different hashes for different pins', () {
      final hash1 = SharedHealthPackage.hashPin('1234');
      final hash2 = SharedHealthPackage.hashPin('5678');
      expect(hash1, isNot(equals(hash2)));
    });
  });

  group('EncryptedPayload', () {
    test('supports value equality', () {
      expect(
        const EncryptedPayload(encryptedData: 'data', iv: 'iv', ephemeralPublicKey: 'key'),
        const EncryptedPayload(encryptedData: 'data', iv: 'iv', ephemeralPublicKey: 'key'),
      );
    });

    test('toJson and fromJson round-trip', () {
      final payload = EncryptedPayload(
        encryptedData: 'enc', iv: 'iv', ephemeralPublicKey: 'pub', authTag: 'auth',
      );
      final json = payload.toJson();
      final decoded = EncryptedPayload.fromJson(json);
      expect(decoded, equals(payload));
    });

    test('default authTag is empty string', () {
      final payload = EncryptedPayload(encryptedData: 'd', iv: 'i', ephemeralPublicKey: 'k');
      expect(payload.authTag, '');
    });
  });

  group('PackageMetadata', () {
    test('supports value equality', () {
      expect(
        const PackageMetadata(
          packageType: 'full', consentVerified: true,
          includedCategories: {DataCategory.labResults}, appVersion: '2.1.0',
        ),
        const PackageMetadata(
          packageType: 'full', consentVerified: true,
          includedCategories: {DataCategory.labResults}, appVersion: '2.1.0',
        ),
      );
    });

    test('verifyPin returns true when no pinHash set', () {
      final meta = const PackageMetadata(
        packageType: 'full', consentVerified: true,
        includedCategories: {}, appVersion: '2.1.0',
      );
      expect(meta.verifyPin('any'), isTrue);
    });

    test('verifyPin validates correct pin', () {
      final pinHash = SharedHealthPackage.hashPin('1234');
      final meta = PackageMetadata(
        packageType: 'selective', consentVerified: true,
        includedCategories: {DataCategory.vitalSigns}, pinHash: pinHash, appVersion: '2.1.0',
      );
      expect(meta.verifyPin('1234'), isTrue);
      expect(meta.verifyPin('wrong'), isFalse);
    });

    test('toJson and fromJson round-trip', () {
      final meta = PackageMetadata(
        packageType: 'selective', consentVerified: false,
        includedCategories: {DataCategory.medications}, appVersion: '2.0.0',
      );
      final json = meta.toJson();
      final decoded = PackageMetadata.fromJson(json);
      expect(decoded, equals(meta));
    });
  });

  group('SharingResult', () {
    test('supports value equality', () {
      expect(
        const SharingResult(success: true, bytesTransferred: 100, transferTime: Duration(seconds: 2)),
        const SharingResult(success: true, bytesTransferred: 100, transferTime: Duration(seconds: 2)),
      );
    });

    test('supports error message', () {
      final result = const SharingResult(
        success: false, error: 'Connection failed',
        bytesTransferred: 0, transferTime: Duration.zero,
      );
      expect(result.error, 'Connection failed');
    });

    test('props are correct', () {
      const result = SharingResult(
        success: true,
        error: null,
        bytesTransferred: 1024,
        transferTime: Duration(seconds: 1),
      );
      expect(result.props, [true, null, 1024, const Duration(seconds: 1)]);
    });
  });

  group('DataCategory', () {
    test('has display names', () {
      expect(DataCategory.labResults.displayName, 'Laboratorios');
      expect(DataCategory.allergies.displayName, 'Alergias');
      expect(DataCategory.conditions.displayName, 'Condiciones');
    });

    test('valueOf returns matching enum', () {
      expect(DataCategory.valueOf('labResults'), DataCategory.labResults);
      expect(DataCategory.valueOf('medications'), DataCategory.medications);
    });

    test('valueOf returns default for unknown', () {
      expect(DataCategory.valueOf('unknown'), DataCategory.labResults);
    });
  });

  group('TransferMethod', () {
    test('has display names and descriptions', () {
      expect(TransferMethod.nfc.displayName, 'NFC');
      expect(TransferMethod.nfc.description, 'Tap phones to share');
      expect(TransferMethod.ble.displayName, 'Bluetooth');
      expect(TransferMethod.ble.description, 'Nearby device');
      expect(TransferMethod.wifi.displayName, 'WiFi Direct');
      expect(TransferMethod.wifi.description, 'Same network');
    });
  });
}
