import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

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

void printUsage() {
  print('''
Embedding Quality Benchmark CLI for Medical RAG

Usage:
  dart run scripts/benchmark_embeddings.dart [options]

Options:
  --help, -h          Show this help message.
  --fixture <path>    Path to medical benchmark queries JSON fixture file.
                      Default: test/fixtures/medical_benchmark_queries.json
  --top-k <int>       Number of top results to retrieve per query (default: 3).
  --precision-threshold <double>
                      Minimum required precision (default: 0.70).
  --recall-threshold <double>
                      Minimum required recall (default: 0.50).
''');
}

void main(List<String> args) async {
  String fixturePath = 'test/fixtures/medical_benchmark_queries.json';
  int topK = 3;
  double precisionThreshold = 0.70;
  double recallThreshold = 0.50;

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--help' || arg == '-h') {
      printUsage();
      exit(0);
    } else if (arg == '--fixture' && i + 1 < args.length) {
      fixturePath = args[++i];
    } else if (arg == '--top-k' && i + 1 < args.length) {
      topK = int.parse(args[++i]);
    } else if (arg == '--precision-threshold' && i + 1 < args.length) {
      precisionThreshold = double.parse(args[++i]);
    } else if (arg == '--recall-threshold' && i + 1 < args.length) {
      recallThreshold = double.parse(args[++i]);
    }
  }

  final fixtureFile = File(fixturePath);
  if (!fixtureFile.existsSync()) {
    stderr.writeln('Error: Fixture file not found at "$fixturePath"');
    exit(1);
  }

  final Map<String, dynamic> data = jsonDecode(
    await fixtureFile.readAsString(),
  );
  final List<dynamic> documentsRaw = data['documents'] ?? [];
  final List<dynamic> queriesRaw = data['queries'] ?? [];

  final adapter = SimpleEmbeddingsAdapter();
  final vectorIndex = InMemoryVectorIndex(dimension: adapter.dimension);

  // Index corpus documents
  for (final doc in documentsRaw) {
    final docId = doc['id'] as String;
    final content = doc['content'] as String;
    final vector = await adapter.embed(content);
    await vectorIndex.addDocument(docId, content, Float32List.fromList(vector));
  }

  final List<double> latencies = [];
  final List<double> precisions = [];
  final List<double> recalls = [];
  final List<double> mrrs = [];
  final List<Map<String, dynamic>> queryMetricsList = [];

  for (final q in queriesRaw) {
    final queryText = q['query'] as String;
    final expectedIds = (q['expected_doc_ids'] as List)
        .map((id) => id.toString())
        .toList();
    final category = q['category'] as String? ?? 'general';

    final stopwatch = Stopwatch()..start();
    final queryVector = await adapter.embed(queryText);
    final searchResults = await vectorIndex.search(
      Float32List.fromList(queryVector),
      topK: topK,
    );
    stopwatch.stop();

    final latencyMs = stopwatch.elapsedMicroseconds / 1000.0;
    latencies.add(latencyMs);

    final retrievedIds = searchResults.map((r) => r.id).toList();
    final relevantRetrieved = retrievedIds
        .where((id) => expectedIds.contains(id))
        .length;

    final precision = retrievedIds.isEmpty
        ? 0.0
        : relevantRetrieved / retrievedIds.length;
    final recall = expectedIds.isEmpty
        ? 0.0
        : relevantRetrieved / expectedIds.length;

    double mrr = 0.0;
    for (int idx = 0; idx < retrievedIds.length; idx++) {
      if (expectedIds.contains(retrievedIds[idx])) {
        mrr = 1.0 / (idx + 1);
        break;
      }
    }

    precisions.add(precision);
    recalls.add(recall);
    mrrs.add(mrr);

    queryMetricsList.add({
      'query': queryText,
      'category': category,
      'latencyMs': latencyMs,
      'precision': precision,
      'recall': recall,
      'mrr': mrr,
      'retrievedIds': retrievedIds,
      'expectedIds': expectedIds,
    });
  }

  latencies.sort();
  double p50 = getPercentile(latencies, 50);
  double p95 = getPercentile(latencies, 95);
  double p99 = getPercentile(latencies, 99);
  double avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;

  double avgPrecision = precisions.reduce((a, b) => a + b) / precisions.length;
  double avgRecall = recalls.reduce((a, b) => a + b) / recalls.length;
  double avgMrr = mrrs.reduce((a, b) => a + b) / mrrs.length;

  final precisionPass = avgPrecision >= precisionThreshold;
  final recallPass = avgRecall >= recallThreshold;
  final overallPass = precisionPass && recallPass;

  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final reportDir = Directory('docs/diagnostics');
  if (!reportDir.existsSync()) {
    reportDir.createSync(recursive: true);
  }
  final reportFile = File('docs/diagnostics/embedding_benchmark_$timestamp.md');

  final markdownContent =
      '''
# Medical RAG Embedding Quality Benchmark Report

**Date:** ${DateTime.now().toIso8601String()}
**Fixture:** `$fixturePath`
**Total Documents:** ${documentsRaw.length}
**Total Queries:** ${queriesRaw.length}
**Provider:** `${adapter.providerName}`

## 📊 Summary Metrics

| Metric | Measured Value | Threshold | Status |
| :--- | :--- | :--- | :--- |
| **Precision@$topK** | ${(avgPrecision * 100).toStringAsFixed(1)}% | ${(precisionThreshold * 100).toStringAsFixed(1)}% | ${precisionPass ? "✅ PASS" : "❌ FAIL"} |
| **Recall@$topK** | ${(avgRecall * 100).toStringAsFixed(1)}% | ${(recallThreshold * 100).toStringAsFixed(1)}% | ${recallPass ? "✅ PASS" : "❌ FAIL"} |
| **MRR (Mean Reciprocal Rank)** | ${avgMrr.toStringAsFixed(3)} | - | ℹ️ INFO |
| **Mean Latency** | ${avgLatency.toStringAsFixed(2)} ms | - | ℹ️ INFO |
| **Latency p50** | ${p50.toStringAsFixed(2)} ms | - | ℹ️ INFO |
| **Latency p95** | ${p95.toStringAsFixed(2)} ms | - | ℹ️ INFO |
| **Latency p99** | ${p99.toStringAsFixed(2)} ms | - | ℹ️ INFO |

---

## 🔍 Detailed Query Performance

| Category | Query | Precision | Recall | MRR | Latency (ms) |
| :--- | :--- | :--- | :--- | :--- | :--- |
${queryMetricsList.map((q) => "| ${q['category']} | `${q['query']}` | ${(q['precision'] * 100).toStringAsFixed(0)}% | ${(q['recall'] * 100).toStringAsFixed(0)}% | ${q['mrr'].toStringAsFixed(2)} | ${q['latencyMs'].toStringAsFixed(2)} |").join('\n')}

---

## 🎯 Overall Outcome: ${overallPass ? "PASSED ✅" : "FAILED ❌"}
''';

  await reportFile.writeAsString(markdownContent);

  print(markdownContent);
  print('Benchmark report saved to: ${reportFile.path}');

  if (!overallPass) {
    stderr.writeln('Benchmark metrics did not meet required thresholds!');
    exit(1);
  } else {
    exit(0);
  }
}

double getPercentile(List<double> sortedValues, double percentile) {
  if (sortedValues.isEmpty) return 0.0;
  final index = ((percentile / 100) * (sortedValues.length - 1)).round();
  return sortedValues[min(index, sortedValues.length - 1)];
}
