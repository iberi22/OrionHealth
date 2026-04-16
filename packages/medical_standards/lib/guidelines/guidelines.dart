/// Clinical practice guidelines references.
///
/// References to major clinical guidelines from authoritative
/// medical organizations.

import 'dart:convert';
import 'package:flutter/services.dart';
import '../medical_standards.dart';

/// Clinical guideline reference
class ClinicalGuidelineReference extends MedicalConcept {
  @override
  final String code;
  @override
  final String displayName;
  @override
  final String? description;
  final String organization;
  final String url;
  final DateTime lastUpdated;
  final String? version;
  final List<String> applicableConditions;

  const ClinicalGuidelineReference({
    required this.code,
    required this.displayName,
    this.description,
    required this.organization,
    required this.url,
    required this.lastUpdated,
    this.version,
    this.applicableConditions = const [],
  });

  factory ClinicalGuidelineReference.fromJson(Map<String, dynamic> json) {
    return ClinicalGuidelineReference(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      organization: json['organization'] as String,
      url: json['url'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      version: json['version'] as String?,
      applicableConditions: (json['applicableConditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [code, organization, lastUpdated];
}

/// Clinical Guidelines Catalog loader
class ClinicalGuidelines {
  static List<ClinicalGuidelineReference>? _cache;

  /// Loads guidelines from JSON asset
  static Future<List<ClinicalGuidelineReference>> load() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('packages/medical_standards/data/full_guidelines.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final dataList = jsonMap['data'] as List<dynamic>;

    _cache = dataList.map((e) => ClinicalGuidelineReference.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  /// Find by ICD-10 condition code
  static Future<List<ClinicalGuidelineReference>> findForCondition(String icd10Code) async {
    final all = await load();
    return all.where((g) => g.applicableConditions.contains(icd10Code)).toList();
  }

  /// Find by organization
  static Future<List<ClinicalGuidelineReference>> findByOrganization(String org) async {
    final all = await load();
    return all.where((g) => g.organization.contains(org)).toList();
  }

  /// Find by code
  static Future<ClinicalGuidelineReference?> findByCode(String code) async {
    final all = await load();
    try {
      return all.firstWhere((g) => g.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Get guidelines for multiple conditions
  static Future<List<ClinicalGuidelineReference>> findForConditions(List<String> icd10Codes) async {
    final all = await load();
    return all.where((g) => g.applicableConditions.any((c) => icd10Codes.contains(c))).toList();
  }

  /// Legacy getter for compatibility
  static Future<List<ClinicalGuidelineReference>> get all => load();
}
