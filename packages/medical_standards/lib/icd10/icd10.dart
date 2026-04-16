/// ICD-10 disease classification models.
///
/// ICD-10 is the International Classification of Diseases, 10th Revision.
/// Used for diagnosing diseases and conditions.

import 'dart:convert';
import 'package:flutter/services.dart';
import '../medical_standards.dart';

/// ICD-10 Disease Code
class Icd10Code extends MedicalConcept {
  @override
  final String code;
  @override
  final String displayName;
  @override
  final String? description;
  final String category;
  final List<String> synonyms;

  const Icd10Code({
    required this.code,
    required this.displayName,
    this.description,
    required this.category,
    this.synonyms = const [],
  });

  factory Icd10Code.fromJson(Map<String, dynamic> json) {
    return Icd10Code(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [code, displayName, category];

  /// Legacy static method for tests (synchronous-like but now returns Future)
  static Future<Icd10Code?> findByCode(String code) => Icd10Catalog.findByCode(code);
  static Future<List<Icd10Code>> findByCategory(String category) => Icd10Catalog.findByCategory(category);
}

/// ICD-10 Catalog loader
class Icd10Catalog {
  static List<Icd10Code>? _cache;

  /// Loads ICD-10 data from JSON asset
  static Future<List<Icd10Code>> load() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('packages/medical_standards/data/full_icd10.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final dataList = jsonMap['data'] as List<dynamic>;

    _cache = dataList.map((e) => Icd10Code.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  /// Find by code
  static Future<Icd10Code?> findByCode(String code) async {
    final all = await load();
    final lower = code.toLowerCase();
    try {
      return all.firstWhere((c) => c.code.toLowerCase() == lower);
    } catch (_) {
      return null;
    }
  }

  /// Find by synonym
  static Future<Icd10Code?> findBySynonym(String term) async {
    final all = await load();
    final lower = term.toLowerCase();
    for (final code in all) {
      if (code.synonyms.any((s) => s.toLowerCase() == lower)) {
        return code;
      }
    }
    return null;
  }

  /// Find by category
  static Future<List<Icd10Code>> findByCategory(String category) async {
    final all = await load();
    final lower = category.toLowerCase();
    return all.where((c) => c.category.toLowerCase().startsWith(lower)).toList();
  }
}

/// Legacy wrapper for backwards compatibility
class Icd10ChronicConditions {
  static Future<List<Icd10Code>> get all => Icd10Catalog.load();
  static Future<Icd10Code?> findByCode(String code) => Icd10Catalog.findByCode(code);
}
