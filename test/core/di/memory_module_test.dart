import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:orionhealth_health/core/di/memory_module.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';

class TestMemoryModule extends MemoryModule {}
class MockIsar extends Mock implements Isar {}
class MockEmbeddingsAdapter extends Mock implements EmbeddingsAdapter {}

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
  });

  group('MemoryModule DI', () {
    test('should register all services in GetIt', () async {
      final gh = GetItHelper(getIt);
      final module = TestMemoryModule();
      final mockIsar = MockIsar();

      gh.lazySingleton<EmbeddingsAdapter>(() => module.embeddingsAdapter);
      await gh.lazySingletonAsync<MemoryGraph>(
        () => module.memoryGraph(mockIsar, getIt<EmbeddingsAdapter>()),
      );

      expect(getIt<EmbeddingsAdapter>(), isA<EmbeddingsAdapter>());
      expect(await getIt.getAsync<MemoryGraph>(), isA<MemoryGraph>());
    });

    test('should register services as singletons', () async {
      final gh = GetItHelper(getIt);
      final module = TestMemoryModule();
      final mockIsar = MockIsar();

      gh.lazySingleton<EmbeddingsAdapter>(() => module.embeddingsAdapter);
      await gh.lazySingletonAsync<MemoryGraph>(
        () => module.memoryGraph(mockIsar, getIt<EmbeddingsAdapter>()),
      );

      final adapter1 = getIt<EmbeddingsAdapter>();
      final adapter2 = getIt<EmbeddingsAdapter>();
      expect(adapter1, same(adapter2));

      final graph1 = await getIt.getAsync<MemoryGraph>();
      final graph2 = await getIt.getAsync<MemoryGraph>();
      expect(graph1, same(graph2));
    });
  });
}
