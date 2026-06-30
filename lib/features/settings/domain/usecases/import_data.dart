import '../repositories/settings_repository.dart';

class ImportData {
  final SettingsRepository repository;
  ImportData(this.repository);

  Future<void> call(String data) => repository.importData(data);
}
