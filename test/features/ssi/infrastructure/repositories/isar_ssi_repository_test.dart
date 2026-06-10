import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/did.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/revocation_entry.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/verifiable_credential.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/repositories/isar_ssi_repository.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/persistence/isar_did.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/persistence/isar_credential.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/persistence/isar_revocation_entry.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late IsarSsiRepository repository;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_ssi_repo');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [IsarDidSchema, IsarCredentialSchema, IsarRevocationEntrySchema],
      directory: testDir,
    );
    repository = IsarSsiRepository(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.isarDids.clear();
      await isar.isarCredentials.clear();
      await isar.isarRevocationEntrys.clear();
    });
  });

  group('IsarSsiRepository - DIDs', () {
    test('saveDid and getDids', () async {
      final did = Did(
        did: 'did:orion:123',
        longForm: 'did:orion:123;initial-state=abc',
        createdAt: DateTime.now(),
        isAnchored: false,
        keyType: 'Ed25519',
      );
      final didDoc = {'id': 'did:orion:123'};

      await repository.saveDid(did, didDoc);

      final dids = await repository.getDids();
      expect(dids.length, 1);
      expect(dids.first.did, 'did:orion:123');

      final savedDoc = await repository.getDidDocument('did:orion:123');
      expect(savedDoc, equals(didDoc));
    });

    test('getDidDocument returns null if not found', () async {
      final doc = await repository.getDidDocument('non-existent');
      expect(doc, isNull);
    });
  });

  group('IsarSsiRepository - Credentials', () {
    test('saveCredential and getCredentials', () async {
      final vc = VerifiableCredential(
        id: 'vc:123',
        issuer: 'did:issuer',
        subject: 'did:subject',
        type: 'TestCredential',
        schemaId: 'schema:1',
        claims: {'name': 'John Doe'},
        issuanceDate: DateTime.now(),
      );

      await repository.saveCredential(vc);

      final credentials = await repository.getCredentials();
      expect(credentials.length, 1);
      expect(credentials.first.id, 'vc:123');
      expect(credentials.first.claims['name'], 'John Doe');
    });

    test('getCredentialById returns the correct credential', () async {
      final vc = VerifiableCredential(
        id: 'vc:123',
        issuer: 'did:issuer',
        subject: 'did:subject',
        type: 'TestCredential',
        schemaId: 'schema:1',
        claims: {'name': 'John Doe'},
        issuanceDate: DateTime.now(),
      );
      await repository.saveCredential(vc);

      final result = await repository.getCredentialById('vc:123');
      expect(result, isNotNull);
      expect(result!.id, 'vc:123');
    });

    test('deleteCredential removes it', () async {
      final vc = VerifiableCredential(
        id: 'vc:123',
        issuer: 'did:issuer',
        subject: 'did:subject',
        type: 'TestCredential',
        schemaId: 'schema:1',
        claims: {'name': 'John Doe'},
        issuanceDate: DateTime.now(),
      );
      await repository.saveCredential(vc);

      await repository.deleteCredential('vc:123');

      final result = await repository.getCredentialById('vc:123');
      expect(result, isNull);
    });
  });

  group('IsarSsiRepository - Revocation', () {
    test('saveRevocationEntry and getRevocationEntry', () async {
      final entry = RevocationEntry(
        credentialId: 'vc:123',
        credentialIndex: 5,
        issuerPublicKey: 'pubkey',
        revokedAt: DateTime.now(),
        issuerSignature: 'sig',
      );

      await repository.saveRevocationEntry(entry);

      final result = await repository.getRevocationEntry('pubkey', 5);
      expect(result, isNotNull);
      expect(result!.credentialId, 'vc:123');
      expect(result.credentialIndex, 5);
    });

    test('getRevocationEntry returns null if not found', () async {
      final result = await repository.getRevocationEntry('missing', 0);
      expect(result, isNull);
    });
  });
}
