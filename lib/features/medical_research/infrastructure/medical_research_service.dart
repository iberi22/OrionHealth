import 'package:injectable/injectable.dart';
import '../domain/models/research_result.dart';
import '../domain/services/medical_web_search_service.dart';
import '../domain/services/medical_scraper_service.dart';

@lazySingleton
class MedicalResearchService {
  final MedicalWebSearchService _searchService;
  final MedicalScraperService _scraperService;

  MedicalResearchService(this._searchService, this._scraperService);

  Future<List<ResearchResult>> performResearch(String query) async {
    // 1. Search across multiple medical sources
    final searchResults = await _searchService.search(query);

    // 2. Optionally scrape the top result for more detail
    if (searchResults.isNotEmpty) {
      final topResult = searchResults.first;
      if (topResult.url.startsWith('http')) {
        final detailed = await _scraperService.scrape(topResult.url);
        if (detailed != null) {
          // Merge or replace with detailed content
          searchResults[0] = detailed;
        }
      }
    }

    return searchResults;
  }
}
