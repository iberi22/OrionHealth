import 'package:health/health.dart';
import 'package:injectable/injectable.dart';
import 'data_source.dart';

/// Repository interface for health data import.
/// Defined here to adhere to file constraints while providing the abstraction.
abstract class HealthDataRepository {
  Future<bool> hasPermissions(List<HealthDataType> types);
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  });
  Future<List<HealthDataPoint>> fetchHealthData(
    HealthDataType type,
    DateTime startTime,
    DateTime endTime,
  );
  Future<String?> pickAndExtractFromFile();
}

@LazySingleton(as: HealthDataRepository)
class HealthDataRepositoryImpl implements HealthDataRepository {
  final SensorHealthDataSource _sensorDataSource;
  final FileHealthDataSource _fileDataSource;

  HealthDataRepositoryImpl(
    this._sensorDataSource,
    this._fileDataSource,
  );

  @override
  Future<bool> hasPermissions(List<HealthDataType> types) {
    return _sensorDataSource.hasPermissions(types);
  }

  @override
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) {
    return _sensorDataSource.requestAuthorization(
      types,
      permissions ?? List.filled(types.length, HealthDataAccess.READ),
    );
  }

  @override
  Future<List<HealthDataPoint>> fetchHealthData(
    HealthDataType type,
    DateTime startTime,
    DateTime endTime,
  ) {
    return _sensorDataSource.fetchData(type, startTime, endTime);
  }

  @override
  Future<String?> pickAndExtractFromFile() {
    return _fileDataSource.pickAndExtractText();
  }
}
