import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_import_result.dart';

void main() {
  group('HealthImportResult', () {
    test('supports value equality', () {
      expect(
        const HealthImportResult(source: HealthDataSource.googleFit, importedCount: 10),
        const HealthImportResult(source: HealthDataSource.googleFit, importedCount: 10),
      );
    });

    test('props are correct', () {
      const result = HealthImportResult(source: HealthDataSource.appleHealth, importedCount: 5);
      expect(result.props, [HealthDataSource.appleHealth, 5]);
    });
  });
}
