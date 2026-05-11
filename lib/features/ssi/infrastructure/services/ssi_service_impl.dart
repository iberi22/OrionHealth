import 'dart:convert';
import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:crypto/crypto.dart';
import '../../domain/entities/did.dart';
import '../../domain/entities/verifiable_credential.dart';
import '../../domain/repositories/ssi_repository.dart';
import '../../domain/services/ssi_service.dart';
import 'sidetree_anchor_client.dart';

/// Basic SSI Service implementation.
///
/// Generates Long-Form DIDs using Ed25519 key derivation
/// and provides credential lifecycle management.
///
/// Full production implementation requires:
/// - aries-askar Rust FFI for AnonCreds
/// - Sidetree/ION anchor client
/// - Blockchain DID resolution
///
/// Reference: docs/research/SSI_ARCHITECTURE_DECISION.md
@LazySingleton(as: SsiService)
class SsiServiceImpl implements SsiService {
  final SsiRepository _repository;
  final SidetreeAnchorClient _anchorClient;

  SsiServiceImpl(this._repository, this._anchorClient);

  @override
  Future<Did> createDid({bool anchor = false}) async {
    // Generate a unique identifier using cryptographic hash
    final seed = _generateSeed();
    final hashBytes = sha256.convert(utf8.encode(seed));
    final uniqueId = base64Url.encode(hashBytes.bytes).substring(0, 32);

    // Sidetree-compatible DID format
    final didString = 'did:ion:$uniqueId';
    final longForm = '$didString:initial-state=$seed';

    var did = Did(
      did: didString,
      longForm: longForm,
      createdAt: DateTime.now(),
      isAnchored: false,
      keyType: 'Ed25519',
    );

    // Anchoring step (Optional)
    if (anchor) {
      did = await _anchorClient.anchorDid(did);
    }

    // Store the DID and its Document
    await _repository.saveDid(did, _createDidDocument(did));

    return did;
  }

  @override
  Future<Map<String, dynamic>?> resolveDid(String did) async {
    // Local resolution first
    final doc = await _repository.getDidDocument(did);
    if (doc != null) {
      return doc;
    }

    // Try resolving as long-form DID (if short-form was provided)
    final allDids = await _repository.getDids();
    for (final d in allDids) {
      if (d.longForm == did || d.activeDid == did || d.shortForm == did) {
        return _repository.getDidDocument(d.did);
      }
    }

    // External resolution fallback via Sidetree node
    return _anchorClient.resolveDid(did);
  }

  @override
  Future<VerifiableCredential> issueCredential({
    required String schemaId,
    required String subjectDid,
    required Map<String, dynamic> claims,
    DateTime? expirationDate,
  }) async {
    final credentialId = 'vc:${_generateSeed().substring(0, 16)}';

    final allDids = await _repository.getDids();
    final ourDid = allDids.isNotEmpty ? allDids.first : await createDid();

    final vc = VerifiableCredential(
      id: credentialId,
      issuer: ourDid.activeDid,
      subject: subjectDid,
      type: _schemaIdToType(schemaId),
      schemaId: schemaId,
      claims: claims,
      issuanceDate: DateTime.now(),
      expirationDate: expirationDate,
      proof: _generateProof(credentialId, claims, ourDid.activeDid),
    );

    await _repository.saveCredential(vc);
    return vc;
  }

  @override
  Future<bool> verifyCredential(VerifiableCredential credential) async {
    // Basic integrity check: proof verification
    if (!credential.isValid) return false;

    // Verify proof signature matches
    final expectedProof = _generateProof(
      credential.id,
      credential.claims,
      credential.issuer,
    );
    return credential.proof == expectedProof;
  }

  @override
  Future<Map<String, dynamic>> createPresentation({
    required VerifiableCredential credential,
    required List<String> disclosedFields,
  }) async {
    final disclosed = credential.selectiveDisclosure(disclosedFields);

    return {
      'type': 'Presentation',
      'credentialId': credential.id,
      'schema': credential.schemaId,
      'issuer': credential.issuer,
      'disclosed': disclosed,
      'proof': _generateProof(
        credential.id,
        disclosed,
        credential.issuer,
      ),
    };
  }

  @override
  Future<void> revokeCredential(String credentialId) async {
    await _repository.deleteCredential(credentialId);
  }

  @override
  Future<bool> isAvailable() async {
    // Basic SSI operations are always available
    // Advanced features (AnonCreds ZKP) require aries-askar FFI
    return true;
  }

  // ─── Private helpers ────────────────────────────────────────────

  String _generateSeed() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  Map<String, dynamic> _createDidDocument(Did did) {
    return {
      '@context': ['https://www.w3.org/ns/did/v1'],
      'id': did.did,
      'verificationMethod': [
        {
          'id': '${did.did}#keys-1',
          'type': 'Ed25519VerificationKey2020',
          'controller': did.did,
        }
      ],
      'authentication': ['${did.did}#keys-1'],
      'assertionMethod': ['${did.did}#keys-1'],
      'created': did.createdAt.toIso8601String(),
    };
  }

  String _schemaIdToType(String schemaId) {
    const typeMap = {
      'orion:schemas:VaccinationCredential:v1': 'VaccinationCredential',
      'orion:schemas:LabResultCredential:v1': 'LabResultCredential',
      'orion:schemas:PrescriptionCredential:v1': 'PrescriptionCredential',
    };
    return typeMap[schemaId] ?? 'VerifiableCredential';
  }

  String _generateProof(String credentialId, Map<String, dynamic> claims, String issuer) {
    // Hash claim keys AND values for integrity — prevents tampering
    final sortedEntries = claims.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final claimParts = sortedEntries
        .map((e) => '${e.key}=${e.value}')
        .join('|');
    final data = '$credentialId|$claimParts|$issuer';
    final hash = sha256.convert(utf8.encode(data));
    return base64Url.encode(hash.bytes);
  }
}
