import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/services/app_logger.dart';
import '../../domain/entities/medical_code.dart';
import '../../domain/repositories/medical_knowledge_repository.dart';
import '../../domain/services/vector_store_service.dart';
import 'patient_context_indexer.dart';

/// Service that orchestrates the loading and indexing of medical standards
/// into the vector store at application startup.
///
/// Flow:
/// 1. Load all medical codes from JSON files (via [MedicalKnowledgeRepository])
/// 2. For each code, create a vector embedding (via [VectorStoreService])
/// 3. Make codes searchable via semantic search alongside RAG context
///
/// This service is auto-initialized by injectable as a singleton.
@LazySingleton()
class MedicalIndexingService {
  final MedicalKnowledgeRepository _knowledgeRepo;
  final VectorStoreService _vectorStore;
  final PatientContextIndexer _patientIndexer;

  bool _hasIndexed = false;
  int _indexedCount = 0;
  int _errorCount = 0;
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  MedicalIndexingService(
    this._knowledgeRepo,
    this._vectorStore,
    this._patientIndexer,
  );

  /// Whether the full indexing pass has completed.
  bool get hasIndexed => _hasIndexed;

  /// Stream of indexing status (true when done).
  Stream<bool> get statusStream => _statusController.stream;

  /// How many documents were successfully indexed.
  int get indexedCount => _indexedCount;

  /// How many documents encountered errors during indexing.
  int get errorCount => _errorCount;

  /// Index all medical codes into the vector store.
  ///
  /// Safe to call multiple times â€” subsequent calls are no-ops
  /// unless [force] is true.
  Future<IndexingResult> indexAll({bool force = false}) async {
    if (_hasIndexed && !force) {
      _statusController.add(true);
      return IndexingResult(
        total: _indexedCount + _errorCount,
        indexed: _indexedCount,
        errors: _errorCount,
        skipped: true,
      );
    }

    _statusController.add(false);

    // 1. Ensure knowledge repo is initialized
    await _knowledgeRepo.initialize();

    // 2. Get all codes
    final allCodes = await _knowledgeRepo.getAllCodes();
    final total = allCodes.length;

    // 3. Index each code as a vector document
    int indexed = 0;
    int errors = 0;

    for (final code in allCodes) {
      try {
        await _vectorStore.addDocument(
          _documentId(code),
          code.embeddingText,
          _buildMetadata(code),
        );
        indexed++;
      } catch (e) {
        errors++;
        AppLogger.e('MedicalIndexing', 'Error indexing ${code.code}: $e');
      }
    }

    _indexedCount = indexed;
    _errorCount = errors;
    _hasIndexed = true;
    _statusController.add(true);

    // 4. Also index patient context
    // This is non-blocking to the medical standards indexing result
    unawaited(_patientIndexer.indexAll());

    return IndexingResult(
      total: total,
      indexed: indexed,
      errors: errors,
      skipped: false,
    );
  }

  /// Search medical codes via vector search with multi-lingual support.
  ///
  /// The query can be in English (displayName) or Spanish (searchTerms).
  /// Returns ranked MedicalCode results with relevance scores.
  Future<List<ScoredMedicalCode>> search(String query, {int limit = 10}) async {
    // 1. Vector search
    try {
      final vectorResults = await _vectorStore.search(query, limit: limit * 2);

      // 2. Also search via knowledge repo (text index fallback)
      final textResults = await _knowledgeRepo.searchByTerm(query);

      // 3. Merge results: prefer vector, supplement with text
      final seenCodes = <String>{};
      final merged = <ScoredMedicalCode>[];

      // Vector results come as raw content strings â€” parse them
      for (final content in vectorResults) {
        final code = _parseCodeFromContent(content);
        if (code != null && seenCodes.add(code.code)) {
          merged.add(ScoredMedicalCode(code: code, score: 1.0));
        }
      }

      // Supplement with text-based results
      int scoreVal = 50;
      for (final code in textResults) {
        if (seenCodes.add(code.code)) {
          merged.add(ScoredMedicalCode(
            code: code,
            score: scoreVal.toDouble() / 100,
          ));
          scoreVal -= 5; // Descending relevance
        }
      }

      return merged.take(limit).toList();
    } catch (e) {
      // Fallback to pure text search if vector store fails
      final results = await _knowledgeRepo.searchByTerm(query);
      return results.take(limit).map((code) {
        return ScoredMedicalCode(code: code, score: 1.0);
      }).toList();
    }
  }

  // ============ Private Helpers ============

  String _documentId(MedicalCode code) {
    return 'med:${code.standard}:${code.code}';
  }

  Map<String, dynamic> _buildMetadata(MedicalCode code) {
    return {
      'type': 'medical_standard',
      'standard': code.standard,
      'category': code.category,
      'code': code.code,
      'displayName': code.displayName,
    };
  }

  /// Parse a MedicalCode from vector store content text.
  /// The embeddingText follows the format: "displayName [standard] â€” category\nterms"
  MedicalCode? _parseCodeFromContent(String content) {
    // Try to find by extracting standard info from the content
    // Format: "displayName [standard] â€” category\nterms"
    final standardMatch = RegExp(r'\[(ICD-10|LOINC|RxNorm|SNOMED)\]\s*â€”\s*(.+)$',
            multiLine: true)
        .firstMatch(content);

    if (standardMatch != null) {
      final standard = standardMatch.group(1)!;
      final category = standardMatch.group(2)!.trim();
      final displayName =
          content.split('[').first.trim();

      // Look up in the knowledge repo by display name (approximate)
      // This is a best-effort parsing
      return MedicalCode(
        code: '',
        displayName: displayName,
        category: category,
        standard: standard,
      );
    }

    // Fallback: try looking up each term via knowledge repo
    return null;
  }
}

/// Result of a full indexing pass.
class IndexingResult {
  final int total;
  final int indexed;
  final int errors;
  final bool skipped;

  const IndexingResult({
    required this.total,
    required this.indexed,
    required this.errors,
    this.skipped = false,
  });

  bool get success => errors == 0;
}

/// A MedicalCode with a relevance score for ranked results.
class ScoredMedicalCode {
  final MedicalCode code;
  final double score;

  const ScoredMedicalCode({required this.code, required this.score});
}

