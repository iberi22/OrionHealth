import 'dart:io' show stderr;

import 'package:injectable/injectable.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import '../../domain/services/vector_store_service.dart';
import '../../domain/repositories/medical_knowledge_repository.dart';

/// Implementation of VectorStoreService using isar_agent_memory package.
/// Provides semantic search and document storage capabilities.
@LazySingleton(as: VectorStoreService)
class IsarVectorStoreService implements VectorStoreService {
  final MemoryGraph _memoryGraph;
  final MedicalKnowledgeRepository _medicalRepo;

  IsarVectorStoreService(this._memoryGraph, this._medicalRepo);

  /// Index all medical standards (ICD-10, LOINC, RxNorm, SNOMED)
  /// into the vector store at startup. Safe to call multiple times.
  /// Errors are caught and logged — DI chain will not break.
  @PostConstruct(preResolve: true)
  Future<void> indexMedicalStandards() async {
    try {
      await _medicalRepo.initialize();

      final allCodes = await _medicalRepo.getAllCodes();
      if (allCodes.isEmpty) return;

      for (final code in allCodes) {
        final id = 'med:${code.standard}:${code.code}';
        final content = code.embeddingText;
        final metadata = <String, dynamic>{
          'type': 'medical_standard',
          'standard': code.standard,
          'category': code.category,
          'code': code.code,
          'displayName': code.displayName,
        };
        try {
          await _memoryGraph.storeNodeWithEmbedding(
            content: content,
            metadata: {'externalId': id, ...metadata},
            deduplicate: true,
          );
        } catch (e) {
          stderr.writeln('[IsarVectorStore] Error indexing ${code.code}: $e');
        }
      }
    } catch (e) {
      stderr.writeln('[IsarVectorStore] Failed to index medical standards: $e');
    }
  }

  @override
  Future<void> addDocument(
    String id,
    String content,
    Map<String, dynamic> metadata,
  ) async {
    await _memoryGraph.storeNodeWithEmbedding(
      content: content,
      metadata: {'externalId': id, ...metadata},
      deduplicate: true,
    );
  }

  @override
  Future<List<String>> search(String query, {int limit = 3}) async {
    // Use hybrid search for better results (combines vector + keyword search)
    final results = await _memoryGraph.hybridSearch(
      query,
      topK: limit,
      alpha: 0.5, // Balance between vector and keyword search
    );

    return results.map((r) => r.node.content).toList();
  }

  @override
  Future<List<String>> searchWithReRanking(
    String query, {
    int limit = 3,
    String strategy = 'mmr',
  }) async {
    // Use basic hybrid search since re-ranking requires LLM adapter setup
    // For now, we'll use the same implementation as basic search
    // TODO: Implement re-ranking when LLM adapter is configured
    return search(query, limit: limit);
  }

  @override
  Future<String> createSummaryNode(
    String summaryContent,
    List<String> childNodeIds, {
    int layer = 1,
    String? type,
  }) async {
    // Convert String IDs to int IDs by querying nodes with matching externalId
    final childNodeIntIds = <int>[];

    final count = await _memoryGraph.isar.memoryNodes.count();
    for (var i = 0; i < count; i++) {
      final node = await _memoryGraph.isar.memoryNodes.get(i + 1);
      if (node != null &&
          node.metadata != null &&
          node.metadata!.containsKey('externalId')) {
        final extId = node.metadata!['externalId'];
        if (childNodeIds.contains(extId)) {
          childNodeIntIds.add(node.id);
        }
      }
    }

    if (childNodeIntIds.isEmpty) {
      throw Exception('No child nodes found with the provided IDs');
    }

    // Use HiRAG Phase 1 feature to create hierarchical summary
    final summaryId = await _memoryGraph.createSummaryNode(
      summaryContent: summaryContent,
      childNodeIds: childNodeIntIds,
      layer: layer,
      type: type ?? 'health_summary',
    );

    return summaryId.toString();
  }

  @override
  Future<List<Map<String, dynamic>>> getNodesByLayer(int layer) async {
    final nodes = await _memoryGraph.getNodesByLayer(layer);

    return nodes
        .map(
          (node) => {
            'id': node.id.toString(),
            'content': node.content,
            'layer': node.layer,
            'type': node.type,
            'metadata': node.metadata,
            'createdAt': node.createdAt.toIso8601String(),
          },
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> multiHopSearch(
    String query, {
    int maxHops = 2,
    int topK = 5,
  }) async {
    // Multi-hop search requires hierarchical layers and LLM summarization
    // For now, fall back to basic search and return in expected format
    // TODO: Implement when hierarchical layers are configured
    final results = await search(query, limit: topK);

    return results
        .map(
          (content) => {
            'node': {'content': content, 'layer': 0},
            'context': <Map<String, dynamic>>[],
          },
        )
        .toList();
  }
}
