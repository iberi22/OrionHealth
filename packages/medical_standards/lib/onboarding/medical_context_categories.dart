/// Medical context categories that can be selectively downloaded.
///
/// Each category maps to specific ICD-10 codes, LOINC labs, and medication
/// classes. Only the categories relevant to a user's profile are downloaded,
/// reducing the data footprint from ~3GB to ~50-200MB per user.

import '../icd10/icd10.dart';
import '../loinc/loinc.dart';
import '../medications/medications.dart';
import '../guidelines/guidelines.dart';

/// Medical context categories that can be selectively downloaded
enum MedicalContextCategory {
  preventive, // Everyone gets this — vaccines, screenings
  diabetes,
  cardiovascular,
  respiratory,
  thyroid,
  renal,
  hepatic,
  hematology,
  oncology,
  mentalHealth,
  infectious,
  musculoskeletal,
  gastrointestinal,
  neurology,
  dermatology,
  pediatrics,
  womensHealth,
  mensHealth,
  geriatrics,
  emergency,
}

/// Holds the result of profile analysis: which categories + priority tiers
class RelevantStandards {
  /// Categories that should be downloaded
  final Set<MedicalContextCategory> categories;

  /// Tiers for progress reporting: tier1 = immediate, tier2 = background
  final Set<MedicalContextCategory> tier1; // Download immediately
  final Set<MedicalContextCategory> tier2; // Download in background

  final Set<String> icd10Codes;
  final Set<String> loincCodes;
  final Set<String> medicationClasses;
  final List<String> guidelineIds;
  final int estimatedSizeMB;

  const RelevantStandards({
    required this.categories,
    required this.tier1,
    required this.tier2,
    this.icd10Codes = const {},
    this.loincCodes = const {},
    this.medicationClasses = const {},
    this.guidelineIds = const [],
    this.estimatedSizeMB = 0,
  });

  /// Empty result with only preventive care
  factory RelevantStandards.minimal() => RelevantStandards(
        categories: {MedicalContextCategory.preventive},
        tier1: {MedicalContextCategory.preventive},
        tier2: {},
        icd10Codes: CategoryIcd10.forCategory(MedicalContextCategory.preventive),
        loincCodes: CategoryLoinc.forCategory(MedicalContextCategory.preventive),
        medicationClasses: CategoryMedications.forCategory(MedicalContextCategory.preventive),
        estimatedSizeMB: 10,
      );

  bool get isEmpty => categories.isEmpty;
  int get totalCategories => categories.length;
}

/// Maps categories to relevant ICD-10 codes (code strings)
class CategoryIcd10 {
  static const Map<MedicalContextCategory, Set<String>> codes = {
    MedicalContextCategory.preventive: {
      'Z00.00', // General adult medical exam
      'Z00.01', // Encounter for general adult medical examination with abnormal findings
      'Z23', // Encounter for immunization
      'Z71.3', // Dietary counseling
      'Z79.4', // Long term insulin use
      'Z87.891', // Personal history of nicotine dependence
      'Z12.31', // Encounter for screening mammogram
      'Z12.11', // Encounter for colonoscopy
      'Z13.220', // Encounter for screening for malignant neoplasm of colon
    },
    MedicalContextCategory.diabetes: {
      'E10', 'E10.1', 'E10.21', 'E10.31', 'E10.4', 'E10.5', 'E10.9',
      'E11', 'E11.00', 'E11.21', 'E11.31', 'E11.4', 'E11.51', 'E11.9',
      'E08', 'E09', 'E13', 'E14',
      'R73.03', // Prediabetes
      'R73.09', // Other abnormal glucose
    },
    MedicalContextCategory.cardiovascular: {
      'I10', 'I11.9', 'I16.1',
      'I48.91', 'I48.3', 'I48.4',
      'I50.9', 'I50.22', 'I50.30',
      'I21.9', 'I21.3', 'I22.9',
      'I25.10', 'I25.9', 'I25.00',
      'I73.9', 'I65.29', 'I71.9', 'I71.00',
      'I83.90', 'I89.0',
      'I80.10', // DVT
      'I26.99', // Pulmonary embolism
      'I80.20', 'I80.10', 'I82.409',
    },
    MedicalContextCategory.respiratory: {
      'J40', 'J41.0', 'J41.1', 'J41.8', 'J42',
      'J43.9', 'J43.8', 'J44.0', 'J44.1',
      'J45.909', 'J45.41', 'J45.20', 'J45.30', 'J45.5',
      'J47.9',
      'J18.9', 'J12.89', 'J96.90', 'J80',
      'J91.8', 'J93.9',
    },
    MedicalContextCategory.thyroid: {
      'E03.9', 'E03.0', 'E03.1', 'E03.2',
      'E05.90', 'E05.00', 'E05.10', 'E05.20',
      'E04.9', 'E04.0', 'E04.1', 'E04.2',
      'C73', // Thyroid cancer
      'E07.9', // Thyroid disorder NOS
    },
    MedicalContextCategory.renal: {
      'N17.9', 'N17.0', 'N00.9',
      'N18.9', 'N18.1', 'N18.2', 'N18.3', 'N18.4', 'N18.5', 'N18.6',
      'N04.9', 'N39.0',
      'N40.1', 'N23', 'N13.9',
      'N05.9', 'N20.9',
      'E87.5', // Hyperkalemia
      'E87.6', // Hypokalemia
    },
    MedicalContextCategory.hepatic: {
      'K70.30', 'K70.0', 'K70.1', 'K70.2',
      'K72.90', 'K72.10', 'K72.91',
      'K76.0', // NAFLD/NASH
      'K76.6', // Portal hypertension
      'B18.1', // HBV
      'B18.2', // HCV
      'B15.9', // HAV
      'K74.60', // Cirrhosis
      'K81.0', 'K80.20',
      'K76.82', 'K76.89',
    },
    MedicalContextCategory.hematology: {
      'D50.9', 'D50.0',
      'D51.9', 'D52.9',
      'D59.9', 'D57.00', 'D56.9',
      'D61.9', 'D61.818',
      'D63.1', 'D63.0', // Anemia in CKD / malignancy
      'D70.9', // Neutropenia
      'D69.6', // Thrombocytopenia
      'D68.9', 'D66', 'D68.0', // Coagulation
      'D45', // Polycythemia vera
      'D47.3', // Thrombocythemia
    },
    MedicalContextCategory.oncology: {
      'C79.9', // Secondary malignancy
      'C34.90', // Lung cancer
      'C50.919', // Breast cancer
      'C18.9', // Colon cancer
      'C61', // Prostate cancer
      'C43.9', // Melanoma
      'C61', // Prostate
      'C56.9', // Ovarian
      'C64.9', // Renal cell
      'C22.0', // Hepatocellular carcinoma
      'C25.9', // Pancreatic
    },
    MedicalContextCategory.mentalHealth: {
      'F32.9', 'F33.9', // Depression
      'F41.1', 'F41.9', // Anxiety
      'F17.210', // Nicotine dependence
      'F10.20', // Alcohol use disorder
      'F11.20', // Opioid use disorder
      'F20.9', // Schizophrenia
      'F31.9', // Bipolar
      'F90.9', // ADHD
      'F43.10', // PTSD
      'G47.00', // Insomnia
    },
    MedicalContextCategory.infectious: {
      'A41.9', // Sepsis
      'J18.9', // Pneumonia
      'N39.0', // UTI
      'K81.0', // Cholecystitis
      'L03.90', // Cellulitis
      'A09', // Infectious gastroenteritis
      'B34.9', // Viral infection NOS
      'J02.9', // Pharyngitis
      'J03.90', // Tonsillitis
    },
    MedicalContextCategory.musculoskeletal: {
      'M54.5', // Low back pain
      'M54.2', // Cervical pain
      'M25.50', // Joint pain
      'M79.3', // Panniculitis
      'M06.9', // Rheumatoid arthritis
      'M15.9', // Osteoarthritis
      'M81.0', // Osteoporosis
      'M10.9', // Gout
      'M75.100', // Shoulder pain
      'M77.9', // Tendinitis
    },
    MedicalContextCategory.gastrointestinal: {
      'K21.9', // GERD
      'K29.70', // Gastritis
      'K58.9', // IBS
      'K59.00', // Constipation
      'K63.5', // Polyp
      'K50.90', // Crohn's
      'K51.90', // Ulcerative colitis
      'K57.90', // Diverticulosis
    },
    MedicalContextCategory.neurology: {
      'G43.909', // Migraine
      'G47.00', // Insomnia
      'G20', // Parkinson's
      'G30.9', // Alzheimer's
      'G35', // MS
      'G40.909', // Epilepsy
      'I63.9', // Stroke
      'G62.9', // Neuropathy
    },
    MedicalContextCategory.dermatology: {
      'L40.9', // Psoriasis
      'L20.9', // Atopic dermatitis
      'L50.9', // Urticaria
      'L70.0', // Acne
      'B07.9', // Warts
      'L03.90', // Cellulitis
      'C43.9', // Melanoma
      'L02.90', // Abscess
    },
    MedicalContextCategory.pediatrics: {
      'J45.909', // Asthma
      'E30.0', // Delayed puberty
      'F90.9', // ADHD
      'R62.50', // Lack of expected normal physiological development
    },
    MedicalContextCategory.womensHealth: {
      'N92.6', // Irregular menstruation
      'N80.9', // Endometriosis
      'N84.1', // Polyps
      'C56.9', // Ovarian cancer
      'C50.919', // Breast cancer
      'O80', // Delivery
      'Z34.00', // Pregnancy supervision
    },
    MedicalContextCategory.mensHealth: {
      'N40.1', // BPH
      'C61', // Prostate cancer
      'E29.1', // Hypogonadism
      'Z90.79', // Acquired absence of testis
    },
    MedicalContextCategory.geriatrics: {
      'M81.0', // Osteoporosis
      'G30.9', // Alzheimer's
      'I50.9', // Heart failure
      'N18.9', // CKD
      'J44.9', // COPD
      'Z87.891', // History of nicotine
    },
    MedicalContextCategory.emergency: {
      'I21.9', // AMI
      'I63.9', // Stroke
      'R07.9', // Chest pain
      'R10.9', // Abdominal pain
      'R50.9', // Fever
      'J96.00', // Respiratory failure
      'R55', // Syncope
    },
  };

  /// Get all ICD-10 codes for a category
  static Set<String> forCategory(MedicalContextCategory cat) =>
      codes[cat] ?? {};
}

/// Maps categories to relevant LOINC lab codes
class CategoryLoinc {
  static const Map<MedicalContextCategory, Set<String>> codes = {
    MedicalContextCategory.preventive: {
      '2345-7', // Glucose
      '4548-4', // HbA1c
      '2093-3', // Total cholesterol
      '13457-7', // LDL
      '2085-9', // HDL
      '2571-8', // Triglycerides
      '718-7', // Hemoglobin
      '6690-2', // WBC
      '777-3', // Platelets
      '2160-0', // Creatinine
      '3094-0', // BUN
    },
    MedicalContextCategory.diabetes: {
      '2345-7', // Glucose
      '4548-4', // HbA1c
      '2339-0', // Glucose [60-90 fasting]
      '17861-6', // Glucose 2hr post meal
      '2160-0', // Creatinine
      '3094-0', // BUN
      '13457-7', // LDL
      '2571-8', // Triglycerides
      '2085-9', // HDL
      '2823-3', // Potassium
      '2951-2', // Sodium
    },
    MedicalContextCategory.cardiovascular: {
      '2093-3', // Total cholesterol
      '13457-7', // LDL
      '2085-9', // HDL
      '2571-8', // Triglycerides
      '718-7', // Hemoglobin
      '2160-0', // Creatinine
      '3094-0', // BUN
      '2951-2', // Sodium
      '2823-3', // Potassium
      '30522-7', // Troponin
      '42757-5', // NT-proBNP
      '3255-7', // INR
    },
    MedicalContextCategory.respiratory: {
      '1989-3', // ABG pO2
      '1994-3', // ABG pCO2
      '2744-1', // pH
      '6309-6', // O2 saturation
      '2975-0', // FEV1
      '19869-1', // FVC
    },
    MedicalContextCategory.thyroid: {
      '3016-3', // TSH
      '3026-2', // Free T4
      '3023-9', // Total T3
      '30522-7', // T3 uptake
    },
    MedicalContextCategory.renal: {
      '2160-0', // Creatinine
      '3094-0', // BUN
      '2276-4', // Ferritin
      '2508-8', // Iron
      '2502-1', // Iron saturation
      '2951-2', // Sodium
      '2823-3', // Potassium
      '3094-0', // BUN
      '44784-7', // eGFR
      '47563-4', // Urine protein
    },
    MedicalContextCategory.hepatic: {
      '1975-2', // Total bilirubin
      '6768-6', // ALT
      '1742-6', // ALT
      '1920-8', // AST
      '2532-0', // ALP
      '1979-4', // GGT
      '2208-8', // Albumin
      '3094-0', // BUN (for hepatorenal)
    },
    MedicalContextCategory.hematology: {
      '718-7', // Hemoglobin
      '4544-3', // Hematocrit
      '6690-2', // WBC
      '777-3', // Platelets
      '2276-4', // Ferritin
      '2508-8', // Iron
      '2502-1', // Iron saturation
      '32623-1', // Vitamin B12
      '2280-6', // Folate
      '3255-7', // INR
      '42757-5', // NT-proBNP (for anemia of heart failure)
    },
    MedicalContextCategory.oncology: {
      '718-7', // Hemoglobin
      '777-3', // Platelets
      '6690-2', // WBC
      '4544-3', // Hematocrit
      '1975-2', // Total bilirubin
      '6768-6', // ALT
      '1920-8', // AST
      '2160-0', // Creatinine
      // Tumor markers
      '2857-1', // CEA
      '10509-5', // CA 125
      '24110-5', // CA 19-9
    },
    MedicalContextCategory.mentalHealth: {
      '2345-7', // Glucose
      '4548-4', // HbA1c (screen metabolic causes)
      '2160-0', // Creatinine (renal causes)
      '2951-2', // Sodium
      '2823-3', // Potassium
      '1946-3', // TSH
    },
    MedicalContextCategory.musculoskeletal: {
      '1989-3', // Vitamin D
      '1988-5', // Calcium
      '2838-9', // Phosphorus
      '6768-6', // ALT (for methotrexate monitoring)
      '2160-0', // Creatinine (for NSAIDs)
    },
  };

  static Set<String> forCategory(MedicalContextCategory cat) =>
      codes[cat] ?? {};
}

/// Maps categories to relevant medication drug classes
class CategoryMedications {
  static const Map<MedicalContextCategory, Set<String>> drugClasses = {
    MedicalContextCategory.preventive: {
      'Vaccine',
      'Analgesic',
    },
    MedicalContextCategory.diabetes: {
      'Biguanide',
      'Sulfonylurea',
      'Meglitinide',
      'Thiazolidinedione',
      'DPP-4 Inhibitor',
      'GLP-1 Receptor Agonist',
      'SGLT2 Inhibitor',
      'Long-acting Insulin',
      'Short-acting Insulin',
      'Intermediate-acting Insulin',
      'Alpha-glucosidase Inhibitor',
    },
    MedicalContextCategory.cardiovascular: {
      'ACE Inhibitor',
      'ARB',
      'Calcium Channel Blocker',
      'Beta Blocker',
      'Diuretic',
      'Statin',
      'Anticoagulant',
      'Antiplatelet',
      'Nitrate',
      'Vasodilator',
      'Antiarrhythmic',
    },
    MedicalContextCategory.respiratory: {
      'Beta-2 Agonist',
      'Inhaled Corticosteroid',
      'Anticholinergic',
      'Leukotriene Inhibitor',
      'Methylxanthine',
      'Mucolytic',
    },
    MedicalContextCategory.thyroid: {
      'Thyroid Hormone',
      'Antithyroid',
    },
    MedicalContextCategory.renal: {
      'Diuretic',
      'ACE Inhibitor',
      'ARB',
      'Phosphate Binder',
      'Vitamin D Analog',
      'Erythropoiesis Stimulating Agent',
    },
    MedicalContextCategory.hepatic: {
      'Hepatoprotective',
      'Antiviral',
      'Diuretic',
    },
    MedicalContextCategory.hematology: {
      'Iron Supplement',
      'Vitamin B12',
      'Folate',
      'Erythropoiesis Stimulating Agent',
      'Anticoagulant',
    },
    MedicalContextCategory.oncology: {
      'Chemotherapy',
      'Targeted Therapy',
      'Immunotherapy',
      'Hormone Therapy',
      'Supportive Care',
    },
    MedicalContextCategory.mentalHealth: {
      'SSRI',
      'SNRI',
      'Tricyclic Antidepressant',
      'Benzodiazepine',
      'Non-benzodiazepine Hypnotic',
      'Antipsychotic',
      'Mood Stabilizer',
      'ADHD Medication',
    },
    MedicalContextCategory.infectious: {
      'Antibiotic',
      'Antiviral',
      'Antifungal',
      'Antiparasitic',
    },
    MedicalContextCategory.musculoskeletal: {
      'NSAID',
      'Acetaminophen',
      'Opioid Analgesic',
      'Muscle Relaxant',
      'DMARD',
      'Biologic',
      'Bisphosphonate',
      'Allopurinol',
      'Colchicine',
    },
    MedicalContextCategory.gastrointestinal: {
      'Proton Pump Inhibitor',
      'H2 Blocker',
      'Antacid',
      'Laxative',
      'Antidiarrheal',
      '5-ASA',
      'Antispasmodic',
    },
  };

  static Set<String> forCategory(MedicalContextCategory cat) =>
      drugClasses[cat] ?? {};
}
