import 'package:health/health.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HealthDataSensorDataSource {
  final Health _health = Health();

  Future<bool> requestAuthorization(List<HealthDataType> types, List<HealthDataAccess> permissions) =>
      _health.requestAuthorization(types, permissions: permissions);

  Future<List<HealthDataPoint>> fetchData(HealthDataType type, DateTime start, DateTime end) =>
      _health.getHealthDataFromTypes(types: [type], startTime: start, endTime: end);

  Future<bool> hasPermissions(List<HealthDataType> types) async =>
      await _health.hasPermissions(types) ?? false;
}
