import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/sidetree_anchor_client.dart';

void main() {
  group('SidetreeAnchorClient Key Generation', () {
    final client = SidetreeAnchorClient();

    test('generateKeyPair() returns valid secp256k1 JWK', () async {
      final keyPair = await client.generateKeyPair();

      expect(keyPair['type'], 'JsonWebKey2020');
      expect(keyPair['publicKeyJwk'], isNotNull);

      final jwk = keyPair['publicKeyJwk'] as Map<String, dynamic>;
      expect(jwk['kty'], 'EC');
      expect(jwk['crv'], 'secp256k1');
      expect(jwk['x'], isNotNull);
      expect(jwk['y'], isNotNull);

      // x and y should be 43 characters (base64url for 32 bytes)
      expect((jwk['x'] as String).length, 43);
      expect((jwk['y'] as String).length, 43);

      expect(keyPair['privateKeyHex'], isNotNull);
      expect((keyPair['privateKeyHex'] as String).length, 64); // 32 bytes hex
    });

    test('generateKeyPair() generates unique keys', () async {
      final key1 = await client.generateKeyPair();
      final key2 = await client.generateKeyPair();

      expect(key1['privateKeyHex'], isNot(key2['privateKeyHex']));
      expect(key1['publicKeyJwk']['x'], isNot(key2['publicKeyJwk']['x']));
    });
  });
}
