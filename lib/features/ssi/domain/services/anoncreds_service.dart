import '../../domain/entities/verifiable_credential.dart';

/// AnonCreds service — Zero-Knowledge Proofs for Verifiable Credentials.
///
/// Provides:
/// - Credential issuance with cryptographic signatures
/// - Selective disclosure (reveal some claims, prove knowledge of others)
/// - Non-revocation proof generation/verification
/// - Link secret binding (holder-binding, prevents credential sharing)
///
/// Production: uses aries-askar Rust FFI for CL-signature–based AnonCreds.
/// PoC: uses Ed25519 signatures from `cryptography` package.
abstract class AnonCredsService {
  /// Generate a new issuer keypair for signing credentials.
  Future<AnonCredsKeyPair> generateIssuerKeys();

  /// Issue a credential with cryptographic proof.
  ///
  /// Returns the [VerifiableCredential] with an AnonCreds-style proof
  /// that binds claims to the issuer's public key.
  Future<VerifiableCredential> issueCredential({
    required VerifiableCredential credential,
    required AnonCredsKeyPair issuerKeys,
    String? linkSecret,
  });

  /// Create a selective-disclosure presentation from a credential.
  ///
  /// [disclosedFields] are the claims the holder chooses to reveal.
  /// Other claims are proven via cryptographic commitment —
  /// the verifier learns they exist but not their values.
  Future<AnonCredsPresentation> createPresentation({
    required VerifiableCredential credential,
    required List<String> disclosedFields,
    required String? linkSecret,
  });

  /// Verify a presentation's cryptographic proof.
  ///
  /// Returns true if:
  /// - The issuer signature is valid
  /// - The disclosed fields match the committed values
  /// - The link secret matches (for holder binding)
  /// - The credential is not revoked (if revocation registry provided)
  Future<bool> verifyPresentation(
    AnonCredsPresentation presentation, {
    String? expectedLinkSecret,
  });

  /// Revoke a credential (issuer-side).
  ///
  /// Adds the credential index to the revocation registry.
  /// Future verifications can check non-revocation via the registry.
  Future<void> revokeCredential(String credentialId, AnonCredsKeyPair issuerKeys);

  /// Check if a specific credential has been revoked.
  ///
  /// Returns true if a valid revocation entry exists for the given
  /// [issuerPublicKey] and [credentialIndex].
  Future<bool> isCredentialRevoked(String issuerPublicKey, int credentialIndex);

  /// Check if the service is available.
  Future<bool> isAvailable();
}

/// Key pair for AnonCreds operations.
class AnonCredsKeyPair {
  /// Public key (for verification, shared freely).
  final String publicKey;

  /// Private key (for signing, kept secret by issuer).
  final String privateKey;

  /// Key type identifier.
  final String keyType;

  const AnonCredsKeyPair({
    required this.publicKey,
    required this.privateKey,
    this.keyType = 'Ed25519',
  });

  Map<String, dynamic> toJson() => {
        'publicKey': publicKey,
        'privateKey': privateKey,
        'keyType': keyType,
      };

  factory AnonCredsKeyPair.fromJson(Map<String, dynamic> json) {
    return AnonCredsKeyPair(
      publicKey: json['publicKey'] as String,
      privateKey: json['privateKey'] as String,
      keyType: json['keyType'] as String? ?? 'Ed25519',
    );
  }
}

/// Zero-knowledge presentation with selective disclosure.
class AnonCredsPresentation {
  /// The credential being presented (partially disclosed).
  final VerifiableCredential credential;

  /// Fields disclosed to the verifier.
  final Map<String, dynamic> disclosedFields;

  /// Cryptographic commitments for non-disclosed fields.
  final Map<String, String> hiddenCommitments;

  /// Signature over the full credential (issuer's proof).
  final String issuerSignature;

  /// Presentation timestamp.
  final DateTime createdAt;

  const AnonCredsPresentation({
    required this.credential,
    required this.disclosedFields,
    required this.hiddenCommitments,
    required this.issuerSignature,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'credential': credential.toJson(),
        'disclosedFields': disclosedFields,
        'hiddenCommitments': hiddenCommitments,
        'issuerSignature': issuerSignature,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AnonCredsPresentation.fromJson(Map<String, dynamic> json) {
    return AnonCredsPresentation(
      credential: VerifiableCredential.fromJson(json['credential'] as Map<String, dynamic>),
      disclosedFields: json['disclosedFields'] as Map<String, dynamic>,
      hiddenCommitments: Map<String, String>.from(json['hiddenCommitments'] as Map),
      issuerSignature: json['issuerSignature'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
