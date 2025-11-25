import 'package:injectable/injectable.dart';
import '../../domain/services/vector_store_service.dart';

/// Use Case: Smart Search with Multiple Strategies
///
/// Demonstrates the new v0.4.0 re-ranking strategies to improve
/// search relevance based on different user needs.
@LazySingleton()
class SmartSearchUseCase {
  final VectorStoreService _vectorStore;

  SmartSearchUseCase(this._vectorStore);

  /// Perform an intelligent search using the best strategy for the query
  ///
  /// The strategy is automatically selected based on query characteristics:
  /// - Specific medical terms → BM25 (keyword matching)
  /// - Exploratory queries → Diversity (variety)
  /// - Recent symptoms → Recency (time-based)
  /// - General queries → MMR (balanced)
  Future<SmartSearchResult> execute(String query, {int limit = 5}) async {
    // Analyze query to determine best strategy
    final strategy = _determineOptimalStrategy(query);

    // Perform search with re-ranking
    final results = await _vectorStore.searchWithReRanking(
      query,
      limit: limit,
      strategy: strategy,
    );

    // Also try multi-hop search for comprehensive context
    final multiHopResults = await _vectorStore.multiHopSearch(
      query,
      maxHops: 2,
      topK: 3,
    );

    return SmartSearchResult(
      query: query,
      strategy: strategy,
      directResults: results,
      hierarchicalResults: multiHopResults,
      searchTime: DateTime.now(),
    );
  }

  /// Compare different strategies side-by-side
  ///
  /// Useful for understanding how each strategy affects results
  Future<Map<String, List<String>>> compareStrategies(
    String query, {
    int limit = 3,
  }) async {
    final strategies = ['bm25', 'mmr', 'diversity', 'recency'];
    final results = <String, List<String>>{};

    for (final strategy in strategies) {
      try {
        final strategyResults = await _vectorStore.searchWithReRanking(
          query,
          limit: limit,
          strategy: strategy,
        );
        results[strategy] = strategyResults;
      } catch (e) {
        results[strategy] = ['Error: $e'];
      }
    }

    return results;
  }

  /// Determine optimal search strategy based on query characteristics
  String _determineOptimalStrategy(String query) {
    final lowerQuery = query.toLowerCase();

    // Medical terminology → Use BM25 for precise keyword matching
    final medicalTerms = [
      'diagnóstico', 'síntoma', 'medicamento', 'tratamiento',
      'prescripción', 'dosis', 'análisis', 'resultado',
      'diabetes', 'hipertensión', 'alergia', 'dolor',
    ];

    if (medicalTerms.any((term) => lowerQuery.contains(term))) {
      return 'bm25';
    }

    // Temporal queries → Use Recency
    final temporalKeywords = [
      'reciente', 'último', 'actual', 'hoy', 'ayer',
      'esta semana', 'este mes', 'nuevo',
    ];

    if (temporalKeywords.any((keyword) => lowerQuery.contains(keyword))) {
      return 'recency';
    }

    // Exploratory queries → Use Diversity
    final exploratoryKeywords = [
      'todos', 'diferentes', 'variedad', 'tipos',
      'opciones', 'alternativas', 'qué más',
    ];

    if (exploratoryKeywords.any((keyword) => lowerQuery.contains(keyword))) {
      return 'diversity';
    }

    // Default: MMR (balanced relevance + diversity)
    return 'mmr';
  }

  /// Get explanation of why a strategy was chosen
  String explainStrategy(String query) {
    final strategy = _determineOptimalStrategy(query);

    switch (strategy) {
      case 'bm25':
        return 'Usando BM25: Tu consulta contiene términos médicos específicos. '
               'Esta estrategia prioriza coincidencias exactas de palabras clave.';
      case 'recency':
        return 'Usando Recency: Tu consulta busca información reciente. '
               'Esta estrategia prioriza los registros más nuevos.';
      case 'diversity':
        return 'Usando Diversity: Tu consulta es exploratoria. '
               'Esta estrategia maximiza la variedad de resultados.';
      case 'mmr':
      default:
        return 'Usando MMR (Maximal Marginal Relevance): Esta estrategia '
               'balancea relevancia y diversidad para resultados óptimos.';
    }
  }
}

/// Smart Search Result Model
class SmartSearchResult {
  final String query;
  final String strategy;
  final List<String> directResults;
  final List<Map<String, dynamic>> hierarchicalResults;
  final DateTime searchTime;

  SmartSearchResult({
    required this.query,
    required this.strategy,
    required this.directResults,
    required this.hierarchicalResults,
    required this.searchTime,
  });

  /// Get total number of unique results
  int get totalResults =>
      directResults.length + hierarchicalResults.length;

  /// Check if hierarchical context is available
  bool get hasHierarchicalContext =>
      hierarchicalResults.any((r) => (r['context'] as List).isNotEmpty);

  Map<String, dynamic> toJson() => {
    'query': query,
    'strategy': strategy,
    'directResultsCount': directResults.length,
    'hierarchicalResultsCount': hierarchicalResults.length,
    'hasContext': hasHierarchicalContext,
    'searchTime': searchTime.toIso8601String(),
  };
}
