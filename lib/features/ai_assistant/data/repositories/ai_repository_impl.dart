import '../../domain/entities/ai_query.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource _remoteDataSource;
  AiRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> queryAi(String prompt, {Map<String, dynamic>? context}) async {
    return _remoteDataSource.query(prompt, context: context);
  }

  @override
  Future<void> setApiKey(String key) async {}
}
