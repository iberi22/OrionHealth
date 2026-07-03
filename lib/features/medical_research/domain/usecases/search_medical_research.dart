import 'package:injectable/injectable.dart';
import '../entities/medical_research_result.dart';
import '../entities/research_query.dart';
import '../models/research_result.dart';
import '../repositories/medical_research_repository.dart';

@injectable
class SearchMedicalResearch {
  final MedicalResearchRepository _repository;

  SearchMedicalResearch(this._repository);

  Future<List<ResearchResult>> execute(ResearchQuery query) async {
    final results = await _repository.search(query);

    if (results.isNotEmpty) {
      final historyEntry = MedicalResearchResult(
        query: query.text,
        timestamp: DateTime.now(),
        items: results.map((r) => ResearchResultItem.fromResearchResult(r)).toList(),
      );
      await _repository.saveToHistory(historyEntry);
    }

    return results;
  }
}
