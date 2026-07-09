import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/domain/repositories/data_source_repository.dart';

class MockRepo extends Mock implements DataSourceRepository {}

void main() {
  late DataSourceRepository repo;

  setUp(() {
    repo = MockRepo();
  });

  test('disconnectDataSource calls repository', () async {
    when(() => repo.disconnectDataSource(any())).thenAnswer((_) async => {});
    await repo.disconnectDataSource('test_id');
    verify(() => repo.disconnectDataSource('test_id')).called(1);
  });
}
