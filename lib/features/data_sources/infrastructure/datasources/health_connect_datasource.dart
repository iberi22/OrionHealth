import 'package:health/health.dart';
import 'package:injectable/injectable.dart';

abstract class HealthConnectDataSource {
  Future<bool> isAvailable();
  Future<bool> requestPermissions();
  Future<void> syncData();
}

@LazySingleton(as: HealthConnectDataSource)
class HealthConnectDataSourceImpl implements HealthConnectDataSource {
  final Health _health;

  HealthConnectDataSourceImpl(this._health);

  @override
  Future<bool> isAvailable() async {
    // Check if Health Connect is installed and available
    // For now we use the health package's general check or platform check
    return await _health.hasPermissions([]) ?? false; // Simplified for now
  }

  @override
  Future<bool> requestPermissions() async {
    return await _health.requestAuthorization([
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
    ]);
  }

  @override
  Future<void> syncData() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    await _health.getHealthDataFromTypes(
      types: [HealthDataType.STEPS, HealthDataType.HEART_RATE],
      startTime: start,
      endTime: now,
    );
  }
}
