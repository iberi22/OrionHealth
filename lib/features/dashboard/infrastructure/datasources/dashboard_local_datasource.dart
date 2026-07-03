import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/dashboard_preference.dart';

@lazySingleton
class DashboardLocalDataSource {
  final Isar _isar;

  DashboardLocalDataSource(this._isar);

  /// Store dashboard preferences (e.g. widget order, collapsed sections).
  Future<void> savePreference(String key, String value) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.dashboardPreferences.filter().keyEqualTo(key).findFirst();
      if (existing != null) {
        existing.value = value;
        await _isar.dashboardPreferences.put(existing);
      } else {
        await _isar.dashboardPreferences.put(DashboardPreference(key: key, value: value));
      }
    });
  }

  Future<String?> getPreference(String key) async {
    final pref = await _isar.dashboardPreferences.filter().keyEqualTo(key).findFirst();
    return pref?.value;
  }
}
