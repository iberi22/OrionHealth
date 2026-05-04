import 'dart:convert';
import 'dart:io' show File, stderr;

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  JsonMedicalKnowledgeRepository();

  String get _basePath => 'medical-standards';

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

  /// Loaded drug-drug interactions.
  List<Map<String, dynamic>> _interactions = [];
  List<Map<String, dynamic>> _classInteractions = [];
  List<Map<String, dynamic>> _symptomMappings = [];

  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize({bool force = false}) async {
    if (_initialized && !force) return;
    _initialized = false; // Reset to allow reload

    final stopwatch = Stopwatch()..start();

    final files = <String, String>{
      'ICD-10': 'icd10.json',
      'LOINC': 'loinc.json',
      'RxNorm': 'rxnorm.json',
      'SNOMED': 'snomed.json',
    };

    final allCodes = <MedicalCode>[];
    
    // Get application support directory for synced standards
    String? supportPath;
    try {
      final dir = await getApplicationSupportDirectory();
      supportPath = p.join(dir.path, 'medical_standards', 'standards_cache');
    } catch (_) {}

    for (final entry in files.entries) {
      final standard = entry.key;
      final fileName = entry.value;
      
      // 1. Try Synced cache first (from SyncService)
      String? jsonString;
      if (supportPath != null) {
        final syncedFile = File(p.join(supportPath, fileName));
        if (await syncedFile.exists()) {
          jsonString = await syncedFile.readAsString();
        }
      }

      // 2. Try Local file system (dev environment)
      if (jsonString == null) {
        final filePath = p.join(_basePath, fileName);
        final file = File(filePath);
        if (await file.exists()) {
          jsonString = await file.readAsString();
        }
      }

      if (jsonString != null) {
        try {
          final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
          final dataList = decoded['data'] as List<dynamic>;

          final codes = dataList
              .map((e) => MedicalCode.fromJson(e as Map<String, dynamic>, standard))
              .toList();

          allCodes.addAll(codes);
        } catch (e) {
          stderr.writeln('Warning: Failed to parse $standard: $e');
        }
      }
    }

    // Load Interactions
    String? interactionsJson;
    final interactionsFileName = 'rxnorm_interactions.json';
    if (supportPath != null) {
      final syncedFile = File(p.join(supportPath, interactionsFileName));
      if (await syncedFile.exists()) {
        interactionsJson = await syncedFile.readAsString();
      }
    }
    if (interactionsJson == null) {
      final filePath = p.join(_basePath, interactionsFileName);
      final file = File(filePath);
      if (await file.exists()) {
        interactionsJson = await file.readAsString();
      }
    }
    if (interactionsJson != null) {
      try {
        final decoded = jsonDecode(interactionsJson) as Map<String, dynamic>;
        _interactions = List<Map<String, dynamic>>.from(decoded['interactions'] ?? []);
        _classInteractions = List<Map<String, dynamic>>.from(decoded['classInteractions'] ?? []);
      } catch (e) {
        stderr.writeln('Warning: Failed to parse interactions: $e');
      }
    }

    // Load Symptoms Mapping
    String? symptomsJson;
    final symptomsFileName = 'symptoms_mapping.json';
    if (supportPath != null) {
      final syncedFile = File(p.join(supportPath, symptomsFileName));
      if (await syncedFile.exists()) {
        symptomsJson = await syncedFile.readAsString();
      }
    }
    if (symptomsJson == null) {
      final filePath = p.join(_basePath, symptomsFileName);
      final file = File(filePath);
      if (await file.exists()) {
        symptomsJson = await file.readAsString();
      }
    }
    if (symptomsJson != null) {
      try {
        final decoded = jsonDecode(symptomsJson) as Map<String, dynamic>;
        _symptomMappings = List<Map<String, dynamic>>.from(decoded['mappings'] ?? []);
      } catch (e) {
        stderr.writeln('Warning: Failed to parse symptoms: $e');
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

  @override
  Future<List<Map<String, dynamic>>> checkInteractions(List<String> drugCodes) async {
    _ensureInitialized();
    if (drugCodes.length < 2) return [];

    final results = <Map<String, dynamic>>[];
    final codes = drugCodes.map((c) => c.toLowerCase()).toSet();
    
    // 1. Direct drug-drug interactions
    for (final interaction in _interactions) {
      final requiredDrugs = (interaction['drugs'] as List<dynamic>)
          .map((d) => d.toString().toLowerCase())
          .toSet();

      if (requiredDrugs.every((d) => codes.contains(d))) {
        results.add(interaction);
      }
    }

    // 2. Class-based interactions
    if (_classInteractions.isNotEmpty) {
      // Get classes for each provided drug
      final drugClasses = <String>{};
      for (final code in drugCodes) {
        final med = _codeIndex[code.toLowerCase()];
        if (med != null && med.category.isNotEmpty) {
          drugClasses.add(med.category.toLowerCase());
        }
      }

      for (final interaction in _classInteractions) {
        final requiredClasses = (interaction['classes'] as List<dynamic>)
            .map((c) => c.toString().toLowerCase())
            .toSet();

        if (requiredClasses.every((c) => drugClasses.contains(c))) {
          // Avoid duplicate results if a direct interaction was already found
          results.add(interaction);
        }
      }
    }

    return results;
  }

  @override
  List<Map<String, dynamic>> getSymptomMappings() {
    return _symptomMappings;
  }

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
