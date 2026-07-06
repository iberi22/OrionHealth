import 'package:injectable/injectable.dart';
import '../../domain/entities/data_source_entity.dart';
import '../../domain/repositories/data_source_repository.dart';
import '../datasources/sensor_api_datasource.dart';
import '../datasources/file_import_datasource.dart';
import '../datasources/health_connect_datasource.dart';

@LazySingleton(as: DataSourceRepository)
class DataSourceRepositoryImpl implements DataSourceRepository {
  final SensorApiDataSource _sensorDataSource;
  final FileImportDataSource _fileDataSource;
  final HealthConnectDataSource _healthConnectDataSource;

  DataSourceRepositoryImpl(
    this._sensorDataSource,
    this._fileDataSource,
    this._healthConnectDataSource,
  );

  @override
  Future<List<DataSource>> getDataSources() async {
    // In a real app, these might be persisted in a DB
    // Here we provide a default list
    return [
      const DataSource(
        id: 'sensors',
        name: 'Device Sensors',
        description: 'Steps, heart rate, and more from your device.',
        type: DataSourceType.sensor,
        status: DataSourceStatus.disconnected,
      ),
      const DataSource(
        id: 'files',
        name: 'Health Files',
        description: 'Import PDF or image health records.',
        type: DataSourceType.file,
        status: DataSourceStatus.disconnected,
      ),
      const DataSource(
        id: 'health_connect',
        name: 'Health Connect',
        description: 'Sync data with Android Health Connect.',
        type: DataSourceType.healthConnect,
        status: DataSourceStatus.disconnected,
      ),
    ];
  }

  @override
  Future<void> connectDataSource(String id) async {
    switch (id) {
      case 'sensors':
        final success = await _sensorDataSource.requestAuthorization();
        if (!success) throw Exception('Authorization failed for sensors');
        break;
      case 'health_connect':
        final success = await _healthConnectDataSource.requestPermissions();
        if (!success) throw Exception('Authorization failed for Health Connect');
        break;
      case 'files':
        // File source doesn't strictly have a "connect" step like APIs
        break;
      default:
        throw Exception('Unknown data source: $id');
    }
  }

  @override
  Future<void> disconnectDataSource(String id) async {
    // Logic to revoke permissions or clear tokens
  }

  @override
  Future<void> syncDataSource(String id) async {
    switch (id) {
      case 'sensors':
        await _sensorDataSource.fetchAndSaveData();
        break;
      case 'health_connect':
        await _healthConnectDataSource.syncData();
        break;
      case 'files':
        await _fileDataSource.pickAndProcessFile();
        break;
      default:
        throw Exception('Unknown data source: $id');
    }
  }
}
