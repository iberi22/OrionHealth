import 'dart:convert';
import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../../../core/services/app_logger.dart';
import '../../domain/entities/medical_code.dart';
import '../../domain/repositories/medical_knowledge_repository.dart';

/// [MedicalKnowledgeRepository] implementation that loads medical standards
/// from Flutter asset bundle (works on mobile).
///
/// Assets must be declared in pubspec.yaml under:
/// ```yaml
/// flutter:
///   assets:
///     - assets/medical-standards/
/// ```
///
/// Falls back to [JsonMedicalKnowledgeRepository] when assets fail
/// (e.g., on desktop or during testing).
@Injectable(as: MedicalKnowledgeRepository, env: ['mobile'])
class AssetMedicalKnowledgeRepository implements MedicalKnowledgeRepository {
  List<MedicalCode> _allCodes = [];
  Map<String, MedicalCode> _codeIndex = {};
  Map<String, List<MedicalCode>> _termIndex = {};
  Map<String, List<MedicalCode>> _categoryIndex = {};
  Map<String, List<MedicalCode>> _standardIndex = {};
  List<Map<String, dynamic>> _symptomMappings = [];
  bool _initialized = false;
  AssetMedicalKnowledgeRepository();

  String get _assetBasePath => 'assets/medical-standards';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize({bool force = false}) async {
    if (_initialized && !force) return;
    _initialized = false; // Reset to allow reload

    final stopwatch = Stopwatch()..start();

    const files = <String, String>{
      'ICD-10': 'icd10.json',
      'LOINC': 'loinc.json',
      'RxNorm': 'rxnorm.json',
      'SNOMED': 'snomed.json',
      'Clinical Guidelines': 'clinical_guidelines.json',
    };

    final allCodes = <MedicalCode>[];

    for (final entry in files.entries) {
      final standard = entry.key;
      final fileName = entry.value;
      final assetPath = p.join(_assetBasePath, fileName);

      try {
        final jsonString = await rootBundle.loadString(assetPath);
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final dataList = decoded['data'] as List<dynamic>;

        final codes = dataList
            .map((e) => MedicalCode.fromJson(e as Map<String, dynamic>, standard))
            .toList();

        allCodes.addAll(codes);
      } catch (e) {
        // Asset not found — will fall back to empty
        AppLogger.w('AssetMedicalRepo', 'Failed to load $assetPath: $e');
      }
    }

    _allCodes = allCodes;

    // Load Symptom Mappings from Assets
    try {
      final symptomsPath = p.join(_assetBasePath, 'symptom_checker.json');
      final symptomsJson = await rootBundle.loadString(symptomsPath);
      final decoded = jsonDecode(symptomsJson) as Map<String, dynamic>;
      _symptomMappings = List<Map<String, dynamic>>.from(decoded['data'] ?? []);
    } catch (e) {
      AppLogger.w('AssetMedicalRepo', 'Failed to load symptom_checker.json: $e');
    }

    _buildIndexes();
    _initialized = true;

    stopwatch.stop();
    AppLogger.i('AssetMedicalRepo', 'Loaded ${allCodes.length} codes in ${stopwatch.elapsedMilliseconds}ms');
  }

  void _buildIndexes() {
    _codeIndex = {};
    _termIndex = {};
    _categoryIndex = {};
    _standardIndex = {};

    for (final code in _allCodes) {
      _codeIndex[code.code.toLowerCase()] = code;
      _standardIndex.putIfAbsent(code.standard, () => []).add(code);

      if (code.category.isNotEmpty) {
        _categoryIndex.putIfAbsent(code.category.toLowerCase(), () => []).add(code);
      }

      final allText = [
        code.displayName,
        ...code.searchTerms,
        code.category,
        code.standard,
        code.code,
      ];

      for (final text in allText) {
        for (final token in _tokenize(text)) {
          _termIndex.putIfAbsent(token, () => []).add(code);
        }
      }
    }
  }

  List<String> _tokenize(String text) {
    if (text.isEmpty) return [];
    final words = text.toLowerCase().split(RegExp(r'[\s,;:/\\\-_\(\)\[\]]+'));
    return words.where((w) => w.length >= 2).toSet().toList();
  }

  @override
  Future<MedicalCode?> searchByCode(String code) async {
    _ensureInitialized();
    return _codeIndex[code.toLowerCase()];
  }

  @override
  Future<MedicalCode?> searchByCodeInStandard(String code, String standard) async {
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
  Future<List<MedicalCode>> searchByTermInStandard(String searchTerm, String standard) async {
    _ensureInitialized();
    final results = await searchByTerm(searchTerm);
    return results.where((c) => c.standard == standard).toList();
  }

  @override
  Future<List<MedicalCode>> searchByCategory(String category) async {
    _ensureInitialized();
    final cat = category.toLowerCase();
    final results = <MedicalCode>{};

    if (_categoryIndex.containsKey(cat)) {
      results.addAll(_categoryIndex[cat]!);
    }

    for (final key in _categoryIndex.keys) {
      if (key.contains(cat) || cat.contains(key)) {
        results.addAll(_categoryIndex[key]!);
      }
    }

    for (final token in _tokenize(category)) {
      if (_termIndex.containsKey(token)) {
        results.addAll(_termIndex[token]!);
      }
    }

    return results.toList();
  }

  @override
  Future<List<MedicalCode>> getAllCodes({String? standard}) async {
    _ensureInitialized();
    if (standard != null) return _standardIndex[standard] ?? [];
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
    // For simplicity in the asset repo, we return empty as interactions 
    // are primarily managed in the Json repository/Sync service.
    return [];
  }

  @override
  List<Map<String, dynamic>> getSymptomMappings() {
    return _symptomMappings;
  }

  List<MedicalCode> _searchByTokens(String query) {
    final tokens = _tokenize(query);
    if (tokens.isEmpty) return [];

    final scores = <MedicalCode, int>{};
    for (final token in tokens) {
      if (_termIndex.containsKey(token)) {
        for (final code in _termIndex[token]!) {
          scores[code] = (scores[code] ?? 0) + 10;
        }
      }
      for (final indexedToken in _termIndex.keys) {
        if (indexedToken.startsWith(token) || token.startsWith(indexedToken)) {
          for (final code in _termIndex[indexedToken]!) {
            scores[code] = (scores[code] ?? 0) + 5;
          }
        }
      }
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AssetMedicalRepo not initialized. Call initialize() first.');
    }
  }
}
