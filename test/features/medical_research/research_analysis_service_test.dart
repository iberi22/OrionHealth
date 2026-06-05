import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_web_search_service.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_scraper_service.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_research_service.dart';

class MockMedicalWebSearchService extends Mock implements MedicalWebSearchService {}
class MockMedicalScraperService extends Mock implements MedicalScraperService {}

void main() {
  late MockMedicalWebSearchService mockSearch;
  late MockMedicalScraperService mockScraper;
  late MedicalResearchService researchService;

  setUp(() {
    mockSearch = MockMedicalWebSearchService();
    mockScraper = MockMedicalScraperService();
    researchService = MedicalResearchService(mockSearch, mockScraper);

    // Default: scraping returns null
    when(() => mockScraper.scrape(any())).thenAnswer((_) async => null);
  });

  group('MedicalResearchService - Research Analysis', () {
    test('performResearch returns results from search service', () async {
      final searchResults = [
        const ResearchResult(
          title: 'Diabetes Overview',
          content: 'Diabetes is a chronic condition...',
          source: 'PubMed',
          url: 'https://example.com/diabetes',
        ),
      ];

      when(() => mockSearch.search('diabetes')).thenAnswer((_) async => searchResults);

      final results = await researchService.performResearch('diabetes');

      expect(results, equals(searchResults));
      verify(() => mockSearch.search('diabetes')).called(1);
    });

    test('performResearch scrapes top result if it is a valid URL', () async {
      final searchResults = [
        const ResearchResult(
          title: 'Top Result',
          content: 'Initial content',
          source: 'PubMed',
          url: 'https://example.com/top',
        ),
        const ResearchResult(
          title: 'Second Result',
          content: 'Other content',
          source: 'FDA',
          url: 'https://example.com/second',
        ),
      ];

      final detailedResult = const ResearchResult(
        title: 'Top Result Detailed',
        content: 'Much more detailed content from scraping',
        source: 'example.com',
        url: 'https://example.com/top',
      );

      when(() => mockSearch.search('fever')).thenAnswer((_) async => List.from(searchResults));
      when(() => mockScraper.scrape('https://example.com/top')).thenAnswer((_) async => detailedResult);

      final results = await researchService.performResearch('fever');

      expect(results.length, 2);
      expect(results[0].content, contains('detailed content'));
      expect(results[0].title, 'Top Result Detailed');
      expect(results[1].content, 'Other content');

      verify(() => mockScraper.scrape('https://example.com/top')).called(1);
    });

    test('performResearch does not scrape if search results are empty', () async {
      when(() => mockSearch.search('unknown')).thenAnswer((_) async => []);

      final results = await researchService.performResearch('unknown');

      expect(results, isEmpty);
      verifyNever(() => mockScraper.scrape(any()));
    });

    test('performResearch returns original results if scraping fails', () async {
      final searchResults = [
        const ResearchResult(
          title: 'Top Result',
          content: 'Initial content',
          source: 'PubMed',
          url: 'https://example.com/top',
        ),
      ];

      when(() => mockSearch.search('fever')).thenAnswer((_) async => List.from(searchResults));
      when(() => mockScraper.scrape('https://example.com/top')).thenAnswer((_) async => null);

      final results = await researchService.performResearch('fever');

      expect(results.first.content, 'Initial content');
    });

    test('performResearch handles non-http URLs for scraping', () async {
       final searchResults = [
        const ResearchResult(
          title: 'Local Info',
          content: 'Some local info',
          source: 'Internal',
          url: 'internal://info',
        ),
      ];

      when(() => mockSearch.search('info')).thenAnswer((_) async => searchResults);

      final results = await researchService.performResearch('info');

      expect(results, equals(searchResults));
      verifyNever(() => mockScraper.scrape(any()));
    });
  });
}
