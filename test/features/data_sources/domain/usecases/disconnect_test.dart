import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/data_sources/domain/entities/data_source_entity.dart';
import 'package:orionhealth_health/features/data_sources/domain/repositories/data_source_repository.dart';

class MockRepo extends Mock implements DataSourceRepository {}

void main() {
  late DataSourceRepository repo;

  setUp(() {
    repo = MockRepo();
  });

  test('disconnect returns true on success', () async {
    when(() => repo.disconnect(any())).thenAnswer((_) async => true);
    final result = await repo.disconnect(DataSourceEntity(name: 'test', type: DataSourceType.file));
    expect(result, isTrue);
  });

  test('disconnect returns false on failure', () async {
    when(() => repo.disconnect(any())).thenAnswer((_) async => false);
    final result = await repo.disconnect(DataSourceEntity(name: 'test', type: DataSourceType.file));
    expect(result, isFalse);
  });
}
