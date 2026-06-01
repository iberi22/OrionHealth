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

/// Comprehensive SNOMED CT concepts
class SnomedCommonConcepts {
  // ==================== ENDOCRINE / DIABETES ====================
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

  static const SnomedConcept gestationalDiabetes = SnomedConcept(
    code: '11687002',
    displayName: 'Gestational diabetes mellitus',
    fullySpecifiedName: 'Gestational diabetes mellitus (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E12'],
    description: 'Glucose intolerance first recognized during pregnancy',
  );

  static const SnomedConcept diabeticKetoacidosis = SnomedConcept(
    code: '420719005',
    displayName: 'Diabetic ketoacidosis',
    fullySpecifiedName: 'Diabetic ketoacidosis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E10.1'],
  );

  static const SnomedConcept diabeticNephropathy = SnomedConcept(
    code: '127013001',
    displayName: 'Diabetic renal disease',
    fullySpecifiedName: 'Diabetic nephropathy (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E11.21'],
  );

  static const SnomedConcept diabeticRetinopathy = SnomedConcept(
    code: '425048006',
    displayName: 'Diabetic retinopathy',
    fullySpecifiedName: 'Diabetic retinopathy (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E11.31'],
  );

  static const SnomedConcept diabeticNeuropathy = SnomedConcept(
    code: '126663001',
    displayName: 'Diabetic neuropathy',
    fullySpecifiedName: 'Diabetic neuropathy (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E11.4'],
  );

  // Thyroid
  static const SnomedConcept hyperthyroidism = SnomedConcept(
    code: '34486009',
    displayName: 'Hyperthyroidism',
    fullySpecifiedName: 'Hyperthyroidism (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E05.90'],
  );

  static const SnomedConcept hypothyroidism = SnomedConcept(
    code: '8410007',
    displayName: 'Hypothyroidism',
    fullySpecifiedName: 'Hypothyroidism (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E03.9'],
  );

  static const SnomedConcept hashimotoThyroiditis = SnomedConcept(
    code: '733941003',
    displayName: 'Hashimoto thyroiditis',
    fullySpecifiedName: 'Hashimoto thyroiditis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E06.3'],
  );

  static const SnomedConcept gravesDisease = SnomedConcept(
    code: '34486009',
    displayName: "Graves' disease",
    fullySpecifiedName: "Graves' disease (disorder)",
    semanticTag: 'disorder',
    icd10Mappings: ['E05.00'],
  );

  // Metabolic
  static const SnomedConcept obesity = SnomedConcept(
    code: '414916001',
    displayName: 'Obesity',
    fullySpecifiedName: 'Obesity (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E66.9'],
  );

  static const SnomedConcept metabolicSyndrome = SnomedConcept(
    code: '237605009',
    displayName: 'Metabolic syndrome',
    fullySpecifiedName: 'Metabolic syndrome (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E88.81'],
  );

  static const SnomedConcept hypercholesterolemia = SnomedConcept(
    code: '13644009',
    displayName: 'Hypercholesterolemia',
    fullySpecifiedName: 'Hypercholesterolemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E78.0'],
  );

  static const SnomedConcept hypertriglyceridemia = SnomedConcept(
    code: '302870006',
    displayName: 'Hypertriglyceridemia',
    fullySpecifiedName: 'Hypertriglyceridemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E78.1'],
  );

  static const SnomedConcept hyperuricemia = SnomedConcept(
    code: '35858006',
    displayName: 'Hyperuricemia',
    fullySpecifiedName: 'Hyperuricemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E79.0'],
  );

  static const SnomedConcept adrenalInsufficiency = SnomedConcept(
    code: '363686003',
    displayName: 'Adrenal insufficiency',
    fullySpecifiedName: 'Adrenal insufficiency (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['E27.40'],
  );

  // ==================== CARDIOVASCULAR ====================
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

  static const SnomedConcept atrialFlutter = SnomedConcept(
    code: '5370000',
    displayName: 'Atrial flutter',
    fullySpecifiedName: 'Atrial flutter (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I48.3'],
  );

  static const SnomedConcept heartFailure = SnomedConcept(
    code: '84114007',
    displayName: 'Heart failure',
    fullySpecifiedName: 'Heart failure (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I50.9'],
  );

  static const SnomedConcept heartFailureReducedEF = SnomedConcept(
    code: '99530004',
    displayName: 'Heart failure with reduced ejection fraction',
    fullySpecifiedName: 'Heart failure with reduced ejection fraction (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I50.22'],
  );

  static const SnomedConcept acuteMI = SnomedConcept(
    code: '57054005',
    displayName: 'Acute myocardial infarction',
    fullySpecifiedName: 'Acute myocardial infarction (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I21.9'],
  );

  static const SnomedConcept stableAngina = SnomedConcept(
    code: '21899001',
    displayName: 'Stable angina',
    fullySpecifiedName: 'Angina pectoris (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I25.10'],
  );

  static const SnomedConcept coronaryArteryDisease = SnomedConcept(
    code: '56265001',
    displayName: 'Coronary artery disease',
    fullySpecifiedName: 'Coronary artery disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I25.9'],
  );

  static const SnomedConcept peripheralArteryDisease = SnomedConcept(
    code: '399957001',
    displayName: 'Peripheral arterial disease',
    fullySpecifiedName: 'Peripheral arterial disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I73.9'],
  );

  static const SnomedConcept carotidStenosis = SnomedConcept(
    code: '429577009',
    displayName: 'Carotid artery stenosis',
    fullySpecifiedName: 'Carotid artery stenosis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I65.29'],
  );

  static const SnomedConcept aorticAneurysm = SnomedConcept(
    code: '233985008',
    displayName: 'Aortic aneurysm',
    fullySpecifiedName: 'Aortic aneurysm (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I71.9'],
  );

  static const SnomedConcept dvt = SnomedConcept(
    code: '128053003',
    displayName: 'Deep vein thrombosis',
    fullySpecifiedName: 'Deep vein thrombosis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I82.409'],
  );

  static const SnomedConcept pulmonaryEmbolism = SnomedConcept(
    code: '5929000',
    displayName: 'Pulmonary embolism',
    fullySpecifiedName: 'Pulmonary embolism (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I26.99'],
  );

  static const SnomedConcept varicoseVeins = SnomedConcept(
    code: '80004',
    displayName: 'Varicose veins',
    fullySpecifiedName: 'Varicose veins (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I83.90'],
  );

  // ==================== RESPIRATORY ====================
  static const SnomedConcept asthma = SnomedConcept(
    code: '195967001',
    displayName: 'Asthma',
    fullySpecifiedName: 'Asthma (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['J45.909'],
  );

  static const SnomedConcept copd = SnomedConcept(
    code: '13645005',
    displayName: 'Chronic obstructive pulmonary disease',
    fullySpecifiedName: 'Chronic obstructive pulmonary disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['J44.9'],
  );

  static const SnomedConcept chronicBronchitis = SnomedConcept(
    code: '6335009',
    displayName: 'Chronic bronchitis',
    fullySpecifiedName: 'Chronic bronchitis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['J42'],
  );

  static const SnomedConcept emphysema = SnomedConcept(
    code: '87433001',
    displayName: 'Pulmonary emphysema',
    fullySpecifiedName: 'Pulmonary emphysema (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['J43.9'],
  );

  static const SnomedConcept bronchiectasis = SnomedConcept(
    code: '122965006',
    displayName: 'Bronchiectasis',
    fullySpecifiedName: 'Bronchiectasis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['J47.9'],
  );

  static const SnomedConcept respiratoryFailure = SnomedConcept(
    code: '6571008',
    displayName: 'Respiratory failure',
    fullySpecifiedName: 'Respiratory failure (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['J96.90'],
  );

  static const SnomedConcept ards = SnomedConcept(
    code: '67782004',
    displayName: 'Acute respiratory distress syndrome',
    fullySpecifiedName: 'Acute respiratory distress syndrome (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['J80'],
  );

  static const SnomedConcept pneumonia = SnomedConcept(
    code: '233604007',
    displayName: 'Pneumonia',
    fullySpecifiedName: 'Pneumonia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['J18.9'],
  );

  static const SnomedConcept pleuralEffusion = SnomedConcept(
    code: '4378000',
    displayName: 'Pleural effusion',
    fullySpecifiedName: 'Pleural effusion (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['J91.8'],
  );

  // ==================== RENAL / KIDNEY ====================
  static const SnomedConcept acuteKidneyInjury = SnomedConcept(
    code: '14677001',
    displayName: 'Acute kidney injury',
    fullySpecifiedName: 'Acute kidney injury (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N17.9'],
  );

  static const SnomedConcept chronicKidneyDisease = SnomedConcept(
    code: '709044004',
    displayName: 'Chronic kidney disease',
    fullySpecifiedName: 'Chronic kidney disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N18.9'],
  );

  static const SnomedConcept ckdStage3 = SnomedConcept(
    code: '431857006',
    displayName: 'Chronic kidney disease stage 3',
    fullySpecifiedName: 'Chronic kidney disease stage 3 (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N18.3'],
  );

  static const SnomedConcept ckdStage4 = SnomedConcept(
    code: '431858001',
    displayName: 'Chronic kidney disease stage 4',
    fullySpecifiedName: 'Chronic kidney disease stage 4 (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N18.4'],
  );

  static const SnomedConcept ckdStage5 = SnomedConcept(
    code: '433951005',
    displayName: 'Chronic kidney disease stage 5',
    fullySpecifiedName: 'Chronic kidney disease stage 5 (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N18.5'],
  );

  static const SnomedConcept endStageRenalDisease = SnomedConcept(
    code: '46177005',
    displayName: 'End stage renal disease',
    fullySpecifiedName: 'End stage renal disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N18.6'],
  );

  static const SnomedConcept nephroticSyndrome = SnomedConcept(
    code: '5624001',
    displayName: 'Nephrotic syndrome',
    fullySpecifiedName: 'Nephrotic syndrome (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N04.9'],
  );

  static const SnomedConcept glomerulonephritis = SnomedConcept(
    code: '69618006',
    displayName: 'Glomerulonephritis',
    fullySpecifiedName: 'Glomerulonephritis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N05.9'],
  );

  static const SnomedConcept urinaryTractInfection = SnomedConcept(
    code: '68566003',
    displayName: 'Urinary tract infection',
    fullySpecifiedName: 'Urinary tract infection (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N39.0'],
  );

  static const SnomedConcept benignProstaticHyperplasia = SnomedConcept(
    code: '19978001',
    displayName: 'Benign prostatic hyperplasia',
    fullySpecifiedName: 'Benign prostatic hyperplasia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N40.1'],
  );

  static const SnomedConcept kidneyStone = SnomedConcept(
    code: '20365006',
    displayName: 'Kidney stone',
    fullySpecifiedName: 'Kidney stone (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['N20.9'],
  );

  // ==================== LIVER ====================
  static const SnomedConcept alcoholicLiverDisease = SnomedConcept(
    code: '235887005',
    displayName: 'Alcoholic liver disease',
    fullySpecifiedName: 'Alcoholic liver disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K70.30'],
  );

  static const SnomedConcept hepaticFailure = SnomedConcept(
    code: '37367000',
    displayName: 'Hepatic failure',
    fullySpecifiedName: 'Hepatic failure (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K72.90'],
  );

  static const SnomedConcept hepaticEncephalopathy = SnomedConcept(
    code: '27463000',
    displayName: 'Hepatic encephalopathy',
    fullySpecifiedName: 'Hepatic encephalopathy (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K72.91'],
  );

  static const SnomedConcept nafld = SnomedConcept(
    code: '197275002',
    displayName: 'Non-alcoholic fatty liver disease',
    fullySpecifiedName: 'Non-alcoholic fatty liver disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K76.0'],
  );

  static const SnomedConcept nash = SnomedConcept(
    code: '443761001',
    displayName: 'Non-alcoholic steatohepatitis',
    fullySpecifiedName: 'Non-alcoholic steatohepatitis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K76.0'],
  );

  static const SnomedConcept hepatitisB = SnomedConcept(
    code: '66099002',
    displayName: 'Hepatitis B',
    fullySpecifiedName: 'Hepatitis B (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['B18.1'],
  );

  static const SnomedConcept hepatitisC = SnomedConcept(
    code: '235935006',
    displayName: 'Hepatitis C',
    fullySpecifiedName: 'Hepatitis C (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['B18.2'],
  );

  static const SnomedConcept liverCirrhosis = SnomedConcept(
    code: '19943007',
    displayName: 'Cirrhosis of liver',
    fullySpecifiedName: 'Cirrhosis of liver (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K74.60'],
  );

  static const SnomedConcept portalHypertension = SnomedConcept(
    code: '281757004',
    displayName: 'Portal hypertension',
    fullySpecifiedName: 'Portal hypertension (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K76.6'],
  );

  static const SnomedConcept cholecystitis = SnomedConcept(
    code: '47605003',
    displayName: 'Cholecystitis',
    fullySpecifiedName: 'Cholecystitis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K81.0'],
  );

  static const SnomedConcept cholelithiasis = SnomedConcept(
    code: '14806000',
    displayName: 'Cholelithiasis',
    fullySpecifiedName: 'Cholelithiasis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K80.20'],
  );

  // ==================== BLOOD / HEMATOLOGY ====================
  static const SnomedConcept ironDeficiencyAnemia = SnomedConcept(
    code: '87532002',
    displayName: 'Iron deficiency anemia',
    fullySpecifiedName: 'Iron deficiency anemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D50.9'],
  );

  static const SnomedConcept vitaminB12Deficiency = SnomedConcept(
    code: '40108008',
    displayName: 'Vitamin B12 deficiency anemia',
    fullySpecifiedName: 'Vitamin B12 deficiency anemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D51.9'],
  );

  static const SnomedConcept folateDeficiencyAnemia = SnomedConcept(
    code: '63434000',
    displayName: 'Folate deficiency anemia',
    fullySpecifiedName: 'Folate deficiency anemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D52.9'],
  );

  static const SnomedConcept hemolyticAnemia = SnomedConcept(
    code: '53711006',
    displayName: 'Hemolytic anemia',
    fullySpecifiedName: 'Hemolytic anemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D59.9'],
  );

  static const SnomedConcept sickleCellDisease = SnomedConcept(
    code: '127654009',
    displayName: 'Sickle cell disease',
    fullySpecifiedName: 'Sickle cell disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D57.00'],
  );

  static const SnomedConcept thalassemia = SnomedConcept(
    code: '111324002',
    displayName: 'Thalassemia',
    fullySpecifiedName: 'Thalassemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D56.9'],
  );

  static const SnomedConcept aplasticAnemia = SnomedConcept(
    code: '14203004',
    displayName: 'Aplastic anemia',
    fullySpecifiedName: 'Aplastic anemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D61.9'],
  );

  static const SnomedConcept anemiaOfChronicDisease = SnomedConcept(
    code: '191309006',
    displayName: 'Anemia of chronic disease',
    fullySpecifiedName: 'Anemia of chronic disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D63.1'],
  );

  static const SnomedConcept neutropenia = SnomedConcept(
    code: '131114000',
    displayName: 'Neutropenia',
    fullySpecifiedName: 'Neutropenia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D70.9'],
  );

  static const SnomedConcept thrombocytopenia = SnomedConcept(
    code: '28929008',
    displayName: 'Thrombocytopenia',
    fullySpecifiedName: 'Thrombocytopenia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D69.6'],
  );

  static const SnomedConcept hemophilia = SnomedConcept(
    code: '127035006',
    displayName: 'Hemophilia',
    fullySpecifiedName: 'Hemophilia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D66'],
  );

  static const SnomedConcept vonWillebrandDisease = SnomedConcept(
    code: '86406008',
    displayName: "Von Willebrand's disease",
    fullySpecifiedName: "Von Willebrand's disease (disorder)",
    semanticTag: 'disorder',
    icd10Mappings: ['D68.0'],
  );

  static const SnomedConcept polycythemiaVera = SnomedConcept(
    code: '56727007',
    displayName: 'Polycythemia vera',
    fullySpecifiedName: 'Polycythemia vera (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['D45'],
  );

  // ==================== CANCER ====================
  static const SnomedConcept lungCancer = SnomedConcept(
    code: '363358000',
    displayName: 'Malignant tumor of lung',
    fullySpecifiedName: 'Malignant tumor of lung (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['C34.90'],
  );

  static const SnomedConcept breastCancer = SnomedConcept(
    code: '254837004',
    displayName: 'Malignant tumor of breast',
    fullySpecifiedName: 'Malignant tumor of breast (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['C50.919'],
  );

  static const SnomedConcept colonCancer = SnomedConcept(
    code: '363406005',
    displayName: 'Malignant tumor of colon',
    fullySpecifiedName: 'Malignant tumor of colon (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['C18.9'],
  );

  static const SnomedConcept prostateCancer = SnomedConcept(
    code: '254900004',
    displayName: 'Malignant tumor of prostate',
    fullySpecifiedName: 'Malignant tumor of prostate (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['C61'],
  );

  static const SnomedConcept pancreaticCancer = SnomedConcept(
    code: '367498001',
    displayName: 'Malignant tumor of pancreas',
    fullySpecifiedName: 'Malignant tumor of pancreas (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['C25.9'],
  );

  static const SnomedConcept leukemia = SnomedConcept(
    code: '88807004',
    displayName: 'Leukemia',
    fullySpecifiedName: 'Leukemia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['C95.90'],
  );

  static const SnomedConcept multipleMyeloma = SnomedConcept(
    code: '109989006',
    displayName: 'Multiple myeloma',
    fullySpecifiedName: 'Multiple myeloma (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['C90.00'],
  );

  static const SnomedConcept lymphoma = SnomedConcept(
    code: '118600007',
    displayName: 'Non-Hodgkin lymphoma',
    fullySpecifiedName: 'Non-Hodgkin lymphoma (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['C85.90'],
  );

  static const SnomedConcept melanoma = SnomedConcept(
    code: '254715000',
    displayName: 'Malignant melanoma',
    fullySpecifiedName: 'Malignant melanoma (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['C43.9'],
  );

  // ==================== MENTAL HEALTH ====================
  static const SnomedConcept majorDepression = SnomedConcept(
    code: '398044002',
    displayName: 'Major depression',
    fullySpecifiedName: 'Major depression disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F32.9'],
  );

  static const SnomedConcept majorDepressionRecurrent = SnomedConcept(
    code: '19485003',
    displayName: 'Major depressive disorder, recurrent',
    fullySpecifiedName: 'Major depressive disorder, recurrent (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F33.9'],
  );

  static const SnomedConcept dysthymia = SnomedConcept(
    code: '31095003',
    displayName: 'Dysthymia',
    fullySpecifiedName: 'Dysthymia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F34.1'],
  );

  static const SnomedConcept bipolarDisorder = SnomedConcept(
    code: '49083000',
    displayName: 'Bipolar disorder',
    fullySpecifiedName: 'Bipolar disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F31.9'],
  );

  static const SnomedConcept generalizedAnxiety = SnomedConcept(
    code: '48694002',
    displayName: 'Generalized anxiety disorder',
    fullySpecifiedName: 'Generalized anxiety disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F41.1'],
  );

  static const SnomedConcept panicDisorder = SnomedConcept(
    code: '57676003',
    displayName: 'Panic disorder',
    fullySpecifiedName: 'Panic disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F41.0'],
  );

  static const SnomedConcept socialAnxiety = SnomedConcept(
    code: '367498001',
    displayName: 'Social anxiety disorder',
    fullySpecifiedName: 'Social anxiety disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F40.10'],
  );

  static const SnomedConcept ptsd = SnomedConcept(
    code: '47505003',
    displayName: 'Post-traumatic stress disorder',
    fullySpecifiedName: 'Post-traumatic stress disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F43.10'],
  );

  static const SnomedConcept ocd = SnomedConcept(
    code: '33449004',
    displayName: 'Obsessive-compulsive disorder',
    fullySpecifiedName: 'Obsessive-compulsive disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F42.9'],
  );

  static const SnomedConcept adjustmentDisorder = SnomedConcept(
    code: '30608005',
    displayName: 'Adjustment disorder',
    fullySpecifiedName: 'Adjustment disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F43.9'],
  );

  static const SnomedConcept schizophrenia = SnomedConcept(
    code: '58214004',
    displayName: 'Schizophrenia',
    fullySpecifiedName: 'Schizophrenia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F20.9'],
  );

  static const SnomedConcept alcoholUseDisorder = SnomedConcept(
    code: '7200002',
    displayName: 'Alcohol use disorder',
    fullySpecifiedName: 'Alcohol use disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F10.20'],
  );

  static const SnomedConcept opioidUseDisorder = SnomedConcept(
    code: '231450006',
    displayName: 'Opioid use disorder',
    fullySpecifiedName: 'Opioid use disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F11.20'],
  );

  static const SnomedConcept autismSpectrumDisorder = SnomedConcept(
    code: '408856003',
    displayName: 'Autism spectrum disorder',
    fullySpecifiedName: 'Autism spectrum disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F84.0'],
  );

  static const SnomedConcept adhd = SnomedConcept(
    code: '406506008',
    displayName: 'Attention deficit hyperactivity disorder',
    fullySpecifiedName: 'Attention deficit hyperactivity disorder (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F90.9'],
  );

  static const SnomedConcept dementia = SnomedConcept(
    code: '52448006',
    displayName: 'Dementia',
    fullySpecifiedName: 'Dementia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['F03.90'],
  );

  static const SnomedConcept mildCognitiveImpairment = SnomedConcept(
    code: '391318001',
    displayName: 'Mild cognitive impairment',
    fullySpecifiedName: 'Mild cognitive impairment (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['F06.7'],
  );

  // ==================== NEUROLOGICAL ====================
  static const SnomedConcept stroke = SnomedConcept(
    code: '230690007',
    displayName: 'Stroke',
    fullySpecifiedName: 'Cerebrovascular accident (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['I64'],
  );

  static const SnomedConcept tia = SnomedConcept(
    code: '282825008',
    displayName: 'Transient ischemic attack',
    fullySpecifiedName: 'Transient ischemic attack (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['G45.9'],
  );

  static const SnomedConcept parkinsonDisease = SnomedConcept(
    code: '49049000',
    displayName: "Parkinson's disease",
    fullySpecifiedName: "Parkinson's disease (disorder)",
    semanticTag: 'disorder',
    icd10Mappings: ['G20'],
  );

  static const SnomedConcept alzheimerDisease = SnomedConcept(
    code: '26929004',
    displayName: "Alzheimer's disease",
    fullySpecifiedName: "Alzheimer's disease (disorder)",
    semanticTag: 'disorder',
    icd10Mappings: ['G30.9'],
  );

  static const SnomedConcept epilepsy = SnomedConcept(
    code: '84757009',
    displayName: 'Epilepsy',
    fullySpecifiedName: 'Epilepsy (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['G40.909'],
  );

  static const SnomedConcept peripheralNeuropathy = SnomedConcept(
    code: '3920002',
    displayName: 'Peripheral neuropathy',
    fullySpecifiedName: 'Peripheral neuropathy (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['G62.9'],
  );

  static const SnomedConcept migraine = SnomedConcept(
    code: '37796009',
    displayName: 'Migraine',
    fullySpecifiedName: 'Migraine (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['G43.909'],
  );

  // ==================== PAIN CONDITIONS ====================
  static const SnomedConcept abdominalPain = SnomedConcept(
    code: '21522001',
    displayName: 'Abdominal pain',
    fullySpecifiedName: 'Abdominal pain (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R10.9'],
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

  static const SnomedConcept lowBackPain = SnomedConcept(
    code: '279039007',
    displayName: 'Low back pain',
    fullySpecifiedName: 'Low back pain (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['M54.5'],
  );

  static const SnomedConcept chronicPain = SnomedConcept(
    code: '82423001',
    displayName: 'Chronic pain',
    fullySpecifiedName: 'Chronic pain (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['G89.29'],
  );

  // ==================== GASTROINTESTINAL ====================
  static const SnomedConcept gerd = SnomedConcept(
    code: '396275008',
    displayName: 'Gastro-esophageal reflux disease',
    fullySpecifiedName: 'Gastro-esophageal reflux disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K21.0'],
  );

  static const SnomedConcept gastritis = SnomedConcept(
    code: '45305002',

    displayName: 'Gastritis',
    fullySpecifiedName: 'Gastritis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K29.70'],
  );

  static const SnomedConcept pepticUlcer = SnomedConcept(
    code: '13200003',
    displayName: 'Peptic ulcer',
    fullySpecifiedName: 'Peptic ulcer (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K27.9'],
  );

  static const SnomedConcept irritableBowelSyndrome = SnomedConcept(
    code: '10743008',
    displayName: 'Irritable bowel syndrome',
    fullySpecifiedName: 'Irritable bowel syndrome (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K58.9'],
  );

  static const SnomedConcept inflammatoryBowelDisease = SnomedConcept(
    code: '192630005',
    displayName: 'Crohn disease',
    fullySpecifiedName: 'Crohn disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K50.90'],
  );

  static const SnomedConcept ulcerativeColitis = SnomedConcept(
    code: '64766004',
    displayName: 'Ulcerative colitis',
    fullySpecifiedName: 'Ulcerative colitis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K51.90'],
  );

  static const SnomedConcept pancreatitis = SnomedConcept(
    code: '75694006',
    displayName: 'Pancreatitis',
    fullySpecifiedName: 'Pancreatitis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K85.90'],
  );

  static const SnomedConcept diverticulosis = SnomedConcept(
    code: '259018006',
    displayName: 'Diverticular disease',
    fullySpecifiedName: 'Diverticular disease (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['K57.90'],
  );

  // ==================== MUSCULOSKELETAL ====================
  static const SnomedConcept osteoarthritis = SnomedConcept(
    code: '396275006',
    displayName: 'Osteoarthritis',
    fullySpecifiedName: 'Osteoarthritis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['M19.90'],
  );

  static const SnomedConcept rheumatoidArthritis = SnomedConcept(
    code: '3723001',
    displayName: 'Rheumatoid arthritis',
    fullySpecifiedName: 'Rheumatoid arthritis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['M06.9'],
  );

  static const SnomedConcept lupus = SnomedConcept(
    code: '55464009',
    displayName: 'Systemic lupus erythematosus',
    fullySpecifiedName: 'Systemic lupus erythematosus (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['M32.9'],
  );

  static const SnomedConcept fibromyalgia = SnomedConcept(
    code: '95417006',
    displayName: 'Fibromyalgia',
    fullySpecifiedName: 'Fibromyalgia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['M79.7'],
  );

  static const SnomedConcept osteoporosis = SnomedConcept(
    code: '282026002',
    displayName: 'Osteoporosis',
    fullySpecifiedName: 'Osteoporosis (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['M81.0'],
  );

  static const SnomedConcept gout = SnomedConcept(
    code: '90560007',
    displayName: 'Gout',
    fullySpecifiedName: 'Gout (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['M10.9'],
  );

  // ==================== SYMPTOMS / FINDINGS ====================
  static const SnomedConcept fatigue = SnomedConcept(
    code: '84229001',
    displayName: 'Fatigue',
    fullySpecifiedName: 'Fatigue (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R53.83'],
  );

  static const SnomedConcept dizziness = SnomedConcept(
    code: '404640003',
    displayName: 'Dizziness',
    fullySpecifiedName: 'Dizziness (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R42'],
  );

  static const SnomedConcept insomnia = SnomedConcept(
    code: '193462001',
    displayName: 'Insomnia',
    fullySpecifiedName: 'Insomnia (disorder)',
    semanticTag: 'disorder',
    icd10Mappings: ['G47.00'],
  );

  static const SnomedConcept dyspnea = SnomedConcept(
    code: '267036007',
    displayName: 'Dyspnea',
    fullySpecifiedName: 'Dyspnea (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R06.02'],
  );

  static const SnomedConcept cough = SnomedConcept(
    code: '49727002',
    displayName: 'Cough',
    fullySpecifiedName: 'Cough (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R05.9'],
  );

  static const SnomedConcept nausea = SnomedConcept(
    code: '422587007',
    displayName: 'Nausea',
    fullySpecifiedName: 'Nausea (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R11.0'],
  );

  static const SnomedConcept fever = SnomedConcept(
    code: '386661006',
    displayName: 'Fever',
    fullySpecifiedName: 'Fever (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R50.9'],
  );

  static const SnomedConcept jaundice = SnomedConcept(
    code: '18121001',
    displayName: 'Jaundice',
    fullySpecifiedName: 'Jaundice (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R17'],
  );

  static const SnomedConcept weightLoss = SnomedConcept(
    code: '39447000',
    displayName: 'Weight loss',
    fullySpecifiedName: 'Weight loss (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R63.4'],
  );

  static const SnomedConcept confusion = SnomedConcept(
    code: '40917000',
    displayName: 'Confusion',
    fullySpecifiedName: 'Confusion (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R41.0'],
  );

  static const SnomedConcept syncope = SnomedConcept(
    code: '271595007',
    displayName: 'Syncope',
    fullySpecifiedName: 'Syncope (finding)',
    semanticTag: 'finding',
    icd10Mappings: ['R55.9'],
  );

  // ==================== LAB OBSERVATIONS ====================
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

  static const SnomedConcept egfrMeasurement = SnomedConcept(
    code: '447842003',
    displayName: 'Glomerular filtration rate measurement',
    fullySpecifiedName: 'Glomerular filtration rate measurement (procedure)',
    semanticTag: 'procedure',
    loincMappings: ['69405-6'],
  );

  static const SnomedConcept altMeasurement = SnomedConcept(
    code: '89381001',
    displayName: 'Alanine aminotransferase measurement',
    fullySpecifiedName: 'Alanine aminotransferase measurement (procedure)',
    semanticTag: 'procedure',
    loincMappings: ['1742-6'],
  );

  static const SnomedConcept astMeasurement = SnomedConcept(
    code: '89640001',
    displayName: 'Aspartate aminotransferase measurement',
    fullySpecifiedName: 'Aspartate aminotransferase measurement (procedure)',
    semanticTag: 'procedure',
    loincMappings: ['1920-8'],
  );

  static const SnomedConcept tshMeasurement = SnomedConcept(
    code: '301665001',
    displayName: 'Thyroid stimulating hormone measurement',
    fullySpecifiedName: 'Thyroid stimulating hormone measurement (procedure)',
    semanticTag: 'procedure',
    loincMappings: ['3016-3'],
  );

  static const SnomedConcept crpMeasurement = SnomedConcept(
    code: '313790008',
    displayName: 'C-reactive protein measurement',
    fullySpecifiedName: 'C-reactive protein measurement (procedure)',
    semanticTag: 'procedure',
    loincMappings: ['1988-5'],
  );

  static const SnomedConcept vitaminDMeasurement = SnomedConcept(
    code: '313814000',
    displayName: 'Vitamin D measurement',
    fullySpecifiedName: 'Vitamin D measurement (procedure)',
    semanticTag: 'procedure',
    loincMappings: ['1989-3'],
  );

  static const SnomedConcept troponinMeasurement = SnomedConcept(
    code: '33747003',
    displayName: 'Troponin measurement',
    fullySpecifiedName: 'Troponin measurement (procedure)',
    semanticTag: 'procedure',
    loincMappings: ['6598-7'],
  );

  // ==================== ALL ====================
  static const List<SnomedConcept> all = [
    // Endocrine
    diabetesType1, diabetesType2, gestationalDiabetes, diabeticKetoacidosis,
    diabeticNephropathy, diabeticRetinopathy, diabeticNeuropathy,
    hyperthyroidism, hypothyroidism, hashimotoThyroiditis, gravesDisease,
    obesity, metabolicSyndrome, hypercholesterolemia, hypertriglyceridemia,
    hyperuricemia, adrenalInsufficiency,
    // Cardiovascular
    hypertension, atrialFibrillation, atrialFlutter, heartFailure,
    heartFailureReducedEF, acuteMI, stableAngina, coronaryArteryDisease,
    peripheralArteryDisease, carotidStenosis, aorticAneurysm,
    dvt, pulmonaryEmbolism, varicoseVeins,
    // Respiratory
    asthma, copd, chronicBronchitis, emphysema, bronchiectasis,
    respiratoryFailure, ards, pneumonia, pleuralEffusion,
    // Renal
    acuteKidneyInjury, chronicKidneyDisease, ckdStage3, ckdStage4, ckdStage5,
    endStageRenalDisease, nephroticSyndrome, glomerulonephritis,
    urinaryTractInfection, benignProstaticHyperplasia, kidneyStone,
    // Liver
    alcoholicLiverDisease, hepaticFailure, hepaticEncephalopathy,
    nafld, nash, hepatitisB, hepatitisC, liverCirrhosis,
    portalHypertension, cholecystitis, cholelithiasis,
    // Blood
    ironDeficiencyAnemia, vitaminB12Deficiency, folateDeficiencyAnemia,
    hemolyticAnemia, sickleCellDisease, thalassemia, aplasticAnemia,
    anemiaOfChronicDisease, neutropenia, thrombocytopenia,
    hemophilia, vonWillebrandDisease, polycythemiaVera,
    // Cancer
    lungCancer, breastCancer, colonCancer, prostateCancer,
    pancreaticCancer, leukemia, multipleMyeloma, lymphoma, melanoma,
    // Mental health
    majorDepression, majorDepressionRecurrent, dysthymia, bipolarDisorder,
    generalizedAnxiety, panicDisorder, socialAnxiety, ptsd, ocd,
    adjustmentDisorder, schizophrenia, alcoholUseDisorder, opioidUseDisorder,
    autismSpectrumDisorder, adhd, dementia, mildCognitiveImpairment,
    // Neurological
    stroke, tia, parkinsonDisease, alzheimerDisease, epilepsy,
    peripheralNeuropathy, migraine,
    // Pain
    abdominalPain, chestPain, headache, lowBackPain, chronicPain,
    // GI
    gerd, gastritis, pepticUlcer, irritableBowelSyndrome,
    inflammatoryBowelDisease, ulcerativeColitis, pancreatitis, diverticulosis,
    // MSK
    osteoarthritis, rheumatoidArthritis, lupus, fibromyalgia,
    osteoporosis, gout,
    // Symptoms
    fatigue, dizziness, insomnia, dyspnea, cough, nausea,
    fever, jaundice, weightLoss, confusion, syncope,
    // Lab observations
    hemoglobinA1c, glucoseMeasurement, egfrMeasurement, altMeasurement,
    astMeasurement, tshMeasurement, crpMeasurement, vitaminDMeasurement,
    troponinMeasurement,
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

  /// Find by LOINC code
  static SnomedConcept? findByLoinc(String loincCode) {
    try {
      return all.firstWhere((c) => c.loincMappings.contains(loincCode));
    } catch (_) {
      return null;
    }
  }

  /// Find by semantic tag
  static List<SnomedConcept> findByTag(String tag) {
    return all.where((c) => c.semanticTag == tag).toList();
  }
}
