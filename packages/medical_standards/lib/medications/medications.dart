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

/// Comprehensive medication catalog
class MedicationCatalog {
  // ==================== ACE INHIBITORS ====================
  static const MedicationReference lisinopril = MedicationReference(
    code: '29046',
    displayName: 'Lisinopril',
    genericName: 'Lisinopril',
    drugClass: 'ACE Inhibitor',
    description: 'For hypertension, heart failure, diabetic nephropathy',
    routes: ['Oral'],
    commonDosages: ['5mg/day', '10mg/day', '20mg/day', '40mg/day'],
  );

  static const MedicationReference enalapril = MedicationReference(
    code: '12014',
    displayName: 'Enalapril',
    genericName: 'Enalapril maleate',
    drugClass: 'ACE Inhibitor',
    description: 'For hypertension and heart failure; prodrug of enalaprilat',
    routes: ['Oral'],
    commonDosages: ['2.5mg/day', '5mg/day', '10mg/day', '20mg/day', '40mg/day'],
  );

  static const MedicationReference enalaprilat = MedicationReference(
    code: '68010',
    displayName: 'Enalaprilat',
    genericName: 'Enalaprilat',
    drugClass: 'ACE Inhibitor',
    description: 'IV ACE inhibitor for hypertensive emergencies',
    routes: ['IV'],
    commonDosages: ['0.625mg-1.25mg IV q6h'],
  );

  static const MedicationReference ramipril = MedicationReference(
    code: '52585',
    displayName: 'Ramipril',
    genericName: 'Ramipril',
    drugClass: 'ACE Inhibitor',
    description: 'ACE inhibitor with cardioprotective benefits',
    routes: ['Oral'],
    commonDosages: ['1.25mg/day', '2.5mg/day', '5mg/day', '10mg/day'],
  );

  static const MedicationReference quinapril = MedicationReference(
    code: '33793',
    displayName: 'Quinapril',
    genericName: 'Quinapril hydrochloride',
    drugClass: 'ACE Inhibitor',
    description: 'ACE inhibitor for hypertension and heart failure',
    routes: ['Oral'],
    commonDosages: ['10mg/day', '20mg/day', '40mg/day'],
  );

  static const MedicationReference captopril = MedicationReference(
    code: '196503',
    displayName: 'Captopril',
    genericName: 'Captopril',
    drugClass: 'ACE Inhibitor',
    description: 'Short-acting ACE inhibitor; also used in heart failure',
    routes: ['Oral'],
    commonDosages: ['6.25mg 3x/day', '12.5mg 3x/day', '25mg 3x/day', '50mg 3x/day'],
  );

  static const MedicationReference fosinopril = MedicationReference(
    code: '50165',
    displayName: 'Fosinopril',
    genericName: 'Fosinopril sodium',
    drugClass: 'ACE Inhibitor',
    description: 'ACE inhibitor with dual hepatic/renal elimination',
    routes: ['Oral'],
    commonDosages: ['10mg/day', '20mg/day', '40mg/day'],
  );

  static const MedicationReference trandolapril = MedicationReference(
    code: '83311',
    displayName: 'Trandolapril',
    genericName: 'Trandolapril',
    drugClass: 'ACE Inhibitor',
    description: 'ACE inhibitor for hypertension and post-MI remodeling',
    routes: ['Oral'],
    commonDosages: ['1mg/day', '2mg/day', '4mg/day'],
  );

  // ==================== BETA BLOCKERS ====================
  static const MedicationReference metoprolol = MedicationReference(
    code: '6918249',
    displayName: 'Metoprolol',
    genericName: 'Metoprolol tartrate',
    drugClass: 'Beta Blocker',
    description: 'Beta-1 selective blocker for HTN, angina, heart failure, MI',
    routes: ['Oral', 'IV'],
    commonDosages: ['25mg 2x/day', '50mg 2x/day', '100mg 2x/day', '200mg/day'],
  );

  static const MedicationReference metoprololSuccinate = MedicationReference(
    code: '866924',
    displayName: 'Metoprolol Succinate',
    genericName: 'Metoprolol succinate (extended release)',
    drugClass: 'Beta Blocker',
    description: 'Extended release metoprolol for heart failure (Toprol-XL)',
    routes: ['Oral'],
    commonDosages: ['25mg/day', '50mg/day', '100mg/day', '200mg/day'],
  );

  static const MedicationReference carvedilol = MedicationReference(
    code: '212017',
    displayName: 'Carvedilol',
    genericName: 'Carvedilol',
    drugClass: 'Beta Blocker (Non-selective)',
    description: 'Alpha-1 and beta blocker; vasodilatory beta blocker for HFrEF',
    routes: ['Oral'],
    commonDosages: ['3.125mg 2x/day', '6.25mg 2x/day', '12.5mg 2x/day', '25mg 2x/day'],
  );

  static const MedicationReference atenolol = MedicationReference(
    code: '1202',
    displayName: 'Atenolol',
    genericName: 'Atenolol',
    drugClass: 'Beta Blocker (Selective)',
    description: 'Beta-1 selective blocker; renally eliminated',
    routes: ['Oral'],
    commonDosages: ['25mg/day', '50mg/day', '100mg/day'],
  );

  static const MedicationReference bisoprolol = MedicationReference(
    code: '19189',
    displayName: 'Bisoprolol',
    genericName: 'Bisoprolol fumarate',
    drugClass: 'Beta Blocker (Selective)',
    description: 'Highly beta-1 selective blocker for hypertension and heart failure',
    routes: ['Oral'],
    commonDosages: ['2.5mg/day', '5mg/day', '10mg/day'],
  );

  static const MedicationReference propranolol = MedicationReference(
    code: '8789',
    displayName: 'Propranolol',
    genericName: 'Propranolol hydrochloride',
    drugClass: 'Beta Blocker (Non-selective)',
    description: 'Non-selective beta blocker for HTN, migraine, tremor, portal hypertension',
    routes: ['Oral', 'IV'],
    commonDosages: ['10mg 2x/day', '20mg 2x/day', '40mg 2x/day', '80mg 2x/day'],
  );

  static const MedicationReference labetalol = MedicationReference(
    code: '397862',
    displayName: 'Labetalol',
    genericName: 'Labetalol hydrochloride',
    drugClass: 'Beta Blocker (Combined alpha/beta)',
    description: 'Combined alpha-1 and beta blocker for hypertensive emergencies',
    routes: ['Oral', 'IV'],
    commonDosages: ['100mg 2x/day', '200mg 2x/day', '400mg 2x/day', 'IV: 10-20mg bolus'],
  );

  static const MedicationReference nebivolol = MedicationReference(
    code: '1717515',
    displayName: 'Nebivolol',
    genericName: 'Nebivolol hydrochloride',
    drugClass: 'Beta Blocker (Selective)',
    description: 'Highly beta-1 selective with NO-mediated vasodilation',
    routes: ['Oral'],
    commonDosages: ['2.5mg/day', '5mg/day', '10mg/day', '20mg/day'],
  );

  static const MedicationReference esmolol = MedicationReference(
    code: '38452',
    displayName: 'Esmolol',
    genericName: 'Esmolol hydrochloride',
    drugClass: 'Beta Blocker (Ultra-short)',
    description: 'Ultra-short acting IV beta-1 blocker for rate control',
    routes: ['IV'],
    commonDosages: ['50-200 mcg/kg/min infusion', '500 mcg/kg bolus'],
  );

  // ==================== ARBs (keep existing) ====================
  static const MedicationReference losartan = MedicationReference(
    code: '52175',
    displayName: 'Losartan',
    genericName: 'Losartan potassium',
    drugClass: 'ARB',
    description: 'Angiotensin receptor blocker for hypertension',
    routes: ['Oral'],
    commonDosages: ['25mg/day', '50mg/day', '100mg/day'],
  );

  static const MedicationReference valsartan = MedicationReference(
    code: '69749',
    displayName: 'Valsartan',
    genericName: 'Valsartan',
    drugClass: 'ARB',
    description: 'ARB for hypertension and heart failure',
    routes: ['Oral'],
    commonDosages: ['80mg/day', '160mg/day', '320mg/day'],
  );

  static const MedicationReference olmesartan = MedicationReference(
    code: '321671',
    displayName: 'Olmesartan',
    genericName: 'Olmesartan medoxomil',
    drugClass: 'ARB',
    description: 'ARB for hypertension',
    routes: ['Oral'],
    commonDosages: ['20mg/day', '40mg/day'],
  );

  static const MedicationReference irbesartan = MedicationReference(
    code: '57255',
    displayName: 'Irbesartan',
    genericName: 'Irbesartan',
    drugClass: 'ARB',
    description: 'ARB for hypertension and diabetic nephropathy',
    routes: ['Oral'],
    commonDosages: ['75mg/day', '150mg/day', '300mg/day'],
  );

  // ==================== CALCIUM CHANNEL BLOCKERS ====================
  static const MedicationReference amlodipine = MedicationReference(
    code: '17767',
    displayName: 'Amlodipine',
    genericName: 'Amlodipine besylate',
    drugClass: 'Calcium Channel Blocker',
    description: 'Dihydropyridine CCB for hypertension and angina',
    routes: ['Oral'],
    commonDosages: ['2.5mg/day', '5mg/day', '10mg/day'],
  );

  static const MedicationReference diltiazem = MedicationReference(
    code: '3443',
    displayName: 'Diltiazem',
    genericName: 'Diltiazem hydrochloride',
    drugClass: 'Calcium Channel Blocker',
    description: 'Non-dihydropyridine CCB for HTN, angina, rate control',
    routes: ['Oral', 'IV'],
    commonDosages: ['30mg 3x/day', '120mg/day ER', '240mg/day ER', 'IV: 5-15mg/hr'],
  );

  static const MedicationReference verapamil = MedicationReference(
    code: '11170',
    displayName: 'Verapamil',
    genericName: 'Verapamil hydrochloride',
    drugClass: 'Calcium Channel Blocker',
    description: 'Non-dihydropyridine CCB for HTN, angina, arrhythmias, migraine',
    routes: ['Oral', 'IV'],
    commonDosages: ['40mg 3x/day', '120mg/day ER', '240mg/day ER'],
  );

  static const MedicationReference nifedipine = MedicationReference(
    code: '3624',
    displayName: 'Nifedipine',
    genericName: 'Nifedipine',
    drugClass: 'Calcium Channel Blocker',
    description: 'Dihydropyridine CCB for hypertension and Raynaud phenomenon',
    routes: ['Oral'],
    commonDosages: ['30mg/day', '60mg/day', '90mg/day'],
  );

  // ==================== DIURETICS ====================
  static const MedicationReference hydrochlorothiazide = MedicationReference(
    code: '4838',
    displayName: 'Hydrochlorothiazide',
    genericName: 'Hydrochlorothiazide',
    drugClass: 'Thiazide Diuretic',
    description: 'Thiazide diuretic for hypertension and edema',
    routes: ['Oral'],
    commonDosages: ['12.5mg/day', '25mg/day', '50mg/day'],
  );

  static const MedicationReference chlorthalidone = MedicationReference(
    code: '38826',
    displayName: 'Chlorthalidone',
    genericName: 'Chlorthalidone',
    drugClass: 'Thiazide-like Diuretic',
    description: 'Long-acting thiazide-like diuretic; more potent than HCTZ',
    routes: ['Oral'],
    commonDosages: ['12.5mg/day', '25mg/day', '50mg/day', '100mg/day'],
  );

  static const MedicationReference indapamide = MedicationReference(
    code: '40147',
    displayName: 'Indapamide',
    genericName: 'Indapamide',
    drugClass: 'Thiazide-like Diuretic',
    description: 'Thiazide-like diuretic with vasodilatory properties',
    routes: ['Oral'],
    commonDosages: ['1.25mg/day', '2.5mg/day'],
  );

  static const MedicationReference furosemide = MedicationReference(
    code: '4608',
    displayName: 'Furosemide',
    genericName: 'Furosemide',
    drugClass: 'Loop Diuretic',
    description: 'Loop diuretic for edema, heart failure, AKI',
    routes: ['Oral', 'IV'],
    commonDosages: ['20mg/day', '40mg/day', '40mg 2x/day', 'IV: 20-40mg bolus'],
  );

  static const MedicationReference bumetanide = MedicationReference(
    code: '18400',
    displayName: 'Bumetanide',
    genericName: 'Bumetanide',
    drugClass: 'Loop Diuretic',
    description: 'Potent loop diuretic; 40x more potent than furosemide',
    routes: ['Oral', 'IV'],
    commonDosages: ['0.5mg/day', '1mg/day', '2mg/day'],
  );

  static const MedicationReference torsemide = MedicationReference(
    code: '69066',
    displayName: 'Torsemide',
    genericName: 'Torsemide',
    drugClass: 'Loop Diuretic',
    description: 'Loop diuretic with longer half-life than furosemide',
    routes: ['Oral', 'IV'],
    commonDosages: ['10mg/day', '20mg/day', '40mg/day', '100mg/day'],
  );

  static const MedicationReference spironolactone = MedicationReference(
    code: '9997',
    displayName: 'Spironolactone',
    genericName: 'Spironolactone',
    drugClass: 'Potassium-sparing Diuretic',
    description: 'Aldosterone antagonist for HFrEF, hypertension, ascites',
    routes: ['Oral'],
    commonDosages: ['12.5mg/day', '25mg/day', '50mg/day', '100mg/day'],
  );

  static const MedicationReference eplerenone = MedicationReference(
    code: '329526',
    displayName: 'Eplerenone',
    genericName: 'Eplerenone',
    drugClass: 'Potassium-sparing Diuretic',
    description: 'Selective aldosterone antagonist; less hormonal side effects',
    routes: ['Oral'],
    commonDosages: ['25mg/day', '50mg/day'],
  );

  static const MedicationReference triamterene = MedicationReference(
    code: '10791',
    displayName: 'Triamterene',
    genericName: 'Triamterene',
    drugClass: 'Potassium-sparing Diuretic',
    description: 'Direct aldosterone antagonist for edema and hypokalemia',
    routes: ['Oral'],
    commonDosages: ['50mg/day', '100mg 2x/day'],
  );

  static const MedicationReference acetazolamide = MedicationReference(
    code: '115980',
    displayName: 'Acetazolamide',
    genericName: 'Acetazolamide',
    drugClass: 'Carbonic Anhydrase Inhibitor',
    description: 'Carbonic anhydrase inhibitor for glaucoma, altitude sickness, edema',
    routes: ['Oral', 'IV'],
    commonDosages: ['250mg 2x/day', '250mg 4x/day'],
  );

  // ==================== STATINS ====================
  static const MedicationReference atorvastatin = MedicationReference(
    code: '83367',
    displayName: 'Atorvastatin',
    genericName: 'Atorvastatin calcium',
    drugClass: 'Statin',
    description: 'HMG-CoA reductase inhibitor for cholesterol; high-intensity statin',
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
    commonDosages: ['5mg/day', '10mg/day', '20mg/day', '40mg/day'],
  );

  static const MedicationReference simvastatin = MedicationReference(
    code: '36567',
    displayName: 'Simvastatin',
    genericName: 'Simvastatin',
    drugClass: 'Statin',
    description: 'HMG-CoA reductase inhibitor; moderate-intensity statin',
    routes: ['Oral'],
    commonDosages: ['10mg/day', '20mg/day', '40mg/day', '80mg/day'],
  );

  static const MedicationReference pravastatin = MedicationReference(
    code: '55478',
    displayName: 'Pravastatin',
    genericName: 'Pravastatin sodium',
    drugClass: 'Statin',
    description: 'Statin with favorable drug interaction profile',
    routes: ['Oral'],
    commonDosages: ['10mg/day', '20mg/day', '40mg/day', '80mg/day'],
  );

  static const MedicationReference pitavastatin = MedicationReference(
    code: '859740',
    displayName: 'Pitavastatin',
    genericName: 'Pitavastatin calcium',
    drugClass: 'Statin',
    description: 'Statin with minimal drug interactions',
    routes: ['Oral'],
    commonDosages: ['1mg/day', '2mg/day', '4mg/day'],
  );

  static const MedicationReference ezetimibe = MedicationReference(
    code: '135814',
    displayName: 'Ezetimibe',
    genericName: 'Ezetimibe',
    drugClass: 'Cholesterol Absorption Inhibitor',
    description: 'Inhibits intestinal cholesterol absorption',
    routes: ['Oral'],
    commonDosages: ['10mg/day'],
  );

  // ==================== ANTICOAGULANTS / ANTIPLATELETS ====================
  static const MedicationReference warfarin = MedicationReference(
    code: '855332',
    displayName: 'Warfarin',
    genericName: 'Warfarin sodium',
    drugClass: 'Vitamin K Antagonist',
    description: 'Vitamin K antagonist for anticoagulation (AFib, DVT, PE, valve)',
    routes: ['Oral'],
    commonDosages: ['2mg/day', '5mg/day', '7.5mg/day', '10mg/day'],
  );

  static const MedicationReference apixaban = MedicationReference(
    code: '825776',
    displayName: 'Apixaban',
    genericName: 'Apixaban',
    drugClass: 'Direct Oral Anticoagulant (Factor Xa Inhibitor)',
    description: 'DOAC for AFib, DVT, PE (lower bleeding risk than warfarin)',
    routes: ['Oral'],
    commonDosages: ['2.5mg 2x/day', '5mg 2x/day'],
  );

  static const MedicationReference rivaroxaban = MedicationReference(
    code: '836444',
    displayName: 'Rivaroxaban',
    genericName: 'Rivaroxaban',
    drugClass: 'Direct Oral Anticoagulant (Factor Xa Inhibitor)',
    description: 'DOAC for AFib, DVT, PE; once daily formulation',
    routes: ['Oral'],
    commonDosages: ['15mg 2x/day (21 days)', '20mg/day'],
  );

  static const MedicationReference dabigatran = MedicationReference(
    code: '737168',
    displayName: 'Dabigatran',
    genericName: 'Dabigatran etexilate',
    drugClass: 'Direct Thrombin Inhibitor',
    description: 'DOAC for AFib, DVT, PE',
    routes: ['Oral'],
    commonDosages: ['75mg 2x/day', '110mg 2x/day', '150mg 2x/day'],
  );

  static const MedicationReference enoxaparin = MedicationReference(
    code: '901965',
    displayName: 'Enoxaparin',
    genericName: 'Enoxaparin sodium',
    drugClass: 'Low Molecular Weight Heparin',
    description: 'LMWH for DVT/PE prophylaxis and treatment',
    routes: ['Subcutaneous'],
    commonDosages: ['40mg/day SC', '1mg/kg 2x/day SC', '1.5mg/kg/day SC'],
  );

  static const MedicationReference heparin = MedicationReference(
    code: '225785',
    displayName: 'Heparin',
    genericName: 'Heparin sodium',
    drugClass: 'Unfractionated Heparin',
    description: 'UFH for ACS, DVT/PE, anticoagulation during procedures',
    routes: ['IV', 'Subcutaneous'],
    commonDosages: ['IV: 18 units/kg/hr', 'SC: 5000 units 2-3x/day'],
  );

  static const MedicationReference aspirin = MedicationReference(
    code: '1191',
    displayName: 'Aspirin',
    genericName: 'Acetylsalicylic acid',
    drugClass: 'NSAID/Antiplatelet',
    description: 'Antiplatelet for cardiovascular protection',
    routes: ['Oral'],
    commonDosages: ['81mg/day', '325mg/day', '650mg q6h PRN'],
  );

  static const MedicationReference clopidogrel = MedicationReference(
    code: '333965',
    displayName: 'Clopidogrel',
    genericName: 'Clopidogrel bisulfate',
    drugClass: 'P2Y12 Inhibitor',
    description: 'Antiplatelet for ACS, PCI, stroke prevention',
    routes: ['Oral'],
    commonDosages: ['75mg/day', '300mg loading dose'],
  );

  static const MedicationReference ticagrelor = MedicationReference(
    code: '1019546',
    displayName: 'Ticagrelor',
    genericName: 'Ticagrelor',
    drugClass: 'P2Y12 Inhibitor',
    description: 'Reversible P2Y12 inhibitor for ACS; faster offset than clopidogrel',
    routes: ['Oral'],
    commonDosages: ['90mg 2x/day', '180mg loading dose'],
  );

  // ==================== DIABETES ====================
  static const MedicationReference metformin = MedicationReference(
    code: '6809',
    displayName: 'Metformin',
    genericName: 'Metformin HCl',
    drugClass: 'Biguanide',
    description: 'First-line therapy for Type 2 diabetes; no hypoglycemia risk',
    routes: ['Oral'],
    commonDosages: ['500mg 2x/day', '850mg 2x/day', '1000mg 2x/day', '2000mg/day max'],
  );

  static const MedicationReference glipizide = MedicationReference(
    code: '5487',
    displayName: 'Glipizide',
    genericName: 'Glipizide',
    drugClass: 'Sulfonylurea',
    description: 'Second-line for Type 2 diabetes; insulin secretagogue',
    routes: ['Oral'],
    commonDosages: ['5mg/day', '10mg/day', '20mg/day'],
  );

  static const MedicationReference glimepiride = MedicationReference(
    code: '25789',
    displayName: 'Glimepiride',
    genericName: 'Glimepiride',
    drugClass: 'Sulfonylurea',
    description: 'Once-daily sulfonylurea for T2DM',
    routes: ['Oral'],
    commonDosages: ['1mg/day', '2mg/day', '4mg/day'],
  );

  static const MedicationReference insulinGlargine = MedicationReference(
    code: '225971',
    displayName: 'Insulin Glargine',
    genericName: 'Insulin glargine recombinant',
    drugClass: 'Long-acting Insulin',
    description: 'Long-acting insulin (24h) for diabetes',
    routes: ['Subcutaneous'],
    commonDosages: ['10 units/day', '20 units/day', '30 units/day', '40 units/day'],
  );

  static const MedicationReference insulinLispro = MedicationReference(
    code: '8619',
    displayName: 'Insulin Lispro',
    genericName: 'Insulin lispro recombinant',
    drugClass: 'Rapid-acting Insulin',
    description: 'Rapid-acting insulin analog; taken at mealtime',
    routes: ['Subcutaneous'],
    commonDosages: ['3 units per 15g carbs', 'Correctional: 1 unit per 50mg/dL above target'],
  );

  static const MedicationReference insulinNph = MedicationReference(
    code: '57317',
    displayName: 'Insulin NPH',
    genericName: 'Insulin human isophane',
    drugClass: 'Intermediate-acting Insulin',
    description: 'Intermediate-acting insulin; onset 1-2h, peak 6-8h',
    routes: ['Subcutaneous'],
    commonDosages: ['10 units 2x/day', '20 units 2x/day'],
  );

  static const MedicationReference empagliflozin = MedicationReference(
    code: '861007',
    displayName: 'Empagliflozin',
    genericName: 'Empagliflozin',
    drugClass: 'SGLT2 Inhibitor',
    description: 'SGLT2 inhibitor for T2DM, heart failure, CKD (cardiovascular benefit)',
    routes: ['Oral'],
    commonDosages: ['10mg/day', '25mg/day'],
  );

  static const MedicationReference dapagliflozin = MedicationReference(
    code: '1429942',
    displayName: 'Dapagliflozin',
    genericName: 'Dapagliflozin propanediol',
    drugClass: 'SGLT2 Inhibitor',
    description: 'SGLT2 inhibitor for T2DM, heart failure, CKD',
    routes: ['Oral'],
    commonDosages: ['5mg/day', '10mg/day'],
  );

  static const MedicationReference liraglutide = MedicationReference(
    code: '1232043',
    displayName: 'Liraglutide',
    genericName: 'Liraglutide',
    drugClass: 'GLP-1 Agonist',
    description: 'GLP-1 agonist for T2DM and weight loss',
    routes: ['Subcutaneous'],
    commonDosages: ['0.6mg/day SC (titrate to 1.2-1.8mg/day)'],
  );

  static const MedicationReference semaglutide = MedicationReference(
    code: '1012661',
    displayName: 'Semaglutide',
    genericName: 'Semaglutide',
    drugClass: 'GLP-1 Agonist',
    description: 'GLP-1 agonist for T2DM; oral formulation available',
    routes: ['Oral', 'Subcutaneous'],
    commonDosages: ['0.5mg/week SC', '1mg/week SC', '14mg/day oral'],
  );

  static const MedicationReference sitagliptin = MedicationReference(
    code: '827008',
    displayName: 'Sitagliptin',
    genericName: 'Sitagliptin phosphate',
    drugClass: 'DPP-4 Inhibitor',
    description: 'DPP-4 inhibitor for T2DM; weight neutral',
    routes: ['Oral'],
    commonDosages: ['100mg/day', '50mg/day (if eGFR<45)', '25mg/day (if eGFR<30)'],
  );

  static const MedicationReference linagliptin = MedicationReference(
    code: '1019739',
    displayName: 'Linagliptin',
    genericName: 'Linagliptin',
    drugClass: 'DPP-4 Inhibitor',
    description: 'DPP-4 inhibitor; renally dosed not required',
    routes: ['Oral'],
    commonDosages: ['5mg/day'],
  );

  // ==================== THYROID ====================
  static const MedicationReference levothyroxine = MedicationReference(
    code: '8667',
    displayName: 'Levothyroxine',
    genericName: 'Levothyroxine sodium',
    drugClass: 'Thyroid Hormone',
    description: 'Synthetic T4 for hypothyroidism; take on empty stomach',
    routes: ['Oral'],
    commonDosages: ['25mcg/day', '50mcg/day', '75mcg/day', '100mcg/day', '125mcg/day', '150mcg/day'],
  );

  static const MedicationReference liothyronine = MedicationReference(
    code: '2567',
    displayName: 'Liothyronine',
    genericName: 'Liothyronine sodium (T3)',
    drugClass: 'Thyroid Hormone',
    description: 'Synthetic T3 for hypothyroidism, myxedema coma',
    routes: ['Oral', 'IV'],
    commonDosages: ['5mcg/day', '25mcg/day', '50mcg/day'],
  );

  static const MedicationReference methimazole = MedicationReference(
    code: '1301022',
    displayName: 'Methimazole',
    genericName: 'Methimazole',
    drugClass: 'Antithyroid Agent',
    description: 'Thionamide for hyperthyroidism; PTU preferred in 1st trimester',
    routes: ['Oral'],
    commonDosages: ['5mg/day', '10mg/day', '15mg/day', '30mg/day'],
  );

  static const MedicationReference propylthiouracil = MedicationReference(
    code: '8727',
    displayName: 'Propylthiouracil',
    genericName: 'Propylthiouracil',
    drugClass: 'Antithyroid Agent',
    description: 'Thionamide for hyperthyroidism; preferred in pregnancy (1st trimester)',
    routes: ['Oral'],
    commonDosages: ['50mg 3x/day', '100mg 3x/day', '150mg 3x/day'],
  );

  // ==================== PPIs ====================
  static const MedicationReference omeprazole = MedicationReference(
    code: '7646',
    displayName: 'Omeprazole',
    genericName: 'Omeprazole',
    drugClass: 'Proton Pump Inhibitor',
    description: 'PPI for GERD and peptic ulcers; CYP2C19 substrate',
    routes: ['Oral'],
    commonDosages: ['20mg/day', '40mg/day', '20mg 2x/day'],
  );

  static const MedicationReference pantoprazole = MedicationReference(
    code: '40790',
    displayName: 'Pantoprazole',
    genericName: 'Pantoprazole sodium',
    drugClass: 'Proton Pump Inhibitor',
    description: 'PPI for GERD and hypersecretory conditions; IV available',
    routes: ['Oral', 'IV'],
    commonDosages: ['40mg/day', '40mg 2x/day', 'IV: 40mg/day'],
  );

  static const MedicationReference esomeprazole = MedicationReference(
    code: '149384',
    displayName: 'Esomeprazole',
    genericName: 'Esomeprazole magnesium',
    drugClass: 'Proton Pump Inhibitor',
    description: 'S-enantiomer of omeprazole; longer half-life',
    routes: ['Oral', 'IV'],
    commonDosages: ['20mg/day', '40mg/day', '40mg 2x/day'],
  );

  static const MedicationReference lansoprazole = MedicationReference(
    code: '272189',
    displayName: 'Lansoprazole',
    genericName: 'Lansoprazole',
    drugClass: 'Proton Pump Inhibitor',
    description: 'PPI with rapid absorption; ODT formulation available',
    routes: ['Oral'],
    commonDosages: ['15mg/day', '30mg/day', '30mg 2x/day'],
  );

  static const MedicationReference rabeprazole = MedicationReference(
    code: '83920',
    displayName: 'Rabeprazole',
    genericName: 'Rabeprazole sodium',
    drugClass: 'Proton Pump Inhibitor',
    description: 'PPI with fastest onset of action',
    routes: ['Oral'],
    commonDosages: ['20mg/day', '40mg/day'],
  );

  static const MedicationReference dexlansoprazole = MedicationReference(
    code: '889010',
    displayName: 'Dexlansoprazole',
    genericName: 'Dexlansoprazole',
    drugClass: 'Proton Pump Inhibitor',
    description: 'Dual delayed-release PPI; twice-daily release',
    routes: ['Oral'],
    commonDosages: ['30mg/day', '60mg/day'],
  );

  // ==================== ANTIBIOTICS ====================
  static const MedicationReference amoxicillin = MedicationReference(
    code: '723',
    displayName: 'Amoxicillin',
    genericName: 'Amoxicillin',
    drugClass: 'Antibiotic (Penicillin)',
    description: 'Broad-spectrum penicillin for respiratory, UTI, H. pylori',
    routes: ['Oral'],
    commonDosages: ['250mg 3x/day', '500mg 3x/day', '875mg 2x/day', '1g 2x/day'],
  );

  static const MedicationReference amoxicillinClavulanate = MedicationReference(
    code: '308136',
    displayName: 'Amoxicillin-Clavulanate',
    genericName: 'Amoxicillin/Clavulanic acid',
    drugClass: 'Antibiotic (Penicillin + Beta-lactamase Inhibitor)',
    description: 'Penicillin with beta-lactamase inhibitor; broad spectrum',
    routes: ['Oral'],
    commonDosages: ['500mg 3x/day', '875mg 2x/day', '1000mg 2x/day'],
  );

  static const MedicationReference azithromycin = MedicationReference(
    code: '18631',
    displayName: 'Azithromycin',
    genericName: 'Azithromycin',
    drugClass: 'Antibiotic (Macrolide)',
    description: 'Macrolide for respiratory infections, STIs, travelers diarrhea',
    routes: ['Oral', 'IV'],
    commonDosages: ['250mg day 1 then 250mg days 2-5', '500mg day 1 then 250mg days 2-5', '500mg IV daily'],
  );

  static const MedicationReference ciprofloxacin = MedicationReference(
    code: '2553',
    displayName: 'Ciprofloxacin',
    genericName: 'Ciprofloxacin hydrochloride',
    drugClass: 'Antibiotic (Fluoroquinolone)',
    description: 'FQ for UTI, prostatitis, bacterial diarrhea, anthrax',
    routes: ['Oral', 'IV'],
    commonDosages: ['250mg 2x/day', '500mg 2x/day', '750mg 2x/day', '400mg IV 2x/day'],
  );

  static const MedicationReference levofloxacin = MedicationReference(
    code: '6387',
    displayName: 'Levofloxacin',
    genericName: 'Levofloxacin',
    drugClass: 'Antibiotic (Fluoroquinolone)',
    description: 'Respiratory FQ for CAP, AECOPD, UTI, skin infections',
    routes: ['Oral', 'IV'],
    commonDosages: ['250mg/day', '500mg/day', '750mg/day'],
  );

  static const MedicationReference doxycycline = MedicationReference(
    code: '351',
    displayName: 'Doxycycline',
    genericName: 'Doxycycline hyclate',
    drugClass: 'Antibiotic (Tetracycline)',
    description: 'Broad-spectrum for Lyme, chlamydia, acne, malaria prophylaxis',
    routes: ['Oral'],
    commonDosages: ['100mg 2x/day', '100mg/day', '200mg day 1 then 100mg days 2-5'],
  );

  static const MedicationReference metronidazole = MedicationReference(
    code: '4444',
    displayName: 'Metronidazole',
    genericName: 'Metronidazole',
    drugClass: 'Antibiotic/Antiprotozoal',
    description: 'Anaerobic coverage; for bacterial vaginosis, trichomoniasis, C. diff',
    routes: ['Oral', 'IV', 'Topical'],
    commonDosages: ['250mg 3x/day', '500mg 3x/day', '500mg IV q8h', '0.75% topical 2x/day'],
  );

  static const MedicationReference sulfamethoxazoleTrimethoprim = MedicationReference(
    code: '8537',
    displayName: 'Sulfamethoxazole-Trimethoprim',
    genericName: 'Sulfamethoxazole/Trimethoprim',
    drugClass: 'Antibiotic (Sulfonamide)',
    description: 'Folate antagonist for UTI, PCP prophylaxis, shigella, MRSA',
    routes: ['Oral', 'IV'],
    commonDosages: ['SS tab 2x/day', 'DS tab 2x/day', 'IV: 5mg/kg q6-12h'],
  );

  static const MedicationReference cephalexin = MedicationReference(
    code: '2185',
    displayName: 'Cephalexin',
    genericName: 'Cephalexin',
    drugClass: 'Antibiotic (Cephalosporin 1st Gen)',
    description: '1st gen cephalosporin for skin/soft tissue, strep pharyngitis',
    routes: ['Oral'],
    commonDosages: ['250mg 4x/day', '500mg 4x/day', '500mg 2x/day'],
  );

  static const MedicationReference vancomycin = MedicationReference(
    code: '11289',
    displayName: 'Vancomycin',
    genericName: 'Vancomycin hydrochloride',
    drugClass: 'Antibiotic (Glycopeptide)',
    description: 'MRSA, C. diff (oral), endocarditis prophylaxis',
    routes: ['IV', 'Oral'],
    commonDosages: ['IV: 15-20mg/kg q8-12h (trough 10-15, 15-20 for pneumonia)', 'Oral: 125mg 4x/day'],
  );

  // ==================== ANTIDEPRESSANTS ====================
  static const MedicationReference sertraline = MedicationReference(
    code: '36567',
    displayName: 'Sertraline',
    genericName: 'Sertraline hydrochloride',
    drugClass: 'SSRI',
    description: 'SSRI for depression, anxiety, PTSD, OCD, PMDD',
    routes: ['Oral'],
    commonDosages: ['50mg/day', '100mg/day', '150mg/day', '200mg/day'],
  );

  static const MedicationReference fluoxetine = MedicationReference(
    code: '312938',
    displayName: 'Fluoxetine',
    genericName: 'Fluoxetine hydrochloride',
    drugClass: 'SSRI',
    description: 'SSRI for depression, OCD, panic disorder, bulimia',
    routes: ['Oral'],
    commonDosages: ['20mg/day', '40mg/day', '60mg/day', '80mg/day'],
  );

  static const MedicationReference escitalopram = MedicationReference(
    code: '321967',
    displayName: 'Escitalopram',
    genericName: 'Escitalopram oxalate',
    drugClass: 'SSRI',
    description: 'SSRI for depression and generalized anxiety disorder',
    routes: ['Oral'],
    commonDosages: ['10mg/day', '20mg/day', '30mg/day', '40mg/day'],
  );

  static const MedicationReference citalopram = MedicationReference(
    code: '72056',
    displayName: 'Citalopram',
    genericName: 'Citalopram hydrobromide',
    drugClass: 'SSRI',
    description: 'SSRI for depression; caution with QTc prolongation',
    routes: ['Oral'],
    commonDosages: ['20mg/day', '40mg/day', '60mg/day'],
  );

  static const MedicationReference paroxetine = MedicationReference(
    code: '67036',
    displayName: 'Paroxetine',
    genericName: 'Paroxetine hydrochloride',
    drugClass: 'SSRI',
    description: 'SSRI for depression, anxiety, OCD, PTSD, PMDD, hot flashes',
    routes: ['Oral'],
    commonDosages: ['10mg/day', '20mg/day', '40mg/day', '50mg/day'],
  );

  static const MedicationReference venlafaxine = MedicationReference(
    code: '38676',
    displayName: 'Venlafaxine',
    genericName: 'Venlafaxine hydrochloride',
    drugClass: 'SNRI',
    description: 'SNRI for depression, GAD, social anxiety, panic disorder',
    routes: ['Oral'],
    commonDosages: ['37.5mg/day', '75mg/day', '150mg/day', '225mg/day'],
  );

  static const MedicationReference desvenlafaxine = MedicationReference(
    code: '102864',
    displayName: 'Desvenlafaxine',
    genericName: 'Desvenlafaxine succinate',
    drugClass: 'SNRI',
    description: 'SNRI; active metabolite of venlafaxine',
    routes: ['Oral'],
    commonDosages: ['50mg/day', '100mg/day'],
  );

  static const MedicationReference duloxetine = MedicationReference(
    code: '73039',
    displayName: 'Duloxetine',
    genericName: 'Duloxetine hydrochloride',
    drugClass: 'SNRI',
    description: 'SNRI for depression, GAD, diabetic neuropathy, fibromyalgia, chronic pain',
    routes: ['Oral'],
    commonDosages: ['30mg/day', '60mg/day', '90mg/day'],
  );

  static const MedicationReference bupropion = MedicationReference(
    code: '1202',
    displayName: 'Bupropion',
    genericName: 'Bupropion hydrochloride',
    drugClass: 'NDRI (Antidepressant)',
    description: 'NDRI for depression, seasonal affective disorder, smoking cessation',
    routes: ['Oral'],
    commonDosages: ['150mg/day', '300mg/day', 'Wellbutrin XL: 150-450mg/day'],
  );

  static const MedicationReference mirtazapine = MedicationReference(
    code: '6839',
    displayName: 'Mirtazapine',
    genericName: 'Mirtazapine',
    drugClass: 'Tetracyclic Antidepressant (NaSSA)',
    description: 'NaSSA for depression; also used for insomnia and appetite stimulation',
    routes: ['Oral'],
    commonDosages: ['15mg/day', '30mg/day', '45mg/day at bedtime'],
  );

  static const MedicationReference trazodone = MedicationReference(
    code: '2508',
    displayName: 'Trazodone',
    genericName: 'Trazodone hydrochloride',
    drugClass: 'SARI',
    description: 'SARI for depression and insomnia (low dose)',
    routes: ['Oral'],
    commonDosages: ['50mg/day', '100mg/day', '150mg 2x/day', '25-100mg PRN insomnia'],
  );

  // ==================== BENZODIAZEPINES / ANXIOLYTICS ====================
  static const MedicationReference alprazolam = MedicationReference(
    code: '32937',
    displayName: 'Alprazolam',
    genericName: 'Alprazolam',
    drugClass: 'Benzodiazepine',
    description: 'Short-acting benzodiazepine for anxiety and panic disorder',
    routes: ['Oral'],
    commonDosages: ['0.25mg 3x/day', '0.5mg 3x/day', '1mg 3x/day', '2mg 3x/day'],
  );

  static const MedicationReference lorazepam = MedicationReference(
    code: '33641',
    displayName: 'Lorazepam',
    genericName: 'Lorazepam',
    drugClass: 'Benzodiazepine',
    description: 'Intermediate-acting benzodiazepine; no active metabolites',
    routes: ['Oral', 'IV', 'IM'],
    commonDosages: ['0.5mg 3x/day', '1mg 3x/day', '2mg 3x/day', 'IV: 0.5-2mg PRN'],
  );

  static const MedicationReference clonazepam = MedicationReference(
    code: '63713',
    displayName: 'Clonazepam',
    genericName: 'Clonazepam',
    drugClass: 'Benzodiazepine',
    description: 'Long-acting benzodiazepine for seizures, anxiety, restless legs',
    routes: ['Oral'],
    commonDosages: ['0.5mg 2x/day', '1mg 2x/day', '2mg 2x/day'],
  );

  static const MedicationReference diazepam = MedicationReference(
    code: '4318',
    displayName: 'Diazepam',
    genericName: 'Diazepam',
    drugClass: 'Benzodiazepine',
    description: 'Long-acting benzodiazepine; for anxiety, muscle spasm, seizures, alcohol withdrawal',
    routes: ['Oral', 'IV', 'Rectal'],
    commonDosages: ['2mg 3x/day', '5mg 3x/day', '10mg 3x/day', 'IV: 2-10mg PRN'],
  );

  // ==================== PAIN / NSAIDs ====================
  static const MedicationReference ibuprofen = MedicationReference(
    code: '5640',
    displayName: 'Ibuprofen',
    genericName: 'Ibuprofen',
    drugClass: 'NSAID',
    description: 'NSAID for pain, fever, inflammation; avoid in CKD, PUD',
    routes: ['Oral', 'Topical', 'IV'],
    commonDosages: ['200mg PRN', '400mg 3x/day', '600mg 3x/day', '800mg 3x/day'],
  );

  static const MedicationReference naproxen = MedicationReference(
    code: '83367',
    displayName: 'Naproxen',
    genericName: 'Naproxen sodium',
    drugClass: 'NSAID',
    description: 'Long-acting NSAID for pain, dysmenorrhea, gout',
    routes: ['Oral'],
    commonDosages: ['220mg 2-3x/day', '500mg 2x/day', '250mg 4x/day'],
  );

  static const MedicationReference meloxicam = MedicationReference(
    code: '60789',
    displayName: 'Meloxicam',
    genericName: 'Meloxicam',
    drugClass: 'NSAID (Cox-2 selective)',
    description: 'COX-2 preferential NSAID for osteoarthritis, RA',
    routes: ['Oral'],
    commonDosages: ['7.5mg/day', '15mg/day'],
  );

  static const MedicationReference celecoxib = MedicationReference(
    code: '141944',
    displayName: 'Celecoxib',
    genericName: 'Celecoxib',
    drugClass: 'NSAID (COX-2 Selective)',
    description: 'COX-2 selective NSAID; lower GI risk than traditional NSAIDs',
    routes: ['Oral'],
    commonDosages: ['100mg 2x/day', '200mg 2x/day', '400mg once'],
  );

  static const MedicationReference acetaminophen = MedicationReference(
    code: '161',
    displayName: 'Acetaminophen',
    genericName: 'Acetaminophen',
    drugClass: 'Analgesic/Antipyretic',
    description: 'Pain reliever and fever reducer; hepatotoxic at high doses',
    routes: ['Oral', 'Rectal', 'IV'],
    commonDosages: ['325mg PRN', '500mg PRN', '650mg q4-6h', '1000mg q6h', 'IV: 1g q6h'],
  );

  static const MedicationReference tramadol = MedicationReference(
    code: '10689',
    displayName: 'Tramadol',
    genericName: 'Tramadol hydrochloride',
    drugClass: 'Opioid Analgesic (Atypical)',
    description: 'Atypical opioid for moderate pain; also inhibits reuptake of NE/SERT',
    routes: ['Oral'],
    commonDosages: ['50mg q6h PRN', '100mg q6h PRN', '200mg 2x/day ER'],
  );

  static const MedicationReference oxycodone = MedicationReference(
    code: '7096',
    displayName: 'Oxycodone',
    genericName: 'Oxycodone hydrochloride',
    drugClass: 'Opioid Analgesic',
    description: 'Semi-synthetic opioid for moderate-severe pain',
    routes: ['Oral'],
    commonDosages: ['5mg q6h PRN', '10mg q6h PRN', 'OxyContin: 10-80mg q12h'],
  );

  static const MedicationReference hydrocodoneAcetaminophen = MedicationReference(
    code: '570669',
    displayName: 'Hydrocodone-Acetaminophen',
    genericName: 'Hydrocodone/Acetaminophen',
    drugClass: 'Opioid Analgesic Combination',
    description: 'Combination opioid for moderate pain',
    routes: ['Oral'],
    commonDosages: ['5/325mg q6h PRN', '7.5/325mg q6h PRN', '10/325mg q6h PRN'],
  );

  // ==================== ALLERGIES / ANTIHISTAMINES ====================
  static const MedicationReference cetirizine = MedicationReference(
    code: '201250',
    displayName: 'Cetirizine',
    genericName: 'Cetirizine hydrochloride',
    drugClass: 'Antihistamine (2nd Gen)',
    description: 'Second-generation antihistamine for allergies; mild sedation',
    routes: ['Oral'],
    commonDosages: ['5mg/day', '10mg/day'],
  );

  static const MedicationReference loratadine = MedicationReference(
    code: '26225',
    displayName: 'Loratadine',
    genericName: 'Loratadine',
    drugClass: 'Antihistamine (2nd Gen)',
    description: 'Non-drowsy antihistamine for allergies',
    routes: ['Oral'],
    commonDosages: ['10mg/day'],
  );

  static const MedicationReference fexofenadine = MedicationReference(
    code: '87516',
    displayName: 'Fexofenadine',
    genericName: 'Fexofenadine hydrochloride',
    drugClass: 'Antihistamine (2nd Gen)',
    description: 'Non-sedating antihistamine for seasonal allergies',
    routes: ['Oral'],
    commonDosages: ['60mg 2x/day', '180mg once daily'],
  );

  static const MedicationReference diphenhydramine = MedicationReference(
    code: '3476',
    displayName: 'Diphenhydramine',
    genericName: 'Diphenhydramine hydrochloride',
    drugClass: 'Antihistamine (1st Gen)',
    description: 'First-generation antihistamine; sedating, anticholinergic effects',
    routes: ['Oral', 'IV', 'IM', 'Topical'],
    commonDosages: ['25mg q6h PRN', '50mg q6h PRN', 'IV/IM: 10-50mg PRN'],
  );

  static const MedicationReference promethazine = MedicationReference(
    code: '5640',
    displayName: 'Promethazine',
    genericName: 'Promethazine hydrochloride',
    drugClass: 'Antihistamine (1st Gen) / Antiemetic',
    description: 'First-gen antihistamine for allergies, nausea, motion sickness, sedation',
    routes: ['Oral', 'IV', 'IM', 'Rectal'],
    commonDosages: ['12.5-25mg q4-6h', '25mg at bedtime'],
  );

  // ==================== RESPIRATORY ====================
  static const MedicationReference albuterol = MedicationReference(
    code: '435',
    displayName: 'Albuterol',
    genericName: 'Albuterol sulfate',
    drugClass: 'Beta-2 Agonist',
    description: 'Short-acting beta-2 agonist for acute bronchospasm',
    routes: ['Inhalation', 'Oral', 'Nebulizer'],
    commonDosages: ['2 puffs q4-6h PRN', '2.5mg via nebulizer q4-6h'],
  );

  static const MedicationReference salmeterol = MedicationReference(
    code: '3511',
    displayName: 'Salmeterol',
    genericName: 'Salmeterol xinafoate',
    drugClass: 'Long-acting Beta-2 Agonist',
    description: 'LABA for asthma and COPD maintenance (always with ICS)',
    routes: ['Inhalation'],
    commonDosages: ['50mcg 2x/day (not for acute symptoms)'],
  );

  static const MedicationReference formoterol = MedicationReference(
    code: '728780',
    displayName: 'Formoterol',
    genericName: 'Formoterol fumarate',
    drugClass: 'Long-acting Beta-2 Agonist',
    description: 'LABA; rapid onset; used in COPD and as budesonide-formoterol combo',
    routes: ['Inhalation'],
    commonDosages: ['12mcg 2x/day'],
  );

  static const MedicationReference fluticasone = MedicationReference(
    code: '197530',
    displayName: 'Fluticasone',
    genericName: 'Fluticasone propionate',
    drugClass: 'Inhaled Corticosteroid',
    description: 'ICS for asthma and COPD maintenance',
    routes: ['Inhalation', 'Nasal'],
    commonDosages: ['50mcg 2x/day nasal', '100mcg 2x/day inhaler', '250mcg 2x/day inhaler', '500mcg 2x/day inhaler'],
  );

  static const MedicationReference budesonide = MedicationReference(
    code: '11074',
    displayName: 'Budesonide',
    genericName: 'Budesonide',
    drugClass: 'Inhaled Corticosteroid',
    description: 'ICS for asthma, COPD, allergic rhinitis; nebulizer form for asthma',
    routes: ['Inhalation', 'Nasal', 'Oral'],
    commonDosages: ['Neb: 0.5mg 2x/day', 'Inhaler: 200mcg 2x/day', 'Nasal: 64mcg 2x/day'],
  );

  static const MedicationReference fluticasoneSalmeterol = MedicationReference(
    code: '284859',
    displayName: 'Fluticasone-Salmeterol',
    genericName: 'Fluticasone/Salmeterol combination',
    drugClass: 'ICS/LABA Combination',
    description: 'Combination inhaler for asthma and COPD',
    routes: ['Inhalation'],
    commonDosages: ['100/50mcg 2x/day', '250/50mcg 2x/day', '500/50mcg 2x/day'],
  );

  static const MedicationReference budesonideFormoterol = MedicationReference(
    code: '351056',
    displayName: 'Budesonide-Formoterol',
    genericName: 'Budesonide/Formoterol',
    drugClass: 'ICS/LABA Combination',
    description: 'Symbicort; combination for asthma and COPD',
    routes: ['Inhalation'],
    commonDosages: ['80/4.5mcg 2x/day', '160/4.5mcg 2x/day', '320/9mcg 2x/day'],
  );

  static const MedicationReference montelukast = MedicationReference(
    code: '292928',
    displayName: 'Montelukast',
    genericName: 'Montelukast sodium',
    drugClass: 'Leukotriene Receptor Antagonist',
    description: 'LTRA for asthma, allergic rhinitis; alternative to ICS',
    routes: ['Oral'],
    commonDosages: ['4mg/day (pediatric)', '5mg/day (pediatric)', '10mg/day (adult)'],
  );

  static const MedicationReference ipratropium = MedicationReference(
    code: '197490',
    displayName: 'Ipratropium',
    genericName: 'Ipratropium bromide',
    drugClass: 'Anticholinergic Bronchodilator',
    description: 'SAMA for COPD, asthma; used with albuterol in nebulizer',
    routes: ['Inhalation', 'Nasal'],
    commonDosages: ['2 puffs q4-6h PRN', '500mcg via nebulizer q6-8h'],
  );

  static const MedicationReference tiotropium = MedicationReference(
    code: '71856',
    displayName: 'Tiotropium',
    genericName: 'Tiotropium bromide',
    drugClass: 'Long-acting Anticholinergic (LAMA)',
    description: 'Once-daily LAMA for COPD; Spiriva',
    routes: ['Inhalation'],
    commonDosages: ['18mcg 1x/day (HandiHaler)', '2.5mcg 2x/day (Respimat)'],
  );

  // ==================== ALL MEDICATIONS ====================
  static const List<MedicationReference> all = [
    // ACE Inhibitors
    lisinopril, enalapril, enalaprilat, ramipril, quinapril, captopril, fosinopril, trandolapril,
    // Beta Blockers
    metoprolol, metoprololSuccinate, carvedilol, atenolol, bisoprolol, propranolol,
    labetalol, nebivolol, esmolol,
    // ARBs
    losartan, valsartan, olmesartan, irbesartan,
    // CCBs
    amlodipine, diltiazem, verapamil, nifedipine,
    // Diuretics
    hydrochlorothiazide, chlorthalidone, indapamide, furosemide, bumetanide,
    torsemide, spironolactone, eplerenone, triamterene, acetazolamide,
    // Statins
    atorvastatin, rosuvastatin, simvastatin, pravastatin, pitavastatin, ezetimibe,
    // Anticoagulants / Antiplatelets
    warfarin, apixaban, rivaroxaban, dabigatran, enoxaparin, heparin,
    aspirin, clopidogrel, ticagrelor,
    // Diabetes
    metformin, glipizide, glimepiride, insulinGlargine, insulinLispro, insulinNph,
    empagliflozin, dapagliflozin, liraglutide, semaglutide, sitagliptin, linagliptin,
    // Thyroid
    levothyroxine, liothyronine, methimazole, propylthiouracil,
    // PPIs
    omeprazole, pantoprazole, esomeprazole, lansoprazole, rabeprazole, dexlansoprazole,
    // Antibiotics
    amoxicillin, amoxicillinClavulanate, azithromycin, ciprofloxacin, levofloxacin,
    doxycycline, metronidazole, sulfamethoxazoleTrimethoprim, cephalexin, vancomycin,
    // Antidepressants
    sertraline, fluoxetine, escitalopram, citalopram, paroxetine,
    venlafaxine, desvenlafaxine, duloxetine, bupropion, mirtazapine, trazodone,
    // Benzodiazepines
    alprazolam, lorazepam, clonazepam, diazepam,
    // Pain / NSAIDs
    ibuprofen, naproxen, meloxicam, celecoxib, acetaminophen,
    tramadol, oxycodone, hydrocodoneAcetaminophen,
    // Antihistamines
    cetirizine, loratadine, fexofenadine, diphenhydramine, promethazine,
    // Respiratory
    albuterol, salmeterol, formoterol, fluticasone, budesonide,
    fluticasoneSalmeterol, budesonideFormoterol, montelukast,
    ipratropium, tiotropium,
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

  /// Find by display name
  static MedicationReference? findByName(String name) {
    final lower = name.toLowerCase();
    try {
      return all.firstWhere((m) => m.displayName.toLowerCase() == lower ||
          (m.genericName?.toLowerCase() ?? '').contains(lower));
    } catch (_) {
      return null;
    }
  }

  /// Find by generic name
  static MedicationReference? findByGeneric(String generic) {
    final lower = generic.toLowerCase();
    try {
      return all.firstWhere((m) => m.genericName?.toLowerCase().contains(lower) ?? false);
    } catch (_) {
      return null;
    }
  }
}
