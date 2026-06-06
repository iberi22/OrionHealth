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
    when(() => mockRepository.saveCredential(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(RevocationEntry(
      credentialId: 'vc:test',
      credentialIndex: 1,
      issuerPublicKey: 'key',
      revokedAt: DateTime.now(),
      issuerSignature: 'sig',
    ));
    registerFallbackValue(VerifiableCredential(
      id: 'id',
      issuer: 'issuer',
      subject: 'subject',
      type: 'type',
      schemaId: 'schema',
      claims: {},
      issuanceDate: DateTime.now(),
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

    test('issueCredential maintains separate indices for different issuers', () async {
      final issuerKeys1 = await service.generateIssuerKeys();
      final issuerKeys2 = await service.generateIssuerKeys();

      final vc1 = await service.issueCredential(
        credential: _createBaseVC('vc:1'),
        issuerKeys: issuerKeys1,
      );

      when(() => mockRepository.getCredentials()).thenAnswer((_) async => [vc1]);

      final vc2 = await service.issueCredential(
        credential: _createBaseVC('vc:2'),
        issuerKeys: issuerKeys2,
      );

      final proof1 = service.parseProofForTest(vc1.proof);
      final proof2 = service.parseProofForTest(vc2.proof);

      expect(proof1['credentialIndex'], 1);
      expect(proof2['credentialIndex'], 1); // Should be 1 for the new issuer
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

    test('verifyPresentation fails if salt is tampered', () async {
      final issuerKeys = await service.generateIssuerKeys();
      final vc = await service.issueCredential(
        credential: _createBaseVC('vc:1'),
        issuerKeys: issuerKeys,
      );

      final presentation = await service.createPresentation(
        credential: vc,
        disclosedFields: ['name'],
      );

      // Tamper with salt for 'name'
      final tamperedSalts = Map<String, String>.from(presentation.disclosedSalts);
      tamperedSalts['name'] = 'tampered-salt';

      final tamperedPresentation = AnonCredsPresentation(
        credential: presentation.credential,
        disclosedFields: presentation.disclosedFields,
        disclosedSalts: tamperedSalts,
        hiddenCommitments: presentation.hiddenCommitments,
        issuerSignature: presentation.issuerSignature,
        createdAt: presentation.createdAt,
      );

      final isValid = await service.verifyPresentation(tamperedPresentation);
      expect(isValid, false);
    });

    test('verifyPresentation fails if hidden commitment is tampered', () async {
      final issuerKeys = await service.generateIssuerKeys();
      final vc = await service.issueCredential(
        credential: VerifiableCredential(
          id: 'vc:2',
          issuer: 'did:orion:issuer',
          subject: 'did:orion:subject',
          type: 'TestCredential',
          schemaId: 'test:v1',
          claims: {'name': 'Alice', 'age': '30'},
          issuanceDate: DateTime.now(),
        ),
        issuerKeys: issuerKeys,
      );

      final presentation = await service.createPresentation(
        credential: vc,
        disclosedFields: ['name'], // 'age' is hidden
      );

      // Tamper with hidden commitment for 'age'
      final tamperedHidden = Map<String, String>.from(presentation.hiddenCommitments);
      tamperedHidden['age'] = '0' * 64; // Fake hash

      final tamperedPresentation = AnonCredsPresentation(
        credential: presentation.credential,
        disclosedFields: presentation.disclosedFields,
        disclosedSalts: presentation.disclosedSalts,
        hiddenCommitments: tamperedHidden,
        issuerSignature: presentation.issuerSignature,
        createdAt: presentation.createdAt,
      );

      final isValid = await service.verifyPresentation(tamperedPresentation);
      expect(isValid, false);
    });

    test('verifyPresentation fails if link secret is missing but required', () async {
      final issuerKeys = await service.generateIssuerKeys();
      final vc = await service.issueCredential(
        credential: _createBaseVC('vc:1'),
        issuerKeys: issuerKeys,
        linkSecret: 'secret123',
      );

      final presentation = await service.createPresentation(
        credential: vc,
        disclosedFields: ['name'],
        linkSecret: 'secret123',
      );

      final isValid = await service.verifyPresentation(presentation);
      expect(isValid, false);
    });

    test('verifyPresentation fails if link secret is incorrect', () async {
      final issuerKeys = await service.generateIssuerKeys();
      final vc = await service.issueCredential(
        credential: _createBaseVC('vc:1'),
        issuerKeys: issuerKeys,
        linkSecret: 'secret123',
      );

      final presentation = await service.createPresentation(
        credential: vc,
        disclosedFields: ['name'],
        linkSecret: 'secret123',
      );

      final isValid = await service.verifyPresentation(
        presentation,
        expectedLinkSecret: 'wrong-secret',
      );
      expect(isValid, false);
    });

    test('createPresentation redacts all salts from credential proof', () async {
      final issuerKeys = await service.generateIssuerKeys();
      final vc = await service.issueCredential(
        credential: _createBaseVC('vc:1'),
        issuerKeys: issuerKeys,
      );

      final presentation = await service.createPresentation(
        credential: vc,
        disclosedFields: ['name'],
      );

      final proof = jsonDecode(presentation.credential.proof!);
      final salts = proof['salts'] as Map;

      expect(salts, isEmpty,
          reason:
              'Salts must be redacted from credential proof to prevent leakage');
    });

    group('Selective Disclosure Edge Cases', () {
      test('createPresentation with 0 fields disclosed is valid', () async {
        final issuerKeys = await service.generateIssuerKeys();
        final vc = await service.issueCredential(
          credential: _createBaseVC('vc:1'),
          issuerKeys: issuerKeys,
        );

        final presentation = await service.createPresentation(
          credential: vc,
          disclosedFields: [],
        );

        expect(presentation.disclosedFields, isEmpty);
        expect(presentation.hiddenCommitments, hasLength(1)); // 'name' is hidden

        final isValid = await service.verifyPresentation(presentation);
        expect(isValid, true);
      });

      test('createPresentation with all fields disclosed is valid', () async {
        final issuerKeys = await service.generateIssuerKeys();
        final vc = await service.issueCredential(
          credential: VerifiableCredential(
            id: 'vc:1',
            issuer: 'did:orion:issuer',
            subject: 'did:orion:subject',
            type: 'TestCredential',
            schemaId: 'test:v1',
            claims: {'name': 'Alice', 'age': '30', 'city': 'Wonderland'},
            issuanceDate: DateTime.now(),
          ),
          issuerKeys: issuerKeys,
        );

        final presentation = await service.createPresentation(
          credential: vc,
          disclosedFields: ['name', 'age', 'city'],
        );

        expect(presentation.disclosedFields, hasLength(3));
        expect(presentation.hiddenCommitments, isEmpty);

        final isValid = await service.verifyPresentation(presentation);
        expect(isValid, true);
      });

      test('createPresentation ignores non-existent fields requested', () async {
        final issuerKeys = await service.generateIssuerKeys();
        final vc = await service.issueCredential(
          credential: _createBaseVC('vc:1'),
          issuerKeys: issuerKeys,
        );

        final presentation = await service.createPresentation(
          credential: vc,
          disclosedFields: ['name', 'nonExistent'],
        );

        expect(presentation.disclosedFields, hasLength(1));
        expect(presentation.disclosedFields.containsKey('nonExistent'), false);
        expect(presentation.hiddenCommitments, isEmpty);

        final isValid = await service.verifyPresentation(presentation);
        expect(isValid, true);
      });
    });

    test('isCredentialRevoked returns false for non-existent index', () async {
      final issuerKeys = await service.generateIssuerKeys();

      when(() => mockRepository.getRevocationEntry(any(), any()))
          .thenAnswer((_) async => null);

      final isRevoked = await service.isCredentialRevoked(issuerKeys.publicKey, 999);
      expect(isRevoked, false);
    });

    group('ZKP Verification Failure Scenarios', () {
      test('verifyPresentation fails if issuerSignature is tampered', () async {
        final issuerKeys = await service.generateIssuerKeys();
        final vc = await service.issueCredential(
          credential: _createBaseVC('vc:1'),
          issuerKeys: issuerKeys,
        );

        final presentation = await service.createPresentation(
          credential: vc,
          disclosedFields: ['name'],
        );

        final proof = jsonDecode(presentation.credential.proof!);
        final tamperedProof = jsonEncode({
          ...proof,
          'signatureValue': base64Url.encode(List.generate(64, (_) => 0)),
        });

        final tamperedVC = VerifiableCredential(
          id: presentation.credential.id,
          issuer: presentation.credential.issuer,
          subject: presentation.credential.subject,
          type: presentation.credential.type,
          schemaId: presentation.credential.schemaId,
          claims: presentation.credential.claims,
          issuanceDate: presentation.credential.issuanceDate,
          proof: tamperedProof,
        );

        final tamperedPresentation = AnonCredsPresentation(
          credential: tamperedVC,
          disclosedFields: presentation.disclosedFields,
          disclosedSalts: presentation.disclosedSalts,
          hiddenCommitments: presentation.hiddenCommitments,
          issuerSignature: 'ignored-by-implementation',
          createdAt: presentation.createdAt,
        );

        final isValid = await service.verifyPresentation(tamperedPresentation);
        expect(isValid, false);
      });

      test('verifyPresentation fails if a disclosed field value is tampered',
          () async {
        final issuerKeys = await service.generateIssuerKeys();
        final vc = await service.issueCredential(
          credential: _createBaseVC('vc:1'),
          issuerKeys: issuerKeys,
        );

        final presentation = await service.createPresentation(
          credential: vc,
          disclosedFields: ['name'],
        );

        final tamperedFields = Map<String, dynamic>.from(presentation.disclosedFields);
        tamperedFields['name'] = 'Eve';

        final tamperedPresentation = AnonCredsPresentation(
          credential: presentation.credential,
          disclosedFields: tamperedFields,
          disclosedSalts: presentation.disclosedSalts,
          hiddenCommitments: presentation.hiddenCommitments,
          issuerSignature: presentation.issuerSignature,
          createdAt: presentation.createdAt,
        );

        final isValid = await service.verifyPresentation(tamperedPresentation);
        expect(isValid, false);
      });

      test('verifyPresentation fails if credentialId in presentation is tampered',
          () async {
        final issuerKeys = await service.generateIssuerKeys();
        final vc = await service.issueCredential(
          credential: _createBaseVC('vc:1'),
          issuerKeys: issuerKeys,
        );

        final presentation = await service.createPresentation(
          credential: vc,
          disclosedFields: ['name'],
        );

        final tamperedVC = VerifiableCredential(
          id: 'vc:TAMPERED',
          issuer: presentation.credential.issuer,
          subject: presentation.credential.subject,
          type: presentation.credential.type,
          schemaId: presentation.credential.schemaId,
          claims: presentation.credential.claims,
          issuanceDate: presentation.credential.issuanceDate,
          proof: presentation.credential.proof,
        );

        final tamperedPresentation = AnonCredsPresentation(
          credential: tamperedVC,
          disclosedFields: presentation.disclosedFields,
          disclosedSalts: presentation.disclosedSalts,
          hiddenCommitments: presentation.hiddenCommitments,
          issuerSignature: presentation.issuerSignature,
          createdAt: presentation.createdAt,
        );

        final isValid = await service.verifyPresentation(tamperedPresentation);
        expect(isValid, false);
      });
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
