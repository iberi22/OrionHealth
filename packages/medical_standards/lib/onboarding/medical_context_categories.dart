/// Medical context categories for selective sync
///
/// These categories determine which medical standards are
/// downloaded and kept local based on user profile.

/// Categories of medical context
enum MedicalContextCategory {
  /// Everyone gets preventive care (vaccines, screenings)
  preventive,
  
  /// Diabetes (Type 1, Type 2, gestational)
  diabetes,
  
  /// Cardiovascular diseases (hypertension, heart disease, etc.)
  cardiovascular,
  
  /// Respiratory conditions (asthma, COPD, etc.)
  respiratory,
  
  /// Thyroid disorders (hypo/hyperthyroidism)
  thyroid,
  
  /// Kidney/renal conditions
  renal,
  
  /// Liver conditions
  hepatic,
  
  /// Blood disorders (anemia, clotting issues)
  hematology,
  
  /// Cancer - screening and monitoring
  oncology,
  
  /// Mental health (depression, anxiety, etc.)
  mentalHealth,
  
  /// Infectious diseases
  infectious,
  
  /// Bone and joint conditions
  musculoskeletal,
  
  /// Digestive/GI conditions
  gastrointestinal,
  
  /// Eye conditions
  ophthalmology,
  
  /// Neurological conditions
  neurology,
  
  /// Allergies and immunology
  immunology,
}

/// Maps categories to relevant ICD-10 code prefixes
class CategoryIcd10Mapping {
  static const Map<MedicalContextCategory, List<String>> icd10Prefixes = {
    MedicalContextCategory.preventive: ['Z00', 'Z01', 'Z02', 'Z23', 'Z71'],
    MedicalContextCategory.diabetes: ['E10', 'E11', 'E12', 'E13', 'O24'],
    MedicalContextCategory.cardiovascular: ['I10', 'I11', 'I20', 'I21', 'I25', 'I48', 'I50', 'I63', 'I64'],
    MedicalContextCategory.respiratory: ['J40', 'J41', 'J42', 'J43', 'J44', 'J45', 'J46', 'J47'],
    MedicalContextCategory.thyroid: ['E03', 'E04', 'E05'],
    MedicalContextCategory.renal: ['N17', 'N18', 'N19', 'N25'],
    MedicalContextCategory.hepatic: ['K70', 'K71', 'K72', 'K73', 'K74', 'K75', 'K76', 'K77'],
    MedicalContextCategory.hematology: ['D50', 'D51', 'D52', 'D53', 'D55', 'D56', 'D57', 'D58', 'D59', 'D60', 'D61', 'D62', 'D63', 'D64'],
    MedicalContextCategory.oncology: ['C00', 'C01', 'C02', 'C03', 'C43', 'C50', 'C53', 'C54', 'C55', 'C56', 'C61', 'C64', 'C65', 'C66', 'C67', 'C68', 'C69', 'D03'],
    MedicalContextCategory.mentalHealth: ['F31', 'F32', 'F33', 'F34', 'F38', 'F39', 'F40', 'F41', 'F42', 'F43', 'F44', 'F45', 'F48'],
    MedicalContextCategory.infectious: ['A00', 'A01', 'A02', 'A09', 'B00', 'B01', 'B02', 'B05', 'B06', 'B15', 'B16', 'B17', 'B18', 'B20', 'B34'],
    MedicalContextCategory.musculoskeletal: ['M05', 'M06', 'M07', 'M10', 'M15', 'M16', 'M17', 'M19', 'M20', 'M21', 'M22', 'M23', 'M25', 'M54'],
    MedicalContextCategory.gastrointestinal: ['K20', 'K21', 'K25', 'K26', 'K27', 'K28', 'K29', 'K30', 'K50', 'K51', 'K52', 'K58', 'K59', 'K63', 'K70'],
    MedicalContextCategory.ophthalmology: ['H10', 'H11', 'H25', 'H26', 'H27', 'H30', 'H33', 'H34', 'H35', 'H40', 'H42'],
    MedicalContextCategory.neurology: ['G20', 'G30', 'G35', 'G40', 'G41', 'G43', 'G44', 'G45', 'G47', 'G50', 'G51', 'G52', 'G53', 'G54', 'G55', 'G56', 'G57', 'G58', 'G59', 'G60', 'G61', 'G62', 'G63', 'G64', 'G65', 'G70', 'G71', 'G72', 'G73', 'G80', 'G81', 'G82', 'G83', 'G89', 'G90', 'G91', 'G92', 'G93', 'G94', 'G95', 'G96', 'G97', 'G98', 'G99'],
    MedicalContextCategory.immunology: ['J30', 'J31', 'J45', 'J46', 'L20', 'L23', 'L24', 'L25', 'L27', 'L28', 'L30', 'L50', 'L51', 'L52', 'L53'],
  };

  static List<String> getIcd10Prefixes(Set<MedicalContextCategory> categories) {
    final prefixes = <String>[];
    for (final category in categories) {
      prefixes.addAll(icd10Prefixes[category] ?? []);
    }
    return prefixes;
  }
}

/// Maps categories to relevant LOINC code prefixes
class CategoryLoincMapping {
  static const Map<MedicalContextCategory, List<String>> loincCodes = {
    MedicalContextCategory.preventive: ['718-7', '2334-0', '4544-3', '6690-2', '777-3', '2951-2', '2823-3', '2160-0', '3094-0'],
    MedicalContextCategory.diabetes: ['4548-4', '2345-7', '2334-0', '2085-9', '2571-8', '2093-3', '13457-7'],
    MedicalContextCategory.cardiovascular: ['85354-9', '8480-6', '8462-4', '8459-0', '8453-3', '8478-8', '8867-4', '2710-2', '2085-9', '2093-3', '13457-7'],
    MedicalContextCategory.respiratory: ['5942-2', '2703-7', '2708-6', '2019-8', '4756-4', '1989-3'],
    MedicalContextCategory.thyroid: ['3016-3', '3026-2', '3024-7', '3053-6', '3052-8', '3051-0'],
    MedicalContextCategory.renal: ['2160-0', '3094-0', '59570-2', '48642-3', '48811-4', '48813-0'],
    MedicalContextCategory.hepatic: ['1920-8', '1921-6', '1922-4', '1923-2', '1924-0', '1925-7', '1972-5', '1973-3', '1974-1', '1975-8', '1976-6'],
    MedicalContextCategory.hematology: ['718-7', '4544-3', '6690-2', '777-3', '7856-2', '7861-2', '7863-8', '7871-1', '7872-9', '7873-7', '7874-5', '2276-4', '2508-8', '2502-1'],
    MedicalContextCategory.oncology: ['21914-2', '2744-1', '21915-9', '27043-1', '2756-5', '21913-4'],
    MedicalContextCategory.mentalHealth: ['LA21926-9', 'LA21927-7', 'LA21928-5'],
    MedicalContextCategory.musculoskeletal: ['4548-4', '17861-6', '30522-7', '62238-9', '82610-7'],
    MedicalContextCategory.gastrointestinal: ['2349-9', '2335-7', '2325-8', '2344-0', '2350-7', '2351-5', '2352-3'],
  };

  static List<String> getLoincCodes(Set<MedicalContextCategory> categories) {
    final codes = <String>[];
    for (final category in categories) {
      codes.addAll(loincCodes[category] ?? []);
    }
    return codes;
  }
}

/// Maps categories to medication drug classes
class CategoryMedicationMapping {
  static const Map<MedicalContextCategory, List<String>> drugClasses = {
    MedicalContextCategory.diabetes: ['Biguanide', 'Sulfonylurea', 'Meglitinide', 'Thiazolidinedione', 'DPP-4 inhibitor', 'GLP-1 agonist', 'SGLT2 inhibitor', 'Insulin'],
    MedicalContextCategory.cardiovascular: ['ACE Inhibitor', 'ARB', 'Calcium Channel Blocker', 'Beta Blocker', 'Diuretic', 'Statin', 'Antiplatelet', 'Anticoagulant'],
    MedicalContextCategory.respiratory: ['Beta-2 Agonist', 'Inhaled Corticosteroid', 'Leukotriene receptor antagonist', 'Methylxanthine', 'Anticholinergic'],
    MedicalContextCategory.thyroid: ['Thyroid Hormone'],
    MedicalContextCategory.mentalHealth: ['SSRI', 'SNRI', 'Tricyclic', 'Benzodiazepine', 'Atypical antipsychotic', 'Mood stabilizer'],
    MedicalContextCategory.pain: ['NSAID', 'Analgesic', 'Opioid', 'Muscle relaxant'],
    MedicalContextCategory.infectious: ['Antibiotic', 'Antiviral', 'Antifungal', 'Antiparasitic'],
  };

  static List<String> getDrugClasses(Set<MedicalContextCategory> categories) {
    final classes = <String>[];
    for (final category in categories) {
      classes.addAll(drugClasses[category] ?? []);
    }
    return classes;
  }
}

/// Relevant standards for a user profile
class RelevantStandards {
  final Set<MedicalContextCategory> categories;
  final List<String> icd10Codes;
  final List<String> loincCodes;
  final List<String> medicationClasses;
  final List<String> guidelineIds;

  const RelevantStandards({
    required this.categories,
    required this.icd10Codes,
    required this.loincCodes,
    required this.medicationClasses,
    required this.guidelineIds,
  });

  int get estimatedSizeMB {
    // Rough estimates
    int size = 10; // Base size for preventive
    size += categories.length * 5; // 5MB per category
    size += (icd10Codes.length * 0.1).round(); // 0.1MB per code
    size += (loincCodes.length * 0.1).round(); // 0.1MB per code
    size += (medicationClasses.length * 0.5).round(); // 0.5MB per class
    return size;
  }
}
