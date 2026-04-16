/// Core interfaces and base models for medical standards.
///
/// All standards in this package implement these interfaces
/// to ensure interoperability.

import 'package:equatable/equatable.dart';

/// Standard export
export 'icd10/icd10.dart';
export 'snomed/snomed.dart';
export 'loinc/loinc.dart';
export 'fhir/fhir.dart';
export 'medications/medications.dart';
export 'guidelines/guidelines.dart';
export 'services/sync_service.dart';
export 'services/medical_context_provider.dart';

/// Base interface for all medical concepts
abstract class MedicalConcept extends Equatable {
  const MedicalConcept();

  /// Unique code in the standard
  String get code;

  /// Human-readable name
  String get displayName;

  /// Optional description
  String? get description;
}

/// Vital sign or observation measurement
class VitalSign extends Equatable {
  final String code;
  final String displayName;
  final String loincCode;
  final String unit;
  final double? normalRangeMin;
  final double? normalRangeMax;

  const VitalSign({
    required this.code,
    required this.displayName,
    required this.loincCode,
    required this.unit,
    this.normalRangeMin,
    this.normalRangeMax,
  });

  bool isNormal(double value) {
    if (normalRangeMin != null && value < normalRangeMin!) return false;
    if (normalRangeMax != null && value > normalRangeMax!) return false;
    return true;
  }

  @override
  List<Object?> get props => [code, displayName, loincCode, unit];
}

/// Lab test definition
class LabTest extends Equatable {
  final String code;
  final String displayName;
  final String loincCode;
  final String unit;
  final String? specimen;
  final double? criticalLow;
  final double? criticalHigh;

  const LabTest({
    required this.code,
    required this.displayName,
    required this.loincCode,
    required this.unit,
    this.specimen,
    this.criticalLow,
    this.criticalHigh,
  });

  bool isCritical(double value) {
    if (criticalLow != null && value < criticalLow!) return true;
    if (criticalHigh != null && value > criticalHigh!) return true;
    return false;
  }

  @override
  List<Object?> get props => [code, displayName, loincCode, unit];
}

/// Medication reference
class Medication extends Equatable {
  final String rxnormCode;
  final String displayName;
  final String? genericName;
  final String? drugClass;
  final List<String> routes;
  final List<String> dosages;

  const Medication({
    required this.rxnormCode,
    required this.displayName,
    this.genericName,
    this.drugClass,
    this.routes = const [],
    this.dosages = const [],
  });

  @override
  List<Object?> get props => [rxnormCode, displayName];
}

/// Clinical guideline reference
class ClinicalGuideline extends Equatable {
  final String id;
  final String title;
  final String organization;
  final String url;
  final DateTime lastUpdated;
  final List<String> applicableConditions;

  const ClinicalGuideline({
    required this.id,
    required this.title,
    required this.organization,
    required this.url,
    required this.lastUpdated,
    this.applicableConditions = const [],
  });

  @override
  List<Object?> get props => [id, title, organization];
}
