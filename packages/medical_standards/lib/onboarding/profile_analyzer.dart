import 'medical_context_categories.dart';

/// Analyzes user profile to determine relevant medical context
class ProfileAnalyzer {

  /// Analyzes a user profile and returns relevant standard categories
  RelevantStandards analyzeProfile({
    required int age,
    required String sex,
    List<String> currentConditions = const [],
    List<String> familyHistory = const [],
    List<String> currentMedications = const [],
    List<String> symptoms = const [],
    List<String> labResults = const [],
  }) {
    final categories = <MedicalContextCategory>{};

    // Everyone gets preventive care
    categories.add(MedicalContextCategory.preventive);

    // Analyze current conditions
    for (final condition in currentConditions) {
      categories.addAll(_mapConditionToCategories(condition));
    }

    // Analyze family history
    for (final history in familyHistory) {
      categories.addAll(_mapHistoryToCategories(history));
    }

    // Age-based risk factors
    if (age >= 35) {
      categories.add(MedicalContextCategory.cardiovascular);
    }
    if (age >= 45) {
      categories.add(MedicalContextCategory.diabetes);
    }
    if (age >= 50) {
      categories.add(MedicalContextCategory.oncology);
      categories.add(MedicalContextCategory.cardiovascular);
    }
    if (age >= 60) {
      categories.add(MedicalContextCategory.neurology);
      categories.add(MedicalContextCategory.musculoskeletal);
    }

    // Sex-specific
    if (sex == 'F' && age >= 40) {
      categories.add(MedicalContextCategory.oncology); // Breast cancer screening
      categories.add(MedicalContextCategory.ophthalmology);
    }
    if (sex == 'M' && age >= 50) {
      categories.add(MedicalContextCategory.oncology); // Prostate screening
    }

    // Analyze medications (some indicate conditions)
    for (final med in currentMedications) {
      categories.addAll(_mapMedicationToCategories(med));
    }

    // Analyze lab results (abnormal values suggest conditions)
    for (final lab in labResults) {
      categories.addAll(_mapLabToCategories(lab));
    }

    // Analyze symptoms
    for (final symptom in symptoms) {
      categories.addAll(_mapSymptomToCategories(symptom));
    }

    // Build the relevant standards
    return RelevantStandards(
      categories: categories,
      icd10Codes: CategoryIcd10Mapping.getIcd10Prefixes(categories),
      loincCodes: CategoryLoincMapping.getLoincCodes(categories),
      medicationClasses: CategoryMedicationMapping.getDrugClasses(categories),
      guidelineIds: _getGuidelineIds(categories),
    );
  }

  Set<MedicalContextCategory> _mapConditionToCategories(String condition) {
    final lower = condition.toLowerCase();
    final categories = <MedicalContextCategory>{};

    if (lower.contains('diabetes') || lower.contains('diabetic')) {
      categories.add(MedicalContextCategory.diabetes);
      categories.add(MedicalContextCategory.cardiovascular);
    }
    if (lower.contains('hypertension') || lower.contains('high blood pressure')) {
      categories.add(MedicalContextCategory.cardiovascular);
    }
    if (lower.contains('heart') || lower.contains('cardiac') || lower.contains('corazon')) {
      categories.add(MedicalContextCategory.cardiovascular);
    }
    if (lower.contains('asthma') || lower.contains('asthm')) {
      categories.add(MedicalContextCategory.respiratory);
    }
    if (lower.contains('copd') || lower.contains('emphysema')) {
      categories.add(MedicalContextCategory.respiratory);
    }
    if (lower.contains('thyroid') || lower.contains('tiroid')) {
      categories.add(MedicalContextCategory.thyroid);
    }
    if (lower.contains('kidney') || lower.contains('renal') || lower.contains('riñon')) {
      categories.add(MedicalContextCategory.renal);
    }
    if (lower.contains('liver') || lower.contains('hepatic') || lower.contains('higado')) {
      categories.add(MedicalContextCategory.hepatic);
    }
    if (lower.contains('anemia') || lower.contains('blood') || lower.contains('sangre')) {
      categories.add(MedicalContextCategory.hematology);
    }
    if (lower.contains('cancer') || lower.contains('tumor') || lower.contains('carcinoma')) {
      categories.add(MedicalContextCategory.oncology);
    }
    if (lower.contains('depression') || lower.contains('depressive') || lower.contains('depresion')) {
      categories.add(MedicalContextCategory.mentalHealth);
    }
    if (lower.contains('anxiety') || lower.contains('ansiedad')) {
      categories.add(MedicalContextCategory.mentalHealth);
    }
    if (lower.contains('arthritis') || lower.contains('artritis') || lower.contains('joint')) {
      categories.add(MedicalContextCategory.musculoskeletal);
    }
    if (lower.contains('gastritis') || lower.contains('colon') || lower.contains('ibd')) {
      categories.add(MedicalContextCategory.gastrointestinal);
    }

    return categories;
  }

  Set<MedicalContextCategory> _mapHistoryToCategories(String history) {
    // Family history is a risk factor, add those categories
    final categories = _mapConditionToCategories(history);
    // Oncology is especially important for family history
    categories.add(MedicalContextCategory.oncology);
    return categories;
  }

  Set<MedicalContextCategory> _mapMedicationToCategories(String medication) {
    final lower = medication.toLowerCase();
    final categories = <MedicalContextCategory>{};

    if (lower.contains('metformin') || lower.contains('insulin') ||
        lower.contains('glipizide') || lower.contains('gliptin') ||
        lower.contains('sglt2') || lower.contains('glp1')) {
      categories.add(MedicalContextCategory.diabetes);
    }
    if (lower.contains('lisinopril') || lower.contains('losartan') ||
        lower.contains('amlodipine') || lower.contains('beta blocker') ||
        lower.contains('statin') || lower.contains('atorvastatin')) {
      categories.add(MedicalContextCategory.cardiovascular);
    }
    if (lower.contains('levothyroxine') || lower.contains('thyroid')) {
      categories.add(MedicalContextCategory.thyroid);
    }
    if (lower.contains('albuterol') || lower.contains('fluticasone') ||
        lower.contains('montelukast')) {
      categories.add(MedicalContextCategory.respiratory);
    }
    if (lower.contains('sertraline') || lower.contains('fluoxetine') ||
        lower.contains('alprazolam') || lower.contains('lorazepam')) {
      categories.add(MedicalContextCategory.mentalHealth);
    }
    if (lower.contains('warfarin') || lower.contains('heparin') ||
        lower.contains('aspirin')) {
      categories.add(MedicalContextCategory.cardiovascular);
    }

    return categories;
  }

  Set<MedicalContextCategory> _mapLabToCategories(String lab) {
    final lower = lab.toLowerCase();
    final categories = <MedicalContextCategory>{};

    if (lower.contains('hba1c') || lower.contains('hemoglobin') && lower.contains('a1c')) {
      categories.add(MedicalContextCategory.diabetes);
    }
    if (lower.contains('tsh') || lower.contains('t4') || lower.contains('t3') ||
        lower.contains('thyroid')) {
      categories.add(MedicalContextCategory.thyroid);
    }
    if (lower.contains('creatinine') || lower.contains('bun') ||
        lower.contains('egfr') || lower.contains('kidney')) {
      categories.add(MedicalContextCategory.renal);
    }
    if (lower.contains('alt') || lower.contains('ast') || lower.contains('bilirubin') ||
        lower.contains('liver')) {
      categories.add(MedicalContextCategory.hepatic);
    }
    if (lower.contains('hemoglobin') || lower.contains('ferritin') ||
        lower.contains('iron') || lower.contains('anemia')) {
      categories.add(MedicalContextCategory.hematology);
    }
    if (lower.contains('cholesterol') || lower.contains('ldl') ||
        lower.contains('hdl') || lower.contains('triglyceride')) {
      categories.add(MedicalContextCategory.cardiovascular);
    }

    return categories;
  }

  Set<MedicalContextCategory> _mapSymptomToCategories(String symptom) {
    final lower = symptom.toLowerCase();
    final categories = <MedicalContextCategory>{};

    if (lower.contains('fatigue') || lower.contains('tired') ||
        lower.contains('cansancio') || lower.contains('fatique')) {
      categories.add(MedicalContextCategory.diabetes);
      categories.add(MedicalContextCategory.thyroid);
      categories.add(MedicalContextCategory.hematology);
    }
    if (lower.contains('chest pain') || lower.contains('dolor') ||
        lower.contains('palpitations') || lower.contains('heart')) {
      categories.add(MedicalContextCategory.cardiovascular);
    }
    if (lower.contains('shortness of breath') || lower.contains('breath') ||
        lower.contains('respiracion') || lower.contains('dyspnea')) {
      categories.add(MedicalContextCategory.respiratory);
      categories.add(MedicalContextCategory.cardiovascular);
    }
    if (lower.contains('headache') || lower.contains('dolor de cabeza')) {
      categories.add(MedicalContextCategory.cardiovascular);
      categories.add(MedicalContextCategory.neurology);
    }
    if (lower.contains('joint pain') || lower.contains('dolor articular')) {
      categories.add(MedicalContextCategory.musculoskeletal);
    }

    return categories;
  }

  List<String> _getGuidelineIds(Set<MedicalContextCategory> categories) {
    final ids = <String>[];

    if (categories.contains(MedicalContextCategory.diabetes)) {
      ids.addAll(['ADA-2024', 'ADA-A1C', 'WHO-DM-2016']);
    }
    if (categories.contains(MedicalContextCategory.cardiovascular)) {
      ids.addAll(['AHA-2017', 'AHA-2018', 'ACC-AHA-ASCVD', 'WHO-2023']);
    }
    if (categories.contains(MedicalContextCategory.thyroid)) {
      ids.add('ATA-2014');
    }
    if (categories.contains(MedicalContextCategory.mentalHealth)) {
      ids.add('APA-DEP-2021');
    }

    // Everyone gets lab reference ranges
    ids.add('CLSI-2017');

    return ids;
  }
}
