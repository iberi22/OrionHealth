/// Medication reference data (RxNorm subset).
///
/// RxNorm provides normalized names for drugs and doses.
/// This is a curated subset of common medications.

import 'dart:convert';
import 'package:flutter/services.dart';
import '../medical_standards.dart';

/// Medication entry
class MedicationReference extends MedicalConcept {
  @override
  final String code;
  @override
  final String displayName;
  @override
  final String? description;
  final String? genericName;
  final String? drugClass;
  final List<String> routes;
  final List<String> commonDosages;

  const MedicationReference({
    required this.code,
    required this.displayName,
    this.description,
    this.genericName,
    this.drugClass,
    this.routes = const ['Oral'],
    this.commonDosages = const [],
  });

  factory MedicationReference.fromJson(Map<String, dynamic> json) {
    return MedicationReference(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      genericName: json['genericName'] as String?,
      drugClass: json['drugClass'] as String?,
      routes: (json['routes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['Oral'],
      commonDosages: (json['commonDosages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [code, displayName, drugClass];
}

/// Medication Catalog loader
class MedicationCatalog {
  static List<MedicationReference>? _cache;

  /// Loads medication data from JSON asset
  static Future<List<MedicationReference>> load() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('packages/medical_standards/data/full_rxnorm.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final dataList = jsonMap['data'] as List<dynamic>;

    _cache = dataList.map((e) => MedicationReference.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  /// Find by RxNorm code
  static Future<MedicationReference?> findByCode(String code) async {
    final all = await load();
    try {
      return all.firstWhere((m) => m.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Find by drug class
  static Future<List<MedicationReference>> findByClass(String drugClass) async {
    final all = await load();
    return all.where((m) => m.drugClass?.contains(drugClass) ?? false).toList();
  }

  /// Find by display name
  static Future<MedicationReference?> findByName(String name) async {
    final all = await load();
    final lower = name.toLowerCase();
    try {
      return all.firstWhere((m) => m.displayName.toLowerCase() == lower ||
          (m.genericName?.toLowerCase() ?? '').contains(lower));
    } catch (_) {
      return null;
    }
  }

  /// Find by generic name
  static Future<MedicationReference?> findByGeneric(String generic) async {
    final all = await load();
    final lower = generic.toLowerCase();
    try {
      return all.firstWhere((m) => m.genericName?.toLowerCase().contains(lower) ?? false);
    } catch (_) {
      return null;
    }
  }

  /// Legacy getter for compatibility
  static Future<List<MedicationReference>> get all => load();
}
