/// Medication reference data (RxNorm subset).
///
/// RxNorm provides normalized names for drugs and doses.
/// This is a curated subset of common medications.

import '../medical_standards.dart';

/// Medication entry
class MedicationReference extends MedicalConcept {
  @override
  final String code;
  @override
  final String displayName;
  @override
  final String? description;
  final String? genericName;
  final String? drugClass;
  final List<String> routes;
  final List<String> commonDosages;

  const MedicationReference({
    required this.code,
    required this.displayName,
    this.description,
    this.genericName,
    this.drugClass,
    this.routes = const ['Oral'],
    this.commonDosages = const [],
  });

  @override
  List<Object?> get props => [code, displayName, drugClass];
}

/// Common medications by category
class MedicationCatalog {
  // Diabetes Medications
  static const MedicationReference metformin = MedicationReference(
    code: '6809',
    displayName: 'Metformin',
    genericName: 'Metformin HCl',
    drugClass: 'Biguanide',
    description: 'First-line therapy for Type 2 diabetes',
    routes: ['Oral'],
    commonDosages: ['500mg 2x/day', '850mg 2x/day', '1000mg 2x/day'],
  );

  static const MedicationReference glipizide = MedicationReference(
    code: '5487',
    displayName: 'Glipizide',
    genericName: 'Glipizide',
    drugClass: 'Sulfonylurea',
    description: 'Second-line for Type 2 diabetes',
    routes: ['Oral'],
    commonDosages: ['5mg/day', '10mg/day', '20mg/day'],
  );

  static const MedicationReference insulinGlargine = MedicationReference(
    code: '225971',
    displayName: 'Insulin Glargine',
    genericName: 'Insulin glargine recombinant',
    drugClass: 'Long-acting Insulin',
    description: 'Long-acting insulin for diabetes',
    routes: ['Subcutaneous'],
    commonDosages: ['10 units/day', '20 units/day', '30 units/day'],
  );

  // Cardiovascular
  static const MedicationReference lisinopril = MedicationReference(
    code: '29046',
    displayName: 'Lisinopril',
    genericName: 'Lisinopril',
    drugClass: 'ACE Inhibitor',
    description: 'For hypertension, heart failure, diabetic nephropathy',
    routes: ['Oral'],
    commonDosages: ['10mg/day', '20mg/day', '40mg/day'],
  );

  static const MedicationReference losartan = MedicationReference(
    code: '52175',
    displayName: 'Losartan',
    genericName: 'Losartan potassium',
    drugClass: 'ARB',
    description: 'Angiotensin receptor blocker for hypertension',
    routes: ['Oral'],
    commonDosages: ['25mg/day', '50mg/day', '100mg/day'],
  );

  static const MedicationReference amlodipine = MedicationReference(
    code: '17767',
    displayName: 'Amlodipine',
    genericName: 'Amlodipine besylate',
    drugClass: 'Calcium Channel Blocker',
    description: 'For hypertension and angina',
    routes: ['Oral'],
    commonDosages: ['5mg/day', '10mg/day'],
  );

  static const MedicationReference atorvastatin = MedicationReference(
    code: '83367',
    displayName: 'Atorvastatin',
    genericName: 'Atorvastatin calcium',
    drugClass: 'Statin',
    description: 'HMG-CoA reductase inhibitor for cholesterol',
    routes: ['Oral'],
    commonDosages: ['10mg/day', '20mg/day', '40mg/day', '80mg/day'],
  );

  static const MedicationReference rosuvastatin = MedicationReference(
    code: '321167',
    displayName: 'Rosuvastatin',
    genericName: 'Rosuvastatin calcium',
    drugClass: 'Statin',
    description: 'High-intensity statin for LDL reduction',
    routes: ['Oral'],
    commonDosages: ['5mg/day', '10mg/day', '20mg/day'],
  );

  static const MedicationReference warfarin = MedicationReference(
    code: '855332',
    displayName: 'Warfarin',
    genericName: 'Warfarin sodium',
    drugClass: 'Anticoagulant',
    description: 'Vitamin K antagonist for anticoagulation',
    routes: ['Oral'],
    commonDosages: ['2mg/day', '5mg/day', '7.5mg/day', '10mg/day'],
  );

  // Antiplatelet
  static const MedicationReference aspirin = MedicationReference(
    code: '1191',
    displayName: 'Aspirin',
    genericName: 'Acetylsalicylic acid',
    drugClass: 'NSAID/Antiplatelet',
    description: 'Antiplatelet for cardiovascular protection',
    routes: ['Oral'],
    commonDosages: ['81mg/day', '325mg/day'],
  );

  static const MedicationReference clopidogrel = MedicationReference(
    code: '333965',
    displayName: 'Clopidogrel',
    genericName: 'Clopidogrel bisulfate',
    drugClass: 'Antiplatelet',
    description: 'P2Y12 inhibitor for cardiovascular protection',
    routes: ['Oral'],
    commonDosages: ['75mg/day'],
  );

  // Thyroid
  static const MedicationReference levothyroxine = MedicationReference(
    code: '8667',
    displayName: 'Levothyroxine',
    genericName: 'Levothyroxine sodium',
    drugClass: 'Thyroid Hormone',
    description: 'Synthetic T4 for hypothyroidism',
    routes: ['Oral'],
    commonDosages: ['25mcg/day', '50mcg/day', '75mcg/day', '100mcg/day', '125mcg/day', '150mcg/day'],
  );

  // Mental Health
  static const MedicationReference sertraline = MedicationReference(
    code: '36567',
    displayName: 'Sertraline',
    genericName: 'Sertraline hydrochloride',
    drugClass: 'SSRI',
    description: 'Selective serotonin reuptake inhibitor for depression/anxiety',
    routes: ['Oral'],
    commonDosages: ['50mg/day', '100mg/day', '200mg/day'],
  );

  static const MedicationReference fluoxetine = MedicationReference(
    code: '312938',
    displayName: 'Fluoxetine',
    genericName: 'Fluoxetine hydrochloride',
    drugClass: 'SSRI',
    description: 'SSRI for depression, OCD, panic disorder',
    routes: ['Oral'],
    commonDosages: ['20mg/day', '40mg/day', '60mg/day'],
  );

  static const MedicationReference alprazolam = MedicationReference(
    code: '32937',
    displayName: 'Alprazolam',
    genericName: 'Alprazolam',
    drugClass: 'Benzodiazepine',
    description: 'Short-acting benzodiazepine for anxiety',
    routes: ['Oral'],
    commonDosages: ['0.25mg 3x/day', '0.5mg 3x/day', '1mg 3x/day'],
  );

  // Pain/Inflammation
  static const MedicationReference ibuprofen = MedicationReference(
    code: '5640',
    displayName: 'Ibuprofen',
    genericName: 'Ibuprofen',
    drugClass: 'NSAID',
    description: 'Non-steroidal anti-inflammatory drug',
    routes: ['Oral', 'Topical'],
    commonDosages: ['200mg PRN', '400mg 3x/day', '600mg 3x/day', '800mg 3x/day'],
  );

  static const MedicationReference acetaminophen = MedicationReference(
    code: '161',
    displayName: 'Acetaminophen',
    genericName: 'Acetaminophen',
    drugClass: 'Analgesic',
    description: 'Pain reliever and fever reducer',
    routes: ['Oral', 'Rectal', 'IV'],
    commonDosages: ['325mg PRN', '500mg PRN', '650mg 4x/day', '1000mg 4x/day'],
  );

  // Allergies
  static const MedicationReference cetirizine = MedicationReference(
    code: '201250',
    displayName: 'Cetirizine',
    genericName: 'Cetirizine hydrochloride',
    drugClass: 'Antihistamine',
    description: 'Second-generation antihistamine for allergies',
    routes: ['Oral'],
    commonDosages: ['5mg/day', '10mg/day'],
  );

  static const MedicationReference loratadine = MedicationReference(
    code: '26225',
    displayName: 'Loratadine',
    genericName: 'Loratadine',
    drugClass: 'Antihistamine',
    description: 'Non-drowsy antihistamine for allergies',
    routes: ['Oral'],
    commonDosages: ['10mg/day'],
  );

  // Respiratory
  static const MedicationReference albuterol = MedicationReference(
    code: '435',
    displayName: 'Albuterol',
    genericName: 'Albuterol sulfate',
    drugClass: 'Beta-2 Agonist',
    description: 'Bronchodilator for asthma/COPD',
    routes: ['Inhalation'],
    commonDosages: ['2 puffs PRN', '5mg via nebulizer'],
  );

  static const MedicationReference fluticasone = MedicationReference(
    code: '197530',
    displayName: 'Fluticasone',
    genericName: 'Fluticasone propionate',
    drugClass: 'Inhaled Corticosteroid',
    description: 'ICS for asthma and COPD maintenance',
    routes: ['Inhalation', 'Nasal'],
    commonDosages: ['50mcg 2x/day nasal', '100mcg 2x/day inhaler', '250mcg 2x/day inhaler'],
  );

  // GERD
  static const MedicationReference omeprazole = MedicationReference(
    code: '7646',
    displayName: 'Omeprazole',
    genericName: 'Omeprazole',
    drugClass: 'Proton Pump Inhibitor',
    description: 'PPI for GERD and peptic ulcers',
    routes: ['Oral'],
    commonDosages: ['20mg/day', '40mg/day'],
  );

  static const MedicationReference pantoprazole = MedicationReference(
    code: '40790',
    displayName: 'Pantoprazole',
    genericName: 'Pantoprazole sodium',
    drugClass: 'Proton Pump Inhibitor',
    description: 'PPI for GERD and hypersecretory conditions',
    routes: ['Oral', 'IV'],
    commonDosages: ['40mg/day', '40mg 2x/day'],
  );

  /// All medications
  static const List<MedicationReference> all = [
    metformin,
    glipizide,
    insulinGlargine,
    lisinopril,
    losartan,
    amlodipine,
    atorvastatin,
    rosuvastatin,
    warfarin,
    aspirin,
    clopidogrel,
    levothyroxine,
    sertraline,
    fluoxetine,
    alprazolam,
    ibuprofen,
    acetaminophen,
    cetirizine,
    loratadine,
    albuterol,
    fluticasone,
    omeprazole,
    pantoprazole,
  ];

  /// Find by RxNorm code
  static MedicationReference? findByCode(String code) {
    try {
      return all.firstWhere((m) => m.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Find by drug class
  static List<MedicationReference> findByClass(String drugClass) {
    return all.where((m) => m.drugClass?.contains(drugClass) ?? false).toList();
  }
}
