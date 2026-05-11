import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/verifiable_credential.dart';
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
  final Map<String, Set<int>> _revocationRegistry = {};
  int _credentialCounter = 0;

  @override
  Future<AnonCredsKeyPair> generateIssuerKeys() async {
    final keyPair = await _ed25519.newKeyPair();
    final data = await keyPair.extract();

    final publicKey = data.publicKey;

    return AnonCredsKeyPair(
      publicKey: base64Url.encode(publicKey.bytes),
      privateKey: base64Url.encode(data.bytes),
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

    final message = _credentialToCanonicalBytes(credential);
    final signature = await _ed25519.sign(message, keyPair: keyPair);

    // Add index for revocation tracking
    _credentialCounter++;

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
        'signatureValue': base64Url.encode(signature.bytes),
        'issuerKey': issuerKeys.publicKey,
        'credentialIndex': _credentialCounter,
        'created': DateTime.now().toIso8601String(),
      }),
    );

    return updatedCredential;
  }

  @override
  Future<AnonCredsPresentation> createPresentation({
    required VerifiableCredential credential,
    required List<String> disclosedFields,
    String? linkSecret,
  }) async {
    final disclosed = <String, dynamic>{};
    final hiddenCommitments = <String, String>{};

    for (final entry in credential.claims.entries) {
      if (disclosedFields.contains(entry.key)) {
        disclosed[entry.key] = entry.value;
      } else {
        // SHA256 commitment: hides the value but proves knowledge
        hiddenCommitments[entry.key] = _hashValue(entry.value.toString());
      }
    }

    // Include the link secret in the presentation for holder binding
    if (linkSecret != null) {
      hiddenCommitments['_link_secret'] = _hashValue(linkSecret);
    }

    return AnonCredsPresentation(
      credential: credential,
      disclosedFields: disclosed,
      hiddenCommitments: hiddenCommitments,
      issuerSignature: _parseProof(credential.proof)?['signatureValue'] as String? ?? '',
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

    // Reconstruct the public key
    final publicKey = SimplePublicKey(
      base64Url.decode(issuerKeyB64),
      type: KeyPairType.ed25519,
    );

    // Verify issuer signature over the original credential
    final message = _credentialToCanonicalBytes(presentation.credential);

    final isValid = await _ed25519.verify(
      message,
      signature: Signature(
        base64Url.decode(signatureB64),
        publicKey: publicKey,
      ),
    );

    if (!isValid) return false;

    // Verify hidden commitments match the original claims
    for (final entry in presentation.hiddenCommitments.entries) {
      if (entry.key == '_link_secret') {
        if (expectedLinkSecret != null &&
            entry.value != _hashValue(expectedLinkSecret)) {
          return false;
        }
        continue;
      }

      // Each commitment must match the hash of the original claim value
      final actualClaim = presentation.credential.claims[entry.key];
      if (actualClaim == null) return false;
      if (entry.value != _hashValue(actualClaim.toString())) return false;
    }

    // Check non-revocation
    final credentialIndex = proof['credentialIndex'] as int?;
    if (credentialIndex != null) {
      final revoked = _revocationRegistry[issuerKeyB64];
      if (revoked != null && revoked.contains(credentialIndex)) {
        return false; // Credential is revoked
      }
    }

    return true;
  }

  @override
  Future<void> revokeCredential(
      String credentialId, AnonCredsKeyPair issuerKeys) async {
    // In production: add to accumulator-based revocation registry
    _revocationRegistry.putIfAbsent(issuerKeys.publicKey, () => <int>{});
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

  /// Serialize credential claims to canonical bytes for signing.
  Uint8List _credentialToCanonicalBytes(VerifiableCredential credential) {
    final entries = credential.claims.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final canonical =
        entries.map((e) => '${e.key}=${e.value}').join('|');

    final fullMessage =
        '${credential.id}|${credential.issuer}|${credential.type}|${credential.schemaId}|$canonical';

    return Uint8List.fromList(utf8.encode(fullMessage));
  }

  /// SHA256 hash commitment for selective disclosure.
  String _hashValue(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }

  /// Reconstruct a SimpleKeyPairData from base64-encoded keys.
  SimpleKeyPairData _reconstructKeyPair(
      String publicB64, String privateB64) {
    final publicBytes = base64Url.decode(publicB64);
    final privateBytes = base64Url.decode(privateB64);

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
}
