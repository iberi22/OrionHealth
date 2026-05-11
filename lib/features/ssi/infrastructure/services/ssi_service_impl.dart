import 'dart:convert';
import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
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
/// Optional ION anchoring via [SidetreeAnchorClient] for
/// blockchain-registered DIDs.
///
/// Production roadmap:
/// - aries-askar Rust FFI for AnonCreds ZKP (#179)
/// - ION anchor client wired (#180) — ✅ DONE
///
/// Reference: docs/research/SSI_ARCHITECTURE_DECISION.md
@LazySingleton(as: SsiService)
class SsiServiceImpl implements SsiService {
  final SsiRepository _repository;
  final SidetreeAnchorClient? _anchorClient;

  SsiServiceImpl(this._repository, [this._anchorClient]);

  @override
  Future<Did> createDid() async {
    // Generate a unique identifier using cryptographic hash
    final seed = _generateSeed();
    final hashBytes = sha256.convert(utf8.encode(seed));
    final uniqueId = base64Url.encode(hashBytes.bytes).substring(0, 32);

    final didString = 'did:orion:$uniqueId';
    final longForm = '$didString;initial-state=$seed';

    // Derive public key for the DID Document
    final keyPair = await Ed25519().newKeyPairFromSeed(base64Url.decode(seed));
    final publicKey = await keyPair.extractPublicKey();

    final did = Did(
      did: didString,
      longForm: longForm,
      createdAt: DateTime.now(),
      isAnchored: false,
      keyType: 'Ed25519',
    );

    // Store the DID and its Document
    await _repository.saveDid(
      did,
      _createDidDocument(did, base64Url.encode(publicKey.bytes)),
    );

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
      if (d.longForm == did || d.activeDid == did) {
        return _repository.getDidDocument(d.did);
      }
    }

    // Try ION network resolution if anchor client is available
    if (_anchorClient != null && did.startsWith('did:ion:')) {
      return _anchorClient.resolve(did);
    }

    return null;
  }

  /// Anchor a locally-created DID to the ION Sidetree network.
  ///
  /// Submits a Create operation to the configured ION node.
  /// The DID becomes globally resolvable once the batch is anchored
  /// to Bitcoin (typically 10-20 minutes).
  ///
  /// Returns the updated [Did] with anchor status and ION DID suffix.
  Future<Did> anchorDid(Did did) async {
    if (_anchorClient == null) {
      throw StateError('SidetreeAnchorClient not configured');
    }

    final keys = await _anchorClient.generateKeyPair();

    final result = await _anchorClient.createDid(
      publicKeys: [
        {
          'id': '${did.did}#keys-1',
          'type': keys['type'],
          'publicKeyJwk': keys['publicKeyJwk'],
          'purposes': ['authentication', 'assertionMethod'],
        },
      ],
    );

    final anchoredDid = Did(
      did: result.did,
      shortForm: result.did,
      longForm: did.longForm,
      createdAt: did.createdAt,
      isAnchored: true,
      keyType: 'secp256k1',
    );

    // Save the anchored DID with its ION document
    await _repository.saveDid(anchoredDid, result.nodeResponse);

    return anchoredDid;
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

    final issuanceDate = DateTime.now();

    final vc = VerifiableCredential(
      id: credentialId,
      issuer: ourDid.activeDid,
      subject: subjectDid,
      type: _schemaIdToType(schemaId),
      schemaId: schemaId,
      claims: claims,
      issuanceDate: issuanceDate,
      expirationDate: expirationDate,
      proof: await _generateProof(
        credentialId,
        claims,
        ourDid.activeDid,
        _extractSeed(ourDid.longForm),
        schemaId: schemaId,
        issuanceDate: issuanceDate,
        expirationDate: expirationDate,
      ),
    );

    await _repository.saveCredential(vc);
    return vc;
  }

  @override
  Future<bool> verifyCredential(VerifiableCredential credential) async {
    // Basic integrity check: proof verification
    if (!credential.isValid || credential.proof == null) return false;

    // Check local repository for revocation status if we have it
    final localRecord = await _repository.getCredentialById(credential.id);
    if (localRecord != null && localRecord.isRevoked) {
      return false;
    }

    final doc = await resolveDid(credential.issuer);
    if (doc == null) return false;

    try {
      // Extract public key from DID Document
      final vm = doc['verificationMethod'] as List;
      final keyData = vm.firstWhere((m) => m['id'].endsWith('#keys-1'));
      final publicKeyB64 = keyData['publicKeyBase64'] as String;

      final publicKey = SimplePublicKey(
        base64Url.decode(publicKeyB64),
        type: KeyPairType.ed25519,
      );

      final data = _canonicalizeClaims(
        credential.id,
        credential.claims,
        credential.issuer,
        schemaId: credential.schemaId,
        issuanceDate: credential.issuanceDate,
        expirationDate: credential.expirationDate,
      );

      return await Ed25519().verify(
        utf8.encode(data),
        signature: Signature(
          base64Url.decode(credential.proof!),
          publicKey: publicKey,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> createPresentation({
    required VerifiableCredential credential,
    required List<String> disclosedFields,
  }) async {
    final disclosed = credential.selectiveDisclosure(disclosedFields);

    // In this basic implementation, we use the holder's DID to sign the presentation
    final allDids = await _repository.getDids();
    if (allDids.isEmpty) {
      throw StateError('No DID found for presentation signing');
    }
    final holderDid = allDids.first;

    return {
      'type': 'Presentation',
      'credentialId': credential.id,
      'schema': credential.schemaId,
      'issuer': credential.issuer,
      'disclosed': disclosed,
      'proof': await _generateProof(
        credential.id,
        disclosed,
        holderDid.activeDid,
        _extractSeed(holderDid.longForm),
        schemaId: credential.schemaId,
        issuanceDate: credential.issuanceDate,
        expirationDate: credential.expirationDate,
      ),
    };
  }

  @override
  Future<void> revokeCredential(String credentialId) async {
    final credential = await _repository.getCredentialById(credentialId);
    if (credential != null) {
      final revokedVc = VerifiableCredential(
        id: credential.id,
        issuer: credential.issuer,
        subject: credential.subject,
        type: credential.type,
        schemaId: credential.schemaId,
        claims: credential.claims,
        issuanceDate: credential.issuanceDate,
        expirationDate: credential.expirationDate,
        proof: credential.proof,
        isRevoked: true,
      );
      await _repository.saveCredential(revokedVc);
    }
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

  Map<String, dynamic> _createDidDocument(Did did, String publicKeyB64) {
    return {
      '@context': ['https://www.w3.org/ns/did/v1'],
      'id': did.did,
      'verificationMethod': [
        {
          'id': '${did.did}#keys-1',
          'type': 'Ed25519VerificationKey2020',
          'controller': did.did,
          'publicKeyBase64': publicKeyB64,
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

  String _extractSeed(String longForm) {
    final parts = longForm.split(';initial-state=');
    if (parts.length < 2) throw StateError('Invalid long-form DID');
    return parts[1];
  }

  Future<String> _generateProof(
    String credentialId,
    Map<String, dynamic> claims,
    String issuer,
    String seed, {
    String? schemaId,
    DateTime? issuanceDate,
    DateTime? expirationDate,
  }) async {
    final keyPair = await Ed25519().newKeyPairFromSeed(base64Url.decode(seed));
    final data = _canonicalizeClaims(
      credentialId,
      claims,
      issuer,
      schemaId: schemaId,
      issuanceDate: issuanceDate,
      expirationDate: expirationDate,
    );
    final signature = await Ed25519().sign(utf8.encode(data), keyPair: keyPair);
    return base64Url.encode(signature.bytes);
  }

  String _canonicalizeClaims(
    String credentialId,
    Map<String, dynamic> claims,
    String issuer, {
    String? schemaId,
    DateTime? issuanceDate,
    DateTime? expirationDate,
  }) {
    // Hash claim keys AND values for integrity — prevents tampering
    final sortedEntries = claims.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final claimParts = sortedEntries
        .map((e) => '${e.key}=${jsonEncode(e.value)}')
        .join('|');

    return '$credentialId|$claimParts|$issuer|$schemaId|'
        '${issuanceDate?.toIso8601String()}|'
        '${expirationDate?.toIso8601String()}';
  }
}
