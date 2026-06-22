import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/adapters/medical_search_adapters.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDio();
  });

  group('PubMedAdapter', () {
    late PubMedAdapter adapter;

    setUp(() {
      adapter = PubMedAdapter(mockDio);
    });

    test('search returns results on success', () async {
      // 1. Search for IDs
      when(() => mockDio.get(
            any(that: contains('esearch.fcgi')),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'esearchresult': {
                'idlist': ['123']
              }
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // 2. Fetch details for IDs
      when(() => mockDio.get(
            any(that: contains('esummary.fcgi')),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'result': {
                '123': {
                  'title': 'Test Study',
                  'source': 'Nature',
                  'pubdate': '2023',
                  'authors': [
                    {'name': 'Author A'}
                  ]
                }
              }
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final results = await adapter.search('asthma');

      expect(results.length, 1);
      expect(results[0].title, 'Test Study');
      expect(results[0].source, 'PubMed');
      expect(results[0].url, contains('123'));
    });

    test('search returns empty list on failure', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final results = await adapter.search('asthma');

      expect(results, isEmpty);
    });
  });

  group('FdaAdapter', () {
    late FdaAdapter adapter;

    setUp(() {
      adapter = FdaAdapter(mockDio);
    });

    test('search returns drug info on success', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
            data: {
              'results': [
                {
                  'openfda': {
                    'brand_name': ['Advil'],
                    'manufacturer_name': ['Pfizer']
                  },
                  'indications_and_usage': ['Used for pain']
                }
              ]
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final results = await adapter.search('ibuprofen');

      expect(results.length, 1);
      expect(results[0].title, 'Advil');
      expect(results[0].source, 'FDA (openFDA)');
      expect(results[0].metadata?['manufacturer'], 'Pfizer');
    });

    test('search returns empty list on error', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final results = await adapter.search('unknown');

      expect(results, isEmpty);
    });
  });

  group('WhoAdapter', () {
    late WhoAdapter adapter;

    setUp(() {
      adapter = WhoAdapter(mockDio);
    });

    test('search returns placeholder info', () async {
      final results = await adapter.search('diabetes');
      expect(results.length, 1);
      expect(results[0].source, 'WHO');
      expect(results[0].title, contains('WHO Information on diabetes'));
    });
  });
}
