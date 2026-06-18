import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/data/datasources/dashboard_local_datasource.dart';

void main() {
  group('DashboardLocalDataSource', () {
    late DashboardLocalDataSource datasource;

    setUp(() {
      datasource = DashboardLocalDataSource();
    });

    group('savePreference', () {
      test('completes without error', () async {
        await datasource.savePreference('widget_order', 'stats,activity');
      });
    });

    group('getPreference', () {
      test('returns null by default', () async {
        final result = await datasource.getPreference('widget_order');
        expect(result, isNull);
      });

      test('returns null for non-existent key', () async {
        final result = await datasource.getPreference('non_existent');
        expect(result, isNull);
      });
    });
  });
}
