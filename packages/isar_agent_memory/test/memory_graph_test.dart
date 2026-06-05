import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'test_utils.dart';

void main() {
  late Isar isar;
  late MemoryGraph memoryGraph;
  late String testDir;
  late MockEmbeddingsAdapter mockEmbeddings;
  late InMemoryVectorIndex mockIndex;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_memory_graph');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [MemoryNodeSchema, MemoryEdgeSchema],
      directory: testDir,
    );

    mockEmbeddings = MockEmbeddingsAdapter(dimension: 3);
    mockIndex = InMemoryVectorIndex(dimension: 3);
    memoryGraph = MemoryGraph(isar, embeddingsAdapter: mockEmbeddings, index: mockIndex);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    await isar.writeTxn(() async {
      await isar.memoryNodes.clear();
      await isar.memoryEdges.clear();
    });
    await mockIndex.clear();
  });

  group('MemoryGraph Node CRUD', () {
    test('storeNode and getNode', () async {
      final node = MemoryNode(content: 'Test content', type: 'test');
      final id = await memoryGraph.storeNode(node);

      final retrieved = await memoryGraph.getNode(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.content, 'Test content');
      expect(retrieved.type, 'test');
    });

    test('deleteNode', () async {
      final node = MemoryNode(content: 'Delete me');
      final id = await memoryGraph.storeNode(node);

      final deleted = await memoryGraph.deleteNode(id);
      expect(deleted, isTrue);

      final retrieved = await memoryGraph.getNode(id);
      expect(retrieved, isNull);
    });

    test('storeNodeWithEmbedding', () async {
      final id = await memoryGraph.storeNodeWithEmbedding(
        content: 'Embedded content',
        type: 'embedded',
      );

      final retrieved = await memoryGraph.getNode(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.content, 'Embedded content');
      expect(retrieved.embedding, isNotNull);
      expect(retrieved.embedding!.vector.length, 3);

      // Verify it's in the index
      final results = await mockIndex.search(
        Float32List.fromList([0.1, 0.2, 0.3]), // dummy query
        topK: 1,
      );
      expect(results, isNotEmpty);
      expect(results.first.id, id.toString());
    });

    test('storeNodeWithEmbedding deduplication', () async {
      final content = 'Duplicate';

      // First store
      final id1 = await memoryGraph.storeNodeWithEmbedding(content: content);

      // Store again with deduplicate=true.
      // InMemoryVectorIndex uses Cosine similarity (1.0 = perfect match)
      // deduplicationThreshold in MemoryGraph is compared with score < threshold.

      final id2 = await memoryGraph.storeNodeWithEmbedding(
        content: content,
        deduplicate: true,
        deduplicationThreshold: 2.0, // High threshold should catch it if it's distance
      );

      expect(id1, id2);
    });
  });

  group('MemoryGraph Edge Operations', () {
    test('storeEdge and getEdgesForNode', () async {
      final nodeA = MemoryNode(content: 'Node A');
      final nodeB = MemoryNode(content: 'Node B');
      final idA = await memoryGraph.storeNode(nodeA);
      final idB = await memoryGraph.storeNode(nodeB);

      final edge = MemoryEdge(
        fromNodeId: idA,
        toNodeId: idB,
        relation: 'related_to',
      );
      final edgeId = await memoryGraph.storeEdge(edge);
      expect(edgeId, isPositive);

      final edgesA = await memoryGraph.getEdgesForNode(idA);
      expect(edgesA.length, 1);
      expect(edgesA.first.relation, 'related_to');
      expect(edgesA.first.fromNodeId, idA);
      expect(edgesA.first.toNodeId, idB);

      final edgesB = await memoryGraph.getEdgesForNode(idB);
      expect(edgesB.length, 1);
      expect(edgesB.first.fromNodeId, idA);
    });
  });

  group('MemoryGraph Search and Initialization', () {
    test('semanticSearch', () async {
      await memoryGraph.storeNodeWithEmbedding(content: 'Apple');
      await memoryGraph.storeNodeWithEmbedding(content: 'Banana');

      final queryVector = await mockEmbeddings.embed('Apple');
      final results = await memoryGraph.semanticSearch(queryVector, topK: 1);

      expect(results, isNotEmpty);
      expect(results.first.node.content, 'Apple');
    });

    test('hybridSearch', () async {
      await memoryGraph.storeNodeWithEmbedding(content: 'Medical report about diabetes');
      await memoryGraph.storeNodeWithEmbedding(content: 'Recipe for chocolate cake');

      final results = await memoryGraph.hybridSearch('diabetes', topK: 1);

      expect(results, isNotEmpty);
      expect(results.first.node.content, contains('diabetes'));
    });

    test('initialize syncs Isar to index', () async {
      // Add node directly to Isar, bypassing MemoryGraph.storeNode
      final vector = [0.1, 0.2, 0.3];
      final node = MemoryNode(
        content: 'Direct Isar node',
        embedding: MemoryEmbedding(vector: vector, provider: 'mock', dimension: 3),
      );

      await isar.writeTxn(() => isar.memoryNodes.put(node));

      // Index should be empty
      var results = await mockIndex.search(Float32List.fromList(vector), topK: 1);
      expect(results, isEmpty);

      // Initialize
      await memoryGraph.initialize();

      // Now it should be in the index
      results = await mockIndex.search(Float32List.fromList(vector), topK: 1);
      expect(results, isNotEmpty);
      expect(results.first.id, node.id.toString());
    });

    test('explainRecall', () async {
      final id = await memoryGraph.storeNodeWithEmbedding(content: 'Explain me');
      final explanation = await memoryGraph.explainRecall(id, queryEmbedding: [0.1, 0.2, 0.3]);

      expect(explanation, contains('recalled'));
      expect(explanation, contains('Semantic distance'));
    });

    test('semanticSearchWithReRanking', () async {
      final oldNode = MemoryNode(content: 'Old news', updatedAt: DateTime(2020));
      final newNode = MemoryNode(content: 'Fresh news', updatedAt: DateTime.now());
      await memoryGraph.storeNode(oldNode);
      await memoryGraph.storeNode(newNode);

      final queryVector = await mockEmbeddings.embed('news');
      final results = await memoryGraph.semanticSearchWithReRanking(
        queryVector,
        reranker: RecencyReRanker(),
        topK: 1,
      );

      expect(results, isNotEmpty);
      expect(results.first.node.content, 'Fresh news');
    });
  });
}
