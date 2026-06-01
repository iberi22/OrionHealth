import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:pointycastle/export.dart';

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
///   - Uses secp256k1 for key generation (ION REQUIREMENT)
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

  @factoryMethod
  static SidetreeAnchorClient create() => SidetreeAnchorClient();

  // ─── Retry Logic ────────────────────────────────────────────────

  /// Executes [operation] with exponential backoff on transient
  /// network errors (SocketException, TimeoutException,
  /// http.ClientException). Does NOT retry on HTTP error responses
  /// (4xx/5xx), which are thrown as [SidetreeException].
  Future<T> _withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await operation();
      } on SidetreeException {
        rethrow; // Don't retry HTTP error responses
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;

        if (e is SocketException ||
            e is TimeoutException ||
            e is http.ClientException) {
          final delayMs = (1 << (attempt - 1)) * 1000; // 1s, 2s, 4s
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }
        rethrow;
      }
    }
  }

  // ─── DID Resolution ─────────────────────────────────────────────

  /// Resolve a DID via the ION network.
  ///
  /// Returns the DID Document if found, or null if not anchored.
  /// This works for ANY ION DID, even those created elsewhere.
  Future<Map<String, dynamic>?> resolve(String did) async {
    try {
      return await _withRetry(() async {
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
      });
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
    // Generate real secp256k1 keys for ION
    final recoveryKey = await generateKeyPair();
    final updateKey = await generateKeyPair();

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

    // Build the delta (hash the update key as multihash)
    final delta = utf8.encode(jsonEncode({
      'patches': patches,
      'updateCommitment': _hashPublicKey(updateKey['publicKeyJwk']!),
    }));

    // Build the suffix data (deltaHash is multihash of the delta bytes)
    final suffixData = utf8.encode(jsonEncode({
      'deltaHash': _base64UrlNoPadding(_multihashSha256(delta)),
      'recoveryCommitment': _hashPublicKey(recoveryKey['publicKeyJwk']!),
    }));

    // Create the Sidetree Create operation
    final operation = {
      'type': 'create',
      'suffixData': _base64UrlNoPadding(suffixData),
      'delta': _base64UrlNoPadding(delta),
    };

    // Submit to ION node with retry on transient network errors
    return _withRetry(() async {
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
    });
  }

  /// Generate a key pair for ION operations.
  ///
  /// Generates a secp256k1 key pair (Bitcoin's curve) and returns it
  /// in JWK format for the public key and hex format for the private key.
  Future<Map<String, dynamic>> generateKeyPair() async {
    final domainParams = ECDomainParameters('secp256k1');
    final keyGen = ECKeyGenerator();

    final random = Random.secure();
    final seed = Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));

    keyGen.init(ParametersWithRandom(
      ECKeyGeneratorParameters(domainParams),
      FortunaRandom()..seed(KeyParameter(seed)),
    ));

    final pair = keyGen.generateKeyPair();
    final publicKey = pair.publicKey as ECPublicKey;
    final privateKey = pair.privateKey as ECPrivateKey;

    final xBigInt = publicKey.Q!.x!.toBigInteger()!;
    final yBigInt = publicKey.Q!.y!.toBigInteger()!;
    final d = privateKey.d!;

    final xBytes = _bigIntToUint8List(xBigInt);
    final yBytes = _bigIntToUint8List(yBigInt);
    final privateKeyHex = d.toRadixString(16).padLeft(64, '0');

    return {
      'type': 'JsonWebKey2020',
      'id': '#key-${random.nextInt(999999)}',
      'publicKeyJwk': {
        'kty': 'EC',
        'crv': 'secp256k1',
        'x': _base64UrlNoPadding(xBytes),
        'y': _base64UrlNoPadding(yBytes),
      },
      'privateKeyHex': privateKeyHex,
    };
  }

  String _base64UrlNoPadding(List<int> bytes) {
    return base64Url.encode(bytes).split('=').first;
  }

  Uint8List _bigIntToUint8List(BigInt bi) {
    var hex = bi.toRadixString(16);
    if (hex.length % 2 != 0) {
      hex = '0$hex';
    }
    // Ensure 32 bytes for secp256k1 coordinates
    while (hex.length < 64) {
      hex = '00$hex';
    }
    if (hex.length > 64) {
      hex = hex.substring(hex.length - 64);
    }

    final result = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  /// Encode a SHA-256 hash as a multihash per the Sidetree spec.
  ///
  /// Multihash format: [hash code (0x12)] [length (0x20)] [32-byte digest]
  Uint8List _multihashSha256(Uint8List data) {
    final hashBytes = sha256.convert(data).bytes;
    final result = Uint8List(2 + hashBytes.length);
    result[0] = 0x12; // SHA2-256 multicodec
    result[1] = hashBytes.length; // 32
    result.setRange(2, result.length, hashBytes);
    return result;
  }

  String _hashPublicKey(Map<String, dynamic> jwk) {
    final canonical = jsonEncode(_sortMapKeys(jwk));
    final multihash = _multihashSha256(utf8.encode(canonical));
    return _base64UrlNoPadding(multihash);
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
