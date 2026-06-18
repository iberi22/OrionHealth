import '../repositories/llm_settings_repository.dart';

class ImportData {
  final LlmSettingsRepository repository;
  ImportData(this.repository);

  Future<void> call(String data) => repository.importData(data);
}
