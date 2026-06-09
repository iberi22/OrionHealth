import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/ble_medical_sharing_service.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/features/ssi/domain/services/ssi_service.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/verifiable_credential.dart';

import 'ble_medical_sharing_service_test.mocks.dart';

@GenerateMocks([BleSharingService, EncryptionService, SsiService])
void main() {
  late BleMedicalSharingService service;
  late MockBleSharingService mockBleService;
  late MockEncryptionService mockEncryptionService;
  late MockSsiService mockSsiService;

  setUp(() {
    mockBleService = MockBleSharingService();
    mockEncryptionService = MockEncryptionService();
    mockSsiService = MockSsiService();
  });

  group('BleMedicalSharingService', () {
    test('sharePresentation should return error if SSI service is null', () async {
      service = BleMedicalSharingService(mockBleService, mockEncryptionService, null);

      final vc = VerifiableCredential(
        id: 'test-vc',
        issuer: 'test-issuer',
        subject: 'test-subject',
        type: 'VerifiableCredential',
        schemaId: 'schema-1',
        claims: {},
        issuanceDate: DateTime.now(),
      );

      final result = await service.sharePresentation(
        credential: vc,
        recipientNodeId: 'node-1',
        disclosedFields: ['name'],
      );

      expect(result.success, isFalse);
      expect(result.error, 'SSI service not available');
    });

    test('sharePresentation should proceed if SSI service is available', () async {
      service = BleMedicalSharingService(mockBleService, mockEncryptionService, mockSsiService);

      final vc = VerifiableCredential(
        id: 'test-vc',
        issuer: 'test-issuer',
        subject: 'test-subject',
        type: 'VerifiableCredential',
        schemaId: 'schema-1',
        claims: {},
        issuanceDate: DateTime.now(),
      );

      when(mockSsiService.createPresentation(
        credential: anyNamed('credential'),
        disclosedFields: anyNamed('disclosedFields'),
      )).thenAnswer((_) async => {'presentation': 'data'});

      when(mockEncryptionService.encryptBytes(any)).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(mockBleService.sendData(any)).thenAnswer((_) async => SharingResult(success: true, bytesTransferred: 3, transferTime: Duration.zero));

      final result = await service.sharePresentation(
        credential: vc,
        recipientNodeId: 'node-1',
        disclosedFields: ['name'],
      );

      expect(result.success, isTrue);
      verify(mockSsiService.createPresentation(credential: vc, disclosedFields: ['name'])).called(1);
    });

    test('receiveCredential should skip verification if SSI service is null', () async {
      service = BleMedicalSharingService(mockBleService, mockEncryptionService, null);

      final vc = VerifiableCredential(
        id: 'test-vc',
        issuer: 'test-issuer',
        subject: 'test-subject',
        type: 'VerifiableCredential',
        schemaId: 'schema-1',
        claims: {},
        issuanceDate: DateTime.now(),
      );

      final package = SharedHealthPackage(
        id: 'pkg-1',
        senderNodeId: 'sender',
        recipientNodeId: 'self',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        payload: EncryptedPayload(
          encryptedData: base64Encode(utf8.encode(jsonEncode(vc.toJson()))),
          iv: 'iv',
          ephemeralPublicKey: '',
          authTag: 'tag',
        ),
        metadata: PackageMetadata(
          packageType: 'VerifiableCredential',
          consentVerified: true,
          includedCategories: {},
          appVersion: '1.0.0',
        ),
        signature: 'sig',
      );

      when(mockBleService.receiveData()).thenAnswer((_) async => package);

      final result = await service.receiveCredential();

      expect(result?.id, 'test-vc');
      verifyNever(mockSsiService.verifyCredential(any));
    });
  });
}
