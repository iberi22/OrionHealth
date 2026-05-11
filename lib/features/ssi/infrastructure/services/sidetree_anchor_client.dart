import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/did.dart';

/// Client for anchoring and resolving DIDs on the ION/Sidetree network.
///
/// This client interacts with a Sidetree REST API to perform DID operations
/// and resolve DID Documents from the blockchain (Bitcoin via ION).
///
/// Reference: https://identity.foundation/sidetree/spec/
@lazySingleton
class SidetreeAnchorClient {
  final Dio _dio;

  // Default ION node endpoint
  static const String defaultIonNodeUrl = 'https://ion.orionhealth.com/v1/identifiers';

  SidetreeAnchorClient(this._dio);

  /// Anchors a Long-Form DID to the ION network.
  ///
  /// Sends a 'create' operation to the ION node. If successful,
  /// returns an updated [Did] with the short-form DID and anchored status.
  Future<Did> anchorDid(Did did) async {
    try {
      // Sidetree 'create' operation requires suffixData and delta
      final operation = {
        'type': 'create',
        'suffixData': _generateSuffixData(did.longForm),
        'delta': _generateDelta(did.longForm),
      };

      final response = await _dio.post(defaultIonNodeUrl, data: operation);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        // The node returns the anchored DID (short-form) in the DID Document
        final shortForm = data['didDocument']?['id'] as String?;

        return Did(
          did: did.did,
          shortForm: shortForm,
          longForm: did.longForm,
          createdAt: did.createdAt,
          isAnchored: true,
          keyType: did.keyType,
        );
      }
      return did;
    } catch (e) {
      // Fallback to original DID if anchoring fails (still usable as long-form)
      return did;
    }
  }

  /// Updates an anchored DID Document.
  ///
  /// Sends an 'update' operation with a JSON Patch.
  /// NOTE: Requires JWS signing of the operation data in production.
  Future<bool> updateDid(String did, Map<String, dynamic> patch) async {
    try {
      final operation = {
        'type': 'update',
        'didSuffix': did.split(':').last,
        'revealValue': _hashValue('reveal_seed'),
        'delta': {
          'patches': [patch],
          'updateCommitment': _hashValue('next_update_seed'),
        },
        'signedData': 'jws_placeholder', // TODO: Implement JWS signing
      };

      final response = await _dio.post(defaultIonNodeUrl, data: operation);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Recovers a DID after key loss.
  ///
  /// Sends a 'recover' operation to reset the DID state.
  /// NOTE: Requires JWS signing of the operation data in production.
  Future<bool> recoverDid(String did, Map<String, dynamic> nextState) async {
    try {
      final operation = {
        'type': 'recover',
        'didSuffix': did.split(':').last,
        'revealValue': _hashValue('recovery_seed'),
        'delta': nextState,
        'signedData': 'jws_placeholder', // TODO: Implement JWS signing
      };

      final response = await _dio.post(defaultIonNodeUrl, data: operation);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Resolves a DID (short-form or long-form) via the ION node.
  Future<Map<String, dynamic>?> resolveDid(String did) async {
    try {
      final response = await _dio.get('$defaultIonNodeUrl/$did');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─── Private Helpers (Protocol Logic) ──────────────────

  String _hashValue(String value) {
    final bytes = utf8.encode(value);
    final digest = sha256.convert(bytes);
    // ION uses multihash-style encoding, usually starts with 'Ei' for SHA-256
    return 'Ei${base64Url.encode(digest.bytes).replaceAll('=', '')}';
  }

  Map<String, dynamic> _generateSuffixData(String longForm) {
    // Suffix data includes the delta hash and recovery commitment
    return {
      'deltaHash': _hashValue(longForm + '.delta'),
      'recoveryCommitment': _hashValue(longForm + '.recovery'),
    };
  }

  Map<String, dynamic> _generateDelta(String longForm) {
    // Delta contains the patches (public keys, services) and next update commitment
    return {
      'patches': [
        {
          'action': 'replace',
          'document': {
            'publicKeys': [
              {
                'id': 'keys-1',
                'type': 'EcdsaSecp256k1VerificationKey2019',
                'publicKeyJwk': {
                  'kty': 'EC',
                  'crv': 'secp256k1',
                  'x': base64Url.encode(utf8.encode('x-placeholder')),
                  'y': base64Url.encode(utf8.encode('y-placeholder'))
                }
              }
            ],
            'services': []
          }
        }
      ],
      'updateCommitment': _hashValue(longForm + '.update'),
    };
  }
}
