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

/// Comprehensive ICD-10 codes for clinical conditions
class Icd10ChronicConditions {
  // ==================== ENDOCRINE (E10-E14) ====================
  // Diabetes
  static const Icd10Code diabetesType1 = Icd10Code(
    code: 'E10',
    displayName: 'Type 1 diabetes mellitus',
    category: 'Endocrine',
    synonyms: ['DM1', 'Diabetes tipo 1', 'Diabetes mellitus type I'],
  );

  static const Icd10Code diabetesType2 = Icd10Code(
    code: 'E11',
    displayName: 'Type 2 diabetes mellitus',
    category: 'Endocrine',
    synonyms: ['DM2', 'Diabetes tipo 2', 'Diabetes mellitus type II'],
  );

  static const Icd10Code diabetesDueToUnderlyingCondition = Icd10Code(
    code: 'E08',
    displayName: 'Diabetes mellitus due to underlying condition',
    category: 'Endocrine',
    synonyms: ['Secondary diabetes'],
  );

  static const Icd10Code drugInducedDiabetes = Icd10Code(
    code: 'E09',
    displayName: 'Drug or chemical induced diabetes mellitus',
    category: 'Endocrine',
    synonyms: ['Steroid diabetes', 'Glucocorticoid-induced diabetes'],
  );

  static const Icd10Code malnutritionRelatedDiabetes = Icd10Code(
    code: 'E12',
    displayName: 'Malnutrition-related diabetes mellitus',
    category: 'Endocrine',
    synonyms: ['JR diabetes', 'Tropical diabetes'],
  );

  static const Icd10Code otherSpecifiedDiabetes = Icd10Code(
    code: 'E13',
    displayName: 'Other specified diabetes mellitus',
    category: 'Endocrine',
    synonyms: ['Other diabetes', 'Diabetes NOS'],
  );

  static const Icd10Code unspecifiedDiabetes = Icd10Code(
    code: 'E14',
    displayName: 'Unspecified diabetes mellitus',
    category: 'Endocrine',
    synonyms: ['Diabetes NOS', 'Diabetes sin especificar'],
  );

  // Diabetes complications
  static const Icd10Code diabetesWithKetoacidosis = Icd10Code(
    code: 'E10.1',
    displayName: 'Type 1 diabetes mellitus with ketoacidosis',
    category: 'Endocrine',
    synonyms: ['DKA', 'Diabetic ketoacidosis'],
  );

  static const Icd10Code diabetesWithNephropathy = Icd10Code(
    code: 'E11.21',
    displayName: 'Type 2 diabetes mellitus with diabetic nephropathy',
    category: 'Endocrine',
    synonyms: ['Diabetic kidney disease', 'DKD'],
  );

  static const Icd10Code diabetesWithRetinopathy = Icd10Code(
    code: 'E11.31',
    displayName: 'Type 2 diabetes mellitus with diabetic retinopathy',
    category: 'Endocrine',
    synonyms: ['Diabetic eye disease'],
  );

  static const Icd10Code diabetesWithNeuropathy = Icd10Code(
    code: 'E11.4',
    displayName: 'Type 2 diabetes mellitus with diabetic neuropathy',
    category: 'Endocrine',
    synonyms: ['Diabetic peripheral neuropathy'],
  );

  static const Icd10Code diabetesWithPeripheralAngiopathy = Icd10Code(
    code: 'E11.51',
    displayName: 'Type 2 diabetes mellitus with diabetic peripheral angiopathy',
    category: 'Endocrine',
    synonyms: ['Diabetic PAD', 'Diabetic vascular disease'],
  );

  // Thyroid
  static const Icd10Code hyperthyroidism = Icd10Code(
    code: 'E05.90',
    displayName: 'Thyrotoxicosis, unspecified without thyrotoxic storm',
    category: 'Endocrine',
    synonyms: ['Hyperthyroidism', 'Tirotoxicosis'],
  );

  static const Icd10Code hypothyroidism = Icd10Code(
    code: 'E03.9',
    displayName: 'Hypothyroidism, unspecified',
    category: 'Endocrine',
    synonyms: ['Underactive thyroid', 'Hipotiroidismo'],
  );

  static const Icd10Code thyroidNodule = Icd10Code(
    code: 'E04.9',
    displayName: 'Thyroid nodule, unspecified',
    category: 'Endocrine',
    synonyms: ['Goiter', 'Bocio'],
  );

  static const Icd10Code thyroidCancer = Icd10Code(
    code: 'C73',
    displayName: 'Malignant neoplasm of thyroid gland',
    category: 'Cancer',
    synonyms: ['Thyroid carcinoma'],
  );

  // Electrolyte disorders
  static const Icd10Code hyperkalemia = Icd10Code(
    code: 'E87.5',
    displayName: 'Hyperkalemia',
    category: 'Endocrine',
    synonyms: ['High potassium'],
  );

  static const Icd10Code hypokalemia = Icd10Code(
    code: 'E87.6',
    displayName: 'Hypokalemia',
    category: 'Endocrine',
    synonyms: ['Low potassium'],
  );

  static const Icd10Code hyponatremia = Icd10Code(
    code: 'E87.1',
    displayName: 'Hyponatremia',
    category: 'Endocrine',
    synonyms: ['Low sodium'],
  );

  static const Icd10Code hypernatremia = Icd10Code(
    code: 'E87.0',
    displayName: 'Hypernatremia',
    category: 'Endocrine',
    synonyms: ['High sodium'],
  );

  static const Icd10Code hypercalcemia = Icd10Code(
    code: 'E83.52',
    displayName: 'Hypercalcemia',
    category: 'Endocrine',
    synonyms: ['High calcium'],
  );

  static const Icd10Code hypocalcemia = Icd10Code(
    code: 'E83.51',
    displayName: 'Hypocalcemia',
    category: 'Endocrine',
    synonyms: ['Low calcium', 'Tetany'],
  );

  // Other endocrine
  static const Icd10Code metabolicSyndrome = Icd10Code(
    code: 'E88.81',
    displayName: 'Metabolic syndrome',
    category: 'Endocrine',
    synonyms: ['MetS', 'Insulin resistance syndrome'],
  );

  static const Icd10Code adrenalInsufficiency = Icd10Code(
    code: 'E27.40',
    displayName: 'Unspecified adrenocortical insufficiency',
    category: 'Endocrine',
    synonyms: ['Addison disease', 'Adrenal failure'],
  );

  static const Icd10Code cushingSyndrome = Icd10Code(
    code: 'E24.9',
    displayName: "Cushing's syndrome, unspecified",
    category: 'Endocrine',
    synonyms: ['Hypercortisolism'],
  );

  static const Icd10Code polycysticOvarySyndrome = Icd10Code(
    code: 'E28.2',
    displayName: 'Polycystic ovarian syndrome',
    category: 'Endocrine',
    synonyms: ['PCOS', 'Stein-Leventhal syndrome'],
  );

  static const Icd10Code vitaminDDeficiency = Icd10Code(
    code: 'E55.9',
    displayName: 'Vitamin D deficiency, unspecified',
    category: 'Endocrine',
    synonyms: ['Hypovitaminosis D', 'Rickets'],
  );

  static const Icd10Code hyperuricemia = Icd10Code(
    code: 'E79.0',
    displayName: 'Hyperuricemia',
    category: 'Endocrine',
    synonyms: ['Gout', 'Gota'],
  );

  // ==================== CARDIOVASCULAR ====================
  static const Icd10Code hypertension = Icd10Code(
    code: 'I10',
    displayName: 'Essential (primary) hypertension',
    category: 'Cardiovascular',
    synonyms: ['High blood pressure', 'Presión alta', 'HTN'],
  );

  static const Icd10Code hypertensiveEmergency = Icd10Code(
    code: 'I16.1',
    displayName: 'Hypertensive urgency',
    category: 'Cardiovascular',
    synonyms: ['Severe hypertension', 'Blood pressure crisis'],
  );

  static const Icd10Code atrialFibrillation = Icd10Code(
    code: 'I48.91',
    displayName: 'Unspecified atrial fibrillation',
    category: 'Cardiovascular',
    synonyms: ['AFib', 'Fibrilación auricular'],
  );

  static const Icd10Code atrialFlutter = Icd10Code(
    code: 'I48.3',
    displayName: 'Typical atrial flutter',
    category: 'Cardiovascular',
    synonyms: ['AFL', 'Atrial flutter'],
  );

  static const Icd10Code heartFailure = Icd10Code(
    code: 'I50.9',
    displayName: 'Heart failure, unspecified',
    category: 'Cardiovascular',
    synonyms: ['CHF', 'Insuficiencia cardíaca', 'Congestive heart failure'],
  );

  static const Icd10Code heartFailureReducedEF = Icd10Code(
    code: 'I50.22',
    displayName: 'Systolic (congestive) heart failure',
    category: 'Cardiovascular',
    synonyms: ['HFrEF', 'Reduced ejection fraction'],
  );

  static const Icd10Code heartFailurePreservedEF = Icd10Code(
    code: 'I50.30',
    displayName: 'Diastolic (congestive) heart failure',
    category: 'Cardiovascular',
    synonyms: ['HFpEF', 'Preserved ejection fraction'],
  );

  static const Icd10Code acuteMyocardialInfarction = Icd10Code(
    code: 'I21.9',
    displayName: 'Acute myocardial infarction, unspecified',
    category: 'Cardiovascular',
    synonyms: ['STEMI', 'NSTEMI', 'Heart attack', 'Infarto'],
  );

  static const Icd10Code stableAngina = Icd10Code(
    code: 'I25.10',
    displayName: 'Atherosclerotic heart disease of native coronary artery',
    category: 'Cardiovascular',
    synonyms: ['Stable angina', 'Chronic stable angina'],
  );

  static const Icd10Code coronaryArteryDisease = Icd10Code(
    code: 'I25.9',
    displayName: 'Chronic ischemic heart disease, unspecified',
    category: 'Cardiovascular',
    synonyms: ['CAD', 'Coronary artery disease', 'EAC'],
  );

  static const Icd10Code peripheralVascularDisease = Icd10Code(
    code: 'I73.9',
    displayName: 'Peripheral vascular disease, unspecified',
    category: 'Cardiovascular',
    synonyms: ['PVD', 'Peripheral arterial disease', 'PAD'],
  );

  static const Icd10Code carotidArteryStenosis = Icd10Code(
    code: 'I65.29',
    displayName: 'Occlusion and stenosis of other carotid artery',
    category: 'Cardiovascular',
    synonyms: ['Carotid stenosis', 'CAS'],
  );

  static const Icd10Code aorticAneurysm = Icd10Code(
    code: 'I71.9',
    displayName: 'Aortic aneurysm, unspecified site',
    category: 'Cardiovascular',
    synonyms: ['AAA', 'Thoracic aortic aneurysm'],
  );

  static const Icd10Code aorticDissection = Icd10Code(
    code: 'I71.00',
    displayName: 'Dissection of unspecified site of aorta',
    category: 'Cardiovascular',
    synonyms: ['Aortic dissection'],
  );

  static const Icd10Code varicoseVeins = Icd10Code(
    code: 'I83.90',
    displayName: 'Asymptomatic varicose veins of unspecified lower extremity',
    category: 'Cardiovascular',
    synonyms: ['Varicose veins', 'Spider veins'],
  );

  static const Icd10Code lymphedema = Icd10Code(
    code: 'I89.0',
    displayName: 'Lymphedema, not elsewhere classified',
    category: 'Cardiovascular',
    synonyms: ['Lymphedema', 'Dependent edema'],
  );

  // ==================== METABOLIC ====================
  static const Icd10Code obesity = Icd10Code(
    code: 'E66.9',
    displayName: 'Obesity, unspecified',
    category: 'Endocrine',
    synonyms: ['Obesidad', 'Obesity class I'],
  );

  static const Icd10Code severeObesity = Icd10Code(
    code: 'E66.01',
    displayName: 'Morbid (severe) obesity with alveolar hypoventilation',
    category: 'Endocrine',
    synonyms: ['Morbid obesity', 'Obesity class III', 'Bariatric'],
  );

  static const Icd10Code hyperlipidemia = Icd10Code(
    code: 'E78.5',
    displayName: 'Hyperlipidemia, unspecified',
    category: 'Endocrine',
    synonyms: ['High cholesterol', 'Colesterol alto', 'Dyslipidemia'],
  );

  static const Icd10Code hypercholesterolemia = Icd10Code(
    code: 'E78.0',
    displayName: 'Pure hypercholesterolemia',
    category: 'Endocrine',
    synonyms: ['High total cholesterol'],
  );

  static const Icd10Code hypertriglyceridemia = Icd10Code(
    code: 'E78.1',
    displayName: 'Pure hyperglyceridemia',
    category: 'Endocrine',
    synonyms: ['High triglycerides'],
  );

  static const Icd10Code mixedHyperlipidemia = Icd10Code(
    code: 'E78.2',
    displayName: 'Mixed hyperlipidemia',
    category: 'Endocrine',
    synonyms: ['Combined dyslipidemia'],
  );

  // ==================== RESPIRATORY (J40-J47) ====================
  static const Icd10Code acuteBronchitis = Icd10Code(
    code: 'J40',
    displayName: 'Bronchitis, not specified as acute or chronic',
    category: 'Respiratory',
    synonyms: ['Chest cold', 'Acute bronchitis', 'Bronquitis aguda'],
  );

  static const Icd10Code simpleChronicBronchitis = Icd10Code(
    code: 'J41.0',
    displayName: 'Simple chronic bronchitis',
    category: 'Respiratory',
    synonyms: ['Chronic simple bronchitis'],
  );

  static const Icd10Code mucopurulentChronicBronchitis = Icd10Code(
    code: 'J41.1',
    displayName: 'Mucopurulent chronic bronchitis',
    category: 'Respiratory',
    synonyms: ['Chronic mucopurulent bronchitis'],
  );

  static const Icd10Code mixedChronicBronchitis = Icd10Code(
    code: 'J41.8',
    displayName: 'Mixed simple and mucopurulent chronic bronchitis',
    category: 'Respiratory',
    synonyms: ['Chronic bronchitis mixed'],
  );

  static const Icd10Code unspecifiedChronicBronchitis = Icd10Code(
    code: 'J42',
    displayName: 'Unspecified chronic bronchitis',
    category: 'Respiratory',
    synonyms: ['Chronic bronchitis', 'Bronquitis crónica'],
  );

  static const Icd10Code emphysema = Icd10Code(
    code: 'J43.9',
    displayName: 'Emphysema, unspecified',
    category: 'Respiratory',
    synonyms: ['COPD emphysema'],
  );

  static const Icd10Code otherEmphysema = Icd10Code(
    code: 'J43.8',
    displayName: 'Other emphysema',
    category: 'Respiratory',
    synonyms: ['Panacinar emphysema', 'Centrilobular emphysema'],
  );

  static const Icd10Code bronchiectasis = Icd10Code(
    code: 'J47.9',
    displayName: 'Bronchiectasis, uncomplicated',
    category: 'Respiratory',
    synonyms: ['Dilated airways', 'Bronchiectasia'],
  );

  static const Icd10Code copdAcuteExacerbation = Icd10Code(
    code: 'J44.1',
    displayName: 'COPD with acute exacerbation',
    category: 'Respiratory',
    synonyms: ['COPD flare', 'Acute COPD exacerbation', 'Exacerbación EPOC'],
  );

  static const Icd10Code copdAcuteBronchitis = Icd10Code(
    code: 'J44.0',
    displayName: 'COPD with acute bronchitis',
    category: 'Respiratory',
    synonyms: ['COPD with acute LRI'],
  );

  static const Icd10Code asthmaUnspecified = Icd10Code(
    code: 'J45.909',
    displayName: 'Unspecified asthma, uncomplicated',
    category: 'Respiratory',
    synonyms: ['Asma', 'Asthma'],
  );

  static const Icd10Code asthmaAcuteExacerbation = Icd10Code(
    code: 'J45.41',
    displayName: 'Chronic obstructive asthma with acute exacerbation',
    category: 'Respiratory',
    synonyms: ['Asthma attack', 'Acute asthma exacerbation'],
  );

  static const Icd10Code asthmaMildIntermittent = Icd10Code(
    code: 'J45.20',
    displayName: 'Mild intermittent asthma, uncomplicated',
    category: 'Respiratory',
    synonyms: ['Mild asthma'],
  );

  static const Icd10Code asthmaModeratePersistent = Icd10Code(
    code: 'J45.30',
    displayName: 'Mild persistent asthma, uncomplicated',
    category: 'Respiratory',
    synonyms: ['Moderate asthma'],
  );

  static const Icd10Code asthmaSeverePersistent = Icd10Code(
    code: 'J45.5',
    displayName: 'Severe persistent asthma',
    category: 'Respiratory',
    synonyms: ['Status asthmaticus', 'Life-threatening asthma'],
  );

  static const Icd10Code respiratoryFailure = Icd10Code(
    code: 'J96.90',
    displayName: 'Respiratory failure, unspecified',
    category: 'Respiratory',
    synonyms: ['Acute respiratory failure', 'Insuficiencia respiratoria'],
  );

  static const Icd10Code ards = Icd10Code(
    code: 'J80',
    displayName: 'Acute respiratory distress syndrome',
    category: 'Respiratory',
    synonyms: ['ARDS', 'Shock lung'],
  );

  static const Icd10Code pneumoniaUnspecified = Icd10Code(
    code: 'J18.9',
    displayName: 'Pneumonia, unspecified organism',
    category: 'Respiratory',
    synonyms: ['Neumonía', 'Lung infection'],
  );

  static const Icd10Code viralPneumonia = Icd10Code(
    code: 'J12.89',
    displayName: 'Other viral pneumonia',
    category: 'Respiratory',
    synonyms: ['Viral pneumonia'],
  );

  static const Icd10Code pleuralEffusion = Icd10Code(
    code: 'J91.8',
    displayName: 'Pleural effusion in conditions classified elsewhere',
    category: 'Respiratory',
    synonyms: ['Fluid around lung', 'Derrame pleural'],
  );

  static const Icd10Code pneumothorax = Icd10Code(
    code: 'J93.9',
    displayName: 'Pneumothorax, unspecified',
    category: 'Respiratory',
    synonyms: ['Collapsed lung', 'Neumotórax'],
  );

  // ==================== RENAL / KIDNEY (N17-N19) ====================
  static const Icd10Code acuteKidneyFailure = Icd10Code(
    code: 'N17.9',
    displayName: 'Acute kidney failure, unspecified',
    category: 'Renal',
    synonyms: ['AKI', 'Acute renal failure', 'Insuficiencia renal aguda'],
  );

  static const Icd10Code acuteTubularNecrosis = Icd10Code(
    code: 'N17.0',
    displayName: 'Acute kidney failure with tubular necrosis',
    category: 'Renal',
    synonyms: ['ATN'],
  );

  static const Icd10Code acuteGlomerulonephritis = Icd10Code(
    code: 'N00.9',
    displayName: 'Acute nephritic syndrome, unspecified',
    category: 'Renal',
    synonyms: ['Acute glomerulonephritis', 'AGN'],
  );

  static const Icd10Code chronicKidneyDisease = Icd10Code(
    code: 'N18.9',
    displayName: 'Chronic kidney disease, unspecified',
    category: 'Renal',
    synonyms: ['CKD', 'Chronic renal disease', 'IRC'],
  );

  static const Icd10Code ckdStage1 = Icd10Code(
    code: 'N18.1',
    displayName: 'Chronic kidney disease, stage 1',
    category: 'Renal',
    synonyms: ['CKD stage 1', 'Kidney disease stage I'],
  );

  static const Icd10Code ckdStage2 = Icd10Code(
    code: 'N18.2',
    displayName: 'Chronic kidney disease, stage 2',
    category: 'Renal',
    synonyms: ['CKD stage 2'],
  );

  static const Icd10Code ckdStage3 = Icd10Code(
    code: 'N18.3',
    displayName: 'Chronic kidney disease, stage 3',
    category: 'Renal',
    synonyms: ['CKD stage 3', 'Moderately decreased GFR'],
  );

  static const Icd10Code ckdStage4 = Icd10Code(
    code: 'N18.4',
    displayName: 'Chronic kidney disease, stage 4',
    category: 'Renal',
    synonyms: ['CKD stage 4', 'Severely decreased GFR'],
  );

  static const Icd10Code ckdStage5 = Icd10Code(
    code: 'N18.5',
    displayName: 'Chronic kidney disease, stage 5',
    category: 'Renal',
    synonyms: ['CKD stage 5'],
  );

  static const Icd10Code endStageRenalDisease = Icd10Code(
    code: 'N18.6',
    displayName: 'End stage renal disease',
    category: 'Renal',
    synonyms: ['ESRD', 'Kidney failure', 'Renal failure'],
  );

  static const Icd10Code nephroticSyndrome = Icd10Code(
    code: 'N04.9',
    displayName: 'Nephrotic syndrome, unspecified',
    category: 'Renal',
    synonyms: ['Nephrosis', 'Heavy proteinuria'],
  );

  static const Icd10Code urinaryTractInfection = Icd10Code(
    code: 'N39.0',
    displayName: 'Urinary tract infection, site not specified',
    category: 'Renal',
    synonyms: ['UTI', 'Cystitis', 'Infección urinaria'],
  );

  static const Icd10Code benignProstaticHyperplasia = Icd10Code(
    code: 'N40.1',
    displayName: 'BPH with lower urinary tract symptoms',
    category: 'Renal',
    synonyms: ['BPH', 'Prostate enlargement', 'HBP'],
  );

  static const Icd10Code renalColic = Icd10Code(
    code: 'N23',
    displayName: 'Unspecified renal colic',
    category: 'Renal',
    synonyms: ['Kidney stone pain', 'Nefrolitiasis'],
  );

  static const Icd10Code hydronephrosis = Icd10Code(
    code: 'N13.9',
    displayName: 'Obstructive and reflux uropathy, unspecified',
    category: 'Renal',
    synonyms: ['Hydronephrosis', 'Blocked kidney'],
  );

  static const Icd10Code glomerulonephritis = Icd10Code(
    code: 'N05.9',
    displayName: 'Nephritic syndrome, unspecified',
    category: 'Renal',
    synonyms: ['Glomerulonephritis', 'GN'],
  );

  static const Icd10Code kidneyStone = Icd10Code(
    code: 'N20.9',
    displayName: 'Urinary calculus, unspecified',
    category: 'Renal',
    synonyms: ['Nephrolithiasis', 'Kidney stone', 'Cálculo renal'],
  );

  // ==================== LIVER CONDITIONS (K70-K77) ====================
  static const Icd10Code alcoholicLiverDisease = Icd10Code(
    code: 'K70.30',
    displayName: 'Alcoholic liver disease, unspecified',
    category: 'Liver',
    synonyms: ['Alcoholic hepatitis', 'ALH'],
  );

  static const Icd10Code alcoholicFattyLiver = Icd10Code(
    code: 'K70.0',
    displayName: 'Alcoholic fatty liver',
    category: 'Liver',
    synonyms: ['Alcoholic steatosis'],
  );

  static const Icd10Code alcoholicHepatitis = Icd10Code(
    code: 'K70.1',
    displayName: 'Alcoholic hepatitis',
    category: 'Liver',
    synonyms: ['Alcoholic liver inflammation'],
  );

  static const Icd10Code alcoholicCirrhosis = Icd10Code(
    code: 'K70.2',
    displayName: 'Alcoholic fibrosis and sclerosis of liver',
    category: 'Liver',
    synonyms: ['Alcoholic cirrhosis'],
  );

  static const Icd10Code hepaticFailure = Icd10Code(
    code: 'K72.90',
    displayName: 'Hepatic failure, unspecified',
    category: 'Liver',
    synonyms: ['Acute liver failure', 'Liver failure', 'Insuficiencia hepática'],
  );

  static const Icd10Code chronicHepaticFailure = Icd10Code(
    code: 'K72.10',
    displayName: 'Chronic hepatic failure',
    category: 'Liver',
    synonyms: ['Chronic liver failure'],
  );

  static const Icd10Code hepaticEncephalopathy = Icd10Code(
    code: 'K72.91',
    displayName: 'Hepatic failure with encephalopathy',
    category: 'Liver',
    synonyms: ['HE', 'Liver encephalopathy'],
  );

  static const Icd10Code nafld = Icd10Code(
    code: 'K76.0',
    displayName: 'Fatty (change of) liver, not elsewhere classified',
    category: 'Liver',
    synonyms: ['NAFLD', 'Non-alcoholic fatty liver disease', 'Hígado graso'],
  );

  static const Icd10Code nash = Icd10Code(
    code: 'K76.0',
    displayName: 'Nonalcoholic steatohepatitis',
    category: 'Liver',
    synonyms: ['NASH', 'Fatty liver with hepatitis'],
  );

  static const Icd10Code hepatitisB = Icd10Code(
    code: 'B18.1',
    displayName: 'Chronic viral hepatitis B without delta-agent',
    category: 'Liver',
    synonyms: ['HBV', 'Hepatitis B'],
  );

  static const Icd10Code hepatitisC = Icd10Code(
    code: 'B18.2',
    displayName: 'Chronic viral hepatitis C',
    category: 'Liver',
    synonyms: ['HCV', 'Hepatitis C'],
  );

  static const Icd10Code hepatitisA = Icd10Code(
    code: 'B15.9',
    displayName: 'Hepatitis A without hepatic coma',
    category: 'Liver',
    synonyms: ['HAV', 'Hepatitis A'],
  );

  static const Icd10Code liverCirrhosis = Icd10Code(
    code: 'K74.60',
    displayName: 'Unspecified cirrhosis of liver',
    category: 'Liver',
    synonyms: ['Cirrhosis', 'Liver scarring', 'Cirrosis'],
  );

  static const Icd10Code portalHypertension = Icd10Code(
    code: 'K76.6',
    displayName: 'Portal hypertension',
    category: 'Liver',
    synonyms: ['Hypertensive portal gastropathy'],
  );

  static const Icd10Code cholecystitis = Icd10Code(
    code: 'K81.0',
    displayName: 'Acute cholecystitis',
    category: 'Liver',
    synonyms: ['Gallbladder inflammation', 'Colecistitis'],
  );

  static const Icd10Code cholelithiasis = Icd10Code(
    code: 'K80.20',
    displayName: 'Calculus of gallbladder without cholecystitis',
    category: 'Liver',
    synonyms: ['Gallstones', 'Cholelithiasis', 'Piedras en vesícula'],
  );

  static const Icd10Code liverLesion = Icd10Code(
    code: 'K76.89',
    displayName: 'Other specified disorders of liver',
    category: 'Liver',
    synonyms: ['Liver lesion', 'Hepatic cyst'],
  );

  static const Icd10Code ascites = Icd10Code(
    code: 'K76.82',
    displayName: 'Hepatic encephalopathy in cirrhosis',
    category: 'Liver',
    synonyms: ['Ascites', 'Fluid in peritoneal cavity'],
  );

  // ==================== BLOOD / ANEMIA (D50-D64) ====================
  static const Icd10Code ironDeficiencyAnemia = Icd10Code(
    code: 'D50.9',
    displayName: 'Iron deficiency anemia, unspecified',
    category: 'Blood',
    synonyms: ['IDA', 'Anemia por deficiencia de hierro'],
  );

  static const Icd10Code ironDeficiencyAnemiaBloodLoss = Icd10Code(
    code: 'D50.0',
    displayName: 'Iron deficiency anemia secondary to blood loss',
    category: 'Blood',
    synonyms: ['Iron deficiency from bleeding'],
  );

  static const Icd10Code vitaminB12DeficiencyAnemia = Icd10Code(
    code: 'D51.9',
    displayName: 'Vitamin B12 deficiency anemia, unspecified',
    category: 'Blood',
    synonyms: ['Pernicious anemia', 'B12 deficiency', 'Anemia megaloblástica'],
  );

  static const Icd10Code folateDeficiencyAnemia = Icd10Code(
    code: 'D52.9',
    displayName: 'Folate deficiency anemia, unspecified',
    category: 'Blood',
    synonyms: ['Folic acid deficiency anemia', 'Anemia por ácido fólico'],
  );

  static const Icd10Code hemolyticAnemia = Icd10Code(
    code: 'D59.9',
    displayName: 'Acquired hemolytic anemia, unspecified',
    category: 'Blood',
    synonyms: ['Hemolytic anemia', 'Anemia hemolítica'],
  );

  static const Icd10Code sickleCellDisease = Icd10Code(
    code: 'D57.00',
    displayName: 'Sickle-cell disease without crisis',
    category: 'Blood',
    synonyms: ['SCD', 'Sickle cell anemia'],
  );

  static const Icd10Code thalassemia = Icd10Code(
    code: 'D56.9',
    displayName: 'Thalassemia, unspecified',
    category: 'Blood',
    synonyms: ['Mediterranean anemia'],
  );

  static const Icd10Code aplasticAnemia = Icd10Code(
    code: 'D61.9',
    displayName: 'Aplastic anemia, unspecified',
    category: 'Blood',
    synonyms: ['Bone marrow failure', 'Anemia aplásica'],
  );

  static const Icd10Code anemiaOfCkd = Icd10Code(
    code: 'D63.1',
    displayName: 'Anemia in chronic kidney disease',
    category: 'Blood',
    synonyms: ['Renal anemia', 'Anemia of CKD'],
  );

  static const Icd10Code anemiaOfMalignancy = Icd10Code(
    code: 'D63.0',
    displayName: 'Anemia in neoplastic disease',
    category: 'Blood',
    synonyms: ['Cancer-related anemia', 'Anemia of malignancy'],
  );

  static const Icd10Code pancytopenia = Icd10Code(
    code: 'D61.818',
    displayName: 'Other pancytopenia',
    category: 'Blood',
    synonyms: ['Pancytopenia'],
  );

  static const Icd10Code neutropenia = Icd10Code(
    code: 'D70.9',
    displayName: 'Neutropenia, unspecified',
    category: 'Blood',
    synonyms: ['Low neutrophils', 'Febrile neutropenia'],
  );

  static const Icd10Code thrombocytopenia = Icd10Code(
    code: 'D69.6',
    displayName: 'Thrombocytopenia, unspecified',
    category: 'Blood',
    synonyms: ['Low platelets', 'Trombocitopenia'],
  );

  static const Icd10Code coagulationDefect = Icd10Code(
    code: 'D68.9',
    displayName: 'Coagulation defect, unspecified',
    category: 'Blood',
    synonyms: ['Bleeding disorder', 'Coagulopathy'],
  );

  static const Icd10Code hemophilia = Icd10Code(
    code: 'D66',
    displayName: 'Hereditary factor VIII deficiency',
    category: 'Blood',
    synonyms: ['Hemophilia A', 'Factor VIII deficiency'],
  );

  static const Icd10Code vonWillebrandDisease = Icd10Code(
    code: 'D68.0',
    displayName: "Von Willebrand's disease",
    category: 'Blood',
    synonyms: ['vWD', 'vWF deficiency'],
  );

  static const Icd10Code dvt = Icd10Code(
    code: 'I82.409',
    displayName: 'Acute embolism and thrombosis of unspecified femoral vein',
    category: 'Blood',
    synonyms: ['DVT', 'Deep vein thrombosis', 'TVP'],
  );

  static const Icd10Code pulmonaryEmbolism = Icd10Code(
    code: 'I26.99',
    displayName: 'Other pulmonary embolism without acute cor pulmonale',
    category: 'Blood',
    synonyms: ['PE', 'Pulmonary embolism', 'Embolia pulmonar'],
  );

  static const Icd10Code polycythemiaVera = Icd10Code(
    code: 'D45',
    displayName: 'Polycythemia vera',
    category: 'Blood',
    synonyms: ['PV', 'Primary polycythemia'],
  );

  static const Icd10Code thrombocythemia = Icd10Code(
    code: 'D47.3',
    displayName: 'Essential (hemorrhagic) thrombocythemia',
    category: 'Blood',
    synonyms: ['ET', 'Thrombocytosis'],
  );

  // ==================== CANCER (C00-D49) ====================
  static const Icd10Code secondaryMalignantNeoplasm = Icd10Code(
    code: 'C79.9',
    displayName: 'Secondary malignant neoplasm of unspecified site',
    category: 'Cancer',
    synonyms: ['Metastatic cancer', 'Metastasis', 'Cancer secundario'],
  );

  static const Icd10Code lungCancer = Icd10Code(
    code: 'C34.90',
    displayName: 'Malignant neoplasm of unspecified part of unspecified bronchus or lung',
    category: 'Cancer',
    synonyms: ['Bronchogenic carcinoma', 'Lung carcinoma'],
  );

  static const Icd10Code breastCancer = Icd10Code(
    code: 'C50.919',
    displayName: 'Malignant neoplasm of breast, unspecified',
    category: 'Cancer',
    synonyms: ['Breast carcinoma', 'Breast cancer'],
  );

  static const Icd10Code colonCancer = Icd10Code(
    code: 'C18.9',
    displayName: 'Malignant neoplasm of colon, unspecified',
    category: 'Cancer',
    synonyms: ['Colon carcinoma', 'Colorectal cancer'],
  );

  static const Icd10Code prostateCancer = Icd10Code(
    code: 'C61',
    displayName: 'Malignant neoplasm of prostate',

    category: 'Cancer',
    synonyms: ['Prostate carcinoma'],
  );

  static const Icd10Code bladderCancer = Icd10Code(
    code: 'C67.90',
    displayName: 'Malignant neoplasm of bladder, unspecified',
    category: 'Cancer',
    synonyms: ['Bladder carcinoma'],
  );

  static const Icd10Code pancreaticCancer = Icd10Code(
    code: 'C25.9',
    displayName: 'Malignant neoplasm of pancreas, unspecified',
    category: 'Cancer',
    synonyms: ['Pancreatic carcinoma'],
  );

  static const Icd10Code gastricCancer = Icd10Code(
    code: 'C16.9',
    displayName: 'Malignant neoplasm of stomach, unspecified',
    category: 'Cancer',
    synonyms: ['Stomach cancer', 'Gastric carcinoma'],
  );

  static const Icd10Code leukemia = Icd10Code(
    code: 'C95.90',
    displayName: 'Leukemia, unspecified',
    category: 'Cancer',
    synonyms: ['Blood cancer', 'Leucemia'],
  );

  static const Icd10Code multipleMyeloma = Icd10Code(
    code: 'C90.00',
    displayName: 'Multiple myeloma not having achieved remission',
    category: 'Cancer',
    synonyms: ['Myeloma', 'Kahler disease'],
  );

  static const Icd10Code lymphoma = Icd10Code(
    code: 'C85.90',
    displayName: 'Non-Hodgkin lymphoma, unspecified',
    category: 'Cancer',
    synonyms: ['NHL', 'Lymphoma'],
  );

  static const Icd10Code melanoma = Icd10Code(
    code: 'C43.9',
    displayName: 'Malignant melanoma of skin, unspecified',
    category: 'Cancer',
    synonyms: ['Melanoma', 'Skin cancer'],
  );

  static const Icd10Code basalCellCarcinoma = Icd10Code(
    code: 'C44.91',
    displayName: 'Basal cell carcinoma of skin, unspecified',
    category: 'Cancer',
    synonyms: ['BCC', 'Rodent ulcer'],
  );

  static const Icd10Code squamousCellCarcinoma = Icd10Code(
    code: 'C44.92',
    displayName: 'Squamous cell carcinoma of skin, unspecified',
    category: 'Cancer',
    synonyms: ['SCC', 'Skin squamous cell carcinoma'],
  );

  static const Icd10Code benignNeoplasm = Icd10Code(
    code: 'D24.9',
    displayName: 'Benign neoplasm of breast, unspecified',
    category: 'Cancer',
    synonyms: ['Fibroadenoma', 'Benign breast lesion'],
  );

  static const Icd10Code carcinoidTumor = Icd10Code(
    code: 'D37.9',
    displayName: 'Neoplasm of uncertain behavior of digestive system, unspecified',
    category: 'Cancer',
    synonyms: ['Carcinoid tumor', 'NET'],
  );

  // ==================== PAIN CONDITIONS (R10-R19) ====================
  static const Icd10Code abdominalPainUnspecified = Icd10Code(
    code: 'R10.9',
    displayName: 'Unspecified abdominal pain',
    category: 'Pain',
    synonyms: ['Stomach pain', 'Abdomen agudo', 'Abdominal discomfort'],
  );

  static const Icd10Code upperAbdominalPain = Icd10Code(
    code: 'R10.10',
    displayName: 'Upper abdominal pain, unspecified',
    category: 'Pain',
    synonyms: ['Epigastric pain', 'Upper GI pain'],
  );

  static const Icd10Code rightLowerQuadrantPain = Icd10Code(
    code: 'R10.31',
    displayName: 'Right lower quadrant pain',
    category: 'Pain',
    synonyms: ['RLQ pain', 'Suspected appendicitis'],
  );

  static const Icd10Code leftLowerQuadrantPain = Icd10Code(
    code: 'R10.32',
    displayName: 'Left lower quadrant pain',
    category: 'Pain',
    synonyms: ['LLQ pain'],
  );

  static const Icd10Code rightUpperQuadrantPain = Icd10Code(
    code: 'R10.11',
    displayName: 'Right upper quadrant pain',
    category: 'Pain',
    synonyms: ['RUQ pain', 'Suspected biliary'],
  );

  static const Icd10Code leftUpperQuadrantPain = Icd10Code(
    code: 'R10.12',
    displayName: 'Left upper quadrant pain',
    category: 'Pain',
    synonyms: ['LUQ pain'],
  );

  static const Icd10Code generalizedAbdominalPain = Icd10Code(
    code: 'R10.84',
    displayName: 'Generalized abdominal pain',
    category: 'Pain',
    synonyms: ['Diffuse abdominal pain'],
  );

  static const Icd10Code chestPainUnspecified = Icd10Code(
    code: 'R07.9',
    displayName: 'Chest pain, unspecified',
    category: 'Pain',
    synonyms: ['Dolor en pecho', 'Thoracic pain'],
  );

  static const Icd10Code chestPainTypicalAnginal = Icd10Code(
    code: 'R07.9',
    displayName: 'Chest pain, other chest pain',
    category: 'Pain',
    synonyms: ['Angina pectoris', 'Cardiac chest pain'],
  );

  static const Icd10Code pleuriticChestPain = Icd10Code(
    code: 'R07.1',
    displayName: 'Chest pain on breathing',
    category: 'Pain',
    synonyms: ['Pleuritic chest pain', 'Pleurisy'],
  );

  static const Icd10Code epigastricPain = Icd10Code(
    code: 'R10.13',
    displayName: 'Epigastric pain',
    category: 'Pain',
    synonyms: ['Pain in upper abdomen', 'Gastric pain'],
  );

  static const Icd10Code neckPain = Icd10Code(
    code: 'M54.2',
    displayName: 'Cervicalgia',
    category: 'Pain',
    synonyms: ['Neck pain', 'Cervical pain'],
  );

  static const Icd10Code lowBackPain = Icd10Code(
    code: 'M54.5',
    displayName: 'Low back pain',
    category: 'Pain',
    synonyms: ['Lumbago', 'Lumbalgia', 'Lower back pain'],
  );

  static const Icd10Code lumbarRadiculopathy = Icd10Code(
    code: 'M54.12',
    displayName: 'Radiculopathy, cervical region',
    category: 'Pain',
    synonyms: ['Sciatica', 'Lumbar radiculopathy', 'Nerve root pain'],
  );

  static const Icd10Code headacheUnspecified = Icd10Code(
    code: 'R51.9',
    displayName: 'Headache, unspecified',
    category: 'Pain',
    synonyms: ['Dolor de cabeza', 'Cephalalgia'],
  );

  static const Icd10Code migraine = Icd10Code(
    code: 'G43.909',
    displayName: 'Migraine, unspecified, not intractable',
    category: 'Pain',
    synonyms: ['Migraine headache', 'Jaqueca'],
  );

  static const Icd10Code tensionHeadache = Icd10Code(
    code: 'G44.209',
    displayName: 'Tension-type headache, unspecified',
    category: 'Pain',
    synonyms: ['Tension headache', 'Muscle contraction headache'],
  );

  static const Icd10Code neuralgia = Icd10Code(
    code: 'M79.2',
    displayName: 'Neuralgia and neuritis, unspecified',
    category: 'Pain',
    synonyms: ['Nerve pain', 'Neuralgia'],
  );

  static const Icd10Code myalgia = Icd10Code(
    code: 'M79.3',
    displayName: 'Panniculitis, unspecified',
    category: 'Pain',
    synonyms: ['Muscle pain', 'Myalgia', 'Myofascial pain'],
  );

  static const Icd10Code arthralgia = Icd10Code(
    code: 'M25.50',
    displayName: 'Pain in unspecified joint',
    category: 'Pain',
    synonyms: ['Joint pain', 'Arthralgia'],
  );

  static const Icd10Code chronicPain = Icd10Code(
    code: 'G89.29',
    displayName: 'Other chronic pain',
    category: 'Pain',
    synonyms: ['Chronic pain syndrome', 'Dolor crónico'],
  );

  // ==================== SYMPTOMS / GENERAL ====================
  static const Icd10Code fatigue = Icd10Code(
    code: 'R53.83',
    displayName: 'Other fatigue',
    category: 'Symptoms',
    synonyms: ['Cansancio', 'Fatigue', 'Malaise'],
  );

  static const Icd10Code dizziness = Icd10Code(
    code: 'R42',
    displayName: 'Dizziness and giddiness',
    category: 'Symptoms',
    synonyms: ['Vertigo', 'Mareo', 'Lightheadedness'],
  );

  static const Icd10Code insomnia = Icd10Code(
    code: 'G47.00',
    displayName: 'Insomnia, unspecified',
    category: 'Symptoms',
    synonyms: ['Sleep disorder', 'Insomnio', 'Cannot sleep'],
  );

  static const Icd10Code edema = Icd10Code(
    code: 'R60.9',
    displayName: 'Edema, unspecified',
    category: 'Symptoms',
    synonyms: ['Swelling', 'Fluid retention', 'Edema'],
  );

  static const Icd10Code dyspnea = Icd10Code(
    code: 'R06.02',
    displayName: 'Shortness of breath',
    category: 'Symptoms',
    synonyms: ['SOB', 'Difficulty breathing', 'Disnea'],
  );

  static const Icd10Code cough = Icd10Code(
    code: 'R05.9',
    displayName: 'Cough, unspecified',
    category: 'Symptoms',
    synonyms: ['Tos', 'Chronic cough'],
  );

  static const Icd10Code nausea = Icd10Code(
    code: 'R11.0',
    displayName: 'Nausea',
    category: 'Symptoms',
    synonyms: ['Nausea', 'Náuseas'],
  );

  static const Icd10Code vomiting = Icd10Code(
    code: 'R11.10',
    displayName: 'Vomiting, unspecified',
    category: 'Symptoms',
    synonyms: ['Emesis', 'Vómito'],
  );

  static const Icd10Code diarrhea = Icd10Code(
    code: 'R19.7',
    displayName: 'Diarrhea, unspecified',
    category: 'Symptoms',
    synonyms: ['Diarrea', 'Loose stools'],
  );

  static const Icd10Code constipation = Icd10Code(
    code: 'K59.00',
    displayName: 'Constipation, unspecified',
    category: 'Symptoms',
    synonyms: ['Estreñimiento', 'Obstipation'],
  );

  static const Icd10Code weightLoss = Icd10Code(
    code: 'R63.4',
    displayName: 'Abnormal weight loss',
    category: 'Symptoms',
    synonyms: ['Unintentional weight loss', 'Perdida de peso'],
  );

  static const Icd10Code weightGain = Icd10Code(
    code: 'R63.5',
    displayName: 'Abnormal weight gain',
    category: 'Symptoms',
    synonyms: ['Weight increase'],
  );

  static const Icd10Code fever = Icd10Code(
    code: 'R50.9',
    displayName: 'Fever, unspecified',
    category: 'Symptoms',
    synonyms: ['Pyrexia', 'Febrile', 'Fiebre'],
  );

  static const Icd10Code nightSweats = Icd10Code(
    code: 'R61',
    displayName: 'Generalized hyperhidrosis',
    category: 'Symptoms',
    synonyms: ['Night sweats', 'Sweating'],
  );

  static const Icd10Code pruritus = Icd10Code(
    code: 'L29.9',
    displayName: 'Pruritus, unspecified',
    category: 'Symptoms',
    synonyms: ['Itching', 'Itchy skin', 'Prurito'],
  );

  static const Icd10Code rash = Icd10Code(
    code: 'R21',
    displayName: 'Rash and other nonspecific skin eruption',
    category: 'Symptoms',
    synonyms: ['Skin rash', 'Erupción'],
  );

  static const Icd10Code hematuria = Icd10Code(
    code: 'R31.9',
    displayName: 'Hematuria, unspecified',
    category: 'Symptoms',
    synonyms: ['Blood in urine'],
  );

  static const Icd10Code proteinuria = Icd10Code(
    code: 'R80.9',
    displayName: 'Proteinuria, unspecified',
    category: 'Symptoms',
    synonyms: ['Protein in urine'],
  );

  static const Icd10Code hematochezia = Icd10Code(
    code: 'K62.5',
    displayName: 'Hemorrhage of anus and rectum',
    category: 'Symptoms',
    synonyms: ['Blood in stool', 'Rectal bleeding'],
  );

  static const Icd10Code melena = Icd10Code(
    code: 'K92.1',
    displayName: 'Melena',
    category: 'Symptoms',
    synonyms: ['Black tarry stools', 'GI bleeding'],
  );

  static const Icd10Code jaundice = Icd10Code(
    code: 'R17',
    displayName: 'Unspecified jaundice',
    category: 'Symptoms',
    synonyms: ['Ictericia', 'Yellow skin'],
  );

  static const Icd10Code confusion = Icd10Code(
    code: 'R41.0',
    displayName: 'Disorientation, unspecified',
    category: 'Symptoms',
    synonyms: ['Altered mental status', 'Confusión', 'Delirium'],
  );

  static const Icd10Code syncope = Icd10Code(
    code: 'R55.9',
    displayName: 'Syncope and collapse',
    category: 'Symptoms',
    synonyms: ['Fainting', 'Síncope', 'Passing out'],
  );

  // ==================== NEUROLOGICAL ====================
  static const Icd10Code stroke = Icd10Code(
    code: 'I64',
    displayName: 'Stroke, not specified as hemorrhage or infarction',
    category: 'Neurological',
    synonyms: ['CVA', 'Cerebrovascular accident', 'ACV'],
  );

  static const Icd10Code ischemicStroke = Icd10Code(
    code: 'I63.9',
    displayName: 'Cerebral infarction, unspecified',
    category: 'Neurological',
    synonyms: ['Ischemic CVA', 'Lacunar infarct'],
  );

  static const Icd10Code tia = Icd10Code(
    code: 'G45.9',
    displayName: 'Transient cerebral ischemic attack, unspecified',
    category: 'Neurological',
    synonyms: ['TIA', 'Mini-stroke'],
  );

  static const Icd10Code parkinsonDisease = Icd10Code(
    code: 'G20',
    displayName: "Parkinson's disease, unspecified",
    category: 'Neurological',
    synonyms: ['PD', 'Parkinsonismo'],
  );

  static const Icd10Code alzheimerDisease = Icd10Code(
    code: 'G30.9',
    displayName: "Alzheimer's disease, unspecified",
    category: 'Neurological',
    synonyms: ['AD', 'Alzheimer'],
  );

  static const Icd10Code epilepsy = Icd10Code(
    code: 'G40.909',
    displayName: 'Epilepsy, unspecified',
    category: 'Neurological',
    synonyms: ['Seizure disorder', 'Epilepsia'],
  );

  static const Icd10Code peripheralNeuropathy = Icd10Code(
    code: 'G62.9',
    displayName: 'Polyneuropathy, unspecified',
    category: 'Neurological',
    synonyms: ['Peripheral neuropathy', 'Nerve damage'],
  );

  static const Icd10Code carpalTunnelSyndrome = Icd10Code(
    code: 'G56.00',
    displayName: 'Carpal tunnel syndrome, unspecified upper limb',
    category: 'Neurological',
    synonyms: ['CTS'],
  );

  static const Icd10Code restlessLegsSyndrome = Icd10Code(
    code: 'G25.81',
    displayName: 'Restless legs syndrome',
    category: 'Neurological',
    synonyms: ['RLS', 'Willis-Ekbom disease'],
  );

  // ==================== GASTROINTESTINAL ====================
  static const Icd10Code gerd = Icd10Code(
    code: 'K21.0',
    displayName: 'Gastro-esophageal reflux disease with esophagitis',
    category: 'Gastrointestinal',
    synonyms: ['GERD', 'Reflujo', 'Acid reflux'],
  );

  static const Icd10Code gastritis = Icd10Code(
    code: 'K29.70',
    displayName: 'Gastritis, unspecified',
    category: 'Gastrointestinal',
    synonyms: ['Gastritis', 'Stomach inflammation'],
  );

  static const Icd10Code pepticUlcer = Icd10Code(
    code: 'K27.9',
    displayName: 'Peptic ulcer, unspecified',
    category: 'Gastrointestinal',
    synonyms: ['Stomach ulcer', 'Duodenal ulcer', 'Ulcer disease'],
  );

  static const Icd10Code irritableBowelSyndrome = Icd10Code(
    code: 'K58.9',
    displayName: 'Irritable bowel syndrome without diarrhea',
    category: 'Gastrointestinal',
    synonyms: ['IBS', 'Síndrome de intestino irritable'],
  );

  static const Icd10Code inflammatoryBowelDisease = Icd10Code(
    code: 'K50.90',
    displayName: 'Crohn disease, unspecified',
    category: 'Gastrointestinal',
    synonyms: ['Crohn disease', 'IBD', 'Regional enteritis'],
  );

  static const Icd10Code ulcerativeColitis = Icd10Code(
    code: 'K51.90',
    displayName: 'Ulcerative colitis, unspecified',
    category: 'Gastrointestinal',
    synonyms: ['UC', 'Colitis ulcerosa'],
  );

  static const Icd10Code celiacDisease = Icd10Code(
    code: 'K90.0',
    displayName: 'Celiac disease',
    category: 'Gastrointestinal',
    synonyms: ['Celiac sprue', 'Gluten enteropathy'],
  );

  static const Icd10Code pancreatitis = Icd10Code(
    code: 'K85.90',
    displayName: 'Acute pancreatitis without necrosis',
    category: 'Gastrointestinal',
    synonyms: ['Acute pancreatitis', 'Pancreatitis'],
  );

  static const Icd10Code chronicPancreatitis = Icd10Code(
    code: 'K86.1',
    displayName: 'Other chronic pancreatitis',
    category: 'Gastrointestinal',
    synonyms: ['Chronic pancreatitis'],
  );

  static const Icd10Code diverticulosis = Icd10Code(
    code: 'K57.90',
    displayName: 'Diverticulosis of intestine, part unspecified',
    category: 'Gastrointestinal',
    synonyms: ['Diverticular disease', 'Diverticulitis'],
  );

  // ==================== MUSCULOSKELETAL ====================
  static const Icd10Code osteoarthritis = Icd10Code(
    code: 'M19.90',
    displayName: 'Osteoarthritis, unspecified site',
    category: 'Musculoskeletal',
    synonyms: ['OA', 'Degenerative joint disease', 'Artrosis'],
  );

  static const Icd10Code rheumatoidArthritis = Icd10Code(
    code: 'M06.9',
    displayName: 'Rheumatoid arthritis, unspecified',
    category: 'Musculoskeletal',
    synonyms: ['RA', 'Artritis reumatoide'],
  );

  static const Icd10Code lupus = Icd10Code(
    code: 'M32.9',
    displayName: 'Systemic lupus erythematosus, unspecified',
    category: 'Musculoskeletal',
    synonyms: ['SLE', 'Lupus'],
  );

  static const Icd10Code fibromyalgia = Icd10Code(
    code: 'M79.7',
    displayName: 'Fibromyalgia',
    category: 'Musculoskeletal',
    synonyms: ['Fibromyalgia syndrome', 'FMS'],
  );

  static const Icd10Code osteopenia = Icd10Code(
    code: 'M85.80',
    displayName: 'Other specified disorders of bone density',
    category: 'Musculoskeletal',
    synonyms: ['Low bone density', 'Osteopenia'],
  );

  static const Icd10Code osteoporosis = Icd10Code(
    code: 'M81.0',
    displayName: 'Age-related osteoporosis without current pathological fracture',
    category: 'Musculoskeletal',
    synonyms: ['Osteoporosis', 'Porous bone'],
  );

  static const Icd10Code goutyArthritis = Icd10Code(
    code: 'M10.9',
    displayName: 'Gout, unspecified',
    category: 'Musculoskeletal',
    synonyms: ['Gouty arthritis', 'Podagra'],
  );

  static const Icd10Code bursitis = Icd10Code(
    code: 'M70.90',
    displayName: 'Unspecified soft tissue disorder related to use',
    category: 'Musculoskeletal',
    synonyms: ['Bursitis', 'Tendinitis'],
  );

  static const Icd10Code plantarFasciitis = Icd10Code(
    code: 'M72.2',
    displayName: 'Plantar fasciitis',
    category: 'Musculoskeletal',
    synonyms: ['Heel pain', 'Policeman heel'],
  );

  // ==================== DERMATOLOGICAL ====================
  static const Icd10Code eczema = Icd10Code(
    code: 'L30.9',
    displayName: 'Dermatitis, unspecified',
    category: 'Dermatological',
    synonyms: ['Eczema', 'Dermatitis'],
  );

  static const Icd10Code psoriasis = Icd10Code(
    code: 'L40.9',
    displayName: 'Psoriasis, unspecified',
    category: 'Dermatological',
    synonyms: ['Psoriasis'],
  );

  static const Icd10Code acne = Icd10Code(
    code: 'L70.0',
    displayName: 'Acne vulgaris',
    category: 'Dermatological',
    synonyms: ['Acne', 'Pimples'],
  );

  static const Icd10Code rosacea = Icd10Code(
    code: 'L71.9',
    displayName: 'Rosacea, unspecified',
    category: 'Dermatological',
    synonyms: ['Rosacea'],
  );

  static const Icd10Code urticaria = Icd10Code(
    code: 'L50.9',
    displayName: 'Urticaria, unspecified',
    category: 'Dermatological',
    synonyms: ['Hives', 'Nettle rash', 'Urticaria'],
  );

  static const Icd10Code herpesZoster = Icd10Code(
    code: 'B02.9',
    displayName: 'Zoster without complications',
    category: 'Dermatological',
    synonyms: ['Shingles', 'Herpes zoster', 'Culebrilla'],
  );

  static const Icd10Code cellulitis = Icd10Code(
    code: 'L03.90',
    displayName: 'Cellulitis, unspecified',
    category: 'Dermatological',
    synonyms: ['Skin infection', 'Celulitis'],
  );

  // ==================== INFECTIOUS ====================
  static const Icd10Code influenza = Icd10Code(
    code: 'J11.1',
    displayName: 'Influenza due to unidentified influenza virus',
    category: 'Infectious',
    synonyms: ['Flu', 'Gripe'],
  );

  static const Icd10Code tuberculosis = Icd10Code(
    code: 'A15.9',
    displayName: 'Respiratory tuberculosis, unspecified',
    category: 'Infectious',
    synonyms: ['TB', 'Tuberculosis'],
  );

  static const Icd10Code hiv = Icd10Code(
    code: 'B20',
    displayName: 'Human immunodeficiency virus [HIV] disease',
    category: 'Infectious',
    synonyms: ['HIV', 'AIDS'],
  );

  static const Icd10Code sepsis = Icd10Code(
    code: 'A41.9',
    displayName: 'Sepsis, unspecified organism',
    category: 'Infectious',
    synonyms: ['Septicemia', 'Blood poisoning'],
  );

  static const Icd10Code urinaryTractInfection = Icd10Code(
    code: 'N39.0',
    displayName: 'Urinary tract infection, site not specified',
    category: 'Infectious',
    synonyms: ['UTI', 'Cystitis'],
  );

  static const Icd10Code covid19 = Icd10Code(
    code: 'U07.1',
    displayName: 'COVID-19',
    category: 'Infectious',
    synonyms: ['Coronavirus', 'SARS-CoV-2'],
  );

  // ==================== ALL ALL ====================
  static const List<Icd10Code> all = [
    // Endocrine - Diabetes
    diabetesType1, diabetesType2, diabetesDueToUnderlyingCondition,
    drugInducedDiabetes, malnutritionRelatedDiabetes, otherSpecifiedDiabetes,
    unspecifiedDiabetes, diabetesWithKetoacidosis, diabetesWithNephropathy,
    diabetesWithRetinopathy, diabetesWithNeuropathy, diabetesWithPeripheralAngiopathy,
    // Endocrine - Thyroid
    hyperthyroidism, hypothyroidism, thyroidNodule, thyroidCancer,
    // Endocrine - Electrolyte
    hyperkalemia, hypokalemia, hyponatremia, hypernatremia,
    hypercalcemia, hypocalcemia,
    // Endocrine - Other
    metabolicSyndrome, adrenalInsufficiency, cushingSyndrome,
    polycysticOvarySyndrome, vitaminDDeficiency, hyperuricemia,
    // Cardiovascular
    hypertension, hypertensiveEmergency, atrialFibrillation, atrialFlutter,
    heartFailure, heartFailureReducedEF, heartFailurePreservedEF,
    acuteMyocardialInfarction, stableAngina, coronaryArteryDisease,
    peripheralVascularDisease, carotidArteryStenosis, aorticAneurysm,
    aorticDissection, varicoseVeins, lymphedema,
    // Metabolic
    obesity, severeObesity, hyperlipidemia, hypercholesterolemia,
    hypertriglyceridemia, mixedHyperlipidemia,
    // Respiratory
    acuteBronchitis, simpleChronicBronchitis, mucopurulentChronicBronchitis,
    mixedChronicBronchitis, unspecifiedChronicBronchitis, emphysema,
    otherEmphysema, bronchiectasis, copdAcuteExacerbation, copdAcuteBronchitis,
    asthmaUnspecified, asthmaAcuteExacerbation, asthmaMildIntermittent,
    asthmaModeratePersistent, asthmaSeverePersistent, respiratoryFailure,
    ards, pneumoniaUnspecified, viralPneumonia, pleuralEffusion, pneumothorax,
    // Renal
    acuteKidneyFailure, acuteTubularNecrosis, acuteGlomerulonephritis,
    chronicKidneyDisease, ckdStage1, ckdStage2, ckdStage3, ckdStage4,
    ckdStage5, endStageRenalDisease, nephroticSyndrome,
    urinaryTractInfection, benignProstaticHyperplasia, renalColic,
    hydronephrosis, glomerulonephritis, kidneyStone,
    // Liver
    alcoholicLiverDisease, alcoholicFattyLiver, alcoholicHepatitis,
    alcoholicCirrhosis, hepaticFailure, chronicHepaticFailure,
    hepaticEncephalopathy, nafld, nash, hepatitisB, hepatitisC,
    hepatitisA, liverCirrhosis, portalHypertension, cholecystitis,
    cholelithiasis, liverLesion, ascites,
    // Blood
    ironDeficiencyAnemia, ironDeficiencyAnemiaBloodLoss,
    vitaminB12DeficiencyAnemia, folateDeficiencyAnemia, hemolyticAnemia,
    sickleCellDisease, thalassemia, aplasticAnemia, anemiaOfCkd,
    anemiaOfMalignancy, pancytopenia, neutropenia, thrombocytopenia,
    coagulationDefect, hemophilia, vonWillebrandDisease, dvt,
    pulmonaryEmbolism, polycythemiaVera, thrombocythemia,
    // Cancer
    secondaryMalignantNeoplasm, lungCancer, breastCancer, colonCancer,
    prostateCancer, bladderCancer, pancreaticCancer, gastricCancer,
    leukemia, multipleMyeloma, lymphoma, melanoma, basalCellCarcinoma,
    squamousCellCarcinoma, benignNeoplasm, carcinoidTumor,
    // Pain
    abdominalPainUnspecified, upperAbdominalPain, rightLowerQuadrantPain,
    leftLowerQuadrantPain, rightUpperQuadrantPain, leftUpperQuadrantPain,
    generalizedAbdominalPain, chestPainUnspecified, chestPainTypicalAnginal,
    pleuriticChestPain, epigastricPain, neckPain, lowBackPain,
    lumbarRadiculopathy, headacheUnspecified, migraine, tensionHeadache,
    neuralgia, myalgia, arthralgia, chronicPain,
    // Symptoms
    fatigue, dizziness, insomnia, edema, dyspnea, cough, nausea,
    vomiting, diarrhea, constipation, weightLoss, weightGain, fever,
    nightSweats, pruritus, rash, hematuria, proteinuria,
    hematochezia, melena, jaundice, confusion, syncope,
    // Neurological
    stroke, ischemicStroke, tia, parkinsonDisease, alzheimerDisease,
    epilepsy, peripheralNeuropathy, carpalTunnelSyndrome, restlessLegsSyndrome,
    // GI
    gerd, gastritis, pepticUlcer, irritableBowelSyndrome, inflammatoryBowelDisease,
    ulcerativeColitis, celiacDisease, pancreatitis, chronicPancreatitis, diverticulosis,
    // MSK
    osteoarthritis, rheumatoidArthritis, lupus, fibromyalgia,
    osteopenia, osteoporosis, goutyArthritis, bursitis, plantarFasciitis,
    // Derm
    eczema, psoriasis, acne, rosacea, urticaria, herpesZoster, cellulitis,
    // Infectious
    influenza, tuberculosis, hiv, sepsis, urinaryTractInfection, covid19,
  ];

  /// Find by code
  static Icd10Code? findByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Find by synonym
  static Icd10Code? findBySynonym(String term) {
    final lower = term.toLowerCase();
    for (final code in all) {
      if (code.synonyms.any((s) => s.toLowerCase() == lower)) {
        return code;
      }
    }
    return null;
  }

  /// Find by category
  static List<Icd10Code> findByCategory(String category) {
    return all.where((c) => c.category == category).toList();
  }
}
