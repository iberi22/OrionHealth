import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_import_result.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';

void main() {
  group('HealthImportState', () {
    test('HealthImportReady support value equality', () {
      expect(
        const HealthImportReady(
          availableSources: [HealthDataSource.googleFit],
          availability: {HealthDataSource.googleFit: true},
        ),
        const HealthImportReady(
          availableSources: [HealthDataSource.googleFit],
          availability: {HealthDataSource.googleFit: true},
        ),
      );
    });

    test('HealthImportAuthenticating support value equality', () {
      expect(
        const HealthImportAuthenticating(HealthDataSource.googleFit),
        const HealthImportAuthenticating(HealthDataSource.googleFit),
      );
    });

    test('HealthImportSuccess support value equality', () {
      final result1 = HealthImportResult(
        source: HealthDataSource.googleFit,
        importedCount: 10,
      );
      final result2 = HealthImportResult(
        source: HealthDataSource.googleFit,
        importedCount: 10,
      );
      expect(
        HealthImportSuccess(result1),
        HealthImportSuccess(result2),
      );
    });
  });
}
