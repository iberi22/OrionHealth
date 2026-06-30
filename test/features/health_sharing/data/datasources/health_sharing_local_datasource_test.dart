import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/data/datasources/health_sharing_local_datasource.dart';

class MockIsar extends Mock implements Isar {}

void main() {
  late HealthSharingLocalDataSource datasource;

  setUp(() {
    datasource = HealthSharingLocalDataSource();
  });

  group('HealthSharingLocalDataSource', () {
    test('getSentPackages returns empty list (placeholder implementation)', () async {
      final result = await datasource.getSentPackages();
      expect(result, isEmpty);
    });
  });
}
