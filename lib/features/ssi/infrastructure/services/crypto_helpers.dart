import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Shared cryptographic helpers for SSI services.
///
/// Extracted from [SsiServiceImpl] to eliminate duplication
/// across SSI and AnonCreds service implementations.
///
/// Provides:
/// - Deterministic JSON-based claim canonicalization for signing/verification
/// - Ed25519 proof generation
class CryptoHelpers {
  CryptoHelpers._(); // Static class — no instantiation

  /// Canonicalize claims into a deterministic JSON string for signing/verification.
  ///
  /// Claims are sorted alphabetically by key and the entire structure is
  /// serialized as a JSON object. This prevents collision attacks where
  /// claim values containing pipe characters could produce identical
  /// canonical strings for different claim sets.
  static String canonicalizeClaims({
    required String credentialId,
    required Map<String, dynamic> claims,
    required String issuer,
    String? schemaId,
    DateTime? issuanceDate,
    DateTime? expirationDate,
  }) {
    final sortedClaims = Map.fromEntries(
      claims.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return jsonEncode({
      'credentialId': credentialId,
      'claims': sortedClaims,
      'issuer': issuer,
      'schemaId': schemaId,
      'issuanceDate': issuanceDate?.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
    });
  }

  /// Generate an Ed25519 signature proof for a set of claims.
  ///
  /// Takes a pre-built [keyPair] instead of a raw seed to decouple
  /// key derivation from signing logic.
  ///
  /// Returns the base64Url-encoded signature bytes.
  static Future<String> generateProof({
    required String credentialId,
    required Map<String, dynamic> claims,
    required String issuer,
    required SimpleKeyPair keyPair,
    String? schemaId,
    DateTime? issuanceDate,
    DateTime? expirationDate,
  }) async {
    final data = canonicalizeClaims(
      credentialId: credentialId,
      claims: claims,
      issuer: issuer,
      schemaId: schemaId,
      issuanceDate: issuanceDate,
      expirationDate: expirationDate,
    );
    final signature = await Ed25519().sign(
      utf8.encode(data),
      keyPair: keyPair,
    );
    return base64Url.encode(signature.bytes);
  }
}
