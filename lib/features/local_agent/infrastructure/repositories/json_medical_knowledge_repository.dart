import 'dart:convert';
import 'dart:io' show File, stderr;

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/medical_code.dart';
import '../../domain/repositories/medical_knowledge_repository.dart';

/// Implementation of [MedicalKnowledgeRepository] that loads medical
/// standards from the project's medical-standards/ JSON files.
///
/// The JSON files (icd10.json, loinc.json, rxnorm.json, snomed.json) are
/// read from the app's [basePath] (default: `medical-standards/` relative to
/// the working directory, or the app's data bundle path in production).
///
/// Once loaded, all codes are indexed in memory for fast lookup.
@LazySingleton(as: MedicalKnowledgeRepository)
class JsonMedicalKnowledgeRepository implements MedicalKnowledgeRepository {
  final String basePath;

  /// In-memory flat index of ALL codes across all standards.
  List<MedicalCode> _allCodes = [];

  /// Index by code → MedicalCode (fast lookup).
  Map<String, MedicalCode> _codeIndex = {};

  /// Inverted index: word → list of MedicalCode (for full-text search).
  /// Each search term (lowercased) maps to codes that contain it.
  Map<String, List<MedicalCode>> _termIndex = {};

  /// Index by category → codes.
  Map<String, List<MedicalCode>> _categoryIndex = {};

  /// Index by standard → codes.
  Map<String, List<MedicalCode>> _standardIndex = {};

  bool _initialized = false;

  JsonMedicalKnowledgeRepository({this.basePath = 'medical-standards'});

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    final stopwatch = Stopwatch()..start();

    final files = <String, String>{
      'ICD-10': 'icd10.json',
      'LOINC': 'loinc.json',
      'RxNorm': 'rxnorm.json',
      'SNOMED': 'snomed.json',
    };

    final allCodes = <MedicalCode>[];

    for (final entry in files.entries) {
      final standard = entry.key;
      final fileName = entry.value;
      final filePath = p.join(basePath, fileName);

      try {
        // Try loading from the file system (relative to cwd or bundle)
        final file = File(filePath);
        if (await file.exists()) {
          final jsonString = await file.readAsString();
          final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
          final dataList = decoded['data'] as List<dynamic>;

          final codes = dataList
              .map((e) => MedicalCode.fromJson(e as Map<String, dynamic>, standard))
              .toList();

          allCodes.addAll(codes);
        } else {
          // Fallback: try loading from asset root
          // If not found, just skip (will use empty list)
          stderr.writeln('Warning: $filePath not found, skipping $standard');
        }
      } catch (e) {
        stderr.writeln('Warning: Failed to load $filePath: $e');
      }
    }

    _allCodes = allCodes;
    _buildIndexes();
    _initialized = true;

    stopwatch.stop();
    // ignore: avoid_print
    print(
      '[MedicalKnowledgeRepo] Loaded ${allCodes.length} codes in ${stopwatch.elapsedMilliseconds}ms',
    );
  }

  /// Build all search indexes from the loaded codes.
  void _buildIndexes() {
    _codeIndex = {};
    _termIndex = {};
    _categoryIndex = {};
    _standardIndex = {};

    for (final code in _allCodes) {
      // Code index: key is code.lowercase()
      _codeIndex[code.code.toLowerCase()] = code;

      // Standard index
      _standardIndex.putIfAbsent(code.standard, () => []).add(code);

      // Category index
      if (code.category.isNotEmpty) {
        final cat = code.category.toLowerCase();
        _categoryIndex.putIfAbsent(cat, () => []).add(code);
      }

      // Term index: tokenize displayName and searchTerms
      final allText = [
        code.displayName,
        ...code.searchTerms,
        // Also index categories and standard names
        code.category,
        code.standard,
        // Index the code itself as a searchable token
        code.code,
      ];

      for (final text in allText) {
        final tokens = _tokenize(text);
        for (final token in tokens) {
          _termIndex.putIfAbsent(token, () => []).add(code);
        }
      }
    }
  }

  /// Tokenize text into lowercase words, removing special characters.
  List<String> _tokenize(String text) {
    if (text.isEmpty) return [];
    // Split on whitespace and common separators
    final words = text.toLowerCase().split(RegExp(r'[\s,;:/\\\-_\(\)\[\]]+'));
    return words.where((w) => w.length >= 2).toSet().toList();
  }

  @override
  Future<MedicalCode?> searchByCode(String code) async {
    _ensureInitialized();
    return _codeIndex[code.toLowerCase()];
  }

  @override
  Future<MedicalCode?> searchByCodeInStandard(
    String code,
    String standard,
  ) async {
    _ensureInitialized();
    final result = _codeIndex[code.toLowerCase()];
    if (result != null && result.standard == standard) return result;
    return null;
  }

  @override
  Future<List<MedicalCode>> searchByTerm(String searchTerm) async {
    _ensureInitialized();
    return _searchByTokens(searchTerm);
  }

  @override
  Future<List<MedicalCode>> searchByTermInStandard(
    String searchTerm,
    String standard,
  ) async {
    _ensureInitialized();
    final results = await searchByTerm(searchTerm);
    return results.where((c) => c.standard == standard).toList();
  }

  @override
  Future<List<MedicalCode>> searchByCategory(String category) async {
    _ensureInitialized();
    final cat = category.toLowerCase();
    final results = <MedicalCode>{};

    // Exact category match
    if (_categoryIndex.containsKey(cat)) {
      results.addAll(_categoryIndex[cat]!);
    }

    // Partial category match
    for (final key in _categoryIndex.keys) {
      if (key.contains(cat) || cat.contains(key)) {
        results.addAll(_categoryIndex[key]!);
      }
    }

    // Also search by term fallback
    final tokens = _tokenize(category);
    for (final token in tokens) {
      if (_termIndex.containsKey(token)) {
        results.addAll(_termIndex[token]!);
      }
    }

    return results.toList();
  }

  @override
  Future<List<MedicalCode>> getAllCodes({String? standard}) async {
    _ensureInitialized();
    if (standard != null) {
      return _standardIndex[standard] ?? [];
    }
    return List.unmodifiable(_allCodes);
  }

  @override
  Map<String, dynamic> getStats() {
    final perStandard = <String, int>{};
    for (final code in _allCodes) {
      perStandard[code.standard] = (perStandard[code.standard] ?? 0) + 1;
    }

    return {
      'total': _allCodes.length,
      'perStandard': perStandard,
      'initialized': _initialized,
      'indexedTerms': _termIndex.length,
      'indexedCategories': _categoryIndex.length,
    };
  }

  /// Search the term index with multi-word matching.
  /// Returns results ranked by relevance (most matches first).
  List<MedicalCode> _searchByTokens(String query) {
    final tokens = _tokenize(query);
    if (tokens.isEmpty) return [];

    // Score each matching code by how many tokens match
    final scores = <MedicalCode, int>{};

    for (final token in tokens) {
      // Exact token match
      if (_termIndex.containsKey(token)) {
        for (final code in _termIndex[token]!) {
          scores[code] = (scores[code] ?? 0) + 10;
        }
      }

      // Partial match (prefix) — helps with typos and abbreviations
      for (final indexedToken in _termIndex.keys) {
        if (indexedToken.startsWith(token) || token.startsWith(indexedToken)) {
          for (final code in _termIndex[indexedToken]!) {
            scores[code] = (scores[code] ?? 0) + 5;
          }
        }
      }
    }

    // Sort by score descending
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => e.key).toList();
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'MedicalKnowledgeRepository not initialized. Call initialize() first.',
      );
    }
  }
}
