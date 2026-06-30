import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_web_search_service_impl.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late MedicalWebSearchServiceImpl webSearchService;

  setUp(() {
    mockDio = MockDio();
    webSearchService = MedicalWebSearchServiceImpl(mockDio);
  });

  group('MedicalWebSearchServiceImpl', () {
    test('search aggregates results from all adapters', () async {
      // PubMed adapter call
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0] as String;
        if (url.contains('esearch.fcgi')) {
          return Response(
            data: {
              'esearchresult': {'idlist': ['123']},
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: url),
          );
        } else if (url.contains('esummary.fcgi')) {
          return Response(
            data: {
              'result': {
                '123': {'title': 'Study 1', 'source': 'Journal', 'pubdate': '2023'},
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: url),
          );
        }
        throw Exception('Unexpected url: $url');
      });

      // FDA adapter call
      when(() => mockDio.get(
            'https://api.fda.gov/drug/label.json',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'results': [
                {
                  'openfda': {'brand_name': ['TestDrug']},
                  'indications_and_usage': ['For pain relief'],
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: 'https://api.fda.gov/drug/label.json'),
          ));

      final results = await webSearchService.search('diabetes');

      // PubMed (1) + FDA (1) + WHO (1 placeholder) = 3 results
      expect(results.length, 3);

      // Check PubMed result
      expect(results.where((r) => r.source == 'PubMed').length, 1);
      expect(results.where((r) => r.source == 'PubMed').first.title, 'Study 1');

      // Check FDA result
      expect(results.where((r) => r.source == 'FDA (openFDA)').length, 1);
      expect(results.where((r) => r.source == 'FDA (openFDA)').first.title, 'TestDrug');

      // Check WHO placeholder result
      expect(results.where((r) => r.source == 'WHO').length, 1);
      expect(
        results.where((r) => r.source == 'WHO').first.title,
        contains('diabetes'),
      );
    });

    test('search handles PubMed failure gracefully', () async {
      // PubMed fails
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0] as String;
        if (url.contains('pubmed')) {
          throw DioException(requestOptions: RequestOptions(path: url));
        }
        // Fall through for FDA
        return Response(
          data: {
            'results': [
              {
                'openfda': {'brand_name': ['Drug']},
                'indications_and_usage': ['Indication'],
              },
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: url),
        );
      });

      // FDA call
      when(() => mockDio.get(
            'https://api.fda.gov/drug/label.json',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'results': [
                {
                  'openfda': {'brand_name': ['Drug']},
                  'indications_and_usage': ['Indication'],
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: 'https://api.fda.gov/drug/label.json'),
          ));

      final results = await webSearchService.search('aspirin');

      // FDA (1) + WHO (1 placeholder) = 2 results (PubMed failed gracefully)
      expect(results.length, 2);
      expect(results.where((r) => r.source == 'FDA (openFDA)').length, 1);
      expect(results.where((r) => r.source == 'WHO').length, 1);
    });

    test('search handles all adapter failures gracefully', () async {
      // All search calls fail
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final results = await webSearchService.search('anything');

      // WHO adapter never calls Dio (returns placeholder), so at least 1 result
      expect(results.length, 1);
      expect(results.first.source, 'WHO');
    });

    test('search returns results with appropriate sources', () async {
      // PubMed
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0] as String;
        if (url.contains('esearch.fcgi')) {
          return Response(
            data: {
              'esearchresult': {'idlist': ['1']},
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: url),
          );
        } else if (url.contains('esummary.fcgi')) {
          return Response(
            data: {
              'result': {
                '1': {'title': 'Pub', 'source': 'Journal', 'pubdate': '2024'},
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: url),
          );
        }
        // FDA
        return Response(
          data: {
            'results': [
              {
                'openfda': {'brand_name': ['Fda Drug']},
                'indications_and_usage': ['Use'],
              },
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: url),
        );
      });

      // FDA call
      when(() => mockDio.get(
            'https://api.fda.gov/drug/label.json',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'results': [
                {
                  'openfda': {'brand_name': ['Fda Drug']},
                  'indications_and_usage': ['Use'],
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: 'https://api.fda.gov/drug/label.json'),
          ));

      final results = await webSearchService.search('hypertension');

      final sources = results.map((r) => r.source).toSet();
      expect(sources, contains('PubMed'));
      expect(sources, contains('FDA (openFDA)'));
      expect(sources, contains('WHO'));
    });
  });
}
