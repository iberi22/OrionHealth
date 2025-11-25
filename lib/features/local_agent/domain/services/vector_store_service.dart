/// Vector Store Service interface for memory management
///
/// This interface abstracts the underlying vector database implementation
/// (isar_agent_memory) and provides hexagonal architecture compliance.
abstract class VectorStoreService {
  /// Add a document to the vector store
  Future<void> addDocument(
    String id,
    String content,
    Map<String, dynamic> metadata,
  );

  /// Basic semantic search
  Future<List<String>> search(
    String query, {
    int limit = 3,
  });

  /// Advanced search with re-ranking (v0.4.0 feature)
  ///
  /// Strategy options:
  /// - 'bm25': Term frequency-based ranking
  /// - 'mmr': Maximal Marginal Relevance (balance relevance & diversity)
  /// - 'diversity': Maximize result variety
  /// - 'recency': Prioritize recent content
  /// - 'none': No re-ranking
  Future<List<String>> searchWithReRanking(
    String query, {
    int limit = 3,
    String strategy = 'mmr',
  });

  /// Create a summary node at a specific hierarchical layer (HiRAG Phase 2)
  Future<String> createSummaryNode(
    String summaryContent,
    List<String> childNodeIds, {
    int layer = 1,
    String? type,
  });

  /// Retrieve nodes by hierarchical layer
  Future<List<Map<String, dynamic>>> getNodesByLayer(int layer);

  /// Multi-hop search across hierarchical layers (HiRAG Phase 2)
  Future<List<Map<String, dynamic>>> multiHopSearch(
    String query, {
    int maxHops = 2,
    int topK = 5,
  });
}
