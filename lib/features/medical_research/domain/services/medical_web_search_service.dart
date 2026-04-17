import '../models/research_result.dart';

abstract class MedicalWebSearchService {
  Future<List<ResearchResult>> search(String query);
}
