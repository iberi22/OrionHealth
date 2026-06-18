/// Clinical practice guidelines references.
///
/// References to major clinical guidelines from authoritative
/// medical organizations.
library;

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

/// Comprehensive clinical guidelines
class ClinicalGuidelines {
  // ==================== DIABETES ====================
  static final ClinicalGuidelineReference adaStandards = ClinicalGuidelineReference(
    code: 'ADA-2024',
    displayName: 'Standards of Care in Diabetes',
    organization: 'American Diabetes Association',
    url: 'https://professional.diabetes.org/content/clinical-practice-recommendations',
    lastUpdated: DateTime(2024, 1),
    version: '2024',
    applicableConditions: ['E10', 'E11'],
    description: 'Comprehensive guidelines for diabetes diagnosis and treatment',
  );

  static final ClinicalGuidelineReference adaA1cTarget = ClinicalGuidelineReference(
    code: 'ADA-A1C',
    displayName: 'A1C Targets for Glycemic Control',
    organization: 'American Diabetes Association',
    url: 'https://diabetes.org/clinical-guidance/quality-metrics',
    lastUpdated: DateTime(2024, 1),
    applicableConditions: ['E10', 'E11'],
    description: 'A1C target <7% for most adults with diabetes; <6.5% if achievable without hypoglycemia',
  );

  static final ClinicalGuidelineReference adaHypertensionInDiabetes = ClinicalGuidelineReference(
    code: 'ADA-HTN-2024',
    displayName: 'Diabetes and Hypertension Management',
    organization: 'American Diabetes Association',
    url: 'https://professional.diabetes.org/content/clinical-practice-recommendations',
    lastUpdated: DateTime(2024, 1),
    applicableConditions: ['E10', 'E11', 'I10'],
    description: 'BP target <130/80 mmHg for diabetics with hypertension',
  );

  static final ClinicalGuidelineReference adaStatin = ClinicalGuidelineReference(
    code: 'ADA-STATIN-2024',
    displayName: 'Diabetes and Cholesterol Management',
    organization: 'American Diabetes Association',
    url: 'https://professional.diabetes.org/content/clinical-practice-recommendations',
    lastUpdated: DateTime(2024, 1),
    applicableConditions: ['E10', 'E11', 'E78.0', 'E78.5', 'I25.9'],
    description: 'Statin therapy for diabetics aged 40-75: moderate intensity; high intensity if ASCVD risk >20%',
  );

  static final ClinicalGuidelineReference whoDiabetes = ClinicalGuidelineReference(
    code: 'WHO-DM-2016',
    displayName: 'Global Report on Diabetes',
    organization: 'World Health Organization',
    url: 'https://www.who.int/publications/i/item/9789241565257',
    lastUpdated: DateTime(2016, 4),
    applicableConditions: ['E10', 'E11'],
    description: 'Global strategy for diabetes prevention and care',
  );

  // ==================== CARDIOVASCULAR / HTN ====================
  static final ClinicalGuidelineReference ahaHypertension = ClinicalGuidelineReference(
    code: 'AHA-2017',
    displayName: 'High Blood Pressure Clinical Practice Guideline',
    organization: 'American Heart Association',
    url: 'https://www.acc.org/latest-in-cardiology/ten-points-to-remember/2017-11-22/new-acc-aha-hypertension-guideline',
    lastUpdated: DateTime(2017, 11),
    version: '2017',
    applicableConditions: ['I10'],
    description: 'BP >=130/80 mmHg = Stage 1 HTN; BP target <130/80 for most adults',
  );

  static final ClinicalGuidelineReference ahaCholesterol = ClinicalGuidelineReference(
    code: 'AHA-2018',
    displayName: 'Cholesterol Management Guideline',
    organization: 'American Heart Association',
    url: 'https://www.acc.org/latest-in-cardiology/ten-points-to-remember/2018-11-10/2018-guideline-on-management-of-blood-cholesterol',
    lastUpdated: DateTime(2018, 11),
    applicableConditions: ['E78.0', 'E78.5', 'I25.9', 'I10'],
    description: 'Statin therapy recommendations by ASCVD risk category',
  );

  static final ClinicalGuidelineReference accAhaRiskCalculator = ClinicalGuidelineReference(
    code: 'ACC-AHA-ASCVD',
    displayName: 'ASCVD Risk Calculator',
    organization: 'ACC/AHA',
    url: 'https://tools.acc.org/ascvd-risk-estimator-plus',
    lastUpdated: DateTime(2023, 8),
    applicableConditions: ['I10', 'E78.0', 'E78.5', 'I25.9'],
    description: '10-year ASCVD risk prediction tool for primary prevention',
  );

  static final ClinicalGuidelineReference whoHypertension = ClinicalGuidelineReference(
    code: 'WHO-2023',
    displayName: 'Hypertension Diagnosis and Management',
    organization: 'World Health Organization',
    url: 'https://www.who.int/publications/i/item/9789240081062',
    lastUpdated: DateTime(2023, 8),
    applicableConditions: ['I10'],
    description: 'WHO guidelines for hypertension management in primary care',
  );

  static final ClinicalGuidelineReference accHeartFailure = ClinicalGuidelineReference(
    code: 'ACC-AHA-HF-2022',
    displayName: 'Guideline for the Management of Heart Failure',
    organization: 'ACC/AHA',
    url: 'https://www.jacc.org/doi/10.1016/j.jacc.2022.01.017',
    lastUpdated: DateTime(2022, 4),
    applicableConditions: ['I50.9', 'I50.22', 'I50.30'],
    description: 'Comprehensive heart failure management: HFrEF (EF<=40%) and HFpEF (EF>=50%)',
  );

  static final ClinicalGuidelineReference escHeartFailure = ClinicalGuidelineReference(
    code: 'ESC-HF-2021',
    displayName: 'ESC Guidelines for Heart Failure',
    organization: 'European Society of Cardiology',
    url: 'https://academic.oup.com/eurheartj/article/42/36/3599/6354367',
    lastUpdated: DateTime(2021, 9),
    applicableConditions: ['I50.9', 'I50.22', 'I50.30'],
    description: 'ESC heart failure guidelines with HFrEF device therapy and pharmacotherapy',
  );

  static final ClinicalGuidelineReference afibAHA = ClinicalGuidelineReference(
    code: 'AHA-AFIB-2023',
    displayName: 'Management of Atrial Fibrillation',
    organization: 'AHA/ACC/HRS',
    url: 'https://www.ahajournals.org/doi/10.1161/CIR.0000000000001197',
    lastUpdated: DateTime(2023, 10),
    applicableConditions: ['I48.91', 'I48.3'],
    description: 'AFib management: rate/rhythm control, anticoagulation (CHA2DS2-VASc), ablation',
  );

  static final ClinicalGuidelineReference stableIschemicHeartDisease = ClinicalGuidelineReference(
    code: 'ACC-AHA-SIHD-2012',
    displayName: 'Management of Stable Ischemic Heart Disease',
    organization: 'ACC/AHA',
    url: 'https://www.jacc.org/doi/10.1016/j.jacc.2012.11.019',
    lastUpdated: DateTime(2012, 12),
    applicableConditions: ['I25.10', 'I25.9'],
    description: 'SIHD management: anti-ischemic therapy, risk stratification, revascularization',
  );

  // ==================== KIDNEY / CKD ====================
  static final ClinicalGuidelineReference kdigoCkd = ClinicalGuidelineReference(
    code: 'KDIGO-CKD-2012',
    displayName: 'KDIGO Clinical Practice Guideline for CKD Evaluation',
    organization: 'Kidney Disease: Improving Global Outcomes',
    url: 'https://kdigo.org/guidelines/ckd-evaluation-and-management/',
    lastUpdated: DateTime(2012, 9),
    applicableConditions: ['N18.9', 'N18.3', 'N18.4', 'N18.5', 'N18.6'],
    description: 'CKD definition, staging, and management based on GFR and albuminuria',
  );

  static final ClinicalGuidelineReference kdigoDiabetesCkd = ClinicalGuidelineReference(
    code: 'KDIGO-DM-CKD-2022',
    displayName: 'KDIGO Clinical Practice Guideline for Diabetes and CKD',
    organization: 'Kidney Disease: Improving Global Outcomes',
    url: 'https://kdigo.org/guidelines/diabetes-and-ckd/',
    lastUpdated: DateTime(2022, 11),
    applicableConditions: ['E10', 'E11', 'N18.9'],
    description: 'Integrated management of diabetes and CKD: glycemic control, BP, lipids',
  );

  static final ClinicalGuidelineReference adaCkdManagement = ClinicalGuidelineReference(
    code: 'ADA-CKD-2024',
    displayName: 'Diabetes and CKD Management',
    organization: 'American Diabetes Association',
    url: 'https://professional.diabetes.org/content/clinical-practice-recommendations',
    lastUpdated: DateTime(2024, 1),
    applicableConditions: ['E10', 'E11', 'N18.9'],
    description: 'SGLT2i and GLP-1 RA use in diabetic CKD; eGFR monitoring',
  );

  // ==================== LIVER ====================
  static final ClinicalGuidelineReference aasldHepatitisB = ClinicalGuidelineReference(
    code: 'AASLD-HBV-2018',
    displayName: 'Hepatitis B Guidance',
    organization: 'American Association for the Study of Liver Diseases',
    url: 'https://aasldpubs.onlinelibrary.wiley.com/doi/10.1002/hep.29800',
    lastUpdated: DateTime(2018, 3),
    applicableConditions: ['B18.1'],
    description: 'HBV screening, treatment, and monitoring recommendations',
  );

  static final ClinicalGuidelineReference aasldHepatitisC = ClinicalGuidelineReference(
    code: 'AASLD-HCV-2020',
    displayName: 'Hepatitis C Guidance',
    organization: 'American Association for the Study of Liver Diseases',
    url: 'https://aasldpubs.onlinelibrary.wiley.com/doi/10.1002/hep.31260',
    lastUpdated: DateTime(2020, 4),
    applicableConditions: ['B18.2'],
    description: 'HCV screening, DAA treatment, and cure monitoring',
  );

  static final ClinicalGuidelineReference aasldNafld = ClinicalGuidelineReference(
    code: 'AASLD-NAFLD-2017',
    displayName: 'NAFLD Diagnosis and Management',
    organization: 'American Association for the Study of Liver Diseases',
    url: 'https://aasldpubs.onlinelibrary.wiley.com/doi/10.1002/hep.29367',
    lastUpdated: DateTime(2017, 6),
    applicableConditions: ['K76.0'],
    description: 'NAFLD/NASH diagnosis, risk stratification, and treatment',
  );

  static final ClinicalGuidelineReference easlNafld = ClinicalGuidelineReference(
    code: 'EASL-NAFLD-2021',
    displayName: 'EASL Guidelines for NAFLD/NASH',
    organization: 'European Association for the Study of the Liver',
    url: 'https://www.journal-of-hepatology.eu/article/S0168-8278(21)00203-4/',
    lastUpdated: DateTime(2021, 6),
    applicableConditions: ['K76.0', 'K72.90'],
    description: 'European guidelines for fatty liver disease and liver failure',
  );

  // ==================== LIPIDS ====================
  static final ClinicalGuidelineReference accAhaPrimaryPrevention = ClinicalGuidelineReference(
    code: 'ACC-AHA-PRIMARY-2019',
    displayName: 'Primary Prevention of ASCVD',
    organization: 'ACC/AHA',
    url: 'https://www.ahajournals.org/doi/10.1161/CIR.0000000000000678',
    lastUpdated: DateTime(2019, 3),
    applicableConditions: ['I10', 'E78.0', 'E78.5', 'E66.9'],
    description: 'Lifestyle and pharmacological primary prevention of ASCVD',
  );

  static final ClinicalGuidelineReference eccEasMalnutrition = ClinicalGuidelineReference(
    code: 'GLIM-Malnutrition-2019',
    displayName: 'GLIM Consensus on Malnutrition',
    organization: 'GLIM Working Group',
    url: 'https://academic.oup.com/jn/article/149/12/2073/5578253',
    lastUpdated: DateTime(2019, 8),
    applicableConditions: ['E43', 'E44.1', 'E46'],
    description: 'Global Leadership Initiative on Malnutrition diagnostic criteria',
  );

  // ==================== THYROID ====================
  static final ClinicalGuidelineReference ataThyroid = ClinicalGuidelineReference(
    code: 'ATA-2014',
    displayName: 'Thyroid Disease in Pregnancy',
    organization: 'American Thyroid Association',
    url: 'https://www.thyroid.org/professionals/ata-guidelines/',
    lastUpdated: DateTime(2014, 1),
    applicableConditions: ['E03.9', 'E05.90', 'E06.3'],
    description: 'Guidelines for thyroid disease management in pregnancy',
  );

  static final ClinicalGuidelineReference ataHypothyroidism = ClinicalGuidelineReference(
    code: 'ATA-HYPOTHYROIDISM-2014',
    displayName: 'Hypothyroidism Guidelines',
    organization: 'American Thyroid Association',
    url: 'https://www.thyroid.org/professionals/ata-guidelines/',
    lastUpdated: DateTime(2014, 2),
    applicableConditions: ['E03.9'],
    description: 'Diagnosis and management of hypothyroidism',
  );

  static final ClinicalGuidelineReference ataHyperthyroidism = ClinicalGuidelineReference(
    code: 'ATA-HYPERTHYROIDISM-2016',
    displayName: 'Hyperthyroidism and Other Causes of Thyrotoxicosis',
    organization: 'American Thyroid Association',
    url: 'https://www.thyroid.org/professionals/ata-guidelines/',
    lastUpdated: DateTime(2016, 9),
    applicableConditions: ['E05.90'],
    description: 'Management of hyperthyroidism and thyrotoxicosis',
  );

  // ==================== MENTAL HEALTH ====================
  static final ClinicalGuidelineReference apaDepression = ClinicalGuidelineReference(
    code: 'APA-DEP-2021',
    displayName: 'Practice Guideline for Treatment of Depression',
    organization: 'American Psychiatric Association',
    url: 'https://psychiatryonline.org/practice-guidelines',
    lastUpdated: DateTime(2021, 10),
    applicableConditions: ['F32.9', 'F33.9', 'F34.1'],
    description: 'Evidence-based treatment recommendations for major depressive disorder',
  );

  static final ClinicalGuidelineReference apaBipolar = ClinicalGuidelineReference(
    code: 'APA-BIPOLAR-2020',
    displayName: 'Practice Guideline for Bipolar Disorder',
    organization: 'American Psychiatric Association',
    url: 'https://psychiatryonline.org/practice-guidelines',
    lastUpdated: DateTime(2020, 4),
    applicableConditions: ['F31.9'],
    description: 'Bipolar disorder diagnosis and treatment',
  );

  static final ClinicalGuidelineReference adaDiabetesMentalHealth = ClinicalGuidelineReference(
    code: 'ADA-MH-2024',
    displayName: 'Psychosocial Care for People with Diabetes',
    organization: 'American Diabetes Association',
    url: 'https://professional.diabetes.org/content/clinical-practice-recommendations',
    lastUpdated: DateTime(2024, 1),
    applicableConditions: ['E10', 'E11', 'F32.9', 'F41.1'],
    description: 'Mental health screening and care for diabetics',
  );

  static final ClinicalGuidelineReference niceDepression = ClinicalGuidelineReference(
    code: 'NICE-DEP-2009',
    displayName: 'Depression in Adults',
    organization: 'National Institute for Health and Care Excellence (UK)',
    url: 'https://www.nice.org.uk/guidance/cg90',
    lastUpdated: DateTime(2009, 10),
    applicableConditions: ['F32.9', 'F33.9'],
    description: 'UK guidelines for depression recognition and treatment',
  );

  // ==================== RESPIRATORY ====================
  static final ClinicalGuidelineReference ginaAsthma = ClinicalGuidelineReference(
    code: 'GINA-2024',
    displayName: 'Global Strategy for Asthma Management',
    organization: 'GINA',
    url: 'https://ginasthma.org/',
    lastUpdated: DateTime(2024, 5),
    applicableConditions: ['J45.909', 'J45.41', 'J45.5'],
    description: 'Stepwise asthma management; emphasizes ICS-containing therapy',
  );

  static final ClinicalGuidelineReference goldCopd = ClinicalGuidelineReference(
    code: 'GOLD-2024',
    displayName: 'Global Strategy for COPD Diagnosis and Management',
    organization: 'GOLD',
    url: 'https://goldcopd.org/',
    lastUpdated: DateTime(2024, 1),
    applicableConditions: ['J44.9', 'J42', 'J43.9', 'J44.1'],
    description: 'COPD assessment, pharmacological and non-pharmacological treatment',
  );

  static final ClinicalGuidelineReference idsaPneumonia = ClinicalGuidelineReference(
    code: 'IDSA-ATS-PNA-2019',
    displayName: 'Community-Acquired Pneumonia Guidelines',
    organization: 'IDSA/ATS',
    url: 'https://www.idsociety.org/practice-guideline/pna/',
    lastUpdated: DateTime(2019, 7),
    applicableConditions: ['J18.9', 'J12.89'],
    description: 'CAP diagnosis, severity assessment (PSI/PORT, CURB-65), antibiotic therapy',
  );

  // ==================== PAIN ====================
  static final ClinicalGuidelineReference cdcOpioidPain = ClinicalGuidelineReference(
    code: 'CDC-OPIOID-2022',
    displayName: 'Clinical Practice Guideline for Opioid Therapy for Chronic Pain',
    organization: 'CDC',
    url: 'https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm',
    lastUpdated: DateTime(2022, 11),
    applicableConditions: ['G89.29', 'M54.5'],
    description: 'Opioid prescribing for chronic pain; non-opioid first; risk assessment',
  );

  static final ClinicalGuidelineReference whoAnalgesicLadder = ClinicalGuidelineReference(
    code: 'WHO-PAIN-1986',
    displayName: 'WHO Analgesic Ladder for Cancer Pain',
    organization: 'World Health Organization',
    url: 'https://www.who.int/publications/i/item/9241541002',
    lastUpdated: DateTime(1986, 1),
    applicableConditions: ['C79.9', 'G89.29'],
    description: 'Three-step analgesic ladder: non-opioid -> weak opioid -> strong opioid',
  );

  static final ClinicalGuidelineReference lowBackPainApt = ClinicalGuidelineReference(
    code: 'ACP-LOWBACK-2017',
    displayName: 'Noninvasive Treatments for Acute/Chronic Low Back Pain',
    organization: 'American College of Physicians',
    url: 'https://www.acpjournals.org/doi/10.7326/M15-2362',
    lastUpdated: DateTime(2017, 4),
    applicableConditions: ['M54.5'],
    description: 'First-line: heat, massage, acupuncture; NSAIDs before opioids for low back pain',
  );

  // ==================== CANCER SCREENING ====================
  static final ClinicalGuidelineReference acsCancerScreening = ClinicalGuidelineReference(
    code: 'ACS-SCREENING-2023',
    displayName: 'Cancer Screening Guidelines',
    organization: 'American Cancer Society',
    url: 'https://www.cancer.org/healthy/find-cancer-early/cancer-screening-guidelines.html',
    lastUpdated: DateTime(2023, 1),
    applicableConditions: ['C50.919', 'C18.9', 'C61', 'C34.90'],
    description: 'Breast, colorectal, lung, prostate cancer screening recommendations',
  );

  // ==================== ANEMIA / HEMATOLOGY ====================
  static final ClinicalGuidelineReference asahAnemia = ClinicalGuidelineReference(
    code: 'ASH-ANEMIA-2020',
    displayName: 'Management of Anemia and Iron Deficiency',
    organization: 'American Society of Hematology',
    url: 'https://ashpublications.org/blood/article/135/19/1633/455458',
    lastUpdated: DateTime(2020, 5),
    applicableConditions: ['D50.9', 'D51.9', 'D52.9', 'D59.9', 'D63.1'],
    description: 'Diagnosis and management of various anemias',
  );

  static final ClinicalGuidelineReference kdigoAnemiaCkd = ClinicalGuidelineReference(
    code: 'KDIGO-ANEMIA-2012',
    displayName: 'CKD-Anemia Guidelines',
    organization: 'Kidney Disease: Improving Global Outcomes',
    url: 'https://kdigo.org/guidelines/ckd-evaluation-and-management/',
    lastUpdated: DateTime(2012, 9),
    applicableConditions: ['D63.1', 'N18.9'],
    description: 'Iron and ESA therapy in anemia of CKD',
  );

  // ==================== LAB REFERENCE ====================
  static final ClinicalGuidelineReference labReferenceRanges = ClinicalGuidelineReference(
    code: 'CLSI-2017',
    displayName: 'Reference intervals for Laboratory Tests',
    organization: 'Clinical and Laboratory Standards Institute',
    url: 'https://clsi.org/standards/products/method-evaluation/documents/c28/',
    lastUpdated: DateTime(2017, 1),
    description: 'Reference intervals for common laboratory tests',
  );

  static final ClinicalGuidelineReference adaStandardsMedicalCare = ClinicalGuidelineReference(
    code: 'ADA-MC-2024',
    displayName: 'Standards of Medical Care in Diabetes',
    organization: 'American Diabetes Association',
    url: 'https://diabetesjournals.org/care/issue/47/Supplement_1',
    lastUpdated: DateTime(2024, 1),
    applicableConditions: ['E10', 'E11'],
    description: 'Comprehensive diabetes care: screening, diagnosis, monitoring, treatment targets',
  );

  // ==================== ALL GUIDELINES ====================
  static final List<ClinicalGuidelineReference> all = [
    // Diabetes
    adaStandards, adaA1cTarget, adaHypertensionInDiabetes, adaStatin, whoDiabetes,
    adaDiabetesMentalHealth, adaCkdManagement, adaStandardsMedicalCare,
    // Cardiovascular
    ahaHypertension, ahaCholesterol, accAhaRiskCalculator, whoHypertension,
    accHeartFailure, escHeartFailure, afibAHA, stableIschemicHeartDisease,
    accAhaPrimaryPrevention, eccEasMalnutrition,
    // Kidney
    kdigoCkd, kdigoDiabetesCkd,
    // Liver
    aasldHepatitisB, aasldHepatitisC, aasldNafld, easlNafld,
    // Thyroid
    ataThyroid, ataHypothyroidism, ataHyperthyroidism,
    // Mental Health
    apaDepression, apaBipolar, niceDepression,
    // Respiratory
    ginaAsthma, goldCopd, idsaPneumonia,
    // Pain
    cdcOpioidPain, whoAnalgesicLadder, lowBackPainApt,
    // Cancer
    acsCancerScreening,
    // Hematology
    asahAnemia, kdigoAnemiaCkd,
    // Lab
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

  /// Find by code
  static ClinicalGuidelineReference? findByCode(String code) {
    try {
      return all.firstWhere((g) => g.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Get guidelines for multiple conditions
  static List<ClinicalGuidelineReference> findForConditions(List<String> icd10Codes) {
    return all.where((g) => g.applicableConditions.any((c) => icd10Codes.contains(c))).toList();
  }
}
