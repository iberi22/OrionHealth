import 'package:injectable/injectable.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import '../../domain/services/vector_store_service.dart';
import '../../domain/services/llm_adapter.dart' as local_llm;

@LazySingleton(as: VectorStoreService)
class IsarVectorStoreService implements VectorStoreService {
  final MemoryGraph _memoryGraph;
  final local_llm.LlmAdapter _llmAdapter;

  IsarVectorStoreService(this._memoryGraph, this._llmAdapter);

  @override
  Future<void> addDocument(
      String id, String content, Map<String, dynamic> metadata) async {
    await _memoryGraph.storeNodeWithEmbedding(
      content: content,
      metadata: {
        'externalId': id,
        ...metadata,
      },
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
    // Get reranker based on strategy
    final reranker = _getReRanker(strategy);

    // Use hybridSearchWithReRanking from v0.4.0
    final results = await _memoryGraph.hybridSearchWithReRanking(
      query,
      reranker: reranker,
      topK: limit,
      alpha: 0.5,
    );

    return results.map((r) => r.node.content).toList();
  }

  @override
  Future<String> createSummaryNode(
    String summaryContent,
    List<String> childNodeIds, {
    int layer = 1,
    String? type,
  }) async {
    // Convert String IDs to int IDs
    // Note: In OrionHealth, we're using external IDs as strings
    // We need to query the actual node IDs by finding nodes with matching externalId
    final childNodeIntIds = <int>[];

    // Query all nodes and filter manually
    final allNodesCount = await _memoryGraph.isar.memoryNodes.count();
    for (var i = 0; i < allNodesCount; i++) {
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

    if (childNodeIntIds.length != childNodeIds.length) {
      throw Exception(
          'Some child nodes not found. Found ${childNodeIntIds.length}/${childNodeIds.length}');
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
        .map((node) => {
              'id': node.id.toString(),
              'content': node.content,
              'layer': node.layer,
              'type': node.type,
              'metadata': node.metadata,
              'createdAt': node.createdAt.toIso8601String(),
            })
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> multiHopSearch(
    String query, {
    int maxHops = 2,
    int topK = 5,
  }) async {
    // Get query embedding
    final embedding = await _memoryGraph.embeddingsAdapter.embed(query);

    // Use HiRAG Phase 2 multi-hop search
    final results = await _memoryGraph.multiHopSearch(
      queryEmbedding: embedding,
      maxHops: maxHops,
      topK: topK,
    );

    return results
        .map((result) => {
              'node': {
                'id': result.node.id.toString(),
                'content': result.node.content,
                'layer': result.node.layer,
              },
              'context': result.context
                  .map((ctx) => {
                        'id': ctx.id.toString(),
                        'content': ctx.content,
                        'layer': ctx.layer,
                      })
                  .toList(),
            })
        .toList();
  }

  /// Helper method to get the appropriate re-ranker based on strategy string
  ReRankingStrategy _getReRanker(String strategy) {
    switch (strategy.toLowerCase()) {
      case 'bm25':
        return BM25ReRanker(k1: 1.5, b: 0.75);
      case 'mmr':
        return MMRReRanker(lambda: 0.5);
      case 'diversity':
        return DiversityReRanker();
      case 'recency':
        return RecencyReRanker();
      case 'none':
      default:
        // Return a no-op reranker that just returns results as-is
        return MMRReRanker(
            lambda: 1.0); // Lambda 1.0 = no diversity, pure relevance
    }
  }

  /// Automatic layer summarization using LLM (HiRAG Phase 2)
  ///
  /// This wraps the isar_agent_memory LLMAdapter with our local LlmAdapter
  Future<String> autoSummarizeLayer(
    int layerIndex, {
    String Function(String)? promptTemplate,
  }) async {
    // Wrap our local LLM adapter to match isar_agent_memory's interface
    final wrappedAdapter = _LLMAdapterWrapper(_llmAdapter);

    final summaryNodeId = await _memoryGraph.autoSummarizeLayer(
      layerIndex: layerIndex,
      llmAdapter: wrappedAdapter,
      promptTemplate: promptTemplate ??
          (content) =>
              'Summarize the following health records concisely:\n\n$content',
    );

    return summaryNodeId.toString();
  }
}

/// Wrapper to adapt our local LlmAdapter to isar_agent_memory's LLMAdapter
class _LLMAdapterWrapper implements LLMAdapter {
  final local_llm.LlmAdapter _localAdapter;

  _LLMAdapterWrapper(this._localAdapter);

  @override
  Future<String> generate(String prompt) => _localAdapter.generate(prompt);
}
