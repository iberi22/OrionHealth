import 'dart:math' as math;
import 'dart:typed_data';
import 'package:isar_agent_memory/src/embeddings_adapter.dart';
import 'package:isar_agent_memory/src/vector_index.dart';

class MockEmbeddingsAdapter implements EmbeddingsAdapter {
  final int _dimension;
  MockEmbeddingsAdapter({int dimension = 3}) : _dimension = dimension;

  @override
  int get dimension => _dimension;

  @override
  String get providerName => 'mock';

  @override
  Future<List<double>> embed(String text) async {
    // Generate a simple deterministic vector based on the text
    final random = math.Random(text.hashCode);
    return List.generate(_dimension, (_) => random.nextDouble());
  }
}

class InMemoryVectorIndex implements VectorIndex {
  final Map<String, _DocEntry> _docs = {};
  final int dimension;
  final VectorMetric _metric;

  InMemoryVectorIndex({this.dimension = 3, VectorMetric metric = VectorMetric.cosine})
      : _metric = metric;

  @override
  String get provider => 'in_memory';
  @override
  String get namespace => 'test';
  @override
  bool get normalize => false;
  @override
  VectorMetric get metric => _metric;

  @override
  Future<void> addDocument(String id, String content, Float32List vector) async {
    _docs[id] = _DocEntry(content: content, vector: vector);
  }

  @override
  Future<void> removeDocument(String id) async {
    _docs.remove(id);
  }

  @override
  Future<List<VectorSearchResult>> search(Float32List query, {int topK = 5}) async {
    final scores = <_ScoredId>[];
    for (final entry in _docs.entries) {
      double score;
      switch (_metric) {
        case VectorMetric.cosine:
          score = _cosine(query, entry.value.vector);
          break;
        case VectorMetric.l2:
          score = _l2(query, entry.value.vector);
          break;
        case VectorMetric.dot:
          score = _dot(query, entry.value.vector);
          break;
      }
      scores.add(_ScoredId(id: entry.key, score: score));
    }

    if (_metric == VectorMetric.l2) {
      scores.sort((a, b) => a.score.compareTo(b.score)); // Smaller is better
    } else {
      scores.sort((a, b) => b.score.compareTo(a.score)); // Larger is better
    }

    return scores.take(topK).map((s) => VectorSearchResult(id: s.id, score: s.score)).toList();
  }

  @override
  Future<void> clear() async {
    _docs.clear();
  }

  @override
  Future<void> load() async {}

  double _cosine(Float32List a, Float32List b) {
    double dot = 0, magA = 0, magB = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      magA += a[i] * a[i];
      magB += b[i] * b[i];
    }
    return magA == 0 || magB == 0 ? 0 : dot / (math.sqrt(magA) * math.sqrt(magB));
  }

  double _l2(Float32List a, Float32List b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += (a[i] - b[i]) * (a[i] - b[i]);
    }
    return math.sqrt(sum);
  }

  double _dot(Float32List a, Float32List b) {
    double dot = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }
}

class _DocEntry {
  final String content;
  final Float32List vector;
  _DocEntry({required this.content, required this.vector});
}

class _ScoredId {
  final String id;
  final double score;
  _ScoredId({required this.id, required this.score});
}
