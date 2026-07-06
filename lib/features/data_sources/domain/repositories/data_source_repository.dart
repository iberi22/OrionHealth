import '../entities/data_source_entity.dart';

abstract class DataSourceRepository {
  Future<List<DataSource>> getDataSources();
  Future<void> connectDataSource(String id);
  Future<void> disconnectDataSource(String id);
  Future<void> syncDataSource(String id);
}
