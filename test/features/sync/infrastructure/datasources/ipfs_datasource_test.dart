import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/infrastructure/datasources/ipfs_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late IpfsDatasource datasource;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDio();
    datasource = IpfsDatasource(mockDio);
  });

  group('IpfsDatasource', () {
    final testData = Uint8List.fromList([1, 2, 3]);
    const testCid = 'QmTest';

    test('add returns CID on success', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {'Hash': testCid},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await datasource.add(testData);

      expect(result, testCid);
      verify(() => mockDio.post(any(that: contains('/add')), data: any(named: 'data'))).called(1);
    });

    test('get returns data on success', () async {
      when(() => mockDio.post(any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                data: testData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await datasource.get(testCid);

      expect(result, testData);
      verify(() => mockDio.post(
            any(that: contains('/cat')),
            queryParameters: {'arg': testCid},
            options: any(named: 'options'),
          )).called(1);
    });

    test('pin completes on success', () async {
      when(() => mockDio.post(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      await datasource.pin(testCid);

      verify(() => mockDio.post(
            any(that: contains('/pin/add')),
            queryParameters: {'arg': testCid},
          )).called(1);
    });

    test('throws Exception on failure', () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      expect(() => datasource.add(testData), throwsA(isA<Exception>()));
    });
  });
}
