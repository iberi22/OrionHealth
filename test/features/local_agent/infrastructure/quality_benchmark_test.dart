import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';

class SimpleEmbeddingsAdapter implements EmbeddingsAdapter {
  @override
  int get dimension => 768;

  @override
  String get providerName => 'simple_hash';

  @override
  Future<List<double>> embed(String text) async {
    final seed = text.hashCode;
    return List.generate(dimension, (i) {
      final rng = ((seed + i * 31) % 0x7FFFFFFF) / 0x7FFFFFFF;
      return rng;
    });
  }
}

class InMemoryVectorIndex implements VectorIndex {
  final Map<String, _DocEntry> _docs = {};
  InMemoryVectorIndex({int dimension = 768}) : _dim = dimension;

  @override
  String get provider => 'in_memory';
  @override
  String get namespace => 'default';
  @override
  bool get normalize => false;
  @override
  VectorMetric get metric => VectorMetric.cosine;

  @override
  int get dimension => _dim;

  final int _dim;

  @override
  Future<void> addDocument(
    String id,
    String content,
    Float32List vector,
  ) async {
    _docs[id] = _DocEntry(content: content, vector: vector);
  }

  @override
  Future<void> removeDocument(String id) async {
    _docs.remove(id);
  }

  @override
  Future<List<VectorSearchResult>> search(
    Float32List query, {
    int topK = 5,
  }) async {
    final scores = <_ScoredId>[];
    for (final entry in _docs.entries) {
      final score = _cosine(query, entry.value.vector);
      scores.add(_ScoredId(id: entry.key, score: score));
    }
    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores
        .take(topK)
        .map((s) => VectorSearchResult(id: s.id, score: s.score))
        .toList();
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
    return magA == 0 || magB == 0 ? 0 : dot / (sqrt(magA) * sqrt(magB));
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

void main() {
  group('Medical RAG Quality Benchmark CI Test', () {
    late SimpleEmbeddingsAdapter adapter;
    late InMemoryVectorIndex vectorIndex;
    late List<dynamic> documents;
    late List<dynamic> querySubset;

    setUp(() async {
      final fixtureFile = File('test/fixtures/medical_benchmark_queries.json');
      expect(
        fixtureFile.existsSync(),
        isTrue,
        reason:
            'Fixture file test/fixtures/medical_benchmark_queries.json should exist',
      );

      final Map<String, dynamic> data = jsonDecode(
        await fixtureFile.readAsString(),
      );
      documents = data['documents'] ?? [];
      final allQueries = data['queries'] as List<dynamic>? ?? [];

      // Subset of 5 benchmark queries for fast CI execution (<30s)
      querySubset = allQueries.take(5).toList();

      adapter = SimpleEmbeddingsAdapter();
      vectorIndex = InMemoryVectorIndex(dimension: adapter.dimension);

      // Populate index with medical documents
      for (final doc in documents) {
        final docId = doc['id'] as String;
        final content = doc['content'] as String;
        final vector = await adapter.embed(content);
        await vectorIndex.addDocument(
          docId,
          content,
          Float32List.fromList(vector),
        );
      }
    });

    test(
      'Executes subset of 5 benchmark queries and verifies latency & recall thresholds',
      () async {
        final stopwatch = Stopwatch()..start();
        final List<double> latencies = [];
        final List<double> recalls = [];

        for (final q in querySubset) {
          final queryText = q['query'] as String;
          final expectedIds = (q['expected_doc_ids'] as List)
              .map((id) => id.toString())
              .toList();

          final queryStopwatch = Stopwatch()..start();
          final queryVector = await adapter.embed(queryText);
          final results = await vectorIndex.search(
            Float32List.fromList(queryVector),
            topK: 3,
          );
          queryStopwatch.stop();

          final latencyMs = queryStopwatch.elapsedMicroseconds / 1000.0;
          latencies.add(latencyMs);

          final retrievedIds = results.map((r) => r.id).toList();
          final relevantCount = retrievedIds
              .where((id) => expectedIds.contains(id))
              .length;
          final recall = expectedIds.isEmpty
              ? 0.0
              : relevantCount / expectedIds.length;
          recalls.add(recall);
        }

        stopwatch.stop();

        // Total test execution time must be under 30 seconds
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(30000),
          reason: 'CI benchmark test execution must be < 30 seconds',
        );

        latencies.sort();
        final indexP95 = ((95 / 100) * (latencies.length - 1)).round();
        final p95Latency = latencies[min(indexP95, latencies.length - 1)];

        final avgRecall = recalls.reduce((a, b) => a + b) / recalls.length;

        // Verify latency p95 < 500ms
        expect(
          p95Latency,
          lessThan(500.0),
          reason: 'p95 latency ($p95Latency ms) must be less than 500ms',
        );

        // Verify recall >= 0.5
        expect(
          avgRecall,
          greaterThanOrEqualTo(0.50),
          reason: 'Recall ($avgRecall) must be >= 0.5',
        );
      },
    );
  });
}
