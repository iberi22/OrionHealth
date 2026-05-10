/// Verifiable Credential (VC) entity.
///
/// Represents a W3C-compliant credential that can be shared
/// with selective disclosure via AnonCreds Zero-Knowledge Proofs.
///
/// Medical credential types include: vaccination records,
/// lab results, prescriptions, and insurance eligibility.
///
/// Reference: W3C Verifiable Credentials Data Model v1.1
class VerifiableCredential {
  /// Unique credential identifier
  final String id;

  /// DID of the issuer (e.g., clinic, lab, pharmacy)
  final String issuer;

  /// DID of the subject (the patient)
  final String subject;

  /// Credential type (e.g., VaccinationCredential, LabResultCredential)
  final String type;

  /// Schema identifier for this credential type
  final String schemaId;

  /// The actual claims/attributes (selective disclosure targets)
  final Map<String, dynamic> claims;

  /// Issuance date
  final DateTime issuanceDate;

  /// Expiration date, if any
  final DateTime? expirationDate;

  /// Cryptographic proof (signature)
  final String? proof;

  /// Whether this credential has been revoked
  final bool isRevoked;

  const VerifiableCredential({
    required this.id,
    required this.issuer,
    required this.subject,
    required this.type,
    required this.schemaId,
    required this.claims,
    required this.issuanceDate,
    this.expirationDate,
    this.proof,
    this.isRevoked = false,
  });

  /// Whether this credential is currently valid.
  bool get isValid {
    if (isRevoked) return false;
    if (expirationDate != null && DateTime.now().isAfter(expirationDate!)) {
      return false;
    }
    return true;
  }

  /// Claims that can be selectively disclosed.
  List<String> get disclosableClaims => claims.keys.toList();

  /// Create a presentation with only the specified claims revealed.
  Map<String, dynamic> selectiveDisclosure(List<String> fields) {
    final filtered = <String, dynamic>{};
    for (final field in fields) {
      if (claims.containsKey(field)) {
        filtered[field] = claims[field];
      }
    }
    return filtered;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'issuer': issuer,
        'subject': subject,
        'type': type,
        'schemaId': schemaId,
        'claims': claims,
        'issuanceDate': issuanceDate.toIso8601String(),
        'expirationDate': expirationDate?.toIso8601String(),
        'proof': proof,
        'isRevoked': isRevoked,
      };

  factory VerifiableCredential.fromJson(Map<String, dynamic> json) => VerifiableCredential(
        id: json['id'] as String,
        issuer: json['issuer'] as String,
        subject: json['subject'] as String,
        type: json['type'] as String,
        schemaId: json['schemaId'] as String,
        claims: Map<String, dynamic>.from(json['claims'] as Map),
        issuanceDate: DateTime.parse(json['issuanceDate'] as String),
        expirationDate: json['expirationDate'] != null
            ? DateTime.parse(json['expirationDate'] as String)
            : null,
        proof: json['proof'] as String?,
        isRevoked: json['isRevoked'] as bool? ?? false,
      );

  @override
  String toString() => 'VerifiableCredential($id, type: $type)';
}
