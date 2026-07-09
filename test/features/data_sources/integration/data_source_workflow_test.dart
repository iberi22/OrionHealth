import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';

void main() {
  group('DataSource Workflow Integration', () {
    test('creates file type', () {
      const ds = DataSource(
        id: '1',
        name: 'CSV',
        description: 'desc',
        type: DataSourceType.file,
        status: DataSourceStatus.disconnected,
      );
      expect(ds.name, 'CSV');
      expect(ds.type, DataSourceType.file);
    });

    test('creates health connect type', () {
      const ds = DataSource(
        id: '2',
        name: 'HC',
        description: 'desc',
        type: DataSourceType.healthConnect,
        status: DataSourceStatus.disconnected,
      );
      expect(ds.name, 'HC');
      expect(ds.type, DataSourceType.healthConnect);
    });

    test('creates sensor type', () {
      const ds = DataSource(
        id: '3',
        name: 'Sensor',
        description: 'desc',
        type: DataSourceType.sensor,
        status: DataSourceStatus.disconnected,
      );
      expect(ds.name, 'Sensor');
      expect(ds.type, DataSourceType.sensor);
    });
  });
}
