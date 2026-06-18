import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/adapters/medical_search_adapters.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late PubMedAdapter pubMedAdapter;
  late FdaAdapter fdaAdapter;
  late WhoAdapter whoAdapter;

  setUp(() {
    mockDio = MockDio();
    pubMedAdapter = PubMedAdapter(mockDio);
    fdaAdapter = FdaAdapter(mockDio);
    whoAdapter = WhoAdapter(mockDio);
  });

  group('MedicalSearchAdapter interface', () {
    test('all adapters implement MedicalSearchAdapter', () {
      expect(pubMedAdapter, isA<MedicalSearchAdapter>());
      expect(fdaAdapter, isA<MedicalSearchAdapter>());
      expect(whoAdapter, isA<MedicalSearchAdapter>());
    });
  });

  group('PubMedAdapter', () {
    test('search fetches IDs then summaries on success', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0] as String;
        if (url.contains('esearch.fcgi')) {
          return Response(
            data: {
              'esearchresult': {
                'idlist': ['123', '456']
              }
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          );
        } else if (url.contains('esummary.fcgi')) {
          return Response(
            data: {
              'result': {
                '123': {
                  'title': 'Diabetes Study',
                  'source': 'NEJM',
                  'pubdate': '2024',
                  'authors': [
                    {'name': 'Smith J'},
                    {'name': 'Doe A'}
                  ]
                },
                '456': {
                  'title': 'Heart Disease Research',
                  'source': 'The Lancet',
                  'pubdate': '2023',
                  'authors': [
                    {'name': 'Lee K'}
                  ]
                }
              }
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          );
        }
        throw Exception('Unexpected URL: $url');
      });

      final results = await pubMedAdapter.search('diabetes');

      expect(results.length, 2);
      expect(results[0].title, 'Diabetes Study');
      expect(results[0].source, 'PubMed');
      expect(results[0].url, 'https://pubmed.ncbi.nlm.nih.gov/123/');
      expect(results[0].content, 'NEJM');
      expect(results[0].metadata, containsPair('pubdate', '2024'));
      expect(results[0].metadata['authors'], containsAll(['Smith J', 'Doe A']));
    });

    test('search passes correct query parameters to esearch', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((invocation) async {
        final params = invocation.namedArguments[Symbol('queryParameters')] as Map;
        expect(params['db'], 'pubmed');
        expect(params['term'], 'cancer treatment');
        expect(params['retmode'], 'json');
        expect(params['retmax'], 5);

        return Response(
          data: {'esearchresult': {'idlist': ['789']}},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );
      });

      await pubMedAdapter.search('cancer treatment');
    });

    test('search returns empty list when no IDs found', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0] as String;
        if (url.contains('esearch.fcgi')) {
          return Response(
            data: {
              'esearchresult': {
                'idlist': []
              }
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          );
        }
        throw Exception('Unexpected call');
      });

      final results = await pubMedAdapter.search('xyznonexistent');

      expect(results, isEmpty);
    });

    test('search returns empty list on DioException', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final results = await pubMedAdapter.search('diabetes');

      expect(results, isEmpty);
    });

    test('search handles missing idlist key in response', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {'esearchresult': {}},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final results = await pubMedAdapter.search('anything');
      expect(results, isEmpty);
    });

    test('search handles summary with missing fields gracefully', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0] as String;
        if (url.contains('esearch.fcgi')) {
          return Response(
            data: {
              'esearchresult': {
                'idlist': ['999']
              }
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          );
        } else {
          return Response(
            data: {
              'result': {
                '999': {
                  // No title, no source
                }
              }
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          );
        }
      });

      final results = await pubMedAdapter.search('cancer');

      expect(results.length, 1);
      expect(results[0].title, 'No Title');
      expect(results[0].content, '');
    });
  });

  group('FdaAdapter', () {
    test('search returns results with brand_name and indications', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'results': [
                    {
                      'openfda': {
                        'brand_name': ['Tylenol'],
                        'generic_name': ['acetaminophen'],
                        'manufacturer_name': ['Johnson & Johnson']
                      },
                      'indications_and_usage': ['For the temporary relief of pain']
                    }
                  ]
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final results = await fdaAdapter.search('acetaminophen');

      expect(results.length, 1);
      expect(results[0].title, 'Tylenol');
      expect(results[0].content, 'For the temporary relief of pain');
      expect(results[0].source, 'FDA (openFDA)');
      expect(results[0].url, 'https://open.fda.gov/');
      expect(results[0].metadata, containsPair('manufacturer', 'Johnson & Johnson'));
    });

    test('search uses generic_name when brand_name is missing', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'results': [
                    {
                      'openfda': {
                        'generic_name': ['aspirin'],
                      },
                      'indications_and_usage': ['Pain relief']
                    }
                  ]
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final results = await fdaAdapter.search('aspirin');

      expect(results.length, 1);
      expect(results[0].title, 'aspirin');
    });

    test('search uses fallback title when no name fields exist', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'results': [
                    {
                      'openfda': {},
                      'indications_and_usage': ['Possible side effects']
                    }
                  ]
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final results = await fdaAdapter.search('unknown');

      expect(results.length, 1);
      expect(results[0].title, 'FDA Drug Info');
    });

    test('search returns empty list on DioException', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final results = await fdaAdapter.search('aspirin');

      expect(results, isEmpty);
    });

    test('search returns empty list when results is null', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {'error': 'No matches found'},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final results = await fdaAdapter.search('xyznonexistent');

      expect(results, isEmpty);
    });

    test('search passes correct query parameters', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((invocation) async {
        final params = invocation.namedArguments[Symbol('queryParameters')] as Map;
        expect(params['search'], 'generic_name:"ibuprofen" OR brand_name:"ibuprofen"');
        expect(params['limit'], 3);
        return Response(
          data: {'results': []},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );
      });

      await fdaAdapter.search('ibuprofen');
    });
  });

  group('WhoAdapter', () {
    test('search returns a placeholder result', () async {
      final results = await whoAdapter.search('covid-19');

      expect(results, isNotEmpty);
      expect(results.length, 1);
      expect(results[0].title, 'WHO Information on covid-19');
      expect(results[0].source, 'WHO');
      expect(results[0].url, contains('who.int'));
      expect(results[0].url, contains('covid-19'));
    });

    test('search returns result with different query', () async {
      final results = await whoAdapter.search('malaria vaccine');

      expect(results, isNotEmpty);
      expect(results[0].title, 'WHO Information on malaria vaccine');
      expect(results[0].content, contains('malaria vaccine'));
    });
  });
}
