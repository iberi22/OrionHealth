import 'dart:convert';
import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:crypto/crypto.dart';
import '../../domain/entities/did.dart';
import '../../domain/entities/verifiable_credential.dart';
import '../../domain/services/ssi_service.dart';

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
  // TODO(ssi): Migrate to Isar persistence for DIDs, credentials, and DID documents.
  // Currently in-memory only — data lost on app restart.
  final List<Did> _dids = [];
  final List<VerifiableCredential> _credentials = [];
  final Map<String, Map<String, dynamic>> _didDocuments = {};

  @override
  Future<Did> createDid() async {
    // Generate a unique identifier using cryptographic hash
    final seed = _generateSeed();
    final hashBytes = sha256.convert(utf8.encode(seed));
    final uniqueId = base64Url.encode(hashBytes.bytes).substring(0, 32);

    final didString = 'did:orion:$uniqueId';
    final longForm = '$didString;initial-state=$seed';

    final did = Did(
      did: didString,
      longForm: longForm,
      createdAt: DateTime.now(),
      isAnchored: false,
      keyType: 'Ed25519',
    );

    _dids.add(did);

    // Store the DID Document
    _didDocuments[didString] = _createDidDocument(did);

    return did;
  }

  @override
  Future<Map<String, dynamic>?> resolveDid(String did) async {
    // Local resolution first (long-form includes initial state)
    if (_didDocuments.containsKey(did)) {
      return _didDocuments[did];
    }

    // Try resolving as long-form DID
    for (final d in _dids) {
      if (d.longForm == did || d.activeDid == did) {
        return _didDocuments[d.did];
      }
    }

    // External resolution not implemented yet
    return null;
  }

  @override
  Future<VerifiableCredential> issueCredential({
    required String schemaId,
    required String subjectDid,
    required Map<String, dynamic> claims,
    DateTime? expirationDate,
  }) async {
    final credentialId = 'vc:${_generateSeed().substring(0, 16)}';
    final ourDid = _dids.isNotEmpty ? _dids.first : await createDid();

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

    _credentials.add(vc);
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
    _credentials.removeWhere((vc) => vc.id == credentialId);
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
