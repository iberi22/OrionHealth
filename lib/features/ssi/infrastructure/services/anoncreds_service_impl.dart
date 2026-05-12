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

/// AnonCreds PoC implementation using Ed25519 + SHA256 commitments.
///
/// Production path: replace with aries-askar Rust FFI.
/// This implementation provides:
/// - Ed25519 issuer signatures (real crypto, production-ready key strength)
/// - SHA256 hash commitments for selective disclosure (secure but not ZKP)
/// - In-memory revocation registry
///
/// Gap from real AnonCreds:
/// - No CL-signatures (Camenisch-Lysyanskaya) — currently using EdDSA
/// - No true zero-knowledge proofs — hash commitments are not ZKP
/// - No link secrets for holder binding (placeholder)
///
/// References:
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

    final publicKey = data.publicKey;

    return AnonCredsKeyPair(
      publicKey: base64Url.encode(publicKey.bytes).replaceAll('=', ''),
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

    // Generate random salts for each claim to prevent brute-force/dictionary attacks
    final salts = <String, String>{};
    for (final key in credential.claims.keys) {
      salts[key] = _generateSalt();
    }

    if (linkSecret != null) {
      salts['_link_secret'] = _generateSalt();
    }

    // Compute commitments and sign them
    final message = _credentialToCanonicalCommitments(credential, salts, linkSecret);
    final signature = await _ed25519.sign(message, keyPair: keyPair);

    // Add index for revocation tracking
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

  /// Get the next available index for a given issuer.
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
        // Compute hidden commitment: H(key:value:salt)
        final salt = salts[entry.key] ?? '';
        hiddenCommitments[entry.key] =
            _computeCommitment(entry.key, entry.value.toString(), salt);
      }
    }

    // Link secret is always proven via commitment, never disclosed as raw value
    if (linkSecret != null && salts.containsKey('_link_secret')) {
      final salt = salts['_link_secret']!;
      disclosedSalts['_link_secret'] = salt;
      // We don't put the link secret in disclosedFields, the verifier will use
      // its own 'expectedLinkSecret' to verify the commitment.
    } else if (salts.containsKey('_link_secret')) {
      // If we have a link secret but didn't provide it for this presentation,
      // we must provide the commitment.
      // Note: in real AnonCreds, link secret is usually mandatory if present.
    }

    // Redact the credential to remove hidden claims and salts from the
    // presentation object, ensuring they are not leaked even if serialized.
    final redactedClaims = Map<String, dynamic>.from(disclosed);

    // Also redact the salts from the proof JSON to prevent leakage
    final redactedProofJson = proof != null
        ? jsonEncode({
            ...proof,
            'salts': {}, // Remove all salts from the proof metadata
          })
        : null;

    final redactedCredential = VerifiableCredential(
      id: credential.id,
      issuer: credential.issuer,
      subject: credential.subject,
      type: credential.type,
      schemaId: credential.schemaId,
      claims: redactedClaims,
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
    final proof = _parseProof(presentation.credential.proof);
    if (proof == null) return false;

    final signatureB64 = proof['signatureValue'] as String?;
    final issuerKeyB64 = proof['issuerKey'] as String?;
    if (signatureB64 == null || issuerKeyB64 == null) return false;

    // Reconstruct the commitments list
    final commitments = <String, String>{};

    // 1. Reconstruct commitments for disclosed fields
    for (final entry in presentation.disclosedFields.entries) {
      final salt = presentation.disclosedSalts[entry.key];
      if (salt == null) return false;
      commitments[entry.key] =
          _computeCommitment(entry.key, entry.value.toString(), salt);
    }

    // 2. Add hidden commitments provided in the presentation
    commitments.addAll(presentation.hiddenCommitments);

    // 3. Handle link secret verification if expected
    if (proof['hasLinkSecret'] == true) {
      if (expectedLinkSecret == null) return false; // Holder binding required
      final salt = presentation.disclosedSalts['_link_secret'];
      if (salt == null) return false;
      commitments['_link_secret'] =
          _computeCommitment('_link_secret', expectedLinkSecret, salt);
    }

    // Reconstruct the public key
    final publicKey = SimplePublicKey(
      _decodeBase64Url(issuerKeyB64),
      type: KeyPairType.ed25519,
    );

    // Verify issuer signature over the commitments
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

    // Check non-revocation
    final credentialIndex = proof['credentialIndex'] as int?;
    if (credentialIndex != null) {
      final revocationEntry = await _repository.getRevocationEntry(
        issuerKeyB64,
        credentialIndex,
      );

      if (revocationEntry != null) {
        // Verify revocation signature
        final dataToVerify = '${revocationEntry.issuerPublicKey}:${revocationEntry.credentialIndex}:${revocationEntry.revokedAt.toIso8601String()}';
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

        if (isSignatureValid) {
          return false; // Credential is validly revoked
        }
      }
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

    final revokedAt = DateTime.now();
    final dataToSign = '${issuerKeys.publicKey}:$credentialIndex:${revokedAt.toIso8601String()}';

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
  }

  @override
  Future<bool> isAvailable() async => true;

  // ─── Internal ───────────────────────────────────────────────────

  /// Parse a JSON-encoded proof string into a map.
  Map<String, dynamic>? _parseProof(String? proofJson) {
    if (proofJson == null || proofJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(proofJson);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Generate a random 32-byte salt and return it as base64url.
  String _generateSalt() {
    final random = Random.secure();
    final bytes =
        Uint8List.fromList(List<int>.generate(32, (_) => random.nextInt(256)));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Compute a salted commitment for a claim.
  String _computeCommitment(String key, String value, String salt) {
    // Format: key:value:salt to ensure commitment is bound to the specific attribute
    return sha256.convert(utf8.encode('$key:$value:$salt')).toString();
  }

  /// Serialize credential commitments to canonical bytes for signing.
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

  /// Format commitments into a canonical byte array for signature.
  Uint8List _canonicalCommitmentsToBytes(
    VerifiableCredential credential,
    Map<String, String> commitments,
  ) {
    final sortedKeys = commitments.keys.toList()..sort();
    final canonical =
        sortedKeys.map((key) => '$key=${commitments[key]}').join('|');

    final fullMessage =
        '${credential.id}|${credential.issuer}|${credential.type}|${credential.schemaId}|'
        '${credential.issuanceDate.toIso8601String()}|'
        '${credential.expirationDate?.toIso8601String()}|$canonical';

    return Uint8List.fromList(utf8.encode(fullMessage));
  }

  /// Reconstruct a SimpleKeyPairData from base64-encoded keys.
  SimpleKeyPairData _reconstructKeyPair(
      String publicB64, String privateB64) {
    final publicBytes = _decodeBase64Url(publicB64);
    final privateBytes = _decodeBase64Url(privateB64);

    final publicKey = SimplePublicKey(
      publicBytes,
      type: KeyPairType.ed25519,
    );

    return SimpleKeyPairData(
      privateBytes,
      publicKey: publicKey,
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
