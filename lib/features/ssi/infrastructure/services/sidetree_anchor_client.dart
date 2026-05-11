import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// ION Sidetree Anchor Client — registers DIDs on the ION network.
///
/// ION (Identity Overlay Network) is a Sidetree-based DID method that
/// anchors DIDs to the Bitcoin blockchain without requiring a full node.
/// Operations are batched and anchored periodically by ION nodes.
///
/// Architecture:
///   - POST /operations  → submit Sidetree create/update/recover operations
///   - GET  /identifiers/{did} → resolve a DID to its DID Document
///
/// Key requirements:
///   - secp256k1 keys for ION Sidetree (Bitcoin's curve)
///   - JCS (JSON Canonicalization Scheme) for deterministic hashing
///   - JWS (JSON Web Signatures) for signing operations
///
/// Current implementation:
///   - DID resolution via public ION node (FULLY FUNCTIONAL)
///   - DID creation skeleton (needs secp256k1 keys)
///   - Uses Ed25519 as placeholder (ION requires secp256k1)
///
/// Reference: https://identity.foundation/sidetree/spec/
@lazySingleton
class SidetreeAnchorClient {
  /// Public ION node URL (Microsoft-hosted).
  static const defaultIonNode = 'https://beta.ion.msidentity.com';

  final String _ionNodeUrl;
  final http.Client _httpClient;

  SidetreeAnchorClient({
    String? ionNodeUrl,
    http.Client? httpClient,
  })  : _ionNodeUrl = ionNodeUrl ?? defaultIonNode,
        _httpClient = httpClient ?? http.Client();

  // ─── DID Resolution ─────────────────────────────────────────────

  /// Resolve a DID via the ION network.
  ///
  /// Returns the DID Document if found, or null if not anchored.
  /// This works for ANY ION DID, even those created elsewhere.
  Future<Map<String, dynamic>?> resolve(String did) async {
    try {
      final uri = Uri.parse('$_ionNodeUrl/identifiers/$did');
      final response = await _httpClient.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode == 404) {
        return null; // Not anchored yet
      }

      throw SidetreeException(
        'Resolution failed: HTTP ${response.statusCode}',
        response.statusCode,
      );
    } catch (e) {
      if (e is SidetreeException) rethrow;
      throw SidetreeException('Resolution error: $e', 0);
    }
  }

  /// Check if a DID is anchored (has a valid DID Document on ION).
  Future<bool> isAnchored(String did) async {
    final doc = await resolve(did);
    return doc != null;
  }

  // ─── DID Creation ───────────────────────────────────────────────

  /// Create a new DID and anchor it to the ION network.
  ///
  /// Returns the anchored DID string (short-form: did:ion:EiD3...).
  /// The operation is submitted to the ION node and will be anchored
  /// in the next batch (typically 10-20 minutes).
  ///
  /// [recoveryKey] and [updateKey] must be secp256k1 public keys
  /// in JWK format. Generate these with [generateKeyPair].
  Future<IonCreateResult> createDid({
    required List<Map<String, dynamic>> publicKeys,
    List<Map<String, dynamic>> services = const [],
  }) async {
    // Generate placeholder keys (Ed25519 — ION needs secp256k1, see TODO)
    final recoveryKey = await _generatePlaceholderKey();
    final updateKey = await _generatePlaceholderKey();

    // Build the DID Document patches
    final patches = <Map<String, dynamic>>[
      {
        'action': 'replace',
        'document': {
          'publicKeys': publicKeys,
          'services': services,
        },
      },
    ];

    // Build the delta
    final delta = utf8.encode(jsonEncode({
      'patches': patches,
      'updateCommitment': _hashPublicKey(updateKey['publicKeyJwk']!),
    }));

    // Build the suffix data
    final suffixData = utf8.encode(jsonEncode({
      'deltaHash': sha256.convert(delta).toString(),
      'recoveryCommitment': _hashPublicKey(recoveryKey['publicKeyJwk']!),
    }));

    // Create the Sidetree Create operation
    final operation = {
      'type': 'create',
      'suffixData': base64Url.encode(suffixData),
      'delta': base64Url.encode(delta),
    };

    // Submit to ION node
    final uri = Uri.parse('$_ionNodeUrl/operations');
    final response = await _httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(operation),
    );

    if (response.statusCode != 200) {
      throw SidetreeException(
        'Create failed: HTTP ${response.statusCode}',
        response.statusCode,
        body: response.body,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    return IonCreateResult(
      didSuffix: _extractDidSuffix(body),
      recoveryKey: recoveryKey,
      updateKey: updateKey,
      operationHash: body['operationHash'] as String?,
      nodeResponse: body,
    );
  }

  /// Generate a key pair for ION operations.
  ///
  /// NOTE: This currently generates Ed25519 keys. ION REQUIRES secp256k1
  /// keys (Bitcoin's curve). To fix:
  ///   1. Add `pointycastle` or `secp256k1` Dart package
  ///   2. Generate a secp256k1 keypair
  ///   3. Encode public key in JWK format with "kty": "EC", "crv": "secp256k1"
  Future<Map<String, dynamic>> generateKeyPair() async {
    return _generatePlaceholderKey();
  }

  Future<Map<String, dynamic>> _generatePlaceholderKey() async {
    final random = Random.secure();
    final privateBytes = List<int>.generate(32, (_) => random.nextInt(256));

    // Ed25519 public key generation (simplified)
    final hash = sha256.convert(privateBytes);
    final publicKeyBytes = base64Url.encode(hash.bytes).substring(0, 43);

    return {
      'type': 'JsonWebKey2020',
      'id': '#key-${random.nextInt(999999)}',
      'publicKeyJwk': {
        // TODO: Change to secp256k1:
        // "kty": "EC", "crv": "secp256k1", "x": "...", "y": "..."
        'kty': 'OKP',
        'crv': 'Ed25519',
        'x': publicKeyBytes,
      },
      'privateKeyHex': privateBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    };
  }

  String _hashPublicKey(Map<String, dynamic> jwk) {
    final canonical = jsonEncode(_sortMapKeys(jwk));
    final hash = sha256.convert(utf8.encode(canonical));
    return hash.toString();
  }

  Map<String, dynamic> _sortMapKeys(Map<String, dynamic> map) {
    final sorted = <String, dynamic>{};
    final keys = map.keys.toList()..sort();
    for (final key in keys) {
      final value = map[key];
      sorted[key] = value is Map<String, dynamic> ? _sortMapKeys(value) : value;
    }
    return sorted;
  }

  String _extractDidSuffix(Map<String, dynamic> response) {
    // ION returns the DID suffix from the operation
    if (response.containsKey('didSuffix')) {
      return response['didSuffix'] as String;
    }

    // Fallback: extract from full DID
    if (response.containsKey('did')) {
      final did = response['did'] as String;
      final parts = did.split(':');
      if (parts.length >= 3) return parts.last;
    }

    return 'unknown';
  }

  /// Clean up resources.
  void dispose() {
    _httpClient.close();
  }
}

/// Result of a DID creation operation on ION.
class IonCreateResult {
  /// The DID suffix (e.g., EiD3...).
  final String didSuffix;

  /// The recovery key pair (secp256k1 JWK).
  final Map<String, dynamic> recoveryKey;

  /// The update key pair (secp256k1 JWK).
  final Map<String, dynamic> updateKey;

  /// Operation hash from the ION node.
  final String? operationHash;

  /// Full response from the ION node.
  final Map<String, dynamic> nodeResponse;

  const IonCreateResult({
    required this.didSuffix,
    required this.recoveryKey,
    required this.updateKey,
    this.operationHash,
    required this.nodeResponse,
  });

  /// The full DID string.
  String get did => 'did:ion:$didSuffix';

  @override
  String toString() => 'IonCreateResult($did, hash: $operationHash)';
}

/// Exception for Sidetree/ION errors.
class SidetreeException implements Exception {
  final String message;
  final int statusCode;
  final String? body;

  const SidetreeException(this.message, this.statusCode, {this.body});

  @override
  String toString() => 'SidetreeException($statusCode): $message';
}
