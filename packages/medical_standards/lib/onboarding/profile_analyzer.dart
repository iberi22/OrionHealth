// ignore_for_file: dangling_library_doc_comments
/// Analyzes user profile to determine relevant medical context.
///
/// Uses pattern matching on conditions, medications, symptoms, and
/// demographic data (age/sex) to determine which [MedicalContextCategory]
/// standards should be downloaded for the AI assistant.


import 'medical_context_categories.dart';

/// Keyword → category mapping for condition-based detection
const Map<String, MedicalContextCategory> _conditionPatterns =
    <String, MedicalContextCategory>{
  // Diabetes
  'diabetes': MedicalContextCategory.diabetes,
  'diabetic': MedicalContextCategory.diabetes,
  'dm1': MedicalContextCategory.diabetes,
  'dm2': MedicalContextCategory.diabetes,
  'prediabetes': MedicalContextCategory.diabetes,
  'hyperglycemia': MedicalContextCategory.diabetes,
  // Cardiovascular
  'hypertension': MedicalContextCategory.cardiovascular,
  'high blood pressure': MedicalContextCategory.cardiovascular,
  'htn': MedicalContextCategory.cardiovascular,
  'atrial fibrillation': MedicalContextCategory.cardiovascular,
  'afib': MedicalContextCategory.cardiovascular,
  'heart failure': MedicalContextCategory.cardiovascular,
  'chf': MedicalContextCategory.cardiovascular,
  'coronary': MedicalContextCategory.cardiovascular,
  'cad': MedicalContextCategory.cardiovascular,
  'angina': MedicalContextCategory.cardiovascular,
  'mi': MedicalContextCategory.cardiovascular,
  'myocardial infarction': MedicalContextCategory.cardiovascular,
  'stroke': MedicalContextCategory.cardiovascular,
  'pad': MedicalContextCategory.cardiovascular,
  'peripheral vascular': MedicalContextCategory.cardiovascular,
  'dvt': MedicalContextCategory.cardiovascular,
  'embolism': MedicalContextCategory.cardiovascular,
  // Respiratory
  'asthma': MedicalContextCategory.respiratory,
  'copd': MedicalContextCategory.respiratory,
  'emphysema': MedicalContextCategory.respiratory,
  'bronchitis': MedicalContextCategory.respiratory,
  'pneumonia': MedicalContextCategory.respiratory,
  'lung disease': MedicalContextCategory.respiratory,
  'fibrosis': MedicalContextCategory.respiratory,
  'tuberculosis': MedicalContextCategory.infectious,
  // Thyroid
  'hypothyroid': MedicalContextCategory.thyroid,
  'hyperthyroid': MedicalContextCategory.thyroid,
  'thyroid': MedicalContextCategory.thyroid,
  'goiter': MedicalContextCategory.thyroid,
  'tsh': MedicalContextCategory.thyroid,
  // Renal
  'kidney': MedicalContextCategory.renal,
  'ckd': MedicalContextCategory.renal,
  'renal': MedicalContextCategory.renal,
  'dialysis': MedicalContextCategory.renal,
  'nephropathy': MedicalContextCategory.renal,
  'nephritis': MedicalContextCategory.renal,
  'bph': MedicalContextCategory.renal,
  'prostate': MedicalContextCategory.renal,
  // Hepatic
  'liver': MedicalContextCategory.hepatic,
  'hepatic': MedicalContextCategory.hepatic,
  'hepatitis': MedicalContextCategory.hepatic,
  'cirrhosis': MedicalContextCategory.hepatic,
  'nafld': MedicalContextCategory.hepatic,
  'nash': MedicalContextCategory.hepatic,
  'fatty liver': MedicalContextCategory.hepatic,
  'gallbladder': MedicalContextCategory.hepatic,
  // Hematology
  'anemia': MedicalContextCategory.hematology,
  'hemoglobin': MedicalContextCategory.hematology,
  'sickle cell': MedicalContextCategory.hematology,
  'thalassemia': MedicalContextCategory.hematology,
  'leukemia': MedicalContextCategory.hematology,
  'lymphoma': MedicalContextCategory.hematology,
  'coagulation': MedicalContextCategory.hematology,
  'hemophilia': MedicalContextCategory.hematology,
  'thrombosis': MedicalContextCategory.hematology,
  'bleeding disorder': MedicalContextCategory.hematology,
  // Oncology
  'cancer': MedicalContextCategory.oncology,
  'tumor': MedicalContextCategory.oncology,
  'malignant': MedicalContextCategory.oncology,
  'neoplasm': MedicalContextCategory.oncology,
  'metastasis': MedicalContextCategory.oncology,
  'carcinoma': MedicalContextCategory.oncology,
  'melanoma': MedicalContextCategory.oncology,
  // Mental Health
  'depression': MedicalContextCategory.mentalHealth,
  'anxiety': MedicalContextCategory.mentalHealth,
  'bipolar': MedicalContextCategory.mentalHealth,
  'schizophrenia': MedicalContextCategory.mentalHealth,
  'ptsd': MedicalContextCategory.mentalHealth,
  'adhd': MedicalContextCategory.mentalHealth,
  'insomnia': MedicalContextCategory.mentalHealth,
  'sleep': MedicalContextCategory.mentalHealth,
  'panic': MedicalContextCategory.mentalHealth,
  'ocd': MedicalContextCategory.mentalHealth,
  'substance abuse': MedicalContextCategory.mentalHealth,
  'alcohol': MedicalContextCategory.mentalHealth,
  'addiction': MedicalContextCategory.mentalHealth,
  'nicotine': MedicalContextCategory.mentalHealth,
  // Infectious
  'infection': MedicalContextCategory.infectious,
  'sepsis': MedicalContextCategory.infectious,
  'uti': MedicalContextCategory.infectious,
  'hiv': MedicalContextCategory.infectious,
  'covid': MedicalContextCategory.infectious,
  'fungal': MedicalContextCategory.infectious,
  'antibiotic': MedicalContextCategory.infectious,
  // Musculoskeletal
  'arthritis': MedicalContextCategory.musculoskeletal,
  'osteoarthritis': MedicalContextCategory.musculoskeletal,
  'rheumatoid': MedicalContextCategory.musculoskeletal,
  'gout': MedicalContextCategory.musculoskeletal,
  'back pain': MedicalContextCategory.musculoskeletal,
  'neck pain': MedicalContextCategory.musculoskeletal,
  'fibromyalgia': MedicalContextCategory.musculoskeletal,
  'osteoporosis': MedicalContextCategory.musculoskeletal,
  'tendinitis': MedicalContextCategory.musculoskeletal,
  'bursitis': MedicalContextCategory.musculoskeletal,
  // Gastrointestinal
  'gerd': MedicalContextCategory.gastrointestinal,
  'acid reflux': MedicalContextCategory.gastrointestinal,
  'gastritis': MedicalContextCategory.gastrointestinal,
  'ibs': MedicalContextCategory.gastrointestinal,
  'crohn': MedicalContextCategory.gastrointestinal,
  'colitis': MedicalContextCategory.gastrointestinal,
  'constipation': MedicalContextCategory.gastrointestinal,
  'diarrhea': MedicalContextCategory.gastrointestinal,
  'diverticulitis': MedicalContextCategory.gastrointestinal,
  // Neurology
  'migraine': MedicalContextCategory.neurology,
  'headache': MedicalContextCategory.neurology,
  'epilepsy': MedicalContextCategory.neurology,
  'seizure': MedicalContextCategory.neurology,
  'parkinson': MedicalContextCategory.neurology,
  'alzheimers': MedicalContextCategory.neurology,
  'dementia': MedicalContextCategory.neurology,
  'ms': MedicalContextCategory.neurology,
  'neuropathy': MedicalContextCategory.neurology,
  'multiple sclerosis': MedicalContextCategory.neurology,
  // Dermatology
  'psoriasis': MedicalContextCategory.dermatology,
  'eczema': MedicalContextCategory.dermatology,
  'dermatitis': MedicalContextCategory.dermatology,
  'acne': MedicalContextCategory.dermatology,
  'rash': MedicalContextCategory.dermatology,
  'cellulitis': MedicalContextCategory.dermatology,
  'wound': MedicalContextCategory.dermatology,
};

/// Drug class → category mapping
const Map<String, MedicalContextCategory> _medicationPatterns =
    <String, MedicalContextCategory>{
  'metformin': MedicalContextCategory.diabetes,
  'insulin': MedicalContextCategory.diabetes,
  'glipizide': MedicalContextCategory.diabetes,
  'glyburide': MedicalContextCategory.diabetes,
  'glimepiride': MedicalContextCategory.diabetes,
  'pioglitazone': MedicalContextCategory.diabetes,
  'sitagliptin': MedicalContextCategory.diabetes,
  'liraglutide': MedicalContextCategory.diabetes,
  'semaglutide': MedicalContextCategory.diabetes,
  'empagliflozin': MedicalContextCategory.diabetes,
  'dapagliflozin': MedicalContextCategory.diabetes,
  'lisinopril': MedicalContextCategory.cardiovascular,
  'ramipril': MedicalContextCategory.cardiovascular,
  'losartan': MedicalContextCategory.cardiovascular,
  'valsartan': MedicalContextCategory.cardiovascular,
  'amlodipine': MedicalContextCategory.cardiovascular,
  'nifedipine': MedicalContextCategory.cardiovascular,
  'diltiazem': MedicalContextCategory.cardiovascular,
  'metoprolol': MedicalContextCategory.cardiovascular,
  'carvedilol': MedicalContextCategory.cardiovascular,
  'atenolol': MedicalContextCategory.cardiovascular,
  'hydrochlorothiazide': MedicalContextCategory.cardiovascular,
  'furosemide': MedicalContextCategory.cardiovascular,
  'spironolactone': MedicalContextCategory.cardiovascular,
  'atorvastatin': MedicalContextCategory.cardiovascular,
  'rosuvastatin': MedicalContextCategory.cardiovascular,
  'simvastatin': MedicalContextCategory.cardiovascular,
  'warfarin': MedicalContextCategory.cardiovascular,
  'apixaban': MedicalContextCategory.cardiovascular,
  'rivaroxaban': MedicalContextCategory.cardiovascular,
  'aspirin': MedicalContextCategory.cardiovascular,
  'clopidogrel': MedicalContextCategory.cardiovascular,
  'albuterol': MedicalContextCategory.respiratory,
  'salbutamol': MedicalContextCategory.respiratory,
  'fluticasone': MedicalContextCategory.respiratory,
  'budesonide': MedicalContextCategory.respiratory,
  'montelukast': MedicalContextCategory.respiratory,
  'tiotropium': MedicalContextCategory.respiratory,
  'levothyroxine': MedicalContextCategory.thyroid,
  'synthroid': MedicalContextCategory.thyroid,
  'methimazole': MedicalContextCategory.thyroid,
  'propylthiouracil': MedicalContextCategory.thyroid,
  'sertraline': MedicalContextCategory.mentalHealth,
  'fluoxetine': MedicalContextCategory.mentalHealth,
  'escitalopram': MedicalContextCategory.mentalHealth,
  'paroxetine': MedicalContextCategory.mentalHealth,
  'citalopram': MedicalContextCategory.mentalHealth,
  'venlafaxine': MedicalContextCategory.mentalHealth,
  'duloxetine': MedicalContextCategory.mentalHealth,
  'alprazolam': MedicalContextCategory.mentalHealth,
  'lorazepam': MedicalContextCategory.mentalHealth,
  'diazepam': MedicalContextCategory.mentalHealth,
  'zolpidem': MedicalContextCategory.mentalHealth,
  'quetiapine': MedicalContextCategory.mentalHealth,
  'aripiprazole': MedicalContextCategory.mentalHealth,
  'lithium': MedicalContextCategory.mentalHealth,
  'methylphenidate': MedicalContextCategory.mentalHealth,
  'amphetamines': MedicalContextCategory.mentalHealth,
  'ibuprofen': MedicalContextCategory.musculoskeletal,
  'naproxen': MedicalContextCategory.musculoskeletal,
  'diclofenac': MedicalContextCategory.musculoskeletal,
  'meloxicam': MedicalContextCategory.musculoskeletal,
  'celecoxib': MedicalContextCategory.musculoskeletal,
  'acetaminophen': MedicalContextCategory.musculoskeletal,
  'tramadol': MedicalContextCategory.musculoskeletal,
  'oxycodone': MedicalContextCategory.musculoskeletal,
  'morphine': MedicalContextCategory.musculoskeletal,
  'methotrexate': MedicalContextCategory.musculoskeletal,
  'hydroxychloroquine': MedicalContextCategory.musculoskeletal,
  'allopurinol': MedicalContextCategory.musculoskeletal,
  'colchicine': MedicalContextCategory.musculoskeletal,
  'omeprazole': MedicalContextCategory.gastrointestinal,
  'pantoprazole': MedicalContextCategory.gastrointestinal,
  'esomeprazole': MedicalContextCategory.gastrointestinal,
  'ranitidine': MedicalContextCategory.gastrointestinal,
  'ondansetron': MedicalContextCategory.gastrointestinal,
  'loperamide': MedicalContextCategory.gastrointestinal,
  'mesalamine': MedicalContextCategory.gastrointestinal,
  'levofloxacin': MedicalContextCategory.infectious,
  'azithromycin': MedicalContextCategory.infectious,
  'amoxicillin': MedicalContextCategory.infectious,
  'ciprofloxacin': MedicalContextCategory.infectious,
  'ceftriaxone': MedicalContextCategory.infectious,
  'doxycycline': MedicalContextCategory.infectious,
  'metronidazole': MedicalContextCategory.infectious,
};

/// Symptom → category mapping
const Map<String, MedicalContextCategory> _symptomPatterns =
    <String, MedicalContextCategory>{
  'polyuria': MedicalContextCategory.diabetes,
  'polydipsia': MedicalContextCategory.diabetes,
  'blurry vision': MedicalContextCategory.diabetes,
  'chest pain': MedicalContextCategory.cardiovascular,
  'shortness of breath': MedicalContextCategory.cardiovascular,
  'dyspnea': MedicalContextCategory.cardiovascular,
  'palpitations': MedicalContextCategory.cardiovascular,
  'edema': MedicalContextCategory.cardiovascular,
  'syncope': MedicalContextCategory.cardiovascular,
  'wheezing': MedicalContextCategory.respiratory,
  'cough': MedicalContextCategory.respiratory,
  'sputum': MedicalContextCategory.respiratory,
  'hemoptysis': MedicalContextCategory.respiratory,
  'fatigue': MedicalContextCategory.hematology,
  'pallor': MedicalContextCategory.hematology,
  'bruising': MedicalContextCategory.hematology,
  'bleeding': MedicalContextCategory.hematology,
  'jaundice': MedicalContextCategory.hepatic,
  'abdominal pain': MedicalContextCategory.gastrointestinal,
  'nausea': MedicalContextCategory.gastrointestinal,
  'vomiting': MedicalContextCategory.gastrointestinal,
  'diarrhea': MedicalContextCategory.gastrointestinal,
  'constipation': MedicalContextCategory.gastrointestinal,
  'weight loss': MedicalContextCategory.oncology,
  'night sweats': MedicalContextCategory.oncology,
  'fever': MedicalContextCategory.infectious,
  'rash': MedicalContextCategory.dermatology,
  'joint pain': MedicalContextCategory.musculoskeletal,
  'muscle pain': MedicalContextCategory.musculoskeletal,
  'back pain': MedicalContextCategory.musculoskeletal,
  'stiffness': MedicalContextCategory.musculoskeletal,
  'headache': MedicalContextCategory.neurology,
  'dizziness': MedicalContextCategory.neurology,
  'numbness': MedicalContextCategory.neurology,
  'tingling': MedicalContextCategory.neurology,
  'confusion': MedicalContextCategory.neurology,
};

/// Family history → category mapping
const Map<String, MedicalContextCategory> _familyHistoryPatterns =
    <String, MedicalContextCategory>{
  'diabetes': MedicalContextCategory.diabetes,
  'heart disease': MedicalContextCategory.cardiovascular,
  'hypertension': MedicalContextCategory.cardiovascular,
  'stroke': MedicalContextCategory.cardiovascular,
  'cancer': MedicalContextCategory.oncology,
  'breast cancer': MedicalContextCategory.oncology,
  'colon cancer': MedicalContextCategory.oncology,
  'thyroid': MedicalContextCategory.thyroid,
  'kidney disease': MedicalContextCategory.renal,
  'mental illness': MedicalContextCategory.mentalHealth,
  'depression': MedicalContextCategory.mentalHealth,
  'bipolar': MedicalContextCategory.mentalHealth,
};

/// Analyzes a user profile and returns relevant standard categories.
class ProfileAnalyzer {
  const ProfileAnalyzer();

  /// Analyze a user profile and return which [RelevantStandards] categories
  /// should be downloaded.
  ///
  /// Priority tiers:
  /// - [tier1]: Download immediately (existing conditions, current medications)
  /// - [tier2]: Download in background (family history, age-based risks, symptoms)
  Future<RelevantStandards> analyzeProfile({
    required int age,
    required String sex,
    List<String> currentConditions = const [],
    List<String> familyHistory = const [],
    List<String> currentMedications = const [],
    List<String> symptoms = const [],
  }) async {
    final tier1 = <MedicalContextCategory>{MedicalContextCategory.preventive};
    final tier2 = <MedicalContextCategory>{};

    // === TIER 1: Existing conditions & medications ===

    for (final condition in currentConditions) {
      final cat = _matchCategory(condition, _conditionPatterns);
      if (cat != null) {
        tier1.add(cat);
      }
    }

    for (final med in currentMedications) {
      final cat = _matchCategory(med.toLowerCase(), _medicationPatterns);
      if (cat != null) {
        tier1.add(cat);
      }
    }

    // === TIER 2: Symptoms, family history, age/sex-based ===

    for (final symptom in symptoms) {
      final cat = _matchCategory(symptom.toLowerCase(), _symptomPatterns);
      if (cat != null) {
        tier2.add(cat);
      }
    }

    for (final fh in familyHistory) {
      final cat = _matchCategory(fh.toLowerCase(), _familyHistoryPatterns);
      if (cat != null) {
        tier2.add(cat);
      }
    }

    // === Age-based category inference ===

    if (age >= 65) {
      tier2.add(MedicalContextCategory.geriatrics);
      tier2.add(MedicalContextCategory.cardiovascular);
      tier2.add(MedicalContextCategory.musculoskeletal);
    } else if (age >= 45) {
      tier2.add(MedicalContextCategory.cardiovascular);
      tier2.add(MedicalContextCategory.musculoskeletal);
      // Metabolic screening
      tier2.add(MedicalContextCategory.diabetes);
    }

    // === Sex-specific categories ===

    if (sex.toLowerCase() == 'f' || sex.toLowerCase() == 'female') {
      tier2.add(MedicalContextCategory.womensHealth);
    } else if (sex.toLowerCase() == 'm' || sex.toLowerCase() == 'male') {
      tier2.add(MedicalContextCategory.mensHealth);
    }

    // Remove tier2 categories that are already in tier1
    tier2.removeAll(tier1);

    return RelevantStandards(
      categories: {...tier1, ...tier2},
      tier1: tier1,
      tier2: tier2,
    );
  }

  /// Match a query string against pattern map (substring match)
  MedicalContextCategory? _matchCategory(
    String query,
    Map<String, MedicalContextCategory> patterns,
  ) {
    final lower = query.toLowerCase();
    for (final entry in patterns.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }
}
