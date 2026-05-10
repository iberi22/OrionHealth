/// Decentralized Identifier (DID) entity.
///
/// Follows the W3C DID Core specification with Sidetree-inspired
/// Long-Form DID support for offline-first identity generation.
///
/// A Long-Form DID can be used immediately for cryptographic operations
/// without waiting for blockchain anchoring.
///
/// Reference: docs/research/SSI_ARCHITECTURE_DECISION.md
class Did {
  /// Full DID string (e.g., did:ion:EiD3...)
  final String did;

  /// Short-form DID (anchored), null if only long-form exists
  final String? shortForm;

  /// Long-form DID (includes initial state delta)
  final String longForm;

  /// Creation timestamp
  final DateTime createdAt;

  /// Whether this DID has been anchored to a blockchain
  final bool isAnchored;

  /// Key type used for this DID (e.g., secp256k1, Ed25519)
  final String keyType;

  const Did({
    required this.did,
    this.shortForm,
    required this.longForm,
    required this.createdAt,
    this.isAnchored = false,
    this.keyType = 'Ed25519',
  });

  /// The active DID string to use in operations.
  /// Prefers short-form if anchored, otherwise uses long-form.
  String get activeDid => shortForm ?? longForm;

  /// Whether this DID can be used for verifiable credentials.
  bool get isUsable => true; // Long-form DIDs are usable immediately

  Map<String, dynamic> toJson() => {
        'did': did,
        'shortForm': shortForm,
        'longForm': longForm,
        'createdAt': createdAt.toIso8601String(),
        'isAnchored': isAnchored,
        'keyType': keyType,
      };

  factory Did.fromJson(Map<String, dynamic> json) => Did(
        did: json['did'] as String,
        shortForm: json['shortForm'] as String?,
        longForm: json['longForm'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isAnchored: json['isAnchored'] as bool? ?? false,
        keyType: json['keyType'] as String? ?? 'Ed25519',
      );

  @override
  String toString() => 'Did($activeDid, anchored: $isAnchored)';
}
