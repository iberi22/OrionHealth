import 'package:flutter_test/flutter_test.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/medical_code.dart';
import 'package:orionhealth_health/features/local_agent/domain/repositories/medical_knowledge_repository.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/isar_vector_store_service.dart';

class MockMemoryGraph extends Mock implements MemoryGraph {}
class MockMedicalKnowledgeRepository extends Mock
    implements MedicalKnowledgeRepository {}

class MockIsarInstance extends Mock implements IsarInstance {}
class MockMemoryNodeCollection extends Mock
    implements IsarCollection<MemoryNode> {}

void main() {
  late MockMemoryGraph mockMemoryGraph;
  late MockMedicalKnowledgeRepository mockMedicalRepo;
  late IsarVectorStoreService service;

  setUp(() {
    mockMemoryGraph = MockMemoryGraph();
    mockMedicalRepo = MockMedicalKnowledgeRepository();

    service = IsarVectorStoreService(mockMemoryGraph, mockMedicalRepo);

    registerFallbackValue('test-query');
    registerFallbackValue(<String, dynamic>{});
  });

  group('IsarVectorStoreService', () {
    test('implements VectorStoreService interface', () {
      expect(service, isA<VectorStoreService>());
    });

    group('search', () {
      test('returns results from hybrid search', () async {
        when(() => mockMemoryGraph.hybridSearch(
              any(),
              topK: any(named: 'topK'),
              alpha: any(named: 'alpha'),
            )).thenAnswer((_) async => [
              _createRecord('Diabetes treatment', DateTime.now()),
              _createRecord('Blood pressure monitor', DateTime.now()),
            ]);

        final results = await service.search('diabetes', limit: 3);

        expect(results, hasLength(2));
        expect(results.first, 'Diabetes treatment');
        verify(() => mockMemoryGraph.hybridSearch(
              'diabetes',
              topK: 3,
              alpha: 0.5,
            )).called(1);
      });

      test('returns empty list when no results', () async {
        when(() => mockMemoryGraph.hybridSearch(
              any(),
              topK: any(named: 'topK'),
              alpha: any(named: 'alpha'),
            )).thenAnswer((_) async => []);

        final results = await service.search('nonexistent');

        expect(results, isEmpty);
      });
    });

    group('addDocument', () {
      test('stores node with embedding via MemoryGraph', () async {
        when(() => mockMemoryGraph.storeNodeWithEmbedding(
              content: any(named: 'content'),
              metadata: any(named: 'metadata'),
              deduplicate: any(named: 'deduplicate'),
            )).thenAnswer((_) async {});

        await service.addDocument(
          'med:ICD-10:E11',
          'Type 2 diabetes [ICD-10] - Endocrine',
          {'standard': 'ICD-10', 'code': 'E11'},
        );

        verify(() => mockMemoryGraph.storeNodeWithEmbedding(
              content: 'Type 2 diabetes [ICD-10] - Endocrine',
              metadata: {
                'externalId': 'med:ICD-10:E11',
                'standard': 'ICD-10',
                'code': 'E11',
              },
              deduplicate: true,
            )).called(1);
      });
    });

    group('searchWithReRanking', () {
      test('returns first results by default (no re-ranking)', () async {
        when(() => mockMemoryGraph.hybridSearch(
              any(),
              topK: any(named: 'topK'),
              alpha: any(named: 'alpha'),
            )).thenAnswer((_) async => [
              _createRecord('Result 1', DateTime(2026, 1, 1)),
              _createRecord('Result 2', DateTime(2026, 1, 2)),
            ]);

        final results = await service.searchWithReRanking(
          'test',
          limit: 1,
          strategy: 'none',
        );

        expect(results, hasLength(1));
        expect(results.first, 'Result 1');
      });

      test('returns empty list for empty candidates', () async {
        when(() => mockMemoryGraph.hybridSearch(
              any(),
              topK: any(named: 'topK'),
              alpha: any(named: 'alpha'),
            )).thenAnswer((_) async => []);

        final results = await service.searchWithReRanking(
          'test',
          strategy: 'mmr',
        );

        expect(results, isEmpty);
      });
    });

    group('indexMedicalStandards', () {
      test('does not throw when called', () async {
        await service.indexMedicalStandards();
        // Should complete without exception
      });

      test('passes force parameter to repository', () async {
        when(() => mockMedicalRepo.initialize(any()))
            .thenAnswer((_) async {});

        await service.indexMedicalStandards(force: true);

        verify(() => mockMedicalRepo.initialize(force: true)).called(1);
      });
    });

    group('createSummaryNode', () {
      test('throws when no child nodes found', () async {
        final mockIsar = MockIsarInstance();
        final mockCollection = MockMemoryNodeCollection();

        when(() => mockMemoryGraph.isar).thenReturn(mockIsar);
        when(() => mockIsar.memoryNodes).thenReturn(mockCollection);
        when(() => mockCollection.count()).thenAnswer((_) async => 0);

        await expectLater(
          () => service.createSummaryNode('Summary', ['nonexistent']),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getNodesByLayer', () {
      test('returns empty list when no nodes exist', () async {
        when(() => mockMemoryGraph.getNodesByLayer(any()))
            .thenAnswer((_) async => []);

        final nodes = await service.getNodesByLayer(1);

        expect(nodes, isEmpty);
      });
    });

    group('multiHopSearch', () {
      test('returns empty when base search returns nothing', () async {
        when(() => mockMemoryGraph.hybridSearch(
              any(),
              topK: any(named: 'topK'),
              alpha: any(named: 'alpha'),
            )).thenAnswer((_) async => []);

        final results = await service.multiHopSearch('test');

        expect(results, isEmpty);
      });
    });
  });
}

/// Helper to create a SearchRecord for tests.
({MemoryNode node, double score}) _createRecord(String content, DateTime createdAt) {
  return (
    node: MemoryNode(
      content: content,
      createdAt: createdAt,
      type: 'test',
    ),
    score: 1.0,
  );
}
