import 'package:flutter_test/flutter_test.dart';
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
      const state = HealthImportReady(
        availableSources: [HealthDataSource.googleFit],
        availability: {HealthDataSource.googleFit: true},
      );
      expect(state, state);
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
      const state = HealthImportSuccess(
        importedCount: 10,
        source: HealthDataSource.googleFit,
      );
      expect(state, state);
    });

    test('HealthImportError supports value equality', () {
      expect(const HealthImportError('error'), const HealthImportError('error'));
    });
  });
}
