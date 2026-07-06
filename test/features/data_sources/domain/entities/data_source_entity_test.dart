import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';

void main() {
  group('DataSource Entity', () {
    const tDataSource = DataSource(
      id: '1',
      name: 'Test Source',
      description: 'Description',
      type: DataSourceType.sensor,
      status: DataSourceStatus.disconnected,
    );

    test('copyWith updates fields correctly', () {
      final updated = tDataSource.copyWith(status: DataSourceStatus.connected);
      expect(updated.status, DataSourceStatus.connected);
      expect(updated.id, tDataSource.id);
    });

    test('props contains all fields', () {
      expect(tDataSource.props, [
        tDataSource.id,
        tDataSource.name,
        tDataSource.description,
        tDataSource.type,
        tDataSource.status,
        tDataSource.lastSync,
        tDataSource.errorMessage,
      ]);
    });

    test('equatable works correctly', () {
      const same = DataSource(
        id: '1',
        name: 'Test Source',
        description: 'Description',
        type: DataSourceType.sensor,
        status: DataSourceStatus.disconnected,
      );
      expect(tDataSource, same);
    });

    test('different fields are not equal', () {
      final different = tDataSource.copyWith(id: '2');
      expect(tDataSource == different, false);
    });
  });
}
