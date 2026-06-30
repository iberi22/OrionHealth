import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/data/repositories/health_sharing_repository_impl.dart';
import 'package:orionhealth_health/features/health_sharing/data/datasources/health_sharing_local_datasource.dart';

class MockLocalDataSource extends Mock implements HealthSharingLocalDataSource {}

void main() {
  late HealthSharingRepository repository;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockLocal = MockLocalDataSource();
    repository = HealthSharingRepository(mockLocal);
  });

  group('HealthSharingRepository', () {
    test('getSentPackages proxies to local data source', () async {
      when(() => mockLocal.getSentPackages()).thenAnswer((_) async => []);
      final result = await repository.getSentPackages();
      expect(result, isEmpty);
    });
  });
}
