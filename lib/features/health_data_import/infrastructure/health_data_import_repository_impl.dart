import 'package:health/health.dart';
import 'package:injectable/injectable.dart';
import '../domain/repositories/health_data_import_repository.dart';
import 'data_source.dart';

@LazySingleton(as: HealthDataImportRepository)
class HealthDataImportRepositoryImpl implements HealthDataImportRepository {
  final SensorHealthDataSource _sensorDataSource;
  final FileHealthDataSource _fileDataSource;

  HealthDataImportRepositoryImpl(
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
