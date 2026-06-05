import 'dart:io';
import 'package:test/test.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'test_utils.dart';

void main() {
  late Isar isar;
  late MemoryGraph memoryGraph;
  late AgentMemoryTypes agentMemory;
  late String testDir;
  late MockEmbeddingsAdapter mockEmbeddings;
  late InMemoryVectorIndex mockIndex;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_agent_memory');
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

  group('AgentMemoryTypes Storage', () {
    test('storeEpisodicMemory', () async {
      final timestamp = DateTime.now();
      final id = await agentMemory.storeEpisodicMemory(
        content: 'Went to the park',
        timestamp: timestamp,
        location: 'Park',
        participants: ['Alice'],
        emotionalValence: 0.8,
      );

      final node = await memoryGraph.getNode(id);
      expect(node, isNotNull);
      expect(node!.type, AgentMemoryTypes.typeEpisodic);
      // Note: metadata is @ignore in MemoryNode, so it is NOT persisted in Isar.
      // This is the current behavior of the package.
    });

    test('storeSemanticMemory', () async {
      final id = await agentMemory.storeSemanticMemory(
        content: 'The sky is blue',
        category: 'Science',
        tags: ['nature'],
        confidence: 0.99,
      );

      final node = await memoryGraph.getNode(id);
      expect(node, isNotNull);
      expect(node!.type, AgentMemoryTypes.typeSemantic);
    });

    test('storeProceduralMemory', () async {
      final id = await agentMemory.storeProceduralMemory(
        procedure: 'Make tea',
        steps: ['Boil water', 'Add tea bag', 'Wait'],
        skill: 'Cooking',
      );

      final node = await memoryGraph.getNode(id);
      expect(node, isNotNull);
      expect(node!.type, AgentMemoryTypes.typeProcedural);
    });

    test('storeWorkingMemory', () async {
      final id = await agentMemory.storeWorkingMemory(
        content: 'Remember the milk',
        ttl: Duration(minutes: 5),
      );

      final node = await memoryGraph.getNode(id);
      expect(node, isNotNull);
      expect(node!.type, AgentMemoryTypes.typeWorking);
    });
  });
}
