import 'package:health/health.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/health_wrapper.dart';

abstract class SensorApiDataSource {
  Future<bool> requestAuthorization();
  Future<bool> hasPermissions();
  Future<void> fetchAndSaveData();
}

@LazySingleton(as: SensorApiDataSource)
class SensorApiDataSourceImpl implements SensorApiDataSource {
  final HealthWrapper _wrapper;

  SensorApiDataSourceImpl(this._wrapper);

  Health? get _health => _wrapper.health;

  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  ];

  @override
  Future<bool> requestAuthorization() async {
    if (_health == null) return false;
    try {
      return await _health!.requestAuthorization(_types);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    if (_health == null) return false;
    try {
      final result = await _health!.hasPermissions(_types);
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> fetchAndSaveData() async {
    if (_health == null) return;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    // In a real implementation, we would fetch and then save to another repository
    // For now, we simulate the fetch
    try {
      await _health!.getHealthDataFromTypes(
        types: _types,
        startTime: yesterday,
        endTime: now,
      );
    } catch (_) {
      // Handle or log error
    }
  }
}
