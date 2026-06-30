import '../repositories/settings_repository.dart';

class ExportData {
  final SettingsRepository repository;
  ExportData(this.repository);

  Future<String> call() => repository.exportData();
}
