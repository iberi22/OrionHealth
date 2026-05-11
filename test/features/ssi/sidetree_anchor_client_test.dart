import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/ssi/domain/entities/did.dart';
import 'package:orionhealth_health/features/ssi/infrastructure/services/sidetree_anchor_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late SidetreeAnchorClient client;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    client = SidetreeAnchorClient(mockDio);
  });

  group('SidetreeAnchorClient', () {
    final testDid = Did(
      did: 'did:ion:123',
      longForm: 'did:ion:123:initial-state=abc',
      createdAt: DateTime.now(),
    );

    test('anchorDid returns anchored DID on success', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  'didDocument': {'id': 'did:ion:short123'}
                },
                statusCode: 201,
              ));

      final anchored = await client.anchorDid(testDid);

      expect(anchored.shortForm, 'did:ion:short123');
      expect(anchored.isAnchored, true);
    });

    test('anchorDid returns original DID on failure', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final anchored = await client.anchorDid(testDid);

      expect(anchored.shortForm, isNull);
      expect(anchored.isAnchored, false);
      expect(anchored.did, testDid.did);
    });

    test('resolveDid returns DID Document on success', () async {
      final doc = {'id': 'did:ion:123', 'verificationMethod': []};
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: doc,
            statusCode: 200,
          ));

      final result = await client.resolveDid('did:ion:123');

      expect(result, isNotNull);
      expect(result!['id'], 'did:ion:123');
    });

    test('updateDid returns true on success', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 200,
              ));

      final result = await client.updateDid('did:ion:123', {'action': 'replace'});
      expect(result, true);
    });

    test('recoverDid returns true on success', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 200,
              ));

      final result = await client.recoverDid('did:ion:123', {'next': 'state'});
      expect(result, true);
    });
  });
}
