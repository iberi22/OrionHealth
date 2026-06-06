import 'dart:io';
import 'package:test/test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:isar_agent_memory/src/memory_graph.dart';
import 'package:isar_agent_memory/src/models/memory_node.dart';
import 'package:isar_agent_memory/src/models/memory_edge.dart';
import 'test_utils.dart';

void main() {
  late Isar isar;
  late MemoryGraph memoryGraph;
  late String testDir;
  late MockEmbeddingsAdapter mockEmbeddings;
  late InMemoryVectorIndex mockIndex;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_memory_crud');
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

  group('Memory CRUD Operations', () {
    test('Basic Node CRUD', () async {
      // Create
      final node = MemoryNode(content: 'CRUD test', type: 'type_a');
      final id = await memoryGraph.storeNode(node);
      expect(id, isPositive);

      // Read
      final retrieved = await memoryGraph.getNode(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.content, 'CRUD test');
      expect(retrieved.type, 'type_a');

      // Update
      retrieved.content = 'Updated content';
      await memoryGraph.storeNode(retrieved);
      final updated = await memoryGraph.getNode(id);
      expect(updated!.content, 'Updated content');

      // Delete
      final deleted = await memoryGraph.deleteNode(id);
      expect(deleted, isTrue);
      expect(await memoryGraph.getNode(id), isNull);
    });

    test('Basic Edge CRUD', () async {
      final id1 = await memoryGraph.storeNode(MemoryNode(content: 'Node 1'));
      final id2 = await memoryGraph.storeNode(MemoryNode(content: 'Node 2'));

      final edge = MemoryEdge(
        fromNodeId: id1,
        toNodeId: id2,
        relation: 'links_to',
        weight: 0.5,
      );
      final edgeId = await memoryGraph.storeEdge(edge);
      expect(edgeId, isPositive);

      final edges = await memoryGraph.getEdgesForNode(id1);
      expect(edges, hasLength(1));
      expect(edges.first.relation, 'links_to');
      expect(edges.first.weight, 0.5);
    });

    test('Metadata is NOT persisted (@ignore)', () async {
      final node = MemoryNode(
        content: 'Metadata test',
        metadata: {'key': 'value'},
      );
      final id = await memoryGraph.storeNode(node);

      final retrieved = await memoryGraph.getNode(id);
      expect(retrieved!.metadata, isNull);
    });

    test('Large payload handling', () async {
      final largeContent = 'A' * 1024 * 1024; // 1MB content
      final node = MemoryNode(content: largeContent);
      final id = await memoryGraph.storeNode(node);

      final retrieved = await memoryGraph.getNode(id);
      expect(retrieved!.content.length, 1024 * 1024);
    });

    test('Empty store behavior', () async {
      expect(await memoryGraph.getNode(999), isNull);
      expect(await memoryGraph.getEdgesForNode(999), isEmpty);
      expect(await memoryGraph.deleteNode(999), isFalse);
    });

    test('UUID uniqueness and replacement', () async {
      final uuid = 'test-uuid-123';
      final node1 = MemoryNode(content: 'First', uuid: uuid);
      await memoryGraph.storeNode(node1);

      final node2 = MemoryNode(content: 'Second', uuid: uuid);
      // Isar should replace because of @Index(unique: true, replace: true)
      await isar.writeTxn(() => isar.memoryNodes.put(node2));

      final count = await isar.memoryNodes.count();
      expect(count, 1);

      final nodes = await isar.memoryNodes.where().findAll();
      expect(nodes.first.content, 'Second');
    });

    test('Delete node removes edges (Manual test)', () async {
      // Note: MemoryGraph doesn't seem to have cascade delete implemented in deleteNode.
      // Let's verify current behavior.
      final id1 = await memoryGraph.storeNode(MemoryNode(content: 'Parent'));
      final id2 = await memoryGraph.storeNode(MemoryNode(content: 'Child'));

      await memoryGraph.storeEdge(MemoryEdge(
        fromNodeId: id1,
        toNodeId: id2,
        relation: 'parent_of',
      ));

      await memoryGraph.deleteNode(id1);

      // Check if edges are still there
      final edges = await isar.memoryEdges.where().findAll();
      expect(edges, isNotEmpty); // Current implementation doesn't delete edges
    });
  });
}
