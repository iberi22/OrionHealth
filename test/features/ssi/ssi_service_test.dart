import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/credential_schema.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/verifiable_credential.dart';
import 'package:orionhealth_health/features/ssi/domain/repositories/ssi_repository.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/did.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/ssi_service_impl.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/sidetree_anchor_client.dart';

class MockSsiRepository extends Mock implements SsiRepository {}
class MockSidetreeAnchorClient extends Mock implements SidetreeAnchorClient {}

void main() {
  late SsiServiceImpl service;
  late MockSsiRepository mockRepository;
  late MockSidetreeAnchorClient mockAnchorClient;

  setUp(() {
    mockRepository = MockSsiRepository();
    mockAnchorClient = MockSidetreeAnchorClient();
    service = SsiServiceImpl(mockRepository, mockAnchorClient);

    // Default mock behaviors
    when(() => mockRepository.getDids()).thenAnswer((_) async => []);
    when(() => mockRepository.saveDid(any(), any())).thenAnswer((_) async {});
    when(() => mockRepository.saveCredential(any())).thenAnswer((_) async {});
    when(() => mockRepository.getDidDocument(any())).thenAnswer((_) async => null);
    when(() => mockRepository.getCredentialById(any())).thenAnswer((_) async => null);
  });

  setUpAll(() {
    registerFallbackValue(Did(
      did: 'did:test',
      longForm: 'did:test:long',
      createdAt: DateTime.now(),
    ));
    registerFallbackValue(VerifiableCredential(
      id: 'vc:test',
      issuer: 'did:issuer',
      subject: 'did:subject',
      type: 'Test',
      schemaId: 'schema',
      claims: {},
      issuanceDate: DateTime.now(),
    ));
  });

  group('SsiServiceImpl', () {
    group('createDid', () {
      test('generates a valid Long-Form DID', () async {
        final did = await service.createDid();

        expect(did.did, startsWith('did:orion:'));
        expect(did.longForm, contains(';initial-state='));
        expect(did.keyType, 'Ed25519');
        expect(did.isAnchored, false);
        expect(did.createdAt, isA<DateTime>());

        verify(() => mockRepository.saveDid(did, any())).called(1);
      });

      test('generates unique DIDs on each call', () async {
        final did1 = await service.createDid();
        final did2 = await service.createDid();

        expect(did1.did, isNot(did2.did));
        expect(did1.longForm, isNot(did2.longForm));
      });
    });

    group('anchorDid', () {
      test('successfully anchors a DID to ION', () async {
        final did = await service.createDid();
        final anchorResult = IonCreateResult(
          didSuffix: 'EiD3...',
          recoveryKey: {},
          updateKey: {},
          nodeResponse: {'id': 'did:ion:EiD3...', 'verificationMethod': []},
        );

        when(() => mockAnchorClient.createDid(
          publicKeys: any(named: 'publicKeys'),
        )).thenAnswer((_) async => anchorResult);

        final anchored = await service.anchorDid(did);

        expect(anchored.isAnchored, true);
        expect(anchored.shortForm, 'did:ion:EiD3...');
        expect(anchored.ionDid, 'did:ion:EiD3...');
        verify(() => mockRepository.saveDid(any(), any())).called(2);
      });

      test('throws StateError when anchor client is null', () async {
        final serviceNoAnchor = SsiServiceImpl(mockRepository);
        final did = await serviceNoAnchor.createDid();

        expect(() => serviceNoAnchor.anchorDid(did), throwsStateError);
      });
    });

    group('resolveDid', () {
      test('returns null for invalid DID format', () async {
        final doc = await service.resolveDid('invalid:did:format');
        expect(doc, isNull);
      });

      test('resolves locally created DID', () async {
        final did = Did(
          did: 'did:orion:123',
          longForm: 'did:orion:123;initial-state=abc',
          createdAt: DateTime.now(),
        );
        final didDoc = {'id': did.did, 'verificationMethod': []};

        when(() => mockRepository.getDidDocument(did.did)).thenAnswer((_) async => didDoc);

        final doc = await service.resolveDid(did.did);

        expect(doc, isNotNull);
        expect(doc!['id'], did.did);
      });

      test('resolves via anchor client for did:ion:', () async {
        final ionDid = 'did:ion:EiABC';
        final expectedDoc = {'id': ionDid};

        when(() => mockRepository.getDidDocument(ionDid)).thenAnswer((_) async => null);
        when(() => mockAnchorClient.resolve(ionDid)).thenAnswer((_) async => expectedDoc);

        final doc = await service.resolveDid(ionDid);

        expect(doc, equals(expectedDoc));
      });
    });

    group('issueCredential', () {
      test('issues a VerifiableCredential with proof', () async {
        final did = await service.createDid();
        when(() => mockRepository.getDids()).thenAnswer((_) async => [did]);

        final vc = await service.issueCredential(
          schemaId: 'orion:schemas:VaccinationCredential:v1',
          subjectDid: did.activeDid,
          claims: {'vaccineName': 'COVID-19 mRNA'},
        );

        expect(vc.id, startsWith('vc:'));
        expect(vc.proof, isNotNull);
        verify(() => mockRepository.saveCredential(vc)).called(1);
      });

      test('issued credential is verifiable', () async {
        late Map<String, dynamic> storedDidDoc;
        when(() => mockRepository.saveDid(any(), any())).thenAnswer((inv) async {
          storedDidDoc = inv.positionalArguments[1] as Map<String, dynamic>;
        });

        final did = await service.createDid();
        when(() => mockRepository.getDids()).thenAnswer((_) async => [did]);
        when(() => mockRepository.getDidDocument(did.did)).thenAnswer((_) async => storedDidDoc);

        final vc = await service.issueCredential(
          schemaId: 'orion:schemas:PrescriptionCredential:v1',
          subjectDid: did.activeDid,
          claims: {'medicationName': 'Paracetamol'},
        );

        final isValid = await service.verifyCredential(vc);
        expect(isValid, true);
      });

      test('does not verify tampered credential', () async {
        late Map<String, dynamic> storedDidDoc;
        when(() => mockRepository.saveDid(any(), any())).thenAnswer((inv) async {
          storedDidDoc = inv.positionalArguments[1] as Map<String, dynamic>;
        });

        final did = await service.createDid();
        when(() => mockRepository.getDids()).thenAnswer((_) async => [did]);
        when(() => mockRepository.getDidDocument(did.did)).thenAnswer((_) async => storedDidDoc);

        final vc = await service.issueCredential(
          schemaId: 'orion:schemas:LabResultCredential:v1',
          subjectDid: did.activeDid,
          claims: {'testName': 'Blood Test'},
        );

        final tampered = VerifiableCredential(
          id: vc.id,
          issuer: vc.issuer,
          subject: vc.subject,
          type: vc.type,
          schemaId: vc.schemaId,
          claims: {'testName': 'TAMPERED'},
          issuanceDate: vc.issuanceDate,
          proof: vc.proof,
        );

        final isValid = await service.verifyCredential(tampered);
        expect(isValid, false);
      });
    });

    group('revokeCredential', () {
      test('marks credential as revoked', () async {
        final vc = VerifiableCredential(
          id: 'vc:123',
          issuer: 'did:orion:issuer',
          subject: 'did:orion:subject',
          type: 'Test',
          schemaId: 'schema',
          claims: {},
          issuanceDate: DateTime.now(),
        );

        when(() => mockRepository.getCredentialById('vc:123')).thenAnswer((_) async => vc);
        await service.revokeCredential('vc:123');

        final captured = verify(() => mockRepository.saveCredential(captureAny())).captured.first as VerifiableCredential;
        expect(captured.isRevoked, true);
      });

      test('does nothing when revoking non-existent credential', () async {
        when(() => mockRepository.getCredentialById('vc:non-existent')).thenAnswer((_) async => null);

        await service.revokeCredential('vc:non-existent');

        verifyNever(() => mockRepository.saveCredential(any()));
      });
    });

    group('verifyCredential edge cases', () {
      test('returns false when issuer DID cannot be resolved', () async {
        final vc = VerifiableCredential(
          id: 'vc:123',
          issuer: 'did:orion:unknown',
          subject: 'did:orion:subject',
          type: 'Test',
          schemaId: 'schema',
          claims: {},
          issuanceDate: DateTime.now(),
          proof: 'some-proof',
        );

        when(() => mockRepository.getDidDocument('did:orion:unknown')).thenAnswer((_) async => null);

        final result = await service.verifyCredential(vc);
        expect(result, false);
      });
    });
  });

  group('VerifiableCredential Entities', () {
    test('isValid returns false for expired credential', () {
      final vc = VerifiableCredential(
        id: 'vc:test',
        issuer: 'did:o:1',
        subject: 'did:o:2',
        type: 'Test',
        schemaId: 's:1',
        claims: {},
        issuanceDate: DateTime.now().subtract(const Duration(days: 60)),
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(vc.isValid, false);
    });
  });
}
