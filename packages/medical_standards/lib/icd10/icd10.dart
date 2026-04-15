/// ICD-10 disease classification models.
///
/// ICD-10 is the International Classification of Diseases, 10th Revision.
/// Used for diagnosing diseases and conditions.

import '../medical_standards.dart';

/// ICD-10 Disease Code
class Icd10Code extends MedicalConcept {
  @override
  final String code;
  @override
  final String displayName;
  @override
  final String? description;
  final String category;
  final List<String> synonyms;

  const Icd10Code({
    required this.code,
    required this.displayName,
    this.description,
    required this.category,
    this.synonyms = const [],
  });

  @override
  List<Object?> get props => [code, displayName, category];
}

/// Common ICD-10 codes for chronic conditions
class Icd10ChronicConditions {
  // Diabetes
  static const Icd10Code diabetesType1 = Icd10Code(
    code: 'E10',
    displayName: 'Type 1 diabetes mellitus',
    category: 'Endocrine',
    synonyms: ['DM1', 'Diabetes tipo 1'],
  );

  static const Icd10Code diabetesType2 = Icd10Code(
    code: 'E11',
    displayName: 'Type 2 diabetes mellitus',
    category: 'Endocrine',
    synonyms: ['DM2', 'Diabetes tipo 2'],
  );

  // Cardiovascular
  static const Icd10Code hypertension = Icd10Code(
    code: 'I10',
    displayName: 'Essential (primary) hypertension',
    category: 'Cardiovascular',
    synonyms: ['High blood pressure', 'Presión alta'],
  );

  static const Icd10Code atrialFibrillation = Icd10Code(
    code: 'I48.91',
    displayName: 'Unspecified atrial fibrillation',
    category: 'Cardiovascular',
    synonyms: ['AFib', 'Fibrilación auricular'],
  );

  static const Icd10Code heartFailure = Icd10Code(
    code: 'I50.9',
    displayName: 'Heart failure, unspecified',
    category: 'Cardiovascular',
    synonyms: ['CHF', 'Insuficiencia cardíaca'],
  );

  // Respiratory
  static const Icd10Code asthma = Icd10Code(
    code: 'J45.909',
    displayName: 'Unspecified asthma, uncomplicated',
    category: 'Respiratory',
    synonyms: ['Asma'],
  );

  static const Icd10Code copd = Icd10Code(
    code: 'J44.9',
    displayName: 'Chronic obstructive pulmonary disease, unspecified',
    category: 'Respiratory',
    synonyms: ['EPOC', 'Enfermedad pulmonar obstructiva crónica'],
  );

  // Metabolic
  static const Icd10Code obesity = Icd10Code(
    code: 'E66.9',
    displayName: 'Obesity, unspecified',
    category: 'Endocrine',
    synonyms: ['Obesidad'],
  );

  static const Icd10Code hyperlipidemia = Icd10Code(
    code: 'E78.5',
    displayName: 'Hyperlipidemia, unspecified',
    category: 'Endocrine',
    synonyms: ['High cholesterol', 'Colesterol alto'],
  );

  // Mental Health
  static const Icd10Code depression = Icd10Code(
    code: 'F32.9',
    displayName: 'Major depressive disorder, single episode, unspecified',
    category: 'Mental',
    synonyms: ['Depresión'],
  );

  static const Icd10Code anxiety = Icd10Code(
    code: 'F41.1',
    displayName: 'Generalized anxiety disorder',
    category: 'Mental',
    synonyms: ['Ansiedad'],
  );

  // Common symptoms
  static const Icd10Code fatigue = Icd10Code(
    code: 'R53.83',
    displayName: 'Other fatigue',
    category: 'Symptoms',
    synonyms: ['Cansancio', 'Fatiga'],
  );

  static const Icd10Code headache = Icd10Code(
    code: 'R51.9',
    displayName: 'Headache, unspecified',
    category: 'Symptoms',
    synonyms: ['Dolor de cabeza'],
  );

  static const Icd10Code chestPain = Icd10Code(
    code: 'R07.9',
    displayName: 'Chest pain, unspecified',
    category: 'Symptoms',
    synonyms: ['Dolor en pecho'],
  );

  /// All common codes
  static const List<Icd10Code> common = [
    diabetesType1,
    diabetesType2,
    hypertension,
    atrialFibrillation,
    heartFailure,
    asthma,
    copd,
    obesity,
    hyperlipidemia,
    depression,
    anxiety,
    fatigue,
    headache,
    chestPain,
  ];

  /// Find by code
  static Icd10Code? findByCode(String code) {
    try {
      return common.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Find by synonym
  static Icd10Code? findBySynonym(String term) {
    final lower = term.toLowerCase();
    for (final code in common) {
      if (code.synonyms.any((s) => s.toLowerCase() == lower)) {
        return code;
      }
    }
    return null;
  }
}
