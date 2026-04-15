/// Clinical practice guidelines references.
///
/// References to major clinical guidelines from authoritative
/// medical organizations.

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

  @override
  List<Object?> get props => [code, organization, lastUpdated];
}

/// Major clinical guidelines
class ClinicalGuidelines {
  // ADA - American Diabetes Association
  static const ClinicalGuidelineReference adaStandards = ClinicalGuidelineReference(
    code: 'ADA-2024',
    displayName: 'Standards of Care in Diabetes',
    organization: 'American Diabetes Association',
    url: 'https://professional.diabetes.org/content/clinical-practice-recommendations',
    lastUpdated: DateTime(2024, 1),
    version: '2024',
    applicableConditions: ['E10', 'E11'], // ICD-10 diabetes codes
    description: 'Comprehensive guidelines for diabetes diagnosis and treatment',
  );

  static const ClinicalGuidelineReference adaA1cTarget = ClinicalGuidelineReference(
    code: 'ADA-A1C',
    displayName: 'A1C Targets for Glycemic Control',
    organization: 'American Diabetes Association',
    url: 'https://diabetes.org/clinical-guidance/quality-metrics',
    lastUpdated: DateTime(2024, 1),
    description: 'A1C target <7% for most adults with diabetes',
  );

  // AHA - American Heart Association
  static const ClinicalGuidelineReference ahaHypertension = ClinicalGuidelineReference(
    code: 'AHA-2017',
    displayName: 'High Blood Pressure Clinical Practice Guideline',
    organization: 'American Heart Association',
    url: 'https://www.acc.org/latest-in-cardiology/ten-points-to-remember/2017-11-22/new-acc-aha-hypertension-guideline',
    lastUpdated: DateTime(2017, 11),
    version: '2017',
    applicableConditions: ['I10'], // ICD-10 hypertension
    description: 'BP target <130/80 mmHg for most adults',
  );

  static const ClinicalGuidelineReference ahaCholesterol = ClinicalGuidelineReference(
    code: 'AHA-2018',
    displayName: 'Cholesterol Management Guideline',
    organization: 'American Heart Association',
    url: 'https://www.acc.org/latest-in-cardiology/ten-points-to-remember/2018-11-10/2018-guideline-on-management-of-blood-cholesterol',
    lastUpdated: DateTime(2018, 11),
    description: 'Statin therapy recommendations by risk category',
  );

  // ACC/AHA - Cardiovascular Risk
  static const ClinicalGuidelineReference accAhaRiskCalculator = ClinicalGuidelineReference(
    code: 'ACC-AHA-ASCVD',
    displayName: 'ASCVD Risk Calculator',
    organization: 'ACC/AHA',
    url: 'https://tools.acc.org/ascvd-risk-estimator-plus',
    lastUpdated: DateTime(2023, 8),
    description: '10-year ASCVD risk prediction tool',
  );

  // WHO Guidelines
  static const ClinicalGuidelineReference whoHypertension = ClinicalGuidelineReference(
    code: 'WHO-2023',
    displayName: 'Hypertension Diagnosis and Management',
    organization: 'World Health Organization',
    url: 'https://www.who.int/publications/i/item/9789240081062',
    lastUpdated: DateTime(2023, 8),
    description: 'WHO guidelines for hypertension management',
  );

  static const ClinicalGuidelineReference whoDiabetes = ClinicalGuidelineReference(
    code: 'WHO-DM-2016',
    displayName: 'Global Report on Diabetes',
    organization: 'World Health Organization',
    url: 'https://www.who.int/publications/i/item/9789241565257',
    lastUpdated: DateTime(2016, 4),
    description: 'Global strategy for diabetes prevention and care',
  );

  // Thyroid
  static const ClinicalGuidelineReference ataThyroid = ClinicalGuidelineReference(
    code: 'ATA-2014',
    displayName: 'Thyroid Disease in Pregnancy',
    organization: 'American Thyroid Association',
    url: 'https://www.thyroid.org/professionals/ata-guidelines/',
    lastUpdated: DateTime(2014, 1),
    description: 'Guidelines for thyroid disease management in pregnancy',
  );

  // Mental Health
  static const ClinicalGuidelineReference apaDepression = ClinicalGuidelineReference(
    code: 'APA-DEP-2021',
    displayName: 'Practice Guideline for Treatment of Depression',
    organization: 'American Psychiatric Association',
    url: 'https://psychiatryonline.org/practice-guidelines',
    lastUpdated: DateTime(2021, 10),
    description: 'Evidence-based treatment recommendations for depression',
  );

  // Lab Reference Ranges (general)
  static const ClinicalGuidelineReference labReferenceRanges = ClinicalGuidelineReference(
    code: 'CLSI-2017',
    displayName: 'Reference intervals for Laboratory Tests',
    organization: 'Clinical and Laboratory Standards Institute',
    url: 'https://clsi.org/standards/products/method-evaluation/documents/c28/',
    lastUpdated: DateTime(2017, 1),
    description: 'Reference intervals for common laboratory tests',
  );

  /// All guidelines
  static const List<ClinicalGuidelineReference> all = [
    adaStandards,
    adaA1cTarget,
    ahaHypertension,
    ahaCholesterol,
    accAhaRiskCalculator,
    whoHypertension,
    whoDiabetes,
    ataThyroid,
    apaDepression,
    labReferenceRanges,
  ];

  /// Find by ICD-10 condition code
  static List<ClinicalGuidelineReference> findForCondition(String icd10Code) {
    return all.where((g) => g.applicableConditions.contains(icd10Code)).toList();
  }

  /// Find by organization
  static List<ClinicalGuidelineReference> findByOrganization(String org) {
    return all.where((g) => g.organization.contains(org)).toList();
  }
}
