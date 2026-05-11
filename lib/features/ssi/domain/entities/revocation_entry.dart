/// Cryptographically verifiable revocation entry.
///
/// Tracks revoked credentials by their index within an issuer's
/// revocation registry. Includes an issuer signature to prevent
/// unauthorized revocation records.
class RevocationEntry {
  /// Unique credential identifier being revoked
  final String credentialId;

  /// Index of the credential in the issuer's registry
  final int credentialIndex;

  /// Public key of the issuer who revoked the credential
  final String issuerPublicKey;

  /// Timestamp of revocation
  final DateTime revokedAt;

  /// Issuer signature over (issuerPublicKey + credentialIndex + revokedAt)
  final String issuerSignature;

  const RevocationEntry({
    required this.credentialId,
    required this.credentialIndex,
    required this.issuerPublicKey,
    required this.revokedAt,
    required this.issuerSignature,
  });

  Map<String, dynamic> toJson() => {
        'credentialId': credentialId,
        'credentialIndex': credentialIndex,
        'issuerPublicKey': issuerPublicKey,
        'revokedAt': revokedAt.toIso8601String(),
        'issuerSignature': issuerSignature,
      };

  factory RevocationEntry.fromJson(Map<String, dynamic> json) => RevocationEntry(
        credentialId: json['credentialId'] as String,
        credentialIndex: json['credentialIndex'] as int,
        issuerPublicKey: json['issuerPublicKey'] as String,
        revokedAt: DateTime.parse(json['revokedAt'] as String),
        issuerSignature: json['issuerSignature'] as String,
      );
}
