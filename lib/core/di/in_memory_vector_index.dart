import 'dart:math' as math;
import 'dart:typed_data';
import 'package:isar_agent_memory/isar_agent_memory.dart';

/// Simple in-memory vector index for development / when ObjectBox is unavailable.
class InMemoryVectorIndex implements VectorIndex {
  final Map<String, _DocEntry> _docs = {};
  InMemoryVectorIndex({int dimension = 768});

  @override
  String get provider => 'in_memory';
  @override
  String get namespace => 'default';
  @override
  bool get normalize => false;
  @override
  VectorMetric get metric => VectorMetric.cosine;

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
      final score = _cosine(query, entry.value.vector);
      scores.add(_ScoredId(id: entry.key, score: score));
    }
    scores.sort((a, b) => b.score.compareTo(a.score));
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
