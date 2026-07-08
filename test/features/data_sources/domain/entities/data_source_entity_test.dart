import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';

void main() {
  group('DataSource Entity - Additional Tests', () {
    group('DataSourceType enum', () {
      test('has sensor value', () {
        expect(DataSourceType.values.contains(DataSourceType.sensor), true);
      });

      test('has file value', () {
        expect(DataSourceType.values.contains(DataSourceType.file), true);
      });

      test('has healthConnect value', () {
        expect(DataSourceType.values.contains(DataSourceType.healthConnect), true);
      });

      test('has exactly 3 values', () {
        expect(DataSourceType.values.length, 3);
      });
    });

    group('DataSourceStatus enum', () {
      test('has disconnected value', () {
        expect(DataSourceStatus.values.contains(DataSourceStatus.disconnected), true);
      });

      test('has connecting value', () {
        expect(DataSourceStatus.values.contains(DataSourceStatus.connecting), true);
      });

      test('has connected value', () {
        expect(DataSourceStatus.values.contains(DataSourceStatus.connected), true);
      });

      test('has error value', () {
        expect(DataSourceStatus.values.contains(DataSourceStatus.error), true);
      });

      test('has exactly 4 values', () {
        expect(DataSourceStatus.values.length, 4);
      });
    });

    group('DataSource constructor', () {
      test('creates instance with all required fields', () {
        const ds = DataSource(
          id: 'test_1',
          name: 'Test Source',
          description: 'A test source description',
          type: DataSourceType.sensor,
          status: DataSourceStatus.disconnected,
        );
        expect(ds.id, 'test_1');
        expect(ds.name, 'Test Source');
        expect(ds.description, 'A test source description');
        expect(ds.type, DataSourceType.sensor);
        expect(ds.status, DataSourceStatus.disconnected);
        expect(ds.lastSync, isNull);
        expect(ds.errorMessage, isNull);
      });

      test('creates instance with optional fields', () {
        final now = DateTime(2025, 1, 15, 10, 30);
        const errorMsg = 'Something went wrong';
        final ds = DataSource(
          id: 'test_2',
          name: 'Source 2',
          description: 'Desc 2',
          type: DataSourceType.file,
          status: DataSourceStatus.error,
          lastSync: now,
          errorMessage: errorMsg,
        );
        expect(ds.id, 'test_2');
        expect(ds.name, 'Source 2');
        expect(ds.type, DataSourceType.file);
        expect(ds.status, DataSourceStatus.error);
        expect(ds.lastSync, now);
        expect(ds.errorMessage, errorMsg);
      });
    });

    group('DataSource equality', () {
      test('identical instances are equal', () {
        const a = DataSource(
          id: '1',
          name: 'A',
          description: 'Desc',
          type: DataSourceType.healthConnect,
          status: DataSourceStatus.connecting,
        );
        const b = DataSource(
          id: '1',
          name: 'A',
          description: 'Desc',
          type: DataSourceType.healthConnect,
          status: DataSourceStatus.connecting,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different id makes instances unequal', () {
        const a = DataSource(
          id: '1',
          name: 'A',
          description: 'Desc',
          type: DataSourceType.sensor,
          status: DataSourceStatus.disconnected,
        );
        const b = DataSource(
          id: '2',
          name: 'A',
          description: 'Desc',
          type: DataSourceType.sensor,
          status: DataSourceStatus.disconnected,
        );
        expect(a, isNot(equals(b)));
      });

      test('different name makes instances unequal', () {
        const a = DataSource(
          id: '1',
          name: 'A',
          description: 'Desc',
          type: DataSourceType.sensor,
          status: DataSourceStatus.disconnected,
        );
        const b = DataSource(
          id: '1',
          name: 'B',
          description: 'Desc',
          type: DataSourceType.sensor,
          status: DataSourceStatus.disconnected,
        );
        expect(a, isNot(equals(b)));
      });

      test('different type makes instances unequal', () {
        const a = DataSource(
          id: '1',
          name: 'A',
          description: 'Desc',
          type: DataSourceType.sensor,
          status: DataSourceStatus.disconnected,
        );
        const b = DataSource(
          id: '1',
          name: 'A',
          description: 'Desc',
          type: DataSourceType.file,
          status: DataSourceStatus.disconnected,
        );
        expect(a, isNot(equals(b)));
      });

      test('different status makes instances unequal', () {
        const a = DataSource(
          id: '1',
          name: 'A',
          description: 'Desc',
          type: DataSourceType.sensor,
          status: DataSourceStatus.disconnected,
        );
        const b = DataSource(
          id: '1',
          name: 'A',
          description: 'Desc',
          type: DataSourceType.sensor,
          status: DataSourceStatus.connected,
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('DataSource copyWith', () {
      const base = DataSource(
        id: '1',
        name: 'Original',
        description: 'Original description',
        type: DataSourceType.sensor,
        status: DataSourceStatus.disconnected,
      );

      test('returns same instance when no arguments', () {
        final result = base.copyWith();
        expect(result, equals(base));
      });

      test('updates id when provided', () {
        final result = base.copyWith(id: 'new_id');
        expect(result.id, 'new_id');
        expect(result.name, base.name);
      });

      test('updates name when provided', () {
        final result = base.copyWith(name: 'New Name');
        expect(result.name, 'New Name');
        expect(result.id, base.id);
      });

      test('updates description when provided', () {
        final result = base.copyWith(description: 'New desc');
        expect(result.description, 'New desc');
      });

      test('updates type when provided', () {
        final result = base.copyWith(type: DataSourceType.healthConnect);
        expect(result.type, DataSourceType.healthConnect);
      });

      test('updates status when provided', () {
        final result = base.copyWith(status: DataSourceStatus.connected);
        expect(result.status, DataSourceStatus.connected);
      });

      test('updates lastSync when provided', () {
        final now = DateTime.now();
        final result = base.copyWith(lastSync: now);
        expect(result.lastSync, now);
      });

      test('updates errorMessage when provided', () {
        final result = base.copyWith(errorMessage: 'error!');
        expect(result.errorMessage, 'error!');
      });

      test('does not mutate original instance', () {
        base.copyWith(
          id: 'new',
          name: 'Changed',
          status: DataSourceStatus.connected,
        );
        expect(base.id, '1');
        expect(base.name, 'Original');
        expect(base.status, DataSourceStatus.disconnected);
      });
    });

    group('DataSource toString and detail', () {
      test('props contains all fields in correct order', () {
        const ds = DataSource(
          id: 'id1',
          name: 'n1',
          description: 'd1',
          type: DataSourceType.sensor,
          status: DataSourceStatus.connected,
          lastSync: null,
          errorMessage: null,
        );
        expect(ds.props[0], 'id1');
        expect(ds.props[1], 'n1');
        expect(ds.props[2], 'd1');
        expect(ds.props[3], DataSourceType.sensor);
        expect(ds.props[4], DataSourceStatus.connected);
        expect(ds.props[5], null);
        expect(ds.props[6], null);
        expect(ds.props.length, 7);
      });
    });
  });
}
