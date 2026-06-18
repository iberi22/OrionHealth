import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_scraper_service.dart';
import 'package:orionhealth_health/features/medical_research/domain/services/medical_web_search_service.dart';

/// Test implementation of MedicalScraperService
class TestMedicalScraperService implements MedicalScraperService {
  @override
  Future<ResearchResult?> scrape(String url) async {
    if (url.startsWith('https://valid-')) {
      return ResearchResult(
        title: 'Scraped Article',
        content: 'Full article content from scraping',
        source: 'example.com',
        url: url,
      );
    }
    return null;
  }
}

/// Test implementation of MedicalWebSearchService
class TestMedicalWebSearchService implements MedicalWebSearchService {
  @override
  Future<List<ResearchResult>> search(String query) async {
    if (query.isEmpty) return [];
    return [
      const ResearchResult(
        title: 'Search Result 1',
        content: 'Content from search',
        source: 'PubMed',
        url: 'https://example.com/result1',
      ),
    ];
  }
}

void main() {
  group('MedicalScraperService interface', () {
    late TestMedicalScraperService service;

    setUp(() {
      service = TestMedicalScraperService();
    });

    test('scrape returns ResearchResult for valid URL', () async {
      final result = await service.scrape('https://valid-example.com/article');
      expect(result, isNotNull);
      expect(result!.title, 'Scraped Article');
      expect(result.source, 'example.com');
      expect(result.url, 'https://valid-example.com/article');
    });

    test('scrape returns null for invalid URL', () async {
      final result = await service.scrape('https://example.com/invalid');
      expect(result, isNull);
    });
  });

  group('MedicalWebSearchService interface', () {
    late TestMedicalWebSearchService service;

    setUp(() {
      service = TestMedicalWebSearchService();
    });

    test('search returns results for non-empty query', () async {
      final results = await service.search('diabetes');
      expect(results, hasLength(1));
      expect(results.first.title, 'Search Result 1');
      expect(results.first.source, 'PubMed');
    });

    test('search returns empty list for empty query', () async {
      final results = await service.search('');
      expect(results, isEmpty);
    });
  });
}
