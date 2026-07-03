import '../entities/medical_research_result.dart';
import '../entities/research_query.dart';
import '../models/research_result.dart';

abstract class MedicalResearchRepository {
  /// Performs a search for medical research based on the given query.
  Future<List<ResearchResult>> search(ResearchQuery query);

  /// Saves the results of a research query to the local history.
  Future<void> saveToHistory(MedicalResearchResult result);

  /// Retrieves the history of medical research results.
  Future<List<MedicalResearchResult>> getHistory();

  /// Clears the research history.
  Future<void> clearHistory();
}
