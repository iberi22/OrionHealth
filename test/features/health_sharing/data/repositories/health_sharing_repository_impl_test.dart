import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/data/repositories/health_sharing_repository_impl.dart';
import 'package:orionhealth_health/features/health_sharing/data/datasources/health_sharing_local_datasource.dart';
import 'package:orionhealth_health/features/health_sharing/data/datasources/health_sharing_remote_datasource.dart';

class MockLocalDataSource extends Mock implements HealthSharingLocalDataSource {}
class MockRemoteDataSource extends Mock implements HealthSharingRemoteDataSource {}

void main() {
  late HealthSharingRepository repository;
  late MockLocalDataSource mockLocal;
  late MockRemoteDataSource mockRemote;

  setUp(() {
    mockLocal = MockLocalDataSource();
    mockRemote = MockRemoteDataSource();
    repository = HealthSharingRepository(mockLocal, mockRemote);
  });

  group('HealthSharingRepository', () {
    test('getSentPackages proxies to local data source', () async {
      when(() => mockLocal.getSentPackages()).thenAnswer((_) async => []);
      final result = await repository.getSentPackages();
      expect(result, isEmpty);
    });
  });
}
