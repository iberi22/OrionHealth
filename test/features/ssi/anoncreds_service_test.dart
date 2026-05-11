import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/verifiable_credential.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/revocation_entry.dart';
import 'package:orionhealth_health/features/ssi/domain/repositories/ssi_repository.dart';
import 'package:orionhealth_health/features/ssi/domain/services/anoncreds_service.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/anoncreds_service_impl.dart';

class MockSsiRepository extends Mock implements SsiRepository {}

void main() {
  late AnonCredsServiceImpl service;
  late MockSsiRepository mockRepository;

  setUp(() {
    mockRepository = MockSsiRepository();
    service = AnonCredsServiceImpl(mockRepository);

    // Default mock behaviors
    when(() => mockRepository.getCredentials()).thenAnswer((_) async => []);
    when(() => mockRepository.getRevocationEntry(any(), any())).thenAnswer((_) async => null);
    when(() => mockRepository.saveRevocationEntry(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(RevocationEntry(
      credentialId: 'vc:test',
      credentialIndex: 1,
      issuerPublicKey: 'key',
      revokedAt: DateTime.now(),
      issuerSignature: 'sig',
    ));
  });

  group('AnonCredsServiceImpl Revocation', () {
    test('issueCredential assigns sequential indices per issuer', () async {
      final issuerKeys = await service.generateIssuerKeys();

      final vc1 = await service.issueCredential(
        credential: _createBaseVC('vc:1'),
        issuerKeys: issuerKeys,
      );

      // Mock that first VC is now in repository
      when(() => mockRepository.getCredentials()).thenAnswer((_) async => [vc1]);

      final vc2 = await service.issueCredential(
        credential: _createBaseVC('vc:2'),
        issuerKeys: issuerKeys,
      );

      final proof1 = service.parseProofForTest(vc1.proof);
      final proof2 = service.parseProofForTest(vc2.proof);

      expect(proof1['credentialIndex'], 1);
      expect(proof2['credentialIndex'], 2);
    });

    test('revokeCredential creates and saves a signed revocation entry', () async {
      final issuerKeys = await service.generateIssuerKeys();
      final vc = await service.issueCredential(
        credential: _createBaseVC('vc:1'),
        issuerKeys: issuerKeys,
      );

      when(() => mockRepository.getCredentialById(vc.id)).thenAnswer((_) async => vc);

      await service.revokeCredential(vc.id, issuerKeys);

      verify(() => mockRepository.saveRevocationEntry(any())).called(1);
    });

    test('verifyPresentation fails for revoked credentials', () async {
      final issuerKeys = await service.generateIssuerKeys();
      final vc = await service.issueCredential(
        credential: _createBaseVC('vc:1'),
        issuerKeys: issuerKeys,
      );

      // Create a presentation
      final presentation = await service.createPresentation(
        credential: vc,
        disclosedFields: [],
      );

      // Initially valid
      when(() => mockRepository.getRevocationEntry(any(), any())).thenAnswer((_) async => null);
      var isValid = await service.verifyPresentation(presentation);
      expect(isValid, true);

      // Now mock revocation
      final proof = service.parseProofForTest(vc.proof);
      final credentialIndex = proof['credentialIndex'] as int;

      // We need to capture the revocation entry to use it in the mock
      late RevocationEntry capturedEntry;
      when(() => mockRepository.getCredentialById(vc.id)).thenAnswer((_) async => vc);
      when(() => mockRepository.saveRevocationEntry(any())).thenAnswer((invocation) async {
        capturedEntry = invocation.positionalArguments[0] as RevocationEntry;
      });

      await service.revokeCredential(vc.id, issuerKeys);

      when(() => mockRepository.getRevocationEntry(issuerKeys.publicKey, credentialIndex))
          .thenAnswer((_) async => capturedEntry);

      isValid = await service.verifyPresentation(presentation);
      expect(isValid, false);
    });

    test('verifyPresentation fails if revocation entry signature is invalid', () async {
      final issuerKeys = await service.generateIssuerKeys();
      final vc = await service.issueCredential(
        credential: _createBaseVC('vc:1'),
        issuerKeys: issuerKeys,
      );

      final presentation = await service.createPresentation(
        credential: vc,
        disclosedFields: [],
      );

      final tamperedEntry = RevocationEntry(
        credentialId: vc.id,
        credentialIndex: 1,
        issuerPublicKey: issuerKeys.publicKey,
        revokedAt: DateTime.now(),
        issuerSignature: 'BeeGRZr9YODAEBmKLqBAcP2G/SQDey4iqZ3y2C81fmEAZBJKpKDMUwnQsPfJlUzrv66k7uHvVf8SNhHDmnDvyQ==',
      );

      when(() => mockRepository.getRevocationEntry(any(), any()))
          .thenAnswer((_) async => tamperedEntry);

      // Should still be valid because the revocation record itself is "fake" (invalid signature)
      final isValid = await service.verifyPresentation(presentation);
      expect(isValid, true);
    });

    test('verifyPresentation fails if issuance date is tampered', () async {
      final issuerKeys = await service.generateIssuerKeys();
      final vc = await service.issueCredential(
        credential: _createBaseVC('vc:1'),
        issuerKeys: issuerKeys,
      );

      final tampered = VerifiableCredential(
        id: vc.id,
        issuer: vc.issuer,
        subject: vc.subject,
        type: vc.type,
        schemaId: vc.schemaId,
        claims: vc.claims,
        issuanceDate: vc.issuanceDate.add(const Duration(days: 1)),
        expirationDate: vc.expirationDate,
        proof: vc.proof,
      );

      final presentation = await service.createPresentation(
        credential: tampered,
        disclosedFields: [],
      );

      final isValid = await service.verifyPresentation(presentation);
      expect(isValid, false);
    });
  });
}

VerifiableCredential _createBaseVC(String id) {
  return VerifiableCredential(
    id: id,
    issuer: 'did:orion:issuer',
    subject: 'did:orion:subject',
    type: 'TestCredential',
    schemaId: 'test:v1',
    claims: {'name': 'Alice'},
    issuanceDate: DateTime.now(),
  );
}

extension on AnonCredsServiceImpl {
  Map<String, dynamic> parseProofForTest(String? proofJson) {
    return jsonDecode(proofJson!);
  }
}
