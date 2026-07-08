import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';

void main() {
  group('DataSource Workflow', () {
    test('creates file type', () {
      final ds = DataSourceEntity(name: 'CSV', type: DataSourceType.file);
      expect(ds.name, 'CSV');
      expect(ds.type, DataSourceType.file);
    });

    test('creates health connect type', () {
      final ds = DataSourceEntity(name: 'HC', type: DataSourceType.healthConnect);
      expect(ds.name, 'HC');
      expect(ds.type, DataSourceType.healthConnect);
    });

    test('creates sensor API type', () {
      final ds = DataSourceEntity(name: 'Sensor', type: DataSourceType.sensorApi);
      expect(ds.name, 'Sensor');
      expect(ds.type, DataSourceType.sensorApi);
    });
  });
}
