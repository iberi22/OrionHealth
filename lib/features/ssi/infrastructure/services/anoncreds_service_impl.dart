import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/revocation_entry.dart';
import '../../domain/entities/verifiable_credential.dart';
import '../../domain/repositories/ssi_repository.dart';
import '../../domain/services/anoncreds_service.dart';

/// AnonCreds implementation with **Salted Cryptographic Commitments**.
///
/// ## Security Improvements over SHA256-only
///
/// Raw SHA256 hash commitments (`sha256(claimValue)`) are vulnerable to
/// dictionary attacks — medical data has low entropy (vaccine names, lab
/// codes, drug names) that can be brute-forced by a malicious verifier.
///
/// This implementation adds **per-claim 32-byte random salts**:
/// ```
/// commitment = sha256("key:value:salt")
/// ```
///
/// - **Salts are NEVER shared** for undisclosed fields — the verifier
///   cannot reconstruct the commitment without the salt.
/// - **Salts are revealed only** for fields the holder chooses to disclose,
///   allowing the verifier to verify the commitment.
/// - **Link secret binding** prevents credential sharing — the holder
///   proves possession of a secret bound to the credential.
///
/// ## Gap from true AnonCreds (CL-Signatures)
///
/// This is still a COMMITMENT scheme, not true Zero-Knowledge Proofs.
/// Real AnonCreds requires CL-signatures (Camenisch-Lysyanskaya) via
/// aries-askar Rust FFI, which supports:
/// - Predicate proofs (e.g., "age > 18" without revealing age)
/// - Non-revocation accumulators
/// - Blind issuance
///
/// ## References
/// - aries-askar: https://github.com/hyperledger/aries-askar
/// - AnonCreds spec: https://anoncreds-wg.github.io/anoncreds-spec/
@LazySingleton(as: AnonCredsService)
class AnonCredsServiceImpl implements AnonCredsService {
  final Ed25519 _ed25519 = Ed25519();
  final SsiRepository _repository;

  AnonCredsServiceImpl(this._repository);

  @override
  Future<AnonCredsKeyPair> generateIssuerKeys() async {
    final keyPair = await _ed25519.newKeyPair();
    final data = await keyPair.extract();

    return AnonCredsKeyPair(
      publicKey: base64Url.encode(data.publicKey.bytes).replaceAll('=', ''),
      privateKey: base64Url.encode(data.bytes).replaceAll('=', ''),
      keyType: 'Ed25519',
    );
  }

  @override
  Future<VerifiableCredential> issueCredential({
    required VerifiableCredential credential,
    required AnonCredsKeyPair issuerKeys,
    String? linkSecret,
  }) async {
    final keyPair = _reconstructKeyPair(
      issuerKeys.publicKey,
      issuerKeys.privateKey,
    );

    // Generate random 32-byte salts for each claim
    final salts = <String, String>{};
    for (final key in credential.claims.keys) {
      salts[key] = _generateSalt();
    }

    if (linkSecret != null) {
      salts['_link_secret'] = _generateSalt();
    }

    // Sign the salted commitments, not raw claims
    final message = _credentialToCanonicalCommitments(credential, salts, linkSecret);
    final signature = await _ed25519.sign(message, keyPair: keyPair);

    // Track index for revocation
    final credentialIndex = await _getNextIndex(issuerKeys.publicKey);

    final updatedCredential = VerifiableCredential(
      id: credential.id,
      issuer: credential.issuer,
      subject: credential.subject,
      type: credential.type,
      schemaId: credential.schemaId,
      claims: credential.claims,
      issuanceDate: credential.issuanceDate,
      expirationDate: credential.expirationDate,
      proof: jsonEncode({
        'type': 'Ed25519Signature2020',
        'signatureValue': base64Url.encode(signature.bytes).replaceAll('=', ''),
        'issuerKey': issuerKeys.publicKey,
        'credentialIndex': credentialIndex,
        'salts': salts,
        'hasLinkSecret': linkSecret != null,
        'created': DateTime.now().toIso8601String(),
      }),
    );

    return updatedCredential;
  }

  Future<int> _getNextIndex(String issuerPublicKey) async {
    final credentials = await _repository.getCredentials();
    int maxIndex = 0;

    for (final vc in credentials) {
      final proof = _parseProof(vc.proof);
      if (proof != null && proof['issuerKey'] == issuerPublicKey) {
        final index = proof['credentialIndex'] as int?;
        if (index != null && index > maxIndex) {
          maxIndex = index;
        }
      }
    }

    return maxIndex + 1;
  }

  @override
  Future<AnonCredsPresentation> createPresentation({
    required VerifiableCredential credential,
    required List<String> disclosedFields,
    String? linkSecret,
  }) async {
    final proof = _parseProof(credential.proof);
    final salts = Map<String, String>.from(proof?['salts'] as Map? ?? {});

    final disclosed = <String, dynamic>{};
    final disclosedSalts = <String, String>{};
    final hiddenCommitments = <String, String>{};

    for (final entry in credential.claims.entries) {
      if (disclosedFields.contains(entry.key)) {
        disclosed[entry.key] = entry.value;
        disclosedSalts[entry.key] = salts[entry.key] ?? '';
      } else {
        final salt = salts[entry.key] ?? '';
        hiddenCommitments[entry.key] =
            _computeCommitment(entry.key, entry.value.toString(), salt);
      }
    }

    // Link secret: always proven via commitment, never disclosed as raw value
    if (linkSecret != null && salts.containsKey('_link_secret')) {
      disclosedSalts['_link_secret'] = salts['_link_secret']!;
    }

    // Redact salts from the proof metadata to prevent leakage in serialized form
    final redactedProofJson = proof != null
        ? jsonEncode({
            ...proof,
            'salts': {},
          })
        : null;

    final redactedCredential = VerifiableCredential(
      id: credential.id,
      issuer: credential.issuer,
      subject: credential.subject,
      type: credential.type,
      schemaId: credential.schemaId,
      claims: Map<String, dynamic>.from(disclosed),
      issuanceDate: credential.issuanceDate,
      expirationDate: credential.expirationDate,
      proof: redactedProofJson,
    );

    return AnonCredsPresentation(
      credential: redactedCredential,
      disclosedFields: disclosed,
      disclosedSalts: disclosedSalts,
      hiddenCommitments: hiddenCommitments,
      issuerSignature: proof?['signatureValue'] as String? ?? '',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<bool> verifyPresentation(
    AnonCredsPresentation presentation, {
    String? expectedLinkSecret,
  }) async {
    if (presentation.credential.isRevoked) return false;

    final proof = _parseProof(presentation.credential.proof);
    if (proof == null) return false;

    final signatureB64 = proof['signatureValue'] as String?;
    final issuerKeyB64 = proof['issuerKey'] as String?;
    if (signatureB64 == null || issuerKeyB64 == null) return false;

    // 1. Reconstruct commitments from disclosed fields + hidden commitments
    final commitments = <String, String>{};

    for (final entry in presentation.disclosedFields.entries) {
      final salt = presentation.disclosedSalts[entry.key];
      if (salt == null) return false;
      commitments[entry.key] =
          _computeCommitment(entry.key, entry.value.toString(), salt);
    }

    commitments.addAll(presentation.hiddenCommitments);

    // 2. Handle link secret binding (holder binding)
    if (proof['hasLinkSecret'] == true) {
      if (expectedLinkSecret == null) return false;
      final salt = presentation.disclosedSalts['_link_secret'];
      if (salt == null) return false;
      commitments['_link_secret'] =
          _computeCommitment('_link_secret', expectedLinkSecret, salt);
    }

    // 3. Verify issuer signature over commitments
    final publicKey = SimplePublicKey(
      _decodeBase64Url(issuerKeyB64),
      type: KeyPairType.ed25519,
    );

    final message = _canonicalCommitmentsToBytes(
      presentation.credential,
      commitments,
    );

    final isValid = await _ed25519.verify(
      message,
      signature: Signature(
        _decodeBase64Url(signatureB64),
        publicKey: publicKey,
      ),
    );

    if (!isValid) return false;

    // 4. Check non-revocation registry
    final credentialIndex = proof['credentialIndex'] as int?;
    if (credentialIndex != null) {
      final isRevoked = await isCredentialRevoked(issuerKeyB64, credentialIndex);
      if (isRevoked) return false;
    }

    return true;
  }

  @override
  Future<void> revokeCredential(
      String credentialId, AnonCredsKeyPair issuerKeys) async {
    final credential = await _repository.getCredentialById(credentialId);
    if (credential == null) return;

    final proof = _parseProof(credential.proof);
    final credentialIndex = proof?['credentialIndex'] as int?;
    if (credentialIndex == null) return;

    final revokedAt = DateTime.now().toUtc();
    final dataToSign =
        '${issuerKeys.publicKey}:$credentialIndex:${revokedAt.toIso8601String()}';

    final keyPair = _reconstructKeyPair(
      issuerKeys.publicKey,
      issuerKeys.privateKey,
    );

    final signature = await _ed25519.sign(
      utf8.encode(dataToSign),
      keyPair: keyPair,
    );

    final entry = RevocationEntry(
      credentialId: credentialId,
      credentialIndex: credentialIndex,
      issuerPublicKey: issuerKeys.publicKey,
      revokedAt: revokedAt,
      issuerSignature: base64Url.encode(signature.bytes).replaceAll('=', ''),
    );

    await _repository.saveRevocationEntry(entry);

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

  @override
  Future<bool> isCredentialRevoked(
      String issuerPublicKey, int credentialIndex) async {
    final revocationEntry = await _repository.getRevocationEntry(
      issuerPublicKey,
      credentialIndex,
    );

    if (revocationEntry == null) return false;

    final dataToVerify =
        '${revocationEntry.issuerPublicKey}:${revocationEntry.credentialIndex}:${revocationEntry.revokedAt.toUtc().toIso8601String()}';
    final publicKey = SimplePublicKey(
      _decodeBase64Url(revocationEntry.issuerPublicKey),
      type: KeyPairType.ed25519,
    );

    final isSignatureValid = await _ed25519.verify(
      utf8.encode(dataToVerify),
      signature: Signature(
        _decodeBase64Url(revocationEntry.issuerSignature),
        publicKey: publicKey,
      ),
    );

    return isSignatureValid;
  }

  @override
  Future<bool> isAvailable() async => true;

  // ─── Internal helpers ─────────────────────────────────────────────

  Map<String, dynamic>? _parseProof(String? proofJson) {
    if (proofJson == null || proofJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(proofJson);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Generate a random 32-byte salt (base64url encoded, no padding).
  String _generateSalt() {
    final random = Random.secure();
    final bytes =
        Uint8List.fromList(List<int>.generate(32, (_) => random.nextInt(256)));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Compute a salted commitment: sha256("key:value:salt")
  String _computeCommitment(String key, String value, String salt) {
    return sha256.convert(utf8.encode('$key:$value:$salt')).toString();
  }

  /// Compute all commitments and serialize for signing.
  Uint8List _credentialToCanonicalCommitments(
    VerifiableCredential credential,
    Map<String, String> salts,
    String? linkSecret,
  ) {
    final commitments = <String, String>{};

    for (final entry in credential.claims.entries) {
      final salt = salts[entry.key]!;
      commitments[entry.key] =
          _computeCommitment(entry.key, entry.value.toString(), salt);
    }

    if (linkSecret != null) {
      final salt = salts['_link_secret']!;
      commitments['_link_secret'] =
          _computeCommitment('_link_secret', linkSecret, salt);
    }

    return _canonicalCommitmentsToBytes(credential, commitments);
  }

  /// Serialize commitments to canonical bytes (sorted keys).
  Uint8List _canonicalCommitmentsToBytes(
    VerifiableCredential credential,
    Map<String, String> commitments,
  ) {
    final sortedKeys = commitments.keys.toList()..sort();
    final canonical =
        sortedKeys.map((key) => '$key=${commitments[key]}').join('|');

    final fullMessage =
        '${credential.id}|${credential.issuer}|${credential.type}|${credential.schemaId}|'
        '${canonical}';
    return Uint8List.fromList(utf8.encode(fullMessage));
  }

  SimpleKeyPairData _reconstructKeyPair(
      String publicB64, String privateB64) {
    final publicBytes = _decodeBase64Url(publicB64);
    final privateBytes = _decodeBase64Url(privateB64);

    return SimpleKeyPairData(
      privateBytes,
      publicKey: SimplePublicKey(publicBytes, type: KeyPairType.ed25519),
      type: KeyPairType.ed25519,
    );
  }

  Uint8List _decodeBase64Url(String input) {
    var normalized = input;
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    return Uint8List.fromList(base64Url.decode(normalized));
  }
}
