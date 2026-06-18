import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';

/// Minimal concrete implementation for testing the abstract interface
class TestVectorStoreService implements VectorStoreService {
  final Map<String, String> _documents = {};
  final Map<String, Map<String, dynamic>> _metadata = {};

  @override
  Future<void> indexMedicalStandards({bool force = false}) async {
    // no-op for test
  }

  @override
  Future<void> addDocument(
    String id,
    String content,
    Map<String, dynamic> metadata,
  ) async {
    _documents[id] = content;
    _metadata[id] = metadata;
  }

  @override
  Future<List<String>> search(String query, {int limit = 3}) async {
    // Simple case-insensitive contains search for testing
    final results = _documents.values
        .where((d) => d.toLowerCase().contains(query.toLowerCase()))
        .take(limit)
        .toList();
    return results;
  }

  @override
  Future<List<String>> searchWithReRanking(
    String query, {
    int limit = 3,
    String strategy = 'mmr',
  }) async {
    return search(query, limit: limit);
  }

  @override
  Future<String> createSummaryNode(
    String summaryContent,
    List<String> childNodeIds, {
    int layer = 1,
    String? type,
  }) async {
    return 'summary-node-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<List<Map<String, dynamic>>> getNodesByLayer(int layer) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> multiHopSearch(
    String query, {
    int maxHops = 2,
    int topK = 5,
  }) async {
    return [];
  }
}

void main() {
  late TestVectorStoreService service;

  setUp(() {
    service = TestVectorStoreService();
  });

  group('VectorStoreService interface', () {
    test('indexMedicalStandards completes without error', () async {
      await service.indexMedicalStandards();
      // Should complete without throwing
    });

    test('indexMedicalStandards with force parameter', () async {
      await service.indexMedicalStandards(force: true);
      // Should complete without throwing
    });

    test('addDocument and search round-trip', () async {
      await service.addDocument('doc1', 'Diabetes treatment metformin', {
        'standard': 'ICD-10',
        'code': 'E11',
      });

      final results = await service.search('diabetes');

      expect(results, hasLength(1));
      expect(results.first, contains('Diabetes'));
    });

    test('search returns empty list when no match', () async {
      await service.addDocument('doc1', 'Heart disease symptoms', {
        'standard': 'ICD-10',
        'code': 'I10',
      });

      final results = await service.search('cancer');

      expect(results, isEmpty);
    });

    test('search respects limit parameter', () async {
      for (var i = 0; i < 5; i++) {
        await service.addDocument('doc$i', 'test document $i for search', {});
      }

      final results = await service.search('test', limit: 2);

      expect(results.length, lessThanOrEqualTo(2));
    });

    test('searchWithReRanking delegates to search', () async {
      await service.addDocument('doc1', 'Hypertension management', {
        'standard': 'ICD-10',
        'code': 'I10',
      });

      final results = await service.searchWithReRanking(
        'hypertension',
        limit: 3,
        strategy: 'bm25',
      );

      expect(results, hasLength(1));
    });

    test('searchWithReRanking supports different strategies', () async {
      await service.addDocument('doc1', 'Depression treatment', {
        'standard': 'ICD-10',
      });

      for (final strategy in ['bm25', 'mmr', 'diversity', 'recency', 'none']) {
        final results = await service.searchWithReRanking(
          'depression',
          strategy: strategy,
        );
        expect(results, hasLength(1));
      }
    });

    test('createSummaryNode returns a node ID', () async {
      final nodeId = await service.createSummaryNode(
        'Summary of diabetes findings',
        ['child1', 'child2'],
        layer: 2,
        type: 'clinical',
      );

      expect(nodeId, isA<String>());
      expect(nodeId, startsWith('summary-node-'));
    });

    test('getNodesByLayer returns empty list', () async {
      final nodes = await service.getNodesByLayer(1);
      expect(nodes, isEmpty);
    });

    test('multiHopSearch returns empty list', () async {
      final results = await service.multiHopSearch(
        'diabetes',
        maxHops: 3,
        topK: 10,
      );
      expect(results, isEmpty);
    });
  });
}
