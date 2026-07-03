import 'package:injectable/injectable.dart';
import '../entities/medical_research_result.dart';
import '../repositories/medical_research_repository.dart';

@injectable
class GetResearchHistory {
  final MedicalResearchRepository _repository;

  GetResearchHistory(this._repository);

  Future<List<MedicalResearchResult>> execute() async {
    return await _repository.getHistory();
  }
}
