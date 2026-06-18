import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_scraper_service.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_web_search_service.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_research_service.dart';

class MockWebSearchService extends Mock implements MedicalWebSearchService {}

class MockScraperService extends Mock implements MedicalScraperService {}

void main() {
  late MockWebSearchService mockSearchService;
  late MockScraperService mockScraperService;
  late MedicalResearchService researchService;

  setUp(() {
    mockSearchService = MockWebSearchService();
    mockScraperService = MockScraperService();
    // Default stub for scrape to return null for any url
    when(() => mockScraperService.scrape(any()))
        .thenAnswer((_) async => null);
    researchService = MedicalResearchService(mockSearchService, mockScraperService);
  });

  group('MedicalResearchService', () {
    test('performResearch scrapes top result when URL starts with http', () async {
      final results = [
        const ResearchResult(
          title: 'Result 1',
          content: 'Content 1',
          source: 'PubMed',
          url: 'https://pubmed.ncbi.nlm.nih.gov/123/',
        ),
      ];

      when(() => mockSearchService.search('diabetes'))
          .thenAnswer((_) async => results);
      when(() => mockScraperService.scrape(any()))
          .thenAnswer((_) async => null);

      final actual = await researchService.performResearch('diabetes');

      expect(actual.length, 1);
      expect(actual[0].title, 'Result 1');
      verify(() => mockSearchService.search('diabetes')).called(1);
      verify(() => mockScraperService.scrape(any())).called(1);
    });

    test('performResearch scrapes top result and replaces it', () async {
      final searchResults = [
        const ResearchResult(
          title: 'Original Title',
          content: 'Original Content',
          source: 'PubMed',
          url: 'https://pubmed.ncbi.nlm.nih.gov/123/',
        ),
        const ResearchResult(
          title: 'Result 2',
          content: 'Content 2',
          source: 'PubMed',
          url: 'https://pubmed.ncbi.nlm.nih.gov/456/',
        ),
      ];

      final scrapedResult = const ResearchResult(
        title: 'Detailed Title',
        content: 'Detailed scraped content',
        source: 'pubmed.ncbi.nlm.nih.gov',
        url: 'https://pubmed.ncbi.nlm.nih.gov/123/',
      );

      when(() => mockSearchService.search('cancer'))
          .thenAnswer((_) async => searchResults);
      when(() => mockScraperService.scrape('https://pubmed.ncbi.nlm.nih.gov/123/'))
          .thenAnswer((_) async => scrapedResult);

      final actual = await researchService.performResearch('cancer');

      expect(actual.length, 2);
      expect(actual[0].title, 'Detailed Title');
      expect(actual[0].content, 'Detailed scraped content');
      // Second result unchanged
      expect(actual[1].title, 'Result 2');
    });

    test('performResearch does not scrape when top result has no http URL', () async {
      final results = [
        const ResearchResult(
          title: 'Local Result',
          content: 'Local content',
          source: 'Local',
          url: 'local-cache://result/123',
        ),
      ];

      when(() => mockSearchService.search('local'))
          .thenAnswer((_) async => results);

      // No scrape expectation because url doesn't start with http
      final actual = await researchService.performResearch('local');

      expect(actual.length, 1);
      expect(actual[0].title, 'Local Result');
      verifyNever(() => mockScraperService.scrape(any()));
    });

    test('performResearch keeps original if scrape returns null', () async {
      final results = [
        const ResearchResult(
          title: 'Original',
          content: 'Original content',
          source: 'PubMed',
          url: 'https://pubmed.ncbi.nlm.nih.gov/123/',
        ),
      ];

      when(() => mockSearchService.search('test'))
          .thenAnswer((_) async => results);
      when(() => mockScraperService.scrape(any()))
          .thenAnswer((_) async => null);

      final actual = await researchService.performResearch('test');

      expect(actual.length, 1);
      expect(actual[0].title, 'Original');
    });

    test('performResearch returns empty list when search returns empty', () async {
      when(() => mockSearchService.search('empty'))
          .thenAnswer((_) async => <ResearchResult>[]);

      final actual = await researchService.performResearch('empty');

      expect(actual, isEmpty);
      verifyNever(() => mockScraperService.scrape(any()));
    });

    test('performResearch propagates search service exception', () async {
      when(() => mockSearchService.search(any()))
          .thenThrow(Exception('Search API down'));

      expect(
        () => researchService.performResearch('error'),
        throwsException,
      );
    });
  });
}
