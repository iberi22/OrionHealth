import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/di/in_memory_vector_index.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';

void main() {
  late InMemoryVectorIndex index;

  setUp(() {
    index = InMemoryVectorIndex(dimension: 3);
  });

  group('InMemoryVectorIndex', () {
    test('should have correct provider and metadata', () {
      expect(index.provider, 'in_memory');
      expect(index.namespace, 'default');
      expect(index.normalize, false);
      expect(index.metric, VectorMetric.cosine);
    });

    test('addDocument and search should return correct results', () async {
      await index.addDocument('1', 'content 1', Float32List.fromList([1.0, 0.0, 0.0]));
      await index.addDocument('2', 'content 2', Float32List.fromList([0.0, 1.0, 0.0]));
      await index.addDocument('3', 'content 3', Float32List.fromList([1.0, 1.0, 0.0]));

      final query = Float32List.fromList([1.0, 0.1, 0.0]);
      final results = await index.search(query, topK: 2);

      expect(results.length, 2);
      expect(results[0].id, '1'); // [1, 0, 0] is closest to [1, 0.1, 0]
      expect(results[1].id, '3'); // [1, 1, 0] is next closest
    });

    test('removeDocument should remove the document from index', () async {
      await index.addDocument('1', 'content 1', Float32List.fromList([1.0, 0.0, 0.0]));

      var results = await index.search(Float32List.fromList([1.0, 0.0, 0.0]));
      expect(results.length, 1);

      await index.removeDocument('1');
      results = await index.search(Float32List.fromList([1.0, 0.0, 0.0]));
      expect(results, isEmpty);
    });

    test('clear should remove all documents', () async {
      await index.addDocument('1', 'content 1', Float32List.fromList([1.0, 0.0, 0.0]));
      await index.addDocument('2', 'content 2', Float32List.fromList([0.0, 1.0, 0.0]));

      await index.clear();
      final results = await index.search(Float32List.fromList([1.0, 0.0, 0.0]));
      expect(results, isEmpty);
    });

    test('load should not throw', () async {
      expect(index.load(), completes);
    });

    test('cosine similarity with zero vector should return 0', () async {
       await index.addDocument('1', 'content 1', Float32List.fromList([0.0, 0.0, 0.0]));
       final results = await index.search(Float32List.fromList([1.0, 1.0, 1.0]));
       expect(results.first.score, 0.0);
    });
  });
}
