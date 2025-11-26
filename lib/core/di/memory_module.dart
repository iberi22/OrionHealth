import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'dart:io';

@module
abstract class MemoryModule {
  @lazySingleton
  EmbeddingsAdapter get embeddingsAdapter => SimpleEmbeddingsAdapter();

  @lazySingleton
  @preResolve
  Future<MemoryGraph> memoryGraph(Isar isar, EmbeddingsAdapter adapter) async {
    // Get application documents directory for ObjectBox storage
    final appDir = await getApplicationDocumentsDirectory();
    final objectBoxDir = Directory('${appDir.path}/objectbox');
    
    return MemoryGraph(
      isar,
      embeddingsAdapter: adapter,
      index: ObjectBoxVectorIndex.open(
        directory: objectBoxDir.path,
        namespace: 'default',
      ),
    );
  }
}

class SimpleEmbeddingsAdapter implements EmbeddingsAdapter {
  @override
  int get dimension => 768; // Default for ObjectBox in isar_agent_memory

  @override
  String get providerName => 'simple_hash';

  @override
  Future<List<double>> embed(String text) async {
    // Deterministic pseudo-random generation based on text hash
    final seed = text.hashCode;
    final random = Random(seed);
    return List.generate(dimension, (_) => random.nextDouble());
  }
}
