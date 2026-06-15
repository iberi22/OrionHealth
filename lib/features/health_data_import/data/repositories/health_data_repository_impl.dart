import 'package:health/health.dart';
import '../../domain/repositories/health_data_import_repository.dart';
import '../datasources/health_data_sensor_datasource.dart';
import '../datasources/health_data_file_datasource.dart';

/// Data-layer implementation of [HealthDataImportRepository].
///
/// Delegates to sensor (Apple Health / Google Fit) and file-based
/// datasources for health data import.
class HealthDataImportRepositoryImpl implements HealthDataImportRepository {
  final HealthDataSensorDataSource _sensorDataSource;
  final HealthDataFileDataSource _fileDataSource;

  HealthDataImportRepositoryImpl(
    this._sensorDataSource,
    this._fileDataSource,
  );

  @override
  Future<bool> hasPermissions(List<HealthDataType> types) =>
      _sensorDataSource.hasPermissions(types);

  @override
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) =>
      _sensorDataSource.requestAuthorization(
        types,
        permissions ?? List.filled(types.length, HealthDataAccess.READ),
      );

  @override
  Future<List<HealthDataPoint>> fetchHealthData(
    HealthDataType type,
    DateTime startTime,
    DateTime endTime,
  ) =>
      _sensorDataSource.fetchData(type, startTime, endTime);

  @override
  Future<String?> pickAndExtractFromFile() =>
      _fileDataSource.pickAndExtractText();
}
