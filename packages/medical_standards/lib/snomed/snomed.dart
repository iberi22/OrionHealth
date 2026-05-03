// SNOMED CT (Systematized Nomenclature of Medicine -- Clinical Terms) models.
//
// SNOMED CT is a comprehensive clinical terminology for
// electronic health records.

import 'dart:convert';
import 'package:flutter/services.dart';
import '../medical_standards.dart';

/// SNOMED CT concept
class SnomedConcept extends MedicalConcept {
  @override
  final String code;
  @override
  final String displayName;
  @override
  final String? description;
  final String? fullySpecifiedName;
  final String? semanticTag;
  final List<String> icd10Mappings;
  final List<String> loincMappings;

  const SnomedConcept({
    required this.code,
    required this.displayName,
    this.description,
    this.fullySpecifiedName,
    this.semanticTag,
    this.icd10Mappings = const [],
    this.loincMappings = const [],
  });

  factory SnomedConcept.fromJson(Map<String, dynamic> json) {
    return SnomedConcept(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      fullySpecifiedName: json['fullySpecifiedName'] as String?,
      semanticTag: json['semanticTag'] as String?,
      icd10Mappings: (json['icd10Mappings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      loincMappings: (json['loincMappings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [code, displayName, semanticTag];
}

/// SNOMED CT Catalog loader
class SnomedCatalog {
  static List<SnomedConcept>? _cache;

  /// Loads SNOMED data from JSON asset
  static Future<List<SnomedConcept>> load() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('packages/medical_standards/data/full_snomed.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final dataList = jsonMap['data'] as List<dynamic>;

    _cache = dataList.map((e) => SnomedConcept.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  /// Find by SNOMED CT code
  static Future<SnomedConcept?> findByCode(String code) async {
    final all = await load();
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Find by ICD-10 code
  static Future<SnomedConcept?> findByIcd10(String icd10Code) async {
    final all = await load();
    try {
      return all.firstWhere((c) => c.icd10Mappings.contains(icd10Code));
    } catch (_) {
      return null;
    }
  }

  /// Get all mappings for ICD-10
  static Future<List<SnomedConcept>> getAllForIcd10(String icd10Code) async {
    final all = await load();
    return all.where((c) => c.icd10Mappings.contains(icd10Code)).toList();
  }

  /// Find by LOINC code
  static Future<SnomedConcept?> findByLoinc(String loincCode) async {
    final all = await load();
    try {
      return all.firstWhere((c) => c.loincMappings.contains(loincCode));
    } catch (_) {
      return null;
    }
  }

  /// Find by semantic tag
  static Future<List<SnomedConcept>> findByTag(String tag) async {
    final all = await load();
    return all.where((c) => c.semanticTag == tag).toList();
  }
}

/// Legacy wrapper for backwards compatibility
class SnomedCommonConcepts {
  static Future<List<SnomedConcept>> get all => SnomedCatalog.load();
  static Future<SnomedConcept?> findByCode(String code) => SnomedCatalog.findByCode(code);
}
