import 'package:injectable/injectable.dart';

@lazySingleton
class DashboardLocalDataSource {
  /// Store dashboard preferences (e.g. widget order, collapsed sections).
  Future<void> savePreference(String key, String value) async {
    // Could be SharedPreferences or Isar
  }

  Future<String?> getPreference(String key) async => null;
}
