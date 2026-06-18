import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/bot_bypass_handler.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_scraper_service_impl.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late BotBypassHandler bypassHandler;
  late MedicalScraperServiceImpl scraperService;

  setUp(() {
    mockDio = MockDio();
    bypassHandler = BotBypassHandler();
    scraperService = MedicalScraperServiceImpl(mockDio, bypassHandler);
  });

  group('MedicalScraperServiceImpl', () {
    test('scrape returns ResearchResult on 200 OK with title and meta', () async {
      final html = '''
<html>
<head>
  <title>Medical Study Results</title>
  <meta name="description" content="Study shows promising results for treatment.">
</head>
<body><p>Content here</p></body>
</html>
''';

      when(() => mockDio.get(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: html,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'https://example.com/article'),
          ));

      final result = await scraperService.scrape('https://example.com/article');

      expect(result, isNotNull);
      expect(result!.title, 'Medical Study Results');
      expect(result.content, 'Study shows promising results for treatment.');
      expect(result.source, 'example.com');
      expect(result.url, 'https://example.com/article');
    });

    test('scrape handles missing title tag', () async {
      final html = '''
<html>
<head>
  <meta name="description" content="Just meta description.">
</head>
<body>Body text</body>
</html>
''';

      when(() => mockDio.get(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: html,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'https://example.org/page'),
          ));

      final result = await scraperService.scrape('https://example.org/page');

      expect(result, isNotNull);
      expect(result!.title, 'Scraped Content');
      expect(result.content, 'Just meta description.');
    });

    test('scrape handles missing title and meta tags', () async {
      final html = '<html><body><p>Hello</p></body></html>';

      when(() => mockDio.get(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: html,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'https://example.net/'),
          ));

      final result = await scraperService.scrape('https://example.net/');

      expect(result, isNotNull);
      expect(result!.title, 'Scraped Content');
      expect(result.content, 'Content extracted from https://example.net/');
    });

    test('scrape returns null on non-200 status code', () async {
      when(() => mockDio.get(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: 'Not Found',
            statusCode: 404,
            requestOptions: RequestOptions(path: 'https://example.com/404'),
          ));

      final result = await scraperService.scrape('https://example.com/404');

      expect(result, isNull);
    });

    test('scrape returns null on DioException', () async {
      when(() => mockDio.get(
            any(),
            options: any(named: 'options'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: 'https://example.com/error'),
            type: DioExceptionType.connectionTimeout,
          ));

      final result = await scraperService.scrape('https://example.com/error');

      expect(result, isNull);
    });

    test('scrape extracts source from URL host', () async {
      final html = '<html><head><title>Test</title></head></html>';

      when(() => mockDio.get(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: html,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'https://news.medical.org/article/1'),
          ));

      final result = await scraperService.scrape('https://news.medical.org/article/1');

      expect(result, isNotNull);
      expect(result!.source, 'news.medical.org');
    });

    test('scrape passes BotBypassHandler headers in request', () async {
      final html = '<html><head><title>Test</title></head></html>';

      // Capture headers passed to Dio
      when(() => mockDio.get(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((invocation) {
        final options = invocation.namedArguments[#options] as Options;
        expect(options.headers, isNotNull);
        expect(options.headers!['User-Agent'], startsWith('Mozilla/5.0'));
        expect(options.headers!['Accept'], contains('text/html'));
        expect(options.headers!['Accept-Language'], 'en-US,en;q=0.9');

        return Future.value(Response(
          data: html,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://example.com/test'),
        ));
      });

      final result = await scraperService.scrape('https://example.com/test');

      expect(result, isNotNull);
      expect(result!.title, 'Test');
    });
  });
}
