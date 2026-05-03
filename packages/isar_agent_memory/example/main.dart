import 'package:isar/isar.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

/// Simple in-memory vector index for example use.
class SimpleMemoryIndex implements VectorIndex {
  final _docs = <String, _DocEntry>{};
  @override
  final String provider = 'simple_memory';
  @override
  final String namespace;
  @override
  bool get normalize => false;
  @override
  VectorMetric get metric => VectorMetric.cosine;

  SimpleMemoryIndex({this.namespace = 'default'});

  @override
  Future<void> addDocument(String id, String content, Float32List vector) async {
    _docs[id] = _DocEntry(content: content, vector: vector);
  }

  @override
  Future<void> removeDocument(String id) async { _docs.remove(id); }

  @override
  Future<List<VectorSearchResult>> search(Float32List query, {int topK = 5}) async {
    final scores = _docs.entries.map((e) {
      final score = _cosine(query, e.value.vector);
      return MapEntry(e.key, score);
    }).toList();
    scores.sort((a, b) => a.value.compareTo(b.value));
    return scores.take(topK)
        .map((e) => VectorSearchResult(id: e.key, score: e.value))
        .toList();
  }

  @override
  Future<void> clear() async { _docs.clear(); }

  @override
  Future<void> load() async {}

  double _cosine(Float32List a, Float32List b) {
    double dot = 0, na = 0, nb = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    return dot / (math.sqrt(na) * math.sqrt(nb) + 1e-10);
  }
}

class _DocEntry {
  final String content;
  final Float32List vector;
  _DocEntry({required this.content, required this.vector});
}

Future<void> main() async {
  // Set your Gemini API key here or via environment variable
  final apiKey =
      Platform.environment['GEMINI_API_KEY'] ?? '<YOUR_GEMINI_API_KEY>';
  final adapter = GeminiEmbeddingsAdapter(apiKey: apiKey);

  // Initialize Isar Core for pure Dart
  await Isar.initializeIsarCore(download: true);

  // Create the directory for the Isar database
  await Directory('./exampledb').create(recursive: true);

  // Open Isar in a temp directory for demo
  final isar = await Isar.open(
    [MemoryNodeSchema, MemoryEdgeSchema],
    inspector: false,
    directory: './exampledb',
  );
  final graph = MemoryGraph(isar, embeddingsAdapter: adapter, index: SimpleMemoryIndex());

  // Store a node with embedding
  final nodeId = await graph.storeNodeWithEmbedding(
      content: 'The quick brown fox jumps over the lazy dog.');
  print('Stored node with id: $nodeId');

  // Query with a similar phrase
  final queryEmbedding = await adapter.embed('A fox jumps over a dog');
  final results = await graph.semanticSearch(queryEmbedding, topK: 3);
  for (final result in results) {
    print(
        'Node: ${result.node.content}, Distance: ${result.distance.toStringAsFixed(3)}, Provider: ${result.provider}');
  }

  // Explain recall for the top result
  if (results.isNotEmpty) {
    final explanation = await graph.explainRecall(results.first.node.id,
        queryEmbedding: queryEmbedding);
    print('Explain: $explanation');
  }

  await isar.close(deleteFromDisk: true);
}
