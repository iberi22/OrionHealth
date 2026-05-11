import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:orionhealth_health/features/ssi/infrastructure/services/sidetree_anchor_client.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late SidetreeAnchorClient client;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = SidetreeAnchorClient(httpClient: mockHttpClient);
  });

  group('SidetreeAnchorClient', () {
    group('resolve', () {
      const did = 'did:ion:test-did';
      final mockDoc = {'id': did, 'verificationMethod': []};

      test('returns decoded JSON when response is 200', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(jsonEncode(mockDoc), 200));

        final result = await client.resolve(did);

        expect(result, equals(mockDoc));
        verify(() => mockHttpClient.get(
              Uri.parse('${SidetreeAnchorClient.defaultIonNode}/identifiers/$did'),
              headers: {'Accept': 'application/json'},
            )).called(1);
      });

      test('returns null when response is 404', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        final result = await client.resolve(did);

        expect(result, isNull);
      });

      test('throws SidetreeException when response is not 200 or 404', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('Internal Server Error', 500));

        expect(() => client.resolve(did), throwsA(isA<SidetreeException>()));
      });

      test('throws SidetreeException on network error', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenThrow(Exception('Network Error'));

        expect(() => client.resolve(did), throwsA(isA<SidetreeException>()));
      });
    });

    group('isAnchored', () {
      const did = 'did:ion:test-did';

      test('returns true when resolve returns a document', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(jsonEncode({'id': did}), 200));

        final result = await client.isAnchored(did);

        expect(result, isTrue);
      });

      test('returns false when resolve returns null', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        final result = await client.isAnchored(did);

        expect(result, isFalse);
      });
    });

    group('createDid', () {
      final publicKeys = [
        {'id': 'key-1', 'type': 'EcdsaSecp256k1VerificationKey2019'}
      ];
      final mockResponse = {
        'didSuffix': 'test-suffix',
        'operationHash': 'test-hash',
      };

      test('returns IonCreateResult on success', () async {
        when(() => mockHttpClient.post(any(),
                headers: any(named: 'headers'), body: any(named: 'body')))
            .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await client.createDid(publicKeys: publicKeys);

        expect(result, isA<IonCreateResult>());
        expect(result.didSuffix, equals('test-suffix'));
        expect(result.did, equals('did:ion:test-suffix'));
        expect(result.operationHash, equals('test-hash'));

        verify(() => mockHttpClient.post(
              Uri.parse('${SidetreeAnchorClient.defaultIonNode}/operations'),
              headers: {'Content-Type': 'application/json'},
              body: any(named: 'body'),
            )).called(1);
      });

      test('throws SidetreeException on error', () async {
        when(() => mockHttpClient.post(any(),
                headers: any(named: 'headers'), body: any(named: 'body')))
            .thenAnswer((_) async => http.Response('Error', 500));

        expect(() => client.createDid(publicKeys: publicKeys),
            throwsA(isA<SidetreeException>()));
      });
    });

    group('generateKeyPair', () {
      test('returns valid JWK structure', () async {
        final keyPair = await client.generateKeyPair();

        expect(keyPair['type'], equals('JsonWebKey2020'));
        expect(keyPair['id'], startsWith('#key-'));
        expect(keyPair['publicKeyJwk'], isA<Map>());
        expect(keyPair['publicKeyJwk']['kty'], equals('OKP'));
        expect(keyPair['publicKeyJwk']['crv'], equals('Ed25519'));
        expect(keyPair['publicKeyJwk']['x'], isA<String>());
        expect(keyPair['privateKeyHex'], isA<String>());
        expect(keyPair['privateKeyHex'].length, equals(64)); // 32 bytes in hex
      });
    });
  });
}
