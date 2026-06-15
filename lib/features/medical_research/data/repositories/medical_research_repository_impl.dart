import '../datasources/research_local_datasource.dart';

class MedicalResearchRepository {
  final ResearchLocalDataSource _localDataSource;
  MedicalResearchRepository(this._localDataSource);

  Future<String?> getCachedResult(String query) => _localDataSource.getCachedResult(query);
  Future<void> cacheResult(String query, String result) => _localDataSource.cacheResult(query, result);
}
