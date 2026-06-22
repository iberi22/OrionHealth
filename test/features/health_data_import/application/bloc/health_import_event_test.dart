import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/application/bloc/health_import_event.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';

void main() {
  group('HealthImportEvent', () {
    test('CheckAvailableSources supports value equality', () {
      expect(const CheckAvailableSources(), const CheckAvailableSources());
    });

    test('ImportFromSource supports value equality', () {
      expect(
        const ImportFromSource(HealthDataSource.googleFit),
        const ImportFromSource(HealthDataSource.googleFit),
      );
    });

    test('ResetImport supports value equality', () {
      expect(const ResetImport(), const ResetImport());
    });
  });
}
