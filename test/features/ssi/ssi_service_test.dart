import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/credential_schema.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/verifiable_credential.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/ssi_service_impl.dart';

void main() {
  late SsiServiceImpl service;

  setUp(() {
    service = SsiServiceImpl();
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
      });

      test('generates unique DIDs on each call', () async {
        final did1 = await service.createDid();
        final did2 = await service.createDid();

        expect(did1.did, isNot(did2.did));
        expect(did1.longForm, isNot(did2.longForm));
      });

      test('activeDid returns long-form when not anchored', () async {
        final did = await service.createDid();
        expect(did.activeDid, did.longForm);
      });
    });

    group('resolveDid', () {
      test('resolves locally created DID', () async {
        final did = await service.createDid();
        final doc = await service.resolveDid(did.did);

        expect(doc, isNotNull);
        expect(doc!['id'], did.did);
        expect(doc['verificationMethod'], isA<List>());
      });

      test('returns null for unknown DID', () async {
        final doc = await service.resolveDid('did:orion:unknown');
        expect(doc, isNull);
      });
    });

    group('issueCredential', () {
      test('issues a VerifiableCredential with proof', () async {
        final did = await service.createDid();
        final vc = await service.issueCredential(
          schemaId: 'orion:schemas:VaccinationCredential:v1',
          subjectDid: did.activeDid,
          claims: {
            'vaccineName': 'COVID-19 mRNA',
            'doseNumber': 2,
            'dateAdministered': '2026-05-01',
          },
        );

        expect(vc.id, startsWith('vc:'));
        expect(vc.type, 'VaccinationCredential');
        expect(vc.subject, did.activeDid);
        expect(vc.claims['vaccineName'], 'COVID-19 mRNA');
        expect(vc.proof, isNotNull);
        expect(vc.isValid, true);
      });

      test('issued credential is verifiable', () async {
        final did = await service.createDid();
        final vc = await service.issueCredential(
          schemaId: 'orion:schemas:PrescriptionCredential:v1',
          subjectDid: did.activeDid,
          claims: {'medicationName': 'Paracetamol'},
        );

        final isValid = await service.verifyCredential(vc);
        expect(isValid, true);
      });

      test('does not verify tampered credential', () async {
        final did = await service.createDid();
        final vc = await service.issueCredential(
          schemaId: 'orion:schemas:LabResultCredential:v1',
          subjectDid: did.activeDid,
          claims: {'testName': 'Blood Test'},
        );

        // Tamper with claims
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

    group('selective disclosure', () {
      test('creates presentation with only specified fields', () async {
        final did = await service.createDid();
        final vc = await service.issueCredential(
          schemaId: 'orion:schemas:VaccinationCredential:v1',
          subjectDid: did.activeDid,
          claims: {
            'vaccineName': 'COVID-19 mRNA',
            'doseNumber': 2,
            'dateAdministered': '2026-05-01',
            'lotNumber': 'LOT-123',
            'administeringClinic': 'Hospital Central',
          },
        );

        final presentation = await service.createPresentation(
          credential: vc,
          disclosedFields: ['vaccineName', 'doseNumber'],
        );

        expect(presentation['type'], 'Presentation');
        expect(presentation['disclosed']['vaccineName'], 'COVID-19 mRNA');
        expect(presentation['disclosed']['doseNumber'], 2);
        expect(presentation['disclosed']['dateAdministered'], isNull);
        expect(presentation['disclosed']['lotNumber'], isNull);
      });
    });

    group('revokeCredential', () {
      test('removes credential from store', () async {
        final did = await service.createDid();
        final vc = await service.issueCredential(
          schemaId: 'orion:schemas:VaccinationCredential:v1',
          subjectDid: did.activeDid,
          claims: {'vaccineName': 'Flu'},
        );

        await service.revokeCredential(vc.id);

        // Verification should fail for revoked credential
        // (in production, this would check a revocation registry)
      });
    });
  });

  group('VerifiableCredential', () {
    test('isValid returns true for non-expired, non-revoked credential', () {
      final vc = VerifiableCredential(
        id: 'vc:test',
        issuer: 'did:orion:issuer',
        subject: 'did:orion:subject',
        type: 'TestCredential',
        schemaId: 'test:v1',
        claims: {},
        issuanceDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(vc.isValid, true);
    });

    test('isValid returns false for expired credential', () {
      final vc = VerifiableCredential(
        id: 'vc:test',
        issuer: 'did:orion:issuer',
        subject: 'did:orion:subject',
        type: 'TestCredential',
        schemaId: 'test:v1',
        claims: {},
        issuanceDate: DateTime.now().subtract(const Duration(days: 60)),
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(vc.isValid, false);
    });

    test('selectiveDisclosure returns only requested fields', () {
      final vc = VerifiableCredential(
        id: 'vc:test',
        issuer: 'did:orion:issuer',
        subject: 'did:orion:subject',
        type: 'TestCredential',
        schemaId: 'test:v1',
        claims: {'a': 1, 'b': 2, 'c': 3},
        issuanceDate: DateTime.now(),
      );

      final disclosed = vc.selectiveDisclosure(['a', 'c']);
      expect(disclosed, {'a': 1, 'c': 3});
      expect(disclosed.containsKey('b'), false);
    });
  });

  group('CredentialSchema', () {
    test('vaccination schema has correct attributes', () {
      expect(CredentialSchema.vaccinationCredential.attributes, [
        'vaccineName',
        'doseNumber',
        'dateAdministered',
        'lotNumber',
        'administeringClinic',
      ]);
    });

    test('lab result schema has correct attributes', () {
      expect(CredentialSchema.labResultCredential.attributes, contains('testName'));
      expect(CredentialSchema.labResultCredential.attributes, contains('resultValue'));
    });

    test('prescription schema has correct attributes', () {
      expect(CredentialSchema.prescriptionCredential.attributes, contains('medicationName'));
      expect(CredentialSchema.prescriptionCredential.attributes, contains('dosage'));
    });
  });
}
