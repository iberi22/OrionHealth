import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/did.dart';
import '../../domain/entities/verifiable_credential.dart';
import '../../domain/repositories/ssi_repository.dart';
import '../persistence/isar_credential.dart';
import '../persistence/isar_did.dart';

@LazySingleton(as: SsiRepository)
class IsarSsiRepository implements SsiRepository {
  final Isar _isar;

  IsarSsiRepository(this._isar);

  @override
  Future<void> saveDid(Did did, Map<String, dynamic> didDocument) async {
    await _isar.writeTxn(() async {
      final isarDid = IsarDid()
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

  @override
  Future<List<Did>> getDids() async {
    final isarDids = await _isar.isarDids.where().findAll();
    return isarDids.map((d) => Did(
      did: d.did,
      shortForm: d.shortForm,
      longForm: d.longForm,
      createdAt: d.createdAt,
      isAnchored: d.isAnchored,
      keyType: d.keyType,
    )).toList();
  }

  @override
  Future<Map<String, dynamic>?> getDidDocument(String did) async {
    final isarDid = await _isar.isarDids.filter().didEqualTo(did).findFirst();
    if (isarDid?.didDocumentJson == null) return null;
    return jsonDecode(isarDid!.didDocumentJson!) as Map<String, dynamic>;
  }

  @override
  Future<void> saveCredential(VerifiableCredential credential) async {
    await _isar.writeTxn(() async {
      final isarCredential = IsarCredential()
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

      await _isar.isarCredentials.putByCredentialId(isarCredential);
    });
  }

  @override
  Future<List<VerifiableCredential>> getCredentials() async {
    final isarCredentials = await _isar.isarCredentials.where().findAll();
    return isarCredentials.map((c) => VerifiableCredential(
      id: c.credentialId,
      issuer: c.issuer,
      subject: c.subject,
      type: c.type,
      schemaId: c.schemaId,
      claims: Map<String, dynamic>.from(jsonDecode(c.claimsJson) as Map),
      issuanceDate: c.issuanceDate,
      expirationDate: c.expirationDate,
      proof: c.proof,
      isRevoked: c.isRevoked,
    )).toList();
  }

  @override
  Future<VerifiableCredential?> getCredentialById(String credentialId) async {
    final c = await _isar.isarCredentials.filter().credentialIdEqualTo(credentialId).findFirst();
    if (c == null) return null;
    return VerifiableCredential(
      id: c.credentialId,
      issuer: c.issuer,
      subject: c.subject,
      type: c.type,
      schemaId: c.schemaId,
      claims: Map<String, dynamic>.from(jsonDecode(c.claimsJson) as Map),
      issuanceDate: c.issuanceDate,
      expirationDate: c.expirationDate,
      proof: c.proof,
      isRevoked: c.isRevoked,
    );
  }

  @override
  Future<void> deleteCredential(String credentialId) async {
    await _isar.writeTxn(() async {
      await _isar.isarCredentials.filter().credentialIdEqualTo(credentialId).deleteAll();
    });
  }
}
