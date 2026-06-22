import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/data/datasources/dashboard_remote_datasource.dart';

void main() {
  group('DashboardRemoteDataSourceImpl', () {
    late DashboardRemoteDataSourceImpl datasource;

    setUp(() {
      datasource = DashboardRemoteDataSourceImpl();
    });

    test('getRemoteDashboardStats returns default empty stats', () async {
      final result = await datasource.getRemoteDashboardStats();
      expect(result.totalMedications, 0);
      expect(result.reportsCount, 0);
    });

    test('getRemoteRecentActivity returns empty list', () async {
      final result = await datasource.getRemoteRecentActivity();
      expect(result, isEmpty);
    });
  });
}
