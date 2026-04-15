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

/// Comprehensive LOINC laboratory codes
class LoincCommonLabs {
  // ==================== HEMATOLOGY / CBC ====================
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

  // RBC indices
  static const LoincCode rbcCount = LoincCode(
    code: '789-8',
    displayName: 'Erythrocytes [Count] in Blood by Automated count',
    component: 'RBC',
    property: 'Number concentration',
    unit: '10*6/uL',
    description: 'Normal: Male 4.5-5.9, Female 4.0-5.4 x10⁶/uL',
  );

  static const LoincCode mcv = LoincCode(
    code: '787-2',
    displayName: 'Erythrocyte mean corpuscular volume [Entitic volume]',
    component: 'MCV',
    property: 'Entitic volume',
    unit: 'fL',
    description: 'Normal: 80-100 fL (microcytic <80, macrocytic >100)',
  );

  static const LoincCode mch = LoincCode(
    code: '785-6',
    displayName: 'Erythrocyte mean corpuscular hemoglobin [Entitic mass]',
    component: 'MCH',
    property: 'Entitic mass',
    unit: 'pg',
    description: 'Normal: 27-33 pg (hypochromic <27)',
  );

  static const LoincCode mchc = LoincCode(
    code: '786-4',
    displayName: 'Erythrocyte mean corpuscular hemoglobin concentration [Mass/volume]',
    component: 'MCHC',
    property: 'Mass concentration',
    unit: 'g/dL',
    description: 'Normal: 32-36 g/dL',
  );

  static const LoincCode rdw = LoincCode(
    code: '788-0',
    displayName: 'Erythrocyte distribution width [Ratio]',
    component: 'RDW',
    property: 'Ratio',
    unit: '%',
    description: 'Normal: 11.5-14.5% (elevated in anisocytosis)',
  );

  static const LoincCode neutrophilsAbsolute = LoincCode(
    code: '753-4',
    displayName: 'Neutrophils [Number fraction] in Blood',
    component: 'Neutrophils (Absolute)',
    property: 'Number fraction',
    unit: '10*3/uL',
    description: 'Normal: 1.5-7.5 x10³/uL',
  );

  static const LoincCode lymphocytesAbsolute = LoincCode(
    code: '731-0',
    displayName: 'Lymphocytes [Number fraction] in Blood',
    component: 'Lymphocytes (Absolute)',
    property: 'Number fraction',
    unit: '10*3/uL',
    description: 'Normal: 1.0-4.0 x10³/uL',
  );

  static const LoincCode monocytesAbsolute = LoincCode(
    code: '742-7',
    displayName: 'Monocytes [Number fraction] in Blood',
    component: 'Monocytes (Absolute)',
    property: 'Number fraction',
    unit: '10*3/uL',
    description: 'Normal: 0.2-0.9 x10³/uL',
  );

  static const LoincCode eosinophilsAbsolute = LoincCode(
    code: '713-8',
    displayName: 'Eosinophils [Number fraction] in Blood',
    component: 'Eosinophils (Absolute)',
    property: 'Number fraction',
    unit: '10*3/uL',
    description: 'Normal: 0.0-0.4 x10³/uL',
  );

  static const LoincCode basophilsAbsolute = LoincCode(
    code: '704-7',
    displayName: 'Basophils [Number fraction] in Blood',
    component: 'Basophils (Absolute)',
    property: 'Number fraction',
    unit: '10*3/uL',
    description: 'Normal: 0.0-0.1 x10³/uL',
  );

  static const LoincCode mpv = LoincCode(
    code: '32623-1',
    displayName: 'Mean platelet volume [Entitic volume] in Blood',
    component: 'MPV',
    property: 'Entitic volume',
    unit: 'fL',
    description: 'Normal: 7.5-11.5 fL',
  );

  // ==================== LIVER FUNCTION ====================
  static const LoincCode alt = LoincCode(
    code: '1742-6',
    displayName: 'Alanine aminotransferase [Enzymatic activity/volume] in Serum or Plasma',
    component: 'ALT',
    property: 'Enzymatic activity',
    unit: 'U/L',
    description: 'Normal: 7-56 U/L (hepatocyte injury marker)',
  );

  static const LoincCode ast = LoincCode(
    code: '1920-8',
    displayName: 'Aspartate aminotransferase [Enzymatic activity/volume] in Serum or Plasma',
    component: 'AST',
    property: 'Enzymatic activity',
    unit: 'U/L',
    description: 'Normal: 10-40 U/L (liver/cardiac marker)',
  );

  static const LoincCode alp = LoincCode(
    code: '6768-6',
    displayName: 'Alkaline phosphatase [Enzymatic activity/volume] in Serum or Plasma',
    component: 'ALP',
    property: 'Enzymatic activity',
    unit: 'U/L',
    description: 'Normal: 44-147 U/L (cholestasis/bone marker)',
  );

  static const LoincCode totalBilirubin = LoincCode(
    code: '1975-2',
    displayName: 'Bilirubin.total [Mass/volume] in Serum or Plasma',
    component: 'Total Bilirubin',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 0.2-1.2 mg/dL',
  );

  static const LoincCode directBilirubin = LoincCode(
    code: '1968-7',
    displayName: 'Bilirubin.direct [Mass/volume] in Serum or Plasma',
    component: 'Direct (Conjugated) Bilirubin',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 0.0-0.3 mg/dL (elevated in obstruction)',
  );

  static const LoincCode indirectBilirubin = LoincCode(
    code: '1971-1',
    displayName: 'Bilirubin.indirect [Mass/volume] in Serum or Plasma',
    component: 'Indirect (Unconjugated) Bilirubin',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 0.2-0.8 mg/dL (elevated in hemolysis)',
  );

  static const LoincCode ggt = LoincCode(
    code: '2324-2',
    displayName: 'Gamma-glutamyltransferase [Enzymatic activity/volume] in Serum or Plasma',
    component: 'GGT',
    property: 'Enzymatic activity',
    unit: 'U/L',
    description: 'Normal: 0-51 U/L (cholestasis/alcohol marker)',
  );

  static const LoincCode ldH = LoincCode(
    code: '2532-0',
    displayName: 'Lactate dehydrogenase [Enzymatic activity/volume] in Serum or Plasma',
    component: 'LDH',
    property: 'Enzymatic activity',
    unit: 'U/L',
    description: 'Normal: 140-280 U/L (tissue damage marker)',
  );

  static const LoincCode totalProtein = LoincCode(
    code: '2951-3',
    displayName: 'Protein.total [Mass/volume] in Serum or Plasma',
    component: 'Total Protein',
    property: 'Mass concentration',
    unit: 'g/dL',
    description: 'Normal: 6.0-8.3 g/dL',
  );

  static const LoincCode albumin = LoincCode(
    code: '1751-7',
    displayName: 'Albumin [Mass/volume] in Serum or Plasma',
    component: 'Albumin',
    property: 'Mass concentration',
    unit: 'g/dL',
    description: 'Normal: 3.5-5.0 g/dL (low in liver disease/malnutrition)',
  );

  static const LoincCode pt = LoincCode(
    code: '5902-0',
    displayName: 'Prothrombin time (PT) [Time] in Blood by Coagulation assay',
    component: 'PT',
    property: 'Time',
    unit: 'sec',
    description: 'Normal: 11-13.5 sec (liver synthetic function)',
  );

  static const LoincCode inr = LoincCode(
    code: '6301-6',
    displayName: 'International normalized ratio of PT',
    component: 'INR',
    property: 'Ratio',
    unit: 'INR',
    description: 'Target: 2.0-3.0 on warfarin (liver synthetic function)',
  );

  static const LoincCode aptt = LoincCode(
    code: '3173-2',
    displayName: 'Partial thromboplastin time (PTT) [Time] in Blood by Coagulation assay',
    component: 'PTT',
    property: 'Time',
    unit: 'sec',
    description: 'Normal: 25-35 sec (intrinsic coagulation pathway)',
  );

  // ==================== KIDNEY FUNCTION ====================
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

  static const LoincCode egfr = LoincCode(
    code: '69405-6',
    displayName: 'Glomerular filtration rate/1.73 sq M.Averageed [Volume rate/Area] in Serum or Plasma',
    component: 'eGFR',
    property: 'Volume rate per area',
    unit: 'mL/min/1.73m2',
    description: 'Normal >90 mL/min/1.73m²; CKD stages 3-5 when <60',
  );

  static const LoincCode egfrNonAfricanAmerican = LoincCode(
    code: '88294-4',
    displayName: 'Glomerular filtration rate/1.73 sq M.Averageed by Creatinine-based formula (MDRD) in Serum or Plasma',
    component: 'eGFR (MDRD)',
    property: 'Volume rate per area',
    unit: 'mL/min/1.73m2',
    description: 'eGFR using MDRD formula (non-African American)',
  );

  static const LoincCode egfrAfricanAmerican = LoincCode(
    code: '88293-6',
    displayName: 'Glomerular filtration rate/1.73 sq M.Averageed by Creatinine-based formula (MDRD) in Serum or Plasma',
    component: 'eGFR (MDRD AA)',
    property: 'Volume rate per area',
    unit: 'mL/min/1.73m2',
    description: 'eGFR using MDRD formula (African American)',
  );

  static const LoincCode egfrCkdEpi = LoincCode(
    code: '48580-6',
    displayName: 'Glomerular filtration rate/1.73 sq M.Averageed by Creatinine-based CKD-EPI formula in Serum or Plasma',
    component: 'eGFR (CKD-EPI)',
    property: 'Volume rate per area',
    unit: 'mL/min/1.73m2',
    description: 'eGFR using CKD-EPI formula (preferred over MDRD)',
  );

  static const LoincCode creatinineUrine = LoincCode(
    code: '2161-8',
    displayName: 'Creatinine [Mass/volume] in Urine',
    component: 'Urine Creatinine',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Spot urine creatinine',
  );

  static const LoincCode proteinUrine = LoincCode(
    code: '2888-6',
    displayName: 'Protein [Mass/volume] in 24 hour Urine',
    component: 'Protein (24h urine)',
    property: 'Mass rate',
    unit: 'mg/24h',
    description: 'Normal: <150 mg/24h (proteinuria >300 mg/24h)',
  );

  static const LoincCode proteinUrineSpot = LoincCode(
    code: '1742-6',
    displayName: 'Protein [Mass/volume] in Urine by Dipstick',
    component: 'Urine Protein (Spot)',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Dipstick: Negative to Trace',
  );

  static const LoincCode microalbuminUrine = LoincCode(
    code: '14959-1',
    displayName: 'Microalbumin [Mass/volume] in Urine',
    component: 'Microalbumin (Urine)',
    property: 'Mass concentration',
    unit: 'mg/L',
    description: 'Normal: <30 mg/L (microalbuminuria 30-300 mg/L)',
  );

  static const LoincCode albuminCreatinineRatio = LoincCode(
    code: '14958-3',
    displayName: 'Albumin/Creatinine ratio [Ratio] in Urine',
    component: 'ACR',
    property: 'Ratio',
    unit: 'mg/g',
    description: 'Normal: <30 mg/g; A2: 30-300; A3: >300 mg/g',
  );

  static const LoincCode bunCreatinineRatio = LoincCode(
    code: '48771-1',
    displayName: 'Urea nitrogen/Creatinine ratio [Mass ratio] in Serum or Plasma',
    component: 'BUN/Creatinine Ratio',
    property: 'Mass ratio',
    unit: 'ratio',
    description: 'Normal: 10-20:1 (elevated in prerenal azotemia)',
  );

  static const LoincCode uricAcid = LoincCode(
    code: '3084-1',
    displayName: 'Uric acid [Mass/volume] in Serum or Plasma',
    component: 'Uric Acid',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: Male 3.4-7.0, Female 2.4-6.0 mg/dL',
  );

  static const LoincCode cystatinC = LoincCode(
    code: '1959-6',
    displayName: 'Cystatin C [Mass/volume] in Serum or Plasma',
    component: 'Cystatin C',
    property: 'Mass concentration',
    unit: 'mg/L',
    description: 'Alternative kidney function marker (not affected by muscle mass)',
  );

  // ==================== METABOLIC PANEL ====================
  static const LoincCode glucose = LoincCode(
    code: '2345-7',
    displayName: 'Glucose [Mass/volume] in Serum or Plasma',
    component: 'Glucose (Fasting)',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Fasting normal: 70-100 mg/dL; Diabetes: >=126 mg/dL',
  );

  static const LoincCode glucoseRandom = LoincCode(
    code: '14749-6',
    displayName: 'Glucose [Mass/volume] in Serum or Plasma by Fasting',
    component: 'Glucose (Random)',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Random glucose: normal <140 mg/dL; Diabetes: >=200 mg/dL',
  );

  static const LoincCode hemoglobinA1c = LoincCode(
    code: '4548-4',
    displayName: 'Hemoglobin A1c/Hemoglobin.total in Blood',
    component: 'HbA1c',
    property: 'Mass fraction',
    unit: '%',
    description: 'Normal <5.7%; Prediabetes 5.7-6.4%; Diabetes >=6.5%',
  );

  static const LoincCode glucoseTwoHourPostPrandial = LoincCode(
    code: '1554-5',
    displayName: 'Glucose [Mass/volume] in Serum or Plasma --2 hours post 75g PO',
    component: 'Glucose (2h Postprandial)',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal <140 mg/dL; Prediabetes 140-199; Diabetes >=200 mg/dL',
  );

  static const LoincCode insulin = LoincCode(
    code: '20448-4',
    displayName: 'Insulin [Mass/volume] in Serum or Plasma',
    component: 'Insulin',
    property: 'Mass concentration',
    unit: 'mIU/L',
    description: 'Fasting: 2.6-24.9 mIU/L (insulin resistance marker)',
  );

  static const LoincCode cpeptide = LoincCode(
    code: '1989-4',
    displayName: 'C-peptide of insulin [Mass/volume] in Serum or Plasma',
    component: 'C-Peptide',
    property: 'Mass concentration',
    unit: 'ng/mL',
    description: 'Fasting: 0.8-3.1 ng/mL (endogenous insulin production)',
  );

  // Electrolytes
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

  static const LoincCode chloride = LoincCode(
    code: '2075-0',
    displayName: 'Chloride [Moles/volume] in Serum or Plasma',
    component: 'Chloride',
    property: 'Molar concentration',
    unit: 'mmol/L',
    description: 'Normal: 96-106 mmol/L',
  );

  static const LoincCode carbonDioxide = LoincCode(
    code: '2028-9',
    displayName: 'Carbon dioxide [Moles/volume] in Serum or Plasma',
    component: 'CO2 (Bicarbonate)',
    property: 'Molar concentration',
    unit: 'mmol/L',
    description: 'Normal: 23-29 mmol/L',
  );

  static const LoincCode anionGap = LoincCode(
    code: '1966-1',
    displayName: 'Anion gap',
    component: 'Anion Gap',
    property: 'Molar concentration',
    unit: 'mmol/L',
    description: 'Normal: 8-12 mmol/L (elevated in metabolic acidosis)',
  );

  static const LoincCode calcium = LoincCode(
    code: '17861-6',
    displayName: 'Calcium [Mass/volume] in Serum or Plasma',
    component: 'Calcium',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 8.5-10.5 mg/dL',
  );

  static const LoincCode calciumIonized = LoincCode(
    code: '19923-1',
    displayName: 'Calcium.ionized [Mass/volume] in Serum or Plasma',
    component: 'Calcium (Ionized)',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 4.5-5.6 mg/dL',
  );

  static const LoincCode phosphorus = LoincCode(
    code: '2777-1',
    displayName: 'Phosphate [Mass/volume] in Serum or Plasma',
    component: 'Phosphorus',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 2.5-4.5 mg/dL',
  );

  static const LoincCode magnesium = LoincCode(
    code: '2597-2',
    displayName: 'Magnesium [Mass/volume] in Serum or Plasma',
    component: 'Magnesium',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 1.7-2.2 mg/dL',
  );

  static const LoincCode iron = LoincCode(
    code: '2508-8',
    displayName: 'Iron [Mass/volume] in Serum or Plasma',
    component: 'Iron (Serum)',
    property: 'Mass concentration',
    unit: 'ug/dL',
    description: 'Normal: Male 65-175, Female 50-170 ug/dL',
  );

  static const LoincCode tibc = LoincCode(
    code: '2501-3',
    displayName: 'Iron binding capacity unsaturated [Mass/volume] in Serum or Plasma',
    component: 'TIBC',
    property: 'Mass concentration',
    unit: 'ug/dL',
    description: 'Normal: 250-370 ug/dL',
  );

  static const LoincCode ferritin = LoincCode(
    code: '2276-4',
    displayName: 'Ferritin [Mass/volume] in Serum or Plasma',
    component: 'Ferritin',
    property: 'Mass concentration',
    unit: 'ng/mL',
    description: 'Normal: Male 20-250, Female 10-120 ng/mL',
  );

  static const LoincCode ironSaturation = LoincCode(
    code: '2502-1',
    displayName: 'Iron saturation [Mass ratio] in Serum or Plasma',
    component: 'Iron Saturation',
    property: 'Mass fraction',
    unit: '%',
    description: 'Normal: 20-50%',
  );

  // ==================== LIPID PANEL ====================
  static const LoincCode totalCholesterol = LoincCode(
    code: '2093-3',
    displayName: 'Cholesterol [Mass/volume] in Serum or Plasma',
    component: 'Total Cholesterol',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Desirable <200 mg/dL; Borderline high 200-239; High >=240',
  );

  static const LoincCode ldlCholesterol = LoincCode(
    code: '13457-7',
    displayName: 'Cholesterol in LDL [Mass/volume] in Serum or Plasma by calculation',
    component: 'LDL Cholesterol (Calculated)',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Optimal <100; Near optimal 100-129; Borderline high 130-159; High 160-189; Very high >=190',
  );

  static const LoincCode ldlDirect = LoincCode(
    code: '2089-1',
    displayName: 'Cholesterol in LDL [Mass/volume] in Serum or Plasma by Direct assay',
    component: 'LDL Cholesterol (Direct)',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Direct measurement when triglycerides >400 mg/dL',
  );

  static const LoincCode hdlCholesterol = LoincCode(
    code: '2085-9',
    displayName: 'Cholesterol in HDL [Mass/volume] in Serum or Plasma',
    component: 'HDL Cholesterol',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Male >=40, Female >=50 mg/dL (higher is protective)',
  );

  static const LoincCode triglycerides = LoincCode(
    code: '2571-8',
    displayName: 'Triglycerides [Mass/volume] in Serum or Plasma',
    component: 'Triglycerides',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal <150; Borderline high 150-199; High 200-499; Very high >=500',
  );

  static const LoincCode nonHdlCholesterol = LoincCode(
    code: '2514-6',
    displayName: 'Cholesterol non-HDL [Mass/volume] in Serum or Plasma',
    component: 'Non-HDL Cholesterol',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Optimal: <130 mg/dL (total minus HDL)',
  );

  static const LoincCode vldl = LoincCode(
    code: '2532-0',
    displayName: 'Cholesterol in VLDL [Mass/volume] in Serum or Plasma by calculation',
    component: 'VLDL Cholesterol',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 2-30 mg/dL (calculated as TG/5)',
  );

  static const LoincCode apolipoproteinA = LoincCode(
    code: '1852-3',
    displayName: 'Apolipoprotein A-I [Mass/volume] in Serum or Plasma',
    component: 'Apo A-I',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 100-180 mg/dL (HDL structural protein)',
  );

  static const LoincCode apolipoproteinB = LoincCode(
    code: '1853-1',
    displayName: 'Apolipoprotein B [Mass/volume] in Serum or Plasma',
    component: 'Apo B',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 60-140 mg/dL (LDL structural protein)',
  );

  static const LoincCode lpA = LoincCode(
    code: '2942-2',
    displayName: 'Lipoprotein (a) [Mass/volume] in Serum or Plasma',
    component: 'Lp(a)',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: <30 mg/dL (independent ASCVD risk factor)',
  );

  // ==================== INFLAMMATORY MARKERS ====================
  static const LoincCode crp = LoincCode(
    code: '1988-5',
    displayName: 'C-reactive protein [Mass/volume] in Serum or Plasma by High sensitivity method',
    component: 'hs-CRP',
    property: 'Mass concentration',
    unit: 'mg/L',
    description: 'Low risk <1.0; Intermediate 1.0-3.0; High >3.0 mg/L',
  );

  static const LoincCode crpStandard = LoincCode(
    code: '30522-7',
    displayName: 'C-reactive protein [Mass/volume] in Serum or Plasma',
    component: 'CRP (Standard)',
    property: 'Mass concentration',
    unit: 'mg/L',
    description: 'Normal <10 mg/L (acute inflammation marker)',
  );

  static const LoincCode esr = LoincCode(
    code: '30341-2',
    displayName: 'Erythrocyte sedimentation rate [Velocity] in Blood',
    component: 'ESR',
    property: 'Velocity',
    unit: 'mm/hr',
    description: 'Normal: Male age/2, Female (age+10)/2 (chronic inflammation)',
  );

  static const LoincCode procalcitonin = LoincCode(
    code: '51801-1',
    displayName: 'Procalcitonin [Mass/volume] in Serum or Plasma',
    component: 'PCT',
    property: 'Mass concentration',
    unit: 'ng/mL',
    description: 'Normal <0.05; Bacterial infection >0.25; Sepsis >2.0 ng/mL',
  );

  static const LoincCode ferritinHigh = LoincCode(
    code: '2276-4',
    displayName: 'Ferritin [Mass/volume] in Serum or Plasma',
    component: 'Ferritin (Inflammation)',
    property: 'Mass concentration',
    unit: 'ng/mL',
    description: 'Also an acute phase reactant (elevated in inflammation)',
  );

  // ==================== VITAMINS ====================
  static const LoincCode vitaminD25Oh = LoincCode(
    code: '1989-3',
    displayName: 'Vitamin D, 25-Hydroxy [Mass/volume] in Serum or Plasma',
    component: '25-Hydroxy Vitamin D',
    property: 'Mass concentration',
    unit: 'ng/mL',
    description: 'Deficient <20; Insufficient 20-29; Sufficient 30-100; Toxic >150 ng/mL',
  );

  static const LoincCode vitaminB12 = LoincCode(
    code: '2132-9',
    displayName: 'Cobalamin (Vitamin B12) [Mass/volume] in Serum or Plasma',
    component: 'Vitamin B12',
    property: 'Mass concentration',
    unit: 'pg/mL',
    description: 'Normal: 200-900 pg/mL; Deficient <200 pg/mL',
  );

  static const LoincCode folate = LoincCode(
    code: '2284-8',
    displayName: 'Folate [Mass/volume] in Serum or Plasma',
    component: 'Folate (Serum)',
    property: 'Mass concentration',
    unit: 'ng/mL',
    description: 'Normal: >3 ng/mL; Deficient <3 ng/mL',
  );

  static const LoincCode folateRbc = LoincCode(
    code: '2278-0',
    displayName: 'Folate [Mass/volume] in Red Blood Cells',
    component: 'Folate (RBC)',
    property: 'Mass concentration',
    unit: 'ng/mL',
    description: 'Normal: 160-700 ng/mL (reflects tissue folate stores)',
  );

  static const LoincCode homocysteine = LoincCode(
    code: '25428-4',
    displayName: 'Homocysteine [Mass/volume] in Serum or Plasma',
    component: 'Homocysteine',
    property: 'Mass concentration',
    unit: 'umol/L',
    description: 'Normal: 4-15 umol/L (elevated in B12/folate deficiency)',
  );

  static const LoincCode methylmalonicAcid = LoincCode(
    code: '2891-9',
    displayName: 'Methylmalonic acid [Mass/volume] in Serum or Plasma',
    component: 'MMA',
    property: 'Mass concentration',
    unit: 'ug/L',
    description: 'Normal: 0-0.4 umol/L (specific for B12 deficiency)',
  );

  static const LoincCode vitaminE = LoincCode(
    code: '2252-5',
    displayName: 'Vitamin E [Mass/volume] in Serum or Plasma',
    component: 'Vitamin E (Alpha-tocopherol)',
    property: 'Mass concentration',
    unit: 'mg/L',
    description: 'Normal: 5-18 mg/L',
  );

  static const LoincCode vitaminK = LoincCode(
    code: '9038-9',
    displayName: 'Phylloquinone (Vitamin K1) [Mass/volume] in Serum or Plasma',
    component: 'Vitamin K',
    property: 'Mass concentration',
    unit: 'ng/L',
    description: 'Reference: 0.1-3.2 ng/L',
  );

  // ==================== THYROID ====================
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

  static const LoincCode freeT3 = LoincCode(
    code: '3053-6',
    displayName: 'Triiodothyronine free T3 [Mass/volume] in Serum or Plasma',
    component: 'Free T3',
    property: 'Mass concentration',
    unit: 'pg/mL',
    description: 'Normal: 2.3-4.2 pg/mL',
  );

  static const LoincCode totalT3 = LoincCode(
    code: '3051-0',
    displayName: 'Triiodothyronine T3 [Mass/volume] in Serum or Plasma',
    component: 'Total T3',
    property: 'Mass concentration',
    unit: 'ng/dL',

    description: 'Normal: 80-200 ng/dL',
  );

  static const LoincCode totalT4 = LoincCode(
    code: '3024-7',
    displayName: 'Thyroxine T4 [Mass/volume] in Serum or Plasma',
    component: 'Total T4',
    property: 'Mass concentration',
    unit: 'ug/dL',
    description: 'Normal: 4.5-12.5 ug/dL',
  );

  static const LoincCode tpoAntibody = LoincCode(
    code: '3016-3',
    displayName: 'Thyroid peroxidase antibody [Titer] in Serum or Plasma',
    component: 'TPO Antibody',
    property: 'Titer',
    unit: 'IU/mL',
    description: 'Normal: <35 IU/mL (elevated in Hashimoto/Graves)',
  );

  static const LoincCode tsgAntibody = LoincCode(
    code: '2878-7',
    displayName: 'Thyroglobulin antibody [Titer] in Serum or Plasma',
    component: 'TSI/TRAb',
    property: 'Titer',
    unit: 'IU/L',
    description: 'Elevated in Graves disease',
  );

  // ==================== URINALYSIS ====================
  static const LoincCode urinePh = LoincCode(
    code: '2756-5',
    displayName: 'pH [Potential of hydrogen] in Urine by Dipstick',
    component: 'Urine pH',
    property: 'Potential of hydrogen',
    unit: 'pH',
    description: 'Normal: 4.5-8.0 (acidic diet lowers, infection raises)',
  );

  static const LoincCode urineSpecificGravity = LoincCode(
    code: '5811-3',
    displayName: 'Specific gravity of Urine',
    component: 'Urine Specific Gravity',
    property: 'Relative density',
    unit: 'g/mL',
    description: 'Normal: 1.005-1.030 (concentrated = hydration status)',
  );

  static const LoincCode urineGlucose = LoincCode(
    code: '5792-5',
    displayName: 'Glucose [Mass/volume] in Urine by Dipstick',
    component: 'Urine Glucose',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: Negative (positive = diabetes/uncontrolled)',
  );

  static const LoincCode urineKetones = LoincCode(
    code: '2514-6',
    displayName: 'Ketones [Mass/volume] in Urine by Dipstick',
    component: 'Urine Ketones',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: Negative (positive = DKA/starvation)',
  );

  static const LoincCode urineBlood = LoincCode(
    code: '5794-1',
    displayName: 'Hemoglobin [Mass/volume] in Urine by Dipstick',
    component: 'Urine Blood',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: Negative (positive = hematuria/RBCs)',
  );

  static const LoincCode urineLeukocyteEsterase = LoincCode(
    code: '5799-0',
    displayName: 'Leukocyte esterase [Enzymatic activity] in Urine by Dipstick',
    component: 'Urine Leukocyte Esterase',
    property: 'Enzymatic activity',
    unit: 'U/L',
    description: 'Normal: Negative (positive = WBCs/UTI)',
  );

  static const LoincCode urineNitrite = LoincCode(
    code: '5802-2',
    displayName: 'Nitrite [Presence] in Urine by Dipstick',
    component: 'Urine Nitrite',
    property: 'Presence',
    unit: 'Positive/Negative',
    description: 'Normal: Negative (positive = bacterial UTI)',
  );

  static const LoincCode urineProteinDipstick = LoincCode(
    code: '20454-0',
    displayName: 'Protein [Mass/volume] in Urine by Dipstick',
    component: 'Urine Protein (Dipstick)',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: Negative to Trace; Significant proteinuria >=30 mg/dL',
  );

  static const LoincCode urineBilirubin = LoincCode(
    code: '20454-1',
    displayName: 'Bilirubin [Mass/volume] in Urine by Dipstick',
    component: 'Urine Bilirubin',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: Negative (positive = liver disease/obstruction)',
  );

  static const LoincCode urineUrobilinogen = LoincCode(
    code: '20454-2',
    displayName: 'Urobilinogen [Mass/volume] in Urine',
    component: 'Urine Urobilinogen',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Normal: 0.1-1.0 mg/dL (elevated in hemolysis/liver disease)',
  );

  static const LoincCode urineColor = LoincCode(
    code: '5778-6',
    displayName: 'Color of Urine',
    component: 'Urine Color',
    property: 'Visual',
    unit: 'description',
    description: 'Normal: Pale yellow (dark = dehydration/concentrated)',
  );

  static const LoincCode urineAppearance = LoincCode(
    code: '5779-4',
    displayName: 'Appearance of Urine',
    component: 'Urine Appearance',
    property: 'Visual',
    unit: 'description',
    description: 'Normal: Clear (cloudy = infection/crystals)',
  );

  // ==================== CARDIAC MARKERS ====================
  static const LoincCode troponinI = LoincCode(
    code: '6598-7',
    displayName: 'Troponin I [Mass/volume] in Serum or Plasma',
    component: 'Troponin I',
    property: 'Mass concentration',
    unit: 'ng/mL',
    description: 'Normal: <0.04 ng/mL (acute MI >0.04)',
  );

  static const LoincCode troponinTHighSensitivity = LoincCode(
    code: '89579-1',
    displayName: 'Troponin T.cardiac [Mass/volume] in Serum or Plasma by High sensitivity method',
    component: 'hs-Troponin T',
    property: 'Mass concentration',
    unit: 'ng/L',
    description: 'Normal: <14 ng/L; elevated in MI, heart failure',
  );

  static const LoincCode bnp = LoincCode(
    code: '33762-6',
    displayName: 'Natriuretic peptide B [Mass/volume] in Serum or Plasma',
    component: 'BNP',
    property: 'Mass concentration',
    unit: 'pg/mL',
    description: 'Normal <100 pg/mL; Heart failure: >400 pg/mL',
  );

  static const LoincCode ntProbnp = LoincCode(
    code: '33762-6',
    displayName: 'Natriuretic peptide B NTpro [Mass/volume] in Serum or Plasma',
    component: 'NT-proBNP',
    property: 'Mass concentration',
    unit: 'pg/mL',
    description: 'Normal <125 pg/mL (<75y); Heart failure >2000 pg/mL',
  );

  static const LoincCode ckTotal = LoincCode(
    code: '2157-6',
    displayName: 'Creatine kinase [Enzymatic activity/volume] in Serum or Plasma',
    component: 'Total CK',
    property: 'Enzymatic activity',
    unit: 'U/L',
    description: 'Normal: Male 39-308, Female 26-192 U/L (muscle damage)',
  );

  static const LoincCode ckMb = LoincCode(
    code: '6777-7',
    displayName: 'Creatine kinase MB isoenzyme [Enzymatic activity/volume] in Serum or Plasma',
    component: 'CK-MB',
    property: 'Enzymatic activity',
    unit: 'U/L',
    description: 'Normal: 0-6% of total (cardiac specific when elevated)',
  );

  static const LoincCode myoglobin = LoincCode(
    code: '2601-2',
    displayName: 'Myoglobin [Mass/volume] in Serum or Plasma',
    component: 'Myoglobin',
    property: 'Mass concentration',
    unit: 'ng/mL',
    description: 'Normal: Male 25-72, Female 25-58 ng/mL (early MI marker)',
  );

  static const LoincCode ldlCholesterolDirect = LoincCode(
    code: '18263-4',
    displayName: 'Cholesterol in LDL [Mass/volume] in Serum or Plasma by Direct measurement',
    component: 'LDL Direct',
    property: 'Mass concentration',
    unit: 'mg/dL',
    description: 'Direct LDL when TG >400 mg/dL',
  );

  // ==================== ALL LABS ====================
  static const List<LoincCode> all = [
    // CBC
    hemoglobin, hematocrit, whiteBloodCellCount, plateletCount,
    rbcCount, mcv, mch, mchc, rdw, neutrophilsAbsolute, lymphocytesAbsolute,
    monocytesAbsolute, eosinophilsAbsolute, basophilsAbsolute, mpv,
    // Liver
    alt, ast, alp, totalBilirubin, directBilirubin, indirectBilirubin,
    ggt, ldH, totalProtein, albumin, pt, inr, aptt,
    // Kidney
    creatinine, bun, egfr, egfrNonAfricanAmerican, egfrAfricanAmerican,
    egfrCkdEpi, creatinineUrine, proteinUrine, proteinUrineSpot,
    microalbuminUrine, albuminCreatinineRatio, bunCreatinineRatio,
    uricAcid, cystatinC,
    // Metabolic
    glucose, glucoseRandom, hemoglobinA1c, glucoseTwoHourPostPrandial,
    insulin, cpeptide,
    // Electrolytes
    sodium, potassium, chloride, carbonDioxide, anionGap,
    calcium, calciumIonized, phosphorus, magnesium,
    iron, tibc, ferritin, ironSaturation,
    // Lipids
    totalCholesterol, ldlCholesterol, ldlDirect, hdlCholesterol,
    triglycerides, nonHdlCholesterol, vldl, apolipoproteinA,
    apolipoproteinB, lpA,
    // Inflammatory
    crp, crpStandard, esr, procalcitonin, ferritinHigh,
    // Vitamins
    vitaminD25Oh, vitaminB12, folate, folateRbc, homocysteine,
    methylmalonicAcid, vitaminE, vitaminK,
    // Thyroid
    tsh, freeT4, freeT3, totalT3, totalT4, tpoAntibody, tsgAntibody,
    // Urinalysis
    urinePh, urineSpecificGravity, urineGlucose, urineKetones,
    urineBlood, urineLeukocyteEsterase, urineNitrite, urineProteinDipstick,
    urineBilirubin, urineUrobilinogen, urineColor, urineAppearance,
    // Cardiac
    troponinI, troponinTHighSensitivity, bnp, ntProbnp,
    ckTotal, ckMb, myoglobin, ldlCholesterolDirect,
  ];

  /// Find by LOINC code
  static LoincCode? findByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Find by component name
  static LoincCode? findByComponent(String component) {
    final lower = component.toLowerCase();
    try {
      return all.firstWhere((c) => c.component.toLowerCase() == lower);
    } catch (_) {
      return null;
    }
  }
}
