/// SNOMED CT (Clinical Terms) mappings.
///
/// SNOMED CT is a standardized medical vocabulary used for
/// clinical documentation. This module maps SNOMED codes to
/// other standards (ICD-10, LOINC) and provides common clinical
/// concepts.

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

  @override
  List<Object?> get props => [code, displayName, semanticTag];
}

/// Common SNOMED CT concepts
class SnomedCommonConcepts {
  // Diabetes
  static const SnomedConcept diabetesType1 = SnomedConcept(
    code: '76684001',
    displayName: 'Diabetes mellitus type 1',
    fullySpecifiedName: 'Diabetes mellitus type 1 (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E10'],
    description: 'Autoimmune destruction of pancreatic beta cells',
  );

  static const SnomedConcept diabetesType2 = SnomedConcept(
    code: '44054006',
    displayName: 'Diabetes mellitus type 2',
    fullySpecifiedName: 'Diabetes mellitus type 2 (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E11'],
    description: 'Insulin resistance with relative insulin deficiency',
  );

  // Cardiovascular
  static const SnomedConcept hypertension = SnomedConcept(
    code: '38341003',
    displayName: 'Hypertensive disorder',
    fullySpecifiedName: 'Hypertensive disorder, systemic arterial (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I10'],
    description: 'Sustained elevation of systemic arterial blood pressure',
  );

  static const SnomedConcept atrialFibrillation = SnomedConcept(
    code: '49436004',
    displayName: 'Atrial fibrillation',
    fullySpecifiedName: 'Atrial fibrillation (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I48.91'],
  );

  static const SnomedConcept heartFailure = SnomedConcept(
    code: '84114007',
    displayName: 'Heart failure',
    fullySpecifiedName: 'Heart failure (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I50.9'],
  );

  // Metabolic
  static const SnomedConcept hypercholesterolemia = SnomedConcept(
    code: '13644009',
    displayName: 'Hypercholesterolemia',
    fullySpecifiedName: 'Hypercholesterolemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E78.5'],
  );

  static const SnomedConcept obesity = SnomedConcept(
    code: '414916001',
    displayName: 'Obesity',
    fullySpecifiedName: 'Obesity (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E66.9'],
  );

  // Respiratory
  static const SnomedConcept asthma = SnomedConcept(
    code: '195967001',
    displayName: 'Asthma',
    fullySpecifiedName: 'Asthma (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['J45.909'],
  );

  // Thyroid
  static const SnomedConcept hypothyroidism = SnomedConcept(
    code: '8410007',
    displayName: 'Hypothyroidism',
    fullySpecifiedName: 'Hypothyroidism (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E03.9'],
  );

  static const SnomedConcept hyperthyroidism = SnomedConcept(
    code: '34486009',
    displayName: 'Hyperthyroidism',
    fullySpecifiedName: 'Hyperthyroidism (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E05.90'],
  );

  // Mental Health
  static const SnomedConcept majorDepression = SnomedConcept(
    code: '398044002',
    displayName: 'Major depression',
    fullySpecifiedName: 'Major depression disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F32.9'],
  );

  static const SnomedConcept generalizedAnxiety = SnomedConcept(
    code: '48694002',
    displayName: 'Generalized anxiety disorder',
    fullySpecifiedName: 'Generalized anxiety disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F41.1'],
  );

  // Symptoms
  static const SnomedConcept fatigue = SnomedConcept(
    code: '84229001',
    displayName: 'Fatigue',
    fullySpecifiedName: 'Fatigue (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R53.83'],
  );

  static const SnomedConcept chestPain = SnomedConcept(
    code: '29857009',
    displayName: 'Chest pain',
    fullySpecifiedName: 'Chest pain (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R07.9'],
  );

  static const SnomedConcept headache = SnomedConcept(
    code: '25064002',
    displayName: 'Headache',
    fullySpecifiedName: 'Headache (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R51.9'],
  );

  // Lab Observations
  static const SnomedConcept hemoglobinA1c = SnomedConcept(
    code: '43396008',
    displayName: 'Hemoglobin A1c',
    fullySpecifiedName: 'Hemoglobin A1c (substance)',
    semanticTag: 'substance',
    loincMappings: ['4548-4'],
  );

  static const SnomedConcept glucoseMeasurement = SnomedConcept(
    code: '33489001',
    displayName: 'Glucose measurement',
    fullySpecifiedName: 'Glucose measurement (procedure)',
    semanticTag: 'procedure',
    loincMappings: ['2345-7'],
  );

  /// All common concepts
  static const List<SnomedConcept> all = [
    diabetesType1,
    diabetesType2,
    hypertension,
    atrialFibrillation,
    heartFailure,
    hypercholesterolemia,
    obesity,
    asthma,
    hypothyroidism,
    hyperthyroidism,
    majorDepression,
    generalizedAnxiety,
    fatigue,
    chestPain,
    headache,
    hemoglobinA1c,
    glucoseMeasurement,
  ];

  /// Find by SNOMED CT code
  static SnomedConcept? findByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Find by ICD-10 code
  static SnomedConcept? findByIcd10(String icd10Code) {
    try {
      return all.firstWhere((c) => c.icd10Mappings.contains(icd10Code));
    } catch (_) {
      return null;
    }
  }

  /// Get all mappings for ICD-10
  static List<SnomedConcept> getAllForIcd10(String icd10Code) {
    return all.where((c) => c.icd10Mappings.contains(icd10Code)).toList();
  }
}
