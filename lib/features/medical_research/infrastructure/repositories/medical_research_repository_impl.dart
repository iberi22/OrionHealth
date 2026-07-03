import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/medical_research_result.dart';
import '../../domain/entities/research_query.dart';
import '../../domain/models/research_result.dart';
import '../../domain/repositories/medical_research_repository.dart';
import '../medical_research_service.dart';

@LazySingleton(as: MedicalResearchRepository)
class MedicalResearchRepositoryImpl implements MedicalResearchRepository {
  final MedicalResearchService _researchService;
  final Isar _isar;

  MedicalResearchRepositoryImpl(this._researchService, this._isar);

  @override
  Future<List<ResearchResult>> search(ResearchQuery query) async {
    return await _researchService.performResearch(query.text);
  }

  @override
  Future<void> saveToHistory(MedicalResearchResult result) async {
    await _isar.writeTxn(() async {
      await _isar.medicalResearchResults.put(result);
    });
  }

  @override
  Future<List<MedicalResearchResult>> getHistory() async {
    return await _isar.medicalResearchResults.where().sortByTimestampDesc().findAll();
  }

  @override
  Future<void> clearHistory() async {
    await _isar.writeTxn(() async {
      await _isar.medicalResearchResults.clear();
    });
  }
}
