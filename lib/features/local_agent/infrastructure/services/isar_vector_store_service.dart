import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import '../../domain/services/vector_store_service.dart';
import '../../domain/repositories/medical_knowledge_repository.dart';
import '../../../../core/services/app_logger.dart';

/// Alias for the record type returned by MemoryGraph searches.
typedef SearchRecord = ({MemoryNode node, double score});

/// Implementation of VectorStoreService using isar_agent_memory package.
///
/// Provides semantic search, hybrid search (vector + BM25), and
/// re-ranking with MMR (Maximal Marginal Relevance) for diverse results.
///
/// This is the **100% offline** vector store — no cloud dependencies.
@LazySingleton(as: VectorStoreService)
class IsarVectorStoreService implements VectorStoreService {
  final MemoryGraph _memoryGraph;
  final MedicalKnowledgeRepository _medicalRepo;

  IsarVectorStoreService(this._memoryGraph, this._medicalRepo);

  /// Index all medical standards (ICD-10, LOINC, RxNorm, SNOMED)
  /// into the vector store at startup. Safe to call multiple times.
  /// Errors are caught and logged — DI chain will not break.
  @override
  @PostConstruct(preResolve: true)
  Future<void> indexMedicalStandards({bool force = false}) async {
    try {
      AppLogger.i('IsarVectorStore', 'Starting indexing medical standards (force: $force)...');
      await _medicalRepo.initialize(force: force);

      final allCodes = await _medicalRepo.getAllCodes();
      AppLogger.i('IsarVectorStore', 'Found ${allCodes.length} codes to index.');
      if (allCodes.isEmpty) return;

      int indexedCount = 0;
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
          indexedCount++;
        } catch (e) {
          AppLogger.e('IsarVectorStore', 'Error indexing ${code.code}', error: e);
        }
      }
      AppLogger.i('IsarVectorStore', 'Indexing complete. Indexed $indexedCount codes.');
    } catch (e) {
      AppLogger.e('IsarVectorStore', 'Failed to index medical standards', error: e);
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
    final results = await _memoryGraph.hybridSearch(
      query,
      topK: limit,
      alpha: 0.5,
    );
    return results.map((r) => r.node.content).toList();
  }

  @override
  Future<List<String>> searchWithReRanking(
    String query, {
    int limit = 3,
    String strategy = 'mmr',
  }) async {
    const candidateMultiplier = 3;
    final rawResults = await _memoryGraph.hybridSearch(
      query,
      topK: limit * candidateMultiplier,
      alpha: 0.5,
    );

    if (rawResults.isEmpty) return [];

    switch (strategy) {
      case 'mmr':
        return _mmrRerank(query, rawResults, limit);
      case 'diversity':
        return _diversityRerank(rawResults, limit);
      case 'recency':
        return _recencyRerank(rawResults, limit);
      case 'bm25':
        return _bm25Rerank(query, rawResults, limit);
      case 'none':
      default:
        return rawResults.take(limit).map((r) => r.node.content).toList();
    }
  }

  /// MMR (Maximal Marginal Relevance) re-ranking.
  /// Balances query relevance and result diversity.
  List<String> _mmrRerank(
    String query,
    List<SearchRecord> candidates,
    int limit,
  ) {
    if (candidates.isEmpty) return [];
    if (candidates.length <= 1) return [candidates.first.node.content];

    const lambda = 0.7;
    final selected = <int>{};
    final contents = <int, String>{};
    final result = <String>[];

    selected.add(0);
    contents[0] = candidates[0].node.content;
    result.add(candidates[0].node.content);

    for (var i = 1; i < min(limit, candidates.length); i++) {
      var bestIdx = -1;
      var bestScore = -1.0;

      for (var j = 1; j < candidates.length; j++) {
        if (selected.contains(j)) continue;

        final relevance = candidates[j].score;

        var maxSimilarity = 0.0;
        final words = candidates[j].node.content.split(RegExp(r'\s+'));
        final wordSet = words.toSet();

        for (final selIdx in selected) {
          if (!contents.containsKey(selIdx)) continue;
          final selWords = contents[selIdx]!.split(RegExp(r'\s+'));
          final selWordSet = selWords.toSet();

          if (wordSet.isEmpty || selWordSet.isEmpty) continue;
          final intersection = wordSet.intersection(selWordSet).length;
          final union = wordSet.union(selWordSet).length;
          final similarity = union > 0 ? intersection / union : 0.0;

          maxSimilarity = max(maxSimilarity, similarity);
        }

        final mmrScore = lambda * relevance - (1 - lambda) * maxSimilarity;
        if (mmrScore > bestScore) {
          bestScore = mmrScore;
          bestIdx = j;
        }
      }

      if (bestIdx >= 0) {
        selected.add(bestIdx);
        contents[bestIdx] = candidates[bestIdx].node.content;
        result.add(candidates[bestIdx].node.content);
      }
    }

    return result;
  }

  /// Diversity-focused re-ranking.
  List<String> _diversityRerank(
    List<SearchRecord> candidates,
    int limit,
  ) {
    if (candidates.isEmpty) return [];
    if (candidates.length <= 1) return [candidates.first.node.content];

    final topicGroups = <String, List<SearchRecord>>{};
    for (final c in candidates) {
      final firstChars = c.node.content.length > 50
          ? c.node.content.substring(0, 50)
          : c.node.content;
      final topicKey = firstChars.hashCode.toString();
      topicGroups.putIfAbsent(topicKey, () => []).add(c);
    }

    final result = <String>[];
    final iterators = topicGroups.values
        .map((g) => g..sort((a, b) => b.score.compareTo(a.score)))
        .toList();

    var groupIdx = 0;
    while (result.length < limit && iterators.isNotEmpty) {
      final group = iterators[groupIdx % iterators.length];
      if (group.isNotEmpty) {
        result.add(group.removeAt(0).node.content);
      }
      groupIdx++;
      iterators.removeWhere((g) => g.isEmpty);
    }

    return result;
  }

  /// Recency-focused re-ranking.
  List<String> _recencyRerank(
    List<SearchRecord> candidates,
    int limit,
  ) {
    final sorted = List<SearchRecord>.from(candidates)
      ..sort((a, b) => b.node.createdAt.compareTo(a.node.createdAt));
    return sorted.take(limit).map((r) => r.node.content).toList();
  }

  /// BM25 keyword-focused re-ranking.
  List<String> _bm25Rerank(
    String query,
    List<SearchRecord> candidates,
    int limit,
  ) {
    final queryTerms = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toList();
    if (queryTerms.isEmpty) {
      return candidates.take(limit).map((r) => r.node.content).toList();
    }

    final scored = candidates.map((c) {
      var termMatches = 0;
      final content = c.node.content.toLowerCase();
      for (final term in queryTerms) {
        if (content.contains(term)) termMatches++;
      }
      return (
        content: c.node.content,
        score: queryTerms.isNotEmpty ? termMatches / queryTerms.length : 0.0,
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).map((s) => s.content).toList();
  }

  @override
  Future<String> createSummaryNode(
    String summaryContent,
    List<String> childNodeIds, {
    int layer = 1,
    String? type,
  }) async {
    final childNodeIntIds = <int>[];

    final count = await _memoryGraph.isar.memoryNodes.count();
    for (var i = 0; i < count; i++) {
      final node = await _memoryGraph.isar.memoryNodes.get(i + 1);
      if (node != null &&
          node.metadata != null &&
          node.metadata!.containsKey('externalId')) {
        final extId = node.metadata!['externalId'] as String?;
        if (extId != null && childNodeIds.contains(extId)) {
          childNodeIntIds.add(node.id);
        }
      }
    }

    if (childNodeIntIds.isEmpty) {
      throw Exception('No child nodes found with the provided IDs');
    }

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
          (node) => <String, dynamic>{
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
    final baseResults = await search(query, limit: topK);
    if (baseResults.isEmpty) return [];

    final result = <Map<String, dynamic>>[];

    for (final baseContent in baseResults) {
      final entry = <String, dynamic>{
        'node': {'content': baseContent, 'layer': 0},
        'context': <Map<String, dynamic>>[],
      };

      final allLayers = <int>{};
      for (var l = 1; l <= maxHops; l++) {
        try {
          final layerNodes = await getNodesByLayer(l);
          for (final layerNode in layerNodes) {
            final layerContent = layerNode['content'] as String? ?? '';
            if (layerContent.contains(baseContent.length > 100
                ? baseContent.substring(0, 100)
                : baseContent)) {
              (entry['context'] as List).add(layerNode);
              allLayers.add(l);
              break;
            }
          }
        } catch (_) {}
      }

      entry['contextDepth'] = allLayers.isNotEmpty ? allLayers.length : 0;
      result.add(entry);
    }

    return result;
  }
}
