import '../models/research_result.dart';

abstract class MedicalScraperService {
  Future<ResearchResult?> scrape(String url);
}
