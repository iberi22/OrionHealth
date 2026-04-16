/// LOINC laboratory observation codes.
///
/// LOINC (Logical Observation Identifiers Names and Codes) is the
/// universal code system for identifying laboratory and clinical
/// observations.

import 'dart:convert';
import 'package:flutter/services.dart';
import '../medical_standards.dart';

/// LOINC observation code
class LoincCode extends MedicalConcept {
  @override
  final String code;
  @override
  final String displayName;
  @override
  final String? description;
  final String component;
  final String property;
  final String unit;

  const LoincCode({
    required this.code,
    required this.displayName,
    this.description,
    required this.component,
    required this.property,
    required this.unit,
  });

  factory LoincCode.fromJson(Map<String, dynamic> json) {
    return LoincCode(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      component: json['component'] as String,
      property: json['property'] as String,
      unit: json['unit'] as String,
    );
  }

  /// Extracts the normal range from the description if present.
  /// Expects format: "Normal: 0.8-1.8 ng/dL"
  String? get normalRange {
    if (description == null) return null;
    if (description!.contains('Normal:')) {
      final parts = description!.split('Normal:');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [code, displayName, component, property];

  /// Legacy static method for tests
  static Future<LoincCode?> findByCode(String code) => LoincCatalog.findByCode(code);
}

/// LOINC Catalog loader
class LoincCatalog {
  static List<LoincCode>? _cache;

  /// Loads LOINC data from JSON asset
  static Future<List<LoincCode>> load() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('packages/medical_standards/data/full_loinc.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final dataList = jsonMap['data'] as List<dynamic>;

    _cache = dataList.map((e) => LoincCode.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  /// Find by LOINC code
  static Future<LoincCode?> findByCode(String code) async {
    final all = await load();
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Find by component name
  static Future<LoincCode?> findByComponent(String component) async {
    final all = await load();
    final lower = component.toLowerCase();
    try {
      return all.firstWhere((c) => c.component.toLowerCase() == lower);
    } catch (_) {
      return null;
    }
  }
}

/// Legacy wrapper for backwards compatibility
class LoincCommonLabs {
  static Future<List<LoincCode>> get all => LoincCatalog.load();
  static Future<LoincCode?> findByCode(String code) => LoincCatalog.findByCode(code);
}
