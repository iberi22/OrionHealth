import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/adapters/medical_search_adapters.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late PubMedAdapter pubMedAdapter;
  late FdaAdapter fdaAdapter;

  setUp(() {
    mockDio = MockDio();
    pubMedAdapter = PubMedAdapter(mockDio);
    fdaAdapter = FdaAdapter(mockDio);
  });

  group('PubMedAdapter', () {
    test('search returns results on success', () async {
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
                '123': {'title': 'Study 1', 'source': 'Journal 1', 'pubdate': '2023'},
                '456': {'title': 'Study 2', 'source': 'Journal 2', 'pubdate': '2024'}
              }
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          );
        }
        throw Exception('Unexpected call');
      });

      final results = await pubMedAdapter.search('diabetes');

      expect(results.length, 2);
      expect(results[0].title, 'Study 1');
      expect(results[0].source, 'PubMed');
    });

    test('search returns empty list on failure', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final results = await pubMedAdapter.search('diabetes');

      expect(results, isEmpty);
    });
   group('FdaAdapter', () {
    test('search returns results on success', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'results': [
                    {
                      'openfda': {'brand_name': ['Tylenol']},
                      'indications_and_usage': ['Pain relief']
                    }
                  ]
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final results = await fdaAdapter.search('acetaminophen');

      expect(results.length, 1);
      expect(results[0].title, 'Tylenol');
      expect(results[0].source, 'FDA (openFDA)');
    });
  });
});
}
