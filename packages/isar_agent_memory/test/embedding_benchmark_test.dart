import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_agent_memory/src/on_device_embeddings_adapter.dart';
import 'package:isar_agent_memory/src/vector_index.dart';
import 'test_utils.dart';
import 'embedding_benchmark_data.dart';

void main() {
  group('Embedding Quality Benchmark and Regression Suite', () {
    final modelPath = 'test_resources/model.onnx';
    final vocabPath = 'test_resources/vocab.txt';

    late OnDeviceEmbeddingsAdapter adapter;
    late InMemoryVectorIndex index;

    setUp(() async {
      // Ensure local ONNX files exist before proceeding
      if (!File(modelPath).existsSync() || !File(vocabPath).existsSync()) {
        fail(
            'Model files not found. Run tool/setup_on_device_test.dart first.');
      }

      adapter = OnDeviceEmbeddingsAdapter(
        modelPath: modelPath,
        vocabPath: vocabPath,
        dimension: 384,
      );

      await adapter.initialize();

      index = InMemoryVectorIndex(
        dimension: 384,
        metric: VectorMetric.cosine,
      );
    });

    tearDown(() {
      adapter.release();
    });

    test('Runs Quality Benchmark and Asserts Recall@K Thresholds', () async {
      final indexingStopwatch = Stopwatch()..start();

      // 1. Indexing all medical documents
      for (final doc in medicalBenchmarkDocuments) {
        final vector = await adapter.embed(doc.content);
        final float32Vector = Float32List.fromList(vector);
        await index.addDocument(doc.id, doc.content, float32Vector);
      }
      indexingStopwatch.stop();

      final totalDocs = medicalBenchmarkDocuments.length;
      final avgIndexingLatencyMs =
          indexingStopwatch.elapsedMilliseconds / totalDocs;

      print('---------------------------------------------------------');
      print('EMBEDDING QUALITY BENCHMARK FOR MEDICAL RAG');
      print('---------------------------------------------------------');
      print('Indexed $totalDocs documents.');
      print(
          'Average Indexing Latency: ${avgIndexingLatencyMs.toStringAsFixed(2)} ms / document');
      print('');

      // 2. Querying and Evaluation
      int hitsAt1 = 0;
      int hitsAt3 = 0;
      int hitsAt5 = 0;

      final queryStopwatch = Stopwatch();
      final List<String> details = [];

      for (final benchmark in medicalBenchmarkQueries) {
        queryStopwatch.start();
        final queryVector = await adapter.embed(benchmark.query);
        final results =
            await index.search(Float32List.fromList(queryVector), topK: 5);
        queryStopwatch.stop();

        final retrievedIds = results.map((r) => r.id).toList();

        // Calculate Recall@K
        // Recall@K = (Retrieved in Top-K intersect Expected) / Expected
        // In our case, Expected size is always 1, so Recall@K is 1 if expected id is in top-K, 0 otherwise.
        final expectedId = benchmark.expectedIds.first;

        final isHitAt1 = retrievedIds.take(1).contains(expectedId);
        final isHitAt3 = retrievedIds.take(3).contains(expectedId);
        final isHitAt5 = retrievedIds.take(5).contains(expectedId);

        if (isHitAt1) hitsAt1++;
        if (isHitAt3) hitsAt3++;
        if (isHitAt5) hitsAt5++;

        details.add('Query: "${benchmark.query}"\n'
            '  Expected: $expectedId\n'
            '  Retrieved Top 3: ${retrievedIds.take(3).toList()}\n'
            '  Hit@1: $isHitAt1 | Hit@3: $isHitAt3 | Hit@5: $isHitAt5\n');
      }

      final totalQueries = medicalBenchmarkQueries.length;
      final recallAt1 = hitsAt1 / totalQueries;
      final recallAt3 = hitsAt3 / totalQueries;
      final recallAt5 = hitsAt5 / totalQueries;

      final avgQueryLatencyMs =
          queryStopwatch.elapsedMilliseconds / totalQueries;

      print('RESULTS TABLE:');
      print('| Metric    | Actual   | Threshold | Pass? |');
      print('|-----------|----------|-----------|-------|');
      print(
          '| Recall@1  | ${(recallAt1 * 100).toStringAsFixed(1)}%   | 70.0%     | ${recallAt1 >= 0.70 ? "✅" : "❌"}     |');
      print(
          '| Recall@3  | ${(recallAt3 * 100).toStringAsFixed(1)}%   | 85.0%     | ${recallAt3 >= 0.85 ? "✅" : "❌"}     |');
      print(
          '| Recall@5  | ${(recallAt5 * 100).toStringAsFixed(1)}%   | 90.0%     | ${recallAt5 >= 0.90 ? "✅" : "❌"}     |');
      print('');
      print(
          'Average Query Latency (Inference + Search): ${avgQueryLatencyMs.toStringAsFixed(2)} ms / query');
      print('');
      print('Detailed Retrieval Breakdown:');
      print(details.join('\n'));
      print('---------------------------------------------------------');

      // Regression assertions to fail CI if thresholds are not met
      expect(recallAt1, greaterThanOrEqualTo(0.70),
          reason: 'Recall@1 threshold (70.0%) not met.');
      expect(recallAt3, greaterThanOrEqualTo(0.85),
          reason: 'Recall@3 threshold (85.0%) not met.');
      expect(recallAt5, greaterThanOrEqualTo(0.90),
          reason: 'Recall@5 threshold (90.0%) not met.');
    });
  });
}
