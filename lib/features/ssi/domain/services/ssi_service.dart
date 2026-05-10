import '../entities/did.dart';
import '../entities/verifiable_credential.dart';

/// SSI Service — Hexagonal port for Self-Sovereign Identity operations.
///
/// Architecture Decision: Hybrid Aries + Sidetree
/// - DID: Sidetree-inspired Long-Form DIDs (offline-first)
/// - VC: AnonCreds-compatible with selective disclosure
/// - Storage: Local Isar vault, P2P sync via BLE
///
/// Reference: docs/research/SSI_ARCHITECTURE_DECISION.md
abstract class SsiService {
  /// Generate a new Long-Form DID for the user.
  /// This DID is usable immediately without blockchain anchoring.
  Future<Did> createDid();

  /// Resolve a DID to its DID Document.
  /// Supports both short-form (anchored) and long-form DIDs.
  Future<Map<String, dynamic>?> resolveDid(String did);

  /// Issue a new verifiable credential.
  /// The credential is signed with the issuer's DID key.
  Future<VerifiableCredential> issueCredential({
    required String schemaId,
    required String subjectDid,
    required Map<String, dynamic> claims,
    DateTime? expirationDate,
  });

  /// Verify a credential's integrity and revocation status.
  Future<bool> verifyCredential(VerifiableCredential credential);

  /// Create a selective-disclosure presentation.
  /// Returns only the claims specified in [fields],
  /// with a Zero-Knowledge Proof that the full credential is valid.
  Future<Map<String, dynamic>> createPresentation({
    required VerifiableCredential credential,
    required List<String> disclosedFields,
  });

  /// Revoke a previously issued credential.
  Future<void> revokeCredential(String credentialId);

  /// Check if SSI capabilities are available on this device.
  Future<bool> isAvailable();
}
