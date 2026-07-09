import 'package:health/health.dart';
import 'package:injectable/injectable.dart';

abstract class SensorApiDataSource {
  Future<bool> requestAuthorization();
  Future<bool> hasPermissions();
  Future<void> fetchAndSaveData();
}

@LazySingleton(as: SensorApiDataSource)
class SensorApiDataSourceImpl implements SensorApiDataSource {
  final Health _health;

  SensorApiDataSourceImpl(this._health);

  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  ];

  @override
  Future<bool> requestAuthorization() async {
    return await _health.requestAuthorization(_types);
  }

  @override
  Future<bool> hasPermissions() async {
    final result = await _health.hasPermissions(_types);
    return result ?? false;
  }

  @override
  Future<void> fetchAndSaveData() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    // In a real implementation, we would fetch and then save to another repository
    // For now, we simulate the fetch
    await _health.getHealthDataFromTypes(
      types: _types,
      startTime: yesterday,
      endTime: now,
    );
  }
}
