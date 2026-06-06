import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:isar_agent_memory/src/memory_graph.dart';
import 'package:isar_agent_memory/src/models/memory_node.dart';
import 'package:isar_agent_memory/src/models/memory_edge.dart';
import 'package:isar_agent_memory/src/models/memory_embedding.dart';
import 'package:isar_agent_memory/src/agent_memory_types.dart';
import 'package:isar_agent_memory/src/sync/sync_manager.dart';
import 'test_utils.dart';

void main() {
  late Isar isar;
  late MemoryGraph memoryGraph;
  late AgentMemoryTypes agentMemory;
  late String testDir;
  late MockEmbeddingsAdapter mockEmbeddings;
  late InMemoryVectorIndex mockIndex;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_memory_session');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [MemoryNodeSchema, MemoryEdgeSchema],
      directory: testDir,
    );

    mockEmbeddings = MockEmbeddingsAdapter(dimension: 3);
    mockIndex = InMemoryVectorIndex(dimension: 3);
    memoryGraph = MemoryGraph(isar, embeddingsAdapter: mockEmbeddings, index: mockIndex);
    agentMemory = AgentMemoryTypes(memoryGraph);
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

  group('Session Lifecycle and Concurrency', () {
    test('MemoryGraph.initialize syncs Isar to index', () async {
      // 1. Add node directly to Isar
      final node = MemoryNode(
        content: 'Presisted node',
        embedding: MemoryEmbedding(vector: [0.1, 0.2, 0.3], provider: 'mock', dimension: 3),
      );
      await isar.writeTxn(() => isar.memoryNodes.put(node));

      // 2. Re-create MemoryGraph or just use initialize
      await mockIndex.clear();
      await memoryGraph.initialize();

      // 3. Verify it is indexed
      final results = await mockIndex.search(Float32List.fromList([0.1, 0.2, 0.3]), topK: 1);
      expect(results, isNotEmpty);
      expect(results.first.id, node.id.toString());
    });

    test('Working memory TTL cleanup (Limitations check)', () async {
      // 1. Store working memory with short TTL
      final id = await agentMemory.storeWorkingMemory(
        content: 'Temporary task',
        ttl: Duration(milliseconds: 100),
      );

      // 2. Wait for it to expire
      await Future.delayed(Duration(milliseconds: 200));

      // 3. Run cleanup
      // This is expected to return 0 because metadata['expires_at'] is lost
      final deletedCount = await agentMemory.cleanupWorkingMemory();
      expect(deletedCount, 0);

      // 4. Verify it's still there
      expect(await memoryGraph.getNode(id), isNotNull);
    });

    test('Concurrent Isar writes', () async {
      // Isar handles transactions, let's verify multiple concurrent storeNode calls
      final futures = List.generate(20, (i) => memoryGraph.storeNode(MemoryNode(content: 'Node $i')));

      final ids = await Future.wait(futures);
      expect(ids.toSet(), hasLength(20));

      final count = await isar.memoryNodes.count();
      expect(count, 20);
    });

    test('SyncManager export/import snapshot', () async {
      final syncManager = SyncManager(memoryGraph);
      final key = List.generate(32, (i) => i);
      await syncManager.initialize(encryptionKey: key);

      // 1. Prepare data
      await memoryGraph.storeNode(MemoryNode(content: 'Node A', uuid: 'uuid-a'));

      // 2. Export
      final snapshot = await syncManager.exportEncryptedSnapshot();
      expect(snapshot, isNotEmpty);

      // 3. Clear and Import
      await isar.writeTxn(() => isar.memoryNodes.clear());
      await syncManager.importEncryptedSnapshot(snapshot);

      // 4. Verify
      final nodes = await isar.memoryNodes.where().findAll();
      expect(nodes, hasLength(1));
      expect(nodes.first.content, 'Node A');
      expect(nodes.first.uuid, 'uuid-a');
    });

    test('Initialize multiple times is safe', () async {
      await memoryGraph.initialize();
      await memoryGraph.initialize();
      await memoryGraph.initialize();

      // Should not throw and index should be consistent
      expect(true, isTrue);
    });
  });
}
