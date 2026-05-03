import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'in_memory_vector_index.dart';

@module
abstract class MemoryModule {
  @lazySingleton
  EmbeddingsAdapter get embeddingsAdapter => SimpleEmbeddingsAdapter();

  @lazySingleton
  @preResolve
  Future<MemoryGraph> memoryGraph(Isar isar, EmbeddingsAdapter adapter) async {
    return MemoryGraph(
      isar,
      embeddingsAdapter: adapter,
      index: InMemoryVectorIndex(dimension: 768),
    );
  }
}

class SimpleEmbeddingsAdapter implements EmbeddingsAdapter {
  @override
  int get dimension => 768;

  @override
  String get providerName => 'simple_hash';

  @override
  Future<List<double>> embed(String text) async {
    final seed = text.hashCode;
    // Deterministic pseudo-random generation based on text hash
    return List.generate(dimension, (i) {
      final rng = ((seed + i * 31) % 0x7FFFFFFF) / 0x7FFFFFFF;
      return rng;
    });
  }
}
