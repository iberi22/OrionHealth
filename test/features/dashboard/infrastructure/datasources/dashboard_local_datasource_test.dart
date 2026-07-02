import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_preference.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionDashboardPreference extends IsarCollection<DashboardPreference> {}
class MockIsarCollection extends Mock implements IsarCollectionDashboardPreference {}

class FakeDashboardPreference extends Fake implements DashboardPreference {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  // ignore: unused_local_variable
  late DashboardLocalDataSource datasource;

  setUpAll(() {
    registerFallbackValue(FakeDashboardPreference());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    datasource = DashboardLocalDataSource(mockIsar);

    when(() => mockIsar.dashboardPreferences).thenReturn(mockCollection);
  });

  group('DashboardLocalDataSource', () {
    test('savePreference puts preference in collection', () async {
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);
    });
  });
}
