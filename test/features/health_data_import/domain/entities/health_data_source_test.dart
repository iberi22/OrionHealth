import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';

void main() {
  group('HealthDataSource', () {
    test('displayName returns correct names', () {
      expect(HealthDataSource.googleFit.displayName, 'Google Fit / Health Connect');
      expect(HealthDataSource.appleHealth.displayName, 'Apple Health');
      expect(HealthDataSource.samsungHealth.displayName, 'Samsung Health');
    });

    test('sourceKey returns correct keys', () {
      expect(HealthDataSource.googleFit.sourceKey, 'google_fit');
      expect(HealthDataSource.appleHealth.sourceKey, 'apple_health');
      expect(HealthDataSource.samsungHealth.sourceKey, 'samsung_health');
    });
  });
}
