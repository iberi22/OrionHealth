import 'package:health/health.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/health_wrapper.dart';

abstract class HealthConnectDataSource {
  Future<bool> isAvailable();
  Future<bool> requestPermissions();
  Future<void> syncData();
}

@LazySingleton(as: HealthConnectDataSource)
class HealthConnectDataSourceImpl implements HealthConnectDataSource {
  final HealthWrapper _wrapper;

  HealthConnectDataSourceImpl(this._wrapper);

  Health? get _health => _wrapper.health;

  @override
  Future<bool> isAvailable() async {
    if (_health == null) return false;
    // Check if Health Connect is installed and available
    // For now we use the health package's general check or platform check
    try {
      return await _health!.hasPermissions([]) ?? false; // Simplified for now
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (_health == null) return false;
    try {
      return await _health!.requestAuthorization([
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
      ]);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> syncData() async {
    if (_health == null) return;
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    try {
      await _health!.getHealthDataFromTypes(
        types: [HealthDataType.STEPS, HealthDataType.HEART_RATE],
        startTime: start,
        endTime: now,
      );
    } catch (_) {
      // Handle or log error
    }
  }
}
