import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_import_result.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';

void main() {
  group('HealthImportState', () {
    test('HealthImportInitial supports value equality', () {
      expect(const HealthImportInitial(), const HealthImportInitial());
    });

    test('HealthImportLoading supports value equality', () {
      expect(const HealthImportLoading(), const HealthImportLoading());
    });

    test('HealthImportReady supports value equality', () {
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

    test('HealthImportAuthenticating supports value equality', () {
      expect(
        const HealthImportAuthenticating(HealthDataSource.googleFit),
        const HealthImportAuthenticating(HealthDataSource.googleFit),
      );
    });

    test('HealthImportImporting supports value equality', () {
      const state = HealthImportImporting(
        source: HealthDataSource.googleFit,
        currentStep: 'Step 1',
        totalSteps: 5,
        currentStepNum: 1,
        importedCount: 0,
      );
      expect(state, state);
      expect(state.progress, 0.2);
    });

    test('HealthImportSuccess supports value equality', () {
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

    test('HealthImportError supports value equality', () {
      expect(const HealthImportError('error'), const HealthImportError('error'));
    });
  });
}
