import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';

void main() {
  group('SharedHealthPackage', () {
    final now = DateTime.now();
    final future = now.add(const Duration(minutes: 5));
    final past = now.subtract(const Duration(minutes: 5));

    final testPackage = SharedHealthPackage(
      id: 'test-id',
      senderNodeId: 'sender-1',
      recipientNodeId: 'recipient-1',
      createdAt: now,
      expiresAt: future,
      payload: const EncryptedPayload(
        encryptedData: 'encrypted-data',
        iv: 'iv-vector',
        ephemeralPublicKey: 'pub-key',
      ),
      metadata: const PackageMetadata(
        packageType: 'selective',
        consentVerified: true,
        includedCategories: {DataCategory.labResults, DataCategory.vitalSigns},
        appVersion: '1.0.0',
      ),
      signature: 'test-signature',
    );

    test('isExpired returns false for future expiration', () {
      expect(testPackage.isExpired, isFalse);
    });

    test('isExpired returns true for past expiration', () {
      final expiredPackage = SharedHealthPackage(
        id: 'test-id',
        senderNodeId: 'sender-1',
        recipientNodeId: 'recipient-1',
        createdAt: past.subtract(const Duration(minutes: 5)),
        expiresAt: past,
        payload: testPackage.payload,
        metadata: testPackage.metadata,
        signature: 'test-signature',
      );
      expect(expiredPackage.isExpired, isTrue);
    });

    test('canShare returns true when not expired and consent verified', () {
      expect(testPackage.canShare, isTrue);
    });

    test('canShare returns false when expired', () {
      final expiredPackage = SharedHealthPackage(
        id: 'test-id',
        senderNodeId: 'sender-1',
        recipientNodeId: 'recipient-1',
        createdAt: past.subtract(const Duration(minutes: 5)),
        expiresAt: past,
        payload: testPackage.payload,
        metadata: testPackage.metadata,
        signature: 'test-signature',
      );
      expect(expiredPackage.canShare, isFalse);
    });

    test('canShare returns false when consent not verified', () {
      final noConsentPackage = SharedHealthPackage(
        id: 'test-id',
        senderNodeId: 'sender-1',
        recipientNodeId: 'recipient-1',
        createdAt: now,
        expiresAt: future,
        payload: testPackage.payload,
        metadata: const PackageMetadata(
          packageType: 'selective',
          consentVerified: false,
          includedCategories: {DataCategory.labResults},
          appVersion: '1.0.0',
        ),
        signature: 'test-signature',
      );
      expect(noConsentPackage.canShare, isFalse);
    });

    test('toJson and fromJson work correctly', () {
      final json = testPackage.toJson();
      final fromJson = SharedHealthPackage.fromJson(json);

      expect(fromJson.id, testPackage.id);
      expect(fromJson.senderNodeId, testPackage.senderNodeId);
      expect(fromJson.recipientNodeId, testPackage.recipientNodeId);
      expect(fromJson.payload, testPackage.payload);
      expect(fromJson.metadata, testPackage.metadata);
      expect(fromJson.signature, testPackage.signature);
    });

    test('encode and decode work correctly', () {
      final encoded = testPackage.encode();
      final decoded = SharedHealthPackage.decode(encoded);

      expect(decoded.id, testPackage.id);
      expect(decoded.senderNodeId, testPackage.senderNodeId);
      expect(decoded.recipientNodeId, testPackage.recipientNodeId);
      expect(decoded.payload, testPackage.payload);
      expect(decoded.metadata, testPackage.metadata);
      expect(decoded.signature, testPackage.signature);
    });
  });

  group('DataCategory', () {
    test('valueOf returns correct category', () {
      expect(DataCategory.valueOf('labResults'), DataCategory.labResults);
      expect(DataCategory.valueOf('vitalSigns'), DataCategory.vitalSigns);
    });

    test('valueOf returns default for unknown name', () {
      expect(DataCategory.valueOf('unknown'), DataCategory.labResults);
    });
  });
}
