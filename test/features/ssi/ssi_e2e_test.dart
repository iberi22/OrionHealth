import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:orionhealth_health/features/auth/infrastructure/services/ble_medical_sharing_service.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/features/ble_sharing/domain/ble_sharing_service.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/did.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/verifiable_credential.dart';
import 'package:orionhealth_health/features/ssi/domain/repositories/ssi_repository.dart';
import 'package:orionhealth_health/features/ssi/domain/services/anoncreds_service.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/anoncreds_service_impl.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/ssi_service_impl.dart';

/// Fake SSI Repository for in-memory testing.
class FakeSsiRepository implements SsiRepository {
  final Map<String, Did> _dids = {};
  final Map<String, Map<String, dynamic>> _didDocs = {};
  final Map<String, VerifiableCredential> _credentials = {};

  @override
  Future<void> saveDid(Did did, Map<String, dynamic> didDocument) async {
    _dids[did.did] = did;
    _didDocs[did.did] = didDocument;
  }

  @override
  Future<List<Did>> getDids() async => _dids.values.toList();

  @override
  Future<Map<String, dynamic>?> getDidDocument(String did) async => _didDocs[did];

  @override
  Future<void> saveCredential(VerifiableCredential credential) async {
    _credentials[credential.id] = credential;
  }

  @override
  Future<List<VerifiableCredential>> getCredentials() async => _credentials.values.toList();

  @override
  Future<VerifiableCredential?> getCredentialById(String credentialId) async => _credentials[credentialId];

  @override
  Future<void> deleteCredential(String credentialId) async {
    _credentials.remove(credentialId);
  }
}

/// Simple Fake Encryption Service that doesn't depend on native plugins.
class FakeEncryptionService extends Mock implements EncryptionService {
  @override
  Future<void> initialize() async {}

  @override
  Future<Uint8List> encryptBytes(Uint8List data) async {
    // Identity "encryption" for tests
    return data;
  }

  @override
  Future<Uint8List> decryptBytes(Uint8List encryptedData) async {
    // Identity "decryption" for tests
    return encryptedData;
  }

  @override
  Future<Uint8List> encrypt(String plaintext) async {
    return Uint8List.fromList(utf8.encode(plaintext));
  }
}

class MockBleSharingService extends Mock implements BleSharingService {}

void main() {
  late SsiServiceImpl ssiService;
  late AnonCredsServiceImpl anonCredsService;
  late BleMedicalSharingService bleSharingService;
  late FakeSsiRepository repository;
  late FakeEncryptionService encryptionService;
  late MockBleSharingService mockBleService;

  setUp(() {
    repository = FakeSsiRepository();
    encryptionService = FakeEncryptionService();
    mockBleService = MockBleSharingService();

    ssiService = SsiServiceImpl(repository);
    anonCredsService = AnonCredsServiceImpl();
    bleSharingService = BleMedicalSharingService(
      mockBleService,
      encryptionService,
      ssiService,
    );
  });

  group('SSI to BLE E2E Integration', () {
    test('Full Pipeline: DID -> VC -> AnonCreds -> Verify -> BLE Package', () async {
      // 1. Setup Identities
      final issuerDid = await ssiService.createDid();
      final subjectDid = await ssiService.createDid();

      expect(issuerDid.activeDid, startsWith('did:orion:'));
      expect(subjectDid.activeDid, startsWith('did:orion:'));

      // 2. Issue Verifiable Credential (Standard)
      final claims = {
        'vaccine': 'Pfizer-BioNTech',
        'lot': 'AA1234',
        'date': '2023-10-01',
        'patientName': 'John Doe',
      };

      final vc = await ssiService.issueCredential(
        schemaId: 'orion:schemas:VaccinationCredential:v1',
        subjectDid: subjectDid.activeDid,
        claims: claims,
      );

      expect(vc.type, 'VaccinationCredential');
      expect(await ssiService.verifyCredential(vc), isTrue);

      // 3. Upgrade to AnonCreds & Issue
      final issuerKeys = await anonCredsService.generateIssuerKeys();
      final anonCredsVc = await anonCredsService.issueCredential(
        credential: vc,
        issuerKeys: issuerKeys,
        linkSecret: 'my-secret-123',
      );

      expect(anonCredsVc.proof, contains('Ed25519Signature2020'));

      // 4. Create Selective Disclosure Presentation
      // We only want to reveal the vaccine name and date, keeping patientName and lot hidden.
      final disclosedFields = ['vaccine', 'date'];
      final presentation = await anonCredsService.createPresentation(
        credential: anonCredsVc,
        disclosedFields: disclosedFields,
        linkSecret: 'my-secret-123',
      );

      expect(presentation.disclosedFields.length, 2);
      expect(presentation.disclosedFields['vaccine'], 'Pfizer-BioNTech');
      expect(presentation.disclosedFields['patientName'], isNull);
      expect(presentation.hiddenCommitments.containsKey('patientName'), isTrue);

      // 5. Verify Presentation
      final isPresentationValid = await anonCredsService.verifyPresentation(
        presentation,
        expectedLinkSecret: 'my-secret-123',
      );
      expect(isPresentationValid, isTrue);

      // 6. Simulate BLE Sharing (Encryption/Decryption)
      // We wrap the AnonCreds presentation in a BLE package
      final presentationData = presentation.toJson();

      final package = await bleSharingService.encryptPackage(
        presentationData,
        packageType: 'VerifiablePresentation',
        recipientNodeId: 'hospital-node-001',
      );

      expect(package.metadata.packageType, 'VerifiablePresentation');
      expect(package.recipientNodeId, 'hospital-node-001');

      // 7. Receive and Decrypt on the other side
      final receivedData = await bleSharingService.decryptPackage(package);
      final receivedPresentation = AnonCredsPresentation.fromJson(receivedData);

      expect(receivedPresentation.disclosedFields['vaccine'], 'Pfizer-BioNTech');
      expect(receivedPresentation.disclosedFields['patientName'], isNull);

      // 8. Re-verify received presentation
      final isReceivedValid = await anonCredsService.verifyPresentation(
        receivedPresentation,
        expectedLinkSecret: 'my-secret-123',
      );
      expect(isReceivedValid, isTrue);
    });
  });
}
