/// LOINC laboratory observation codes.
///
/// LOINC (Logical Observation Identifiers Names and Codes) is the
/// universal code system for identifying laboratory and clinical
/// observations.

import '../medical_standards.dart';

/// LOINC observation code
class LoincCode extends MedicalConcept {
  @override
  final String code;
  @override
  final String displayName;
  @override
  final String? description;
  final String component;
  final String property;
  final String unit;

  const LoincCode({
    required this.code,
    required this.displayName,
    this.description,
    required this.component,
    required this.property,
    required this.unit,
  });

  @override
  List<Object?> get props => [code, displayName, component, property];
}

/// Common laboratory LOINC codes
class LoincCommonLabs {
  // Hematology
  static const LoincCode hemoglobin = LoincCode(
    code: '718-7',
    displayName: 'Hemoglobin [Mass/volume] in Blood',
    component: 'Hemoglobin',
    property: 'Mass concentration',
    unit: 'g/dL',
    description: 'Normal: Male 13.5-17.5 g/dL, Female 12-16 g/dL',
  );

  static const LoincCode hematocrit = LoincCode(
    code: '4544-3',
    displayName: 'Hematocrit [Volume fraction] of Blood',
    component: 'Hematocrit',
    property: 'Volume fraction',
    unit: '%',
    description: 'Normal: Male 38-50%, Female 34-44%',
  );

  static const LoincCode whiteBloodCellCount = LoincCode(
    code: '6690-2',
    displayName: 'Leukocytes [Count] in Blood by Automated count',
    component: 'WBC',
    property: 'Number concentration',
    unit: '10*3/uL',
    description: 'Normal: 4.5-11.0 x10³/uL',
  );

  static const LoincCode plateletCount = LoincCode(
    code: '777-3',
    displayName: 'Platelets [Count] in Blood by Automated count',
    component: 'Platelets',
    property: 'Number concentration',
    unit: '10*3/uL',
    description: 'Normal: 150-400 x10³/uL',
  );

  // Metabolic Panel
  static const LoincCode glucose = LoincCode(
    code: '2345-7',
    displayName: 'Glucose [Mass/volume] in Serum or Plasma',
    component: 'Glucose',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Fasting normal: 70-100 mg/dL',
  );

  static const LoincCode hemoglobinA1c = LoincCode(
    code: '4548-4',
    displayName: 'Hemoglobin A1c/Hemoglobin.total in Blood',
    component: 'HbA1c',
    property: 'Mass fraction',
    unit: '%',
    description: 'Normal <5.7%, Prediabetes 5.7-6.4%, Diabetes >=6.5%',
  );

  static const LoincCode creatinine = LoincCode(
    code: '2160-0',
    displayName: 'Creatinine [Mass/volume] in Serum or Plasma',
    component: 'Creatinine',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: Male 0.7-1.3, Female 0.6-1.1 mg/dL',
  );

  static const LoincCode bun = LoincCode(
    code: '3094-0',
    displayName: 'Urea nitrogen [Mass/volume] in Serum or Plasma',
    component: 'BUN',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 7-20 mg/dL',
  );

  static const LoincCode sodium = LoincCode(
    code: '2951-2',
    displayName: 'Sodium [Moles/volume] in Serum or Plasma',
    component: 'Sodium',
    property: 'Molar concentration',
    unit: 'mmol/L',
    description: 'Normal: 136-145 mmol/L',
  );

  static const LoincCode potassium = LoincCode(
    code: '2823-3',
    displayName: 'Potassium [Moles/volume] in Serum or Plasma',
    component: 'Potassium',
    property: 'Molar concentration',
    unit: 'mmol/L',
    description: 'Normal: 3.5-5.0 mmol/L',
  );

  // Lipid Panel
  static const LoincCode totalCholesterol = LoincCode(
    code: '2093-3',
    displayName: 'Cholesterol [Mass/volume] in Serum or Plasma',
    component: 'Total Cholesterol',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Desirable <200 mg/dL',
  );

  static const LoincCode ldlCholesterol = LoincCode(
    code: '13457-7',
    displayName: 'Cholesterol.LDL [Mass/volume] in Serum or Plasma by calculation',
    component: 'LDL Cholesterol',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Optimal <100 mg/dL',
  );

  static const LoincCode hdlCholesterol = LoincCode(
    code: '2085-9',
    displayName: 'Cholesterol in HDL [Mass/volume] in Serum or Plasma',
    component: 'HDL Cholesterol',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Male >=40, Female >=50 mg/dL',
  );

  static const LoincCode triglycerides = LoincCode(
    code: '2571-8',
    displayName: 'Triglycerides [Mass/volume] in Serum or Plasma',
    component: 'Triglycerides',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal <150 mg/dL',
  );

  // Thyroid
  static const LoincCode tsh = LoincCode(
    code: '3016-3',
    displayName: 'Thyrotropin [Units/volume] in Serum or Plasma',
    component: 'TSH',
    property: 'Unit concentration',
    unit: 'mIU/L',
    description: 'Normal: 0.4-4.0 mIU/L',
  );

  static const LoincCode freeT4 = LoincCode(
    code: '3026-2',
    displayName: 'Thyroxine free T4 [Mass/volume] in Serum or Plasma',
    component: 'Free T4',
    property: 'Mass concentration',
    unit: 'ng/dL',
    description: 'Normal: 0.8-1.8 ng/dL',
  );

  // Iron Studies
  static const LoincCode ferritin = LoincCode(
    code: '2276-4',
    displayName: 'Ferritin [Mass/volume] in Serum or Plasma',
    component: 'Ferritin',
    property: 'Mass concentration',
    unit: 'ng/mL',
    description: 'Normal: Male 20-250, Female 10-120 ng/mL',
  );

  static const LoincCode iron = LoincCode(
    code: '2508-8',
    displayName: 'Iron [Mass/volume] in Serum or Plasma',
    component: 'Iron',
    property: 'Mass concentration',
    unit: 'ug/dL',
    description: 'Normal: Male 65-175, Female 50-170 ug/dL',
  );

  static const LoincCode ironSaturation = LoincCode(
    code: '2502-1',
    displayName: 'Iron saturation [Mass ratio] in Serum or Plasma',
    component: 'Iron Saturation',
    property: 'Mass fraction',
    unit: '%',
    description: 'Normal: 20-50%',
  );

  /// All common lab codes
  static const List<LoincCode> all = [
    hemoglobin,
    hematocrit,
    whiteBloodCellCount,
    plateletCount,
    glucose,
    hemoglobinA1c,
    creatinine,
    bun,
    sodium,
    potassium,
    totalCholesterol,
    ldlCholesterol,
    hdlCholesterol,
    triglycerides,
    tsh,
    freeT4,
    ferritin,
    iron,
    ironSaturation,
  ];

  /// Find by LOINC code
  static LoincCode? findByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }
}
