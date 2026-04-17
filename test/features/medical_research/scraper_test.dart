import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_scraper_service_impl.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/bot_bypass_handler.dart';

class MockDio extends Mock implements Dio {}
class MockBotBypassHandler extends Mock implements BotBypassHandler {}

void main() {
  late MockDio mockDio;
  late MockBotBypassHandler mockBotBypass;
  late MedicalScraperServiceImpl scraperService;

  setUp(() {
    mockDio = MockDio();
    mockBotBypass = MockBotBypassHandler();
    scraperService = MedicalScraperServiceImpl(mockDio, mockBotBypass);

    when(() => mockBotBypass.waitHumanTime()).thenAnswer((_) async => {});
    when(() => mockBotBypass.getHeaders()).thenReturn({'User-Agent': 'TestAgent'});
  });

  test('scrape successfully parses title and content', () async {
    const html = '<html><head><title>Medical Article</title><meta name="description" content="Important health info"></head><body></body></html>';

    when(() => mockDio.get(any(), options: any(named: 'options')))
        .thenAnswer((_) async => Response(
              data: html,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

    final result = await scraperService.scrape('https://example.com/article');

    expect(result, isNotNull);
    expect(result!.title, 'Medical Article');
    expect(result.content, 'Important health info');
    expect(result.source, 'example.com');
  });

  test('scrape returns null on error', () async {
    when(() => mockDio.get(any(), options: any(named: 'options')))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

    final result = await scraperService.scrape('https://example.com/article');

    expect(result, isNull);
  });
}
