import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/verifiable_credential.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/did.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/revocation_entry.dart';
import 'package:orionhealth_health/features/ssi/domain/repositories/ssi_repository.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/anoncreds_service_impl.dart';

class FakeSsiRepository implements SsiRepository {
  final Map<String, VerifiableCredential> _credentials = {};
  final Map<String, RevocationEntry> _revocations = {};

  @override
  Future<void> saveDid(Did did, Map<String, dynamic> didDocument) async {}
  @override
  Future<List<Did>> getDids() async => [];
  @override
  Future<Map<String, dynamic>?> getDidDocument(String did) async => null;

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

  @override
  Future<void> saveRevocationEntry(RevocationEntry entry) async {
    _revocations['${entry.issuerPublicKey}_${entry.credentialIndex}'] = entry;
  }

  @override
  Future<RevocationEntry?> getRevocationEntry(String issuerPublicKey, int credentialIndex) async {
    return _revocations['${issuerPublicKey}_$credentialIndex'];
  }
}

void main() {
  late AnonCredsServiceImpl service;
  late FakeSsiRepository repository;

  setUp(() {
    repository = FakeSsiRepository();
    service = AnonCredsServiceImpl(repository);
  });

  test('Revocation flow', () async {
    final issuerKeys = await service.generateIssuerKeys();

    final vc = VerifiableCredential(
      id: 'vc:123',
      issuer: 'did:orion:issuer',
      subject: 'did:orion:subject',
      type: 'TestCredential',
      schemaId: 'schema:1',
      claims: {'name': 'Alice'},
      issuanceDate: DateTime.now(),
    );

    // 1. Issue
    final anonCredsVc = await service.issueCredential(
      credential: vc,
      issuerKeys: issuerKeys,
    );

    // We must save it for revocation to find it by ID
    await repository.saveCredential(anonCredsVc);

    // 2. Create presentation
    final presentation = await service.createPresentation(
      credential: anonCredsVc,
      disclosedFields: ['name'],
    );

    // 3. Verify (should be valid)
    expect(await service.verifyPresentation(presentation), isTrue);

    // 4. Revoke
    await service.revokeCredential(anonCredsVc.id, issuerKeys);

    // Check explicit revocation method
    final proof = jsonDecode(anonCredsVc.proof!);
    final index = proof['credentialIndex'] as int;
    expect(await service.isCredentialRevoked(issuerKeys.publicKey, index), isTrue);

    // 5. Verify (should be invalid)
    final isValidAfterRevocation = await service.verifyPresentation(presentation);
    expect(isValidAfterRevocation, isFalse);
  });
}
