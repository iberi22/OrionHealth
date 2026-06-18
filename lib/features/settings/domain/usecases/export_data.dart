import '../repositories/llm_settings_repository.dart';

class ExportData {
  final LlmSettingsRepository repository;
  ExportData(this.repository);

  Future<String> call() => repository.exportData();
}
