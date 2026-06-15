import '../../domain/entities/medical_query.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/repositories/medical_assistant_repository.dart';
import '../datasources/medical_assistant_local_datasource.dart';

class MedicalAssistantRepositoryImpl implements MedicalAssistantRepository {
  final MedicalAssistantLocalDataSource _localDataSource;
  MedicalAssistantRepositoryImpl(this._localDataSource);

  @override
  Future<AiMedicalResponse> submitQuery(MedicalQuery query) async =>
      throw UnimplementedError('Use MedicalLlmAdapter for LLM calls');
  @override
  Future<List<AiMedicalResponse>> getHistory(String userId, {int limit = 20}) =>
      _localDataSource.getHistory(userId, limit: limit);
  @override
  Future<void> clearHistory(String userId) => _localDataSource.clearHistory(userId);
  @override
  Future<void> saveResponse(AiMedicalResponse response) => _localDataSource.saveResponse(response);
}
