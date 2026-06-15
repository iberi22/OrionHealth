import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/did.dart';
import '../../domain/entities/verifiable_credential.dart';
import '../models/credential_schema_dto.dart';
import '../models/did_dto.dart';

@lazySingleton
class SsiLocalDataSource {
  final Isar _isar;
  SsiLocalDataSource(this._isar);

  // -- DID operations --
  Future<void> saveDid(Did did, Map<String, dynamic> didDocument) async {
    await _isar.writeTxn(() async {
      final isarDid = IsarDidDto()
        ..did = did.did
        ..shortForm = did.shortForm
        ..longForm = did.longForm
        ..createdAt = did.createdAt
        ..isAnchored = did.isAnchored
        ..keyType = did.keyType
        ..didDocumentJson = jsonEncode(didDocument);
      await _isar.isarDids.putByDid(isarDid);
    });
  }

  Future<List<Did>> getDids() async {
    final isarDids = await _isar.isarDids.where().findAll();
    return isarDids.map((d) => Did(
      did: d.did, shortForm: d.shortForm, longForm: d.longForm,
      createdAt: d.createdAt, isAnchored: d.isAnchored, keyType: d.keyType,
    )).toList();
  }

  Future<Map<String, dynamic>?> getDidDocument(String did) async {
    final isarDid = await _isar.isarDids.filter().didEqualTo(did).findFirst();
    if (isarDid?.didDocumentJson == null) return null;
    return jsonDecode(isarDid!.didDocumentJson!) as Map<String, dynamic>;
  }

  // -- Credential operations --
  Future<void> saveCredential(VerifiableCredential credential) async {
    await _isar.writeTxn(() async {
      final dto = IsarCredentialDto()
        ..credentialId = credential.id
        ..issuer = credential.issuer
        ..subject = credential.subject
        ..type = credential.type
        ..schemaId = credential.schemaId
        ..claimsJson = jsonEncode(credential.claims)
        ..issuanceDate = credential.issuanceDate
        ..expirationDate = credential.expirationDate
        ..proof = credential.proof
        ..isRevoked = credential.isRevoked;
      await _isar.isarCredentials.putByCredentialId(dto);
    });
  }

  Future<List<VerifiableCredential>> getCredentials() async {
    final dtos = await _isar.isarCredentials.where().findAll();
    return dtos.map((c) => _toCredential(c)).toList();
  }

  Future<VerifiableCredential?> getCredentialById(String credentialId) async {
    final c = await _isar.isarCredentials.filter().credentialIdEqualTo(credentialId).findFirst();
    if (c == null) return null;
    return _toCredential(c);
  }

  Future<void> deleteCredential(String credentialId) async {
    await _isar.writeTxn(() async {
      await _isar.isarCredentials.filter().credentialIdEqualTo(credentialId).deleteAll();
    });
  }

  // -- Revocation entry operations --
  Future<void> saveRevocationEntry(String credentialId, String issuerPublicKey, int credentialIndex, DateTime revokedAt, String signature) async {
    await _isar.writeTxn(() async {
      final entry = IsarRevocationEntryDto()
        ..credentialId = credentialId
        ..issuerPublicKey = issuerPublicKey
        ..credentialIndex = credentialIndex
        ..revokedAt = revokedAt
        ..issuerSignature = signature;
      await _isar.isarRevocationEntrys.put(entry);
    });
  }

  Future<Map<String, dynamic>?> getRevocationEntry(String issuerPublicKey, int credentialIndex) async {
    final entry = await _isar.isarRevocationEntrys
        .filter().issuerPublicKeyEqualTo(issuerPublicKey)
        .credentialIndexEqualTo(credentialIndex).findFirst();
    if (entry == null) return null;
    return {
      'credentialId': entry.credentialId,
      'credentialIndex': entry.credentialIndex,
      'issuerPublicKey': entry.issuerPublicKey,
      'revokedAt': entry.revokedAt,
      'issuerSignature': entry.issuerSignature,
    };
  }

  VerifiableCredential _toCredential(IsarCredentialDto c) => VerifiableCredential(
    id: c.credentialId, issuer: c.issuer, subject: c.subject,
    type: c.type, schemaId: c.schemaId,
    claims: Map<String, dynamic>.from(jsonDecode(c.claimsJson) as Map),
    issuanceDate: c.issuanceDate, expirationDate: c.expirationDate,
    proof: c.proof, isRevoked: c.isRevoked,
  );
}
