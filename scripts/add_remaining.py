#!/usr/bin/env python3
"""Append remaining RxNorm entries + add SNOMED data + execution code to append_all.py"""
import os

script_path = r'E:\scripts-python\orionhealth\scripts\append_all.py'

with open(script_path, 'a', encoding='utf-8') as f:
    f.write(""","Tiotropium","Anticholinergic Inhaler",["Spiriva","Tiotropio"]),
("83020","Ipratropium","Anticholinergic Inhaler",["Atrovent","Ipratropio"]),
("7646","Omeprazole","PPI",["Prilosec","Omeprazol"]),
("40790","Pantoprazole","PPI",["Protonix","Pantoprazol"]),
("5605","Esomeprazole","PPI",["Nexium","Esomeprazol"]),
("34892","Lansoprazole","PPI",["Prevacid","Lansoprazol"]),
("8050","Ranitidine","H2 Blocker",["Zantac","Ranitidina"]),
("421254","Famotidine","H2 Blocker",["Pepcid","Famotidina"]),
("1292","Ondansetron","Antiemetic",["Zofran","Ondansetron"]),
("24885","Metoclopramide","Prokinetic",["Reglan","Metoclopramida"]),
("16837","Amoxicillin","Penicillin Antibiotic",["Amoxil","Amoxicilina"]),
("11234","Cephalexin","Cephalosporin",["Keflex","Cefalexina"]),
("4377","Ciprofloxacin","Fluoroquinolone",["Cipro","Ciprofloxacina"]),
("4981","Levofloxacin","Fluoroquinolone",["Levaquin","Levofloxacino"]),
("7207","Azithromycin","Macrolide",["Zithromax","Azitromicina"]),
("5372","Erythromycin","Macrolide",["Eryc","Eritromicina"]),
("14314","Clarithromycin","Macrolide",["Biaxin","Claritromicina"]),
("7819","Doxycycline","Tetracycline",["Vibramycin","Doxiciclina"]),
("13679","Metronidazole","Nitroimidazole",["Flagyl","Metronidazol"]),
("3260","Clindamycin","Lincosamide",["Cleocin","Clindamicina"]),
("24958","Sulfamethoxazole/Trimethoprim","Sulfonamide",["Bactrim","Septra","TMP-SMX"]),
("134965","Nitrofurantoin","Urinary Antibiotic",["Macrodantin","Nitrofurantoina"]),
("11355","Vancomycin","Glycopeptide",["Vancocin","Vancomicina"]),
("18765","Prednisolone","Corticosteroid",["Prednisolona","Orapred"]),
("9233","Hydrocortisone","Corticosteroid",["Cortisol","Hidrocortisona"]),
("36309","Allopurinol","Xanthine Oxidase Inhibitor",["Zyloprim","Alopurinol"]),
("1881","Colchicine","Antigout",["Colcrys","Colchicina"]),
("2152","Bisoprolol","Beta Blocker",["Zebeta","Bisoprolol"]),
("21842","Propranolol","Beta Blocker",["Inderal","Propranolol"]),
("28422","Diltiazem","Calcium Channel Blocker",["Cardizem","Diltiazem"]),
("3589","Nifedipine","Calcium Channel Blocker",["Procardia","Nifedipina"]),
("221391","Verapamil","Calcium Channel Blocker",["Calan","Verapamilo","Verapamil"]),
("23899","Clonidine","Alpha Agonist",["Catapres","Clonidina"]),
("3653","Prazosin","Alpha Blocker",["Minipress","Prazosina"]),
("8910","Doxazosin","Alpha Blocker",["Cardura","Doxazosina"]),
("2454","Terazosin","Alpha Blocker",["Hytrin","Terazosina"]),
("9471","Finasteride","5-Alpha Reductase Inhibitor",["Proscar","Finasterida","Propecia"]),
("6817","Tamsulosin","Alpha Blocker",["Flomax","Tamsulosina"]),
("32549","Sildenafil","PDE5 Inhibitor",["Viagra","Sildenafilo","Revatio"]),
("16231","Tadalafil","PDE5 Inhibitor",["Cialis","Tadalafilo"]),
("5046","Vardenafil","PDE5 Inhibitor",["Levitra","Vardenafilo"]),
("875","Insulin Glargine","Insulin",["Lantus","Insulina glargina","Toujeo"]),
("200141","Insulin Lispro","Insulin",["Humalog","Insulina lispro"]),
("54693","Insulin Aspart","Insulin",["Novolog","Insulina aspart"]),
("16068","Insulin Detemir","Insulin",["Levemir","Insulina detemir"]),
("226","Insulin Regular","Insulin",["Humulin R","Novolin R","Insulina regular"]),
("18552","Insulin NPH","Insulin",["Humulin N","Novolin N","Insulina NPH"]),
("3622","Pioglitazone","Thiazolidinedione",["Actos","Pioglitazona"]),
("3616","Rosiglitazone","Thiazolidinedione",["Avandia","Rosiglitazona"]),
("24560","Sitagliptin","DPP-4 Inhibitor",["Januvia","Sitagliptina"]),
("36981","Saxagliptin","DPP-4 Inhibitor",["Onglyza","Saxagliptina"]),
("12578","Linagliptin","DPP-4 Inhibitor",["Tradjenta","Linagliptina"]),
("466138","Empagliflozin","SGLT2 Inhibitor",["Jardiance","Empagliflozina"]),
("157949","Dapagliflozin","SGLT2 Inhibitor",["Farxiga","Dapagliflozina"]),
("17053","Canagliflozin","SGLT2 Inhibitor",["Invokana","Canagliflozina"]),
("8435","Liraglutide","GLP-1 Agonist",["Victoza","Saxenda","Liraglutida"]),
("159325","Semaglutide","GLP-1 Agonist",["Ozempic","Wegovy","Rybelsus","Semaglutida"]),
("248688","Dulaglutide","GLP-1 Agonist",["Trulicity","Dulaglutida"]),
("5939","Acetaminophen","Analgesic",["Tylenol","Paracetamol","Acetaminofeno"]),
("5051","Cyclobenzaprine","Muscle Relaxant",["Flexeril","Ciclobenzaprina"]),
("510","Baclofen","Muscle Relaxant",["Lioresal","Baclofeno"]),
("6937","Methocarbamol","Muscle Relaxant",["Robaxin","Metocarbamol"]),
("621","Tizanidine","Muscle Relaxant",["Zanaflex","Tizanidina"]),
("519","Zolpidem","Sedative",["Ambien","Zolpidem"]),
("28883","Eszopiclone","Sedative",["Lunesta","Eszopiclona"]),
("2585","Temazepam","Benzodiazepine",["Restoril","Temazepam"]),
("1437","Midazolam","Benzodiazepine",["Versed","Midazolam"]),
]
print(f'RxNorm entries: {len(RXNORM)}')

# ====== SNOMED CT DATA ======
SNOMED = [
("73211009","Diabetes mellitus type 2","Endocrine Disorder",["T2DM","type 2 diabetes","diabetes tipo 2"]),
("46635009","Diabetes mellitus type 1","Endocrine Disorder",["T1DM","type 1 diabetes","diabetes tipo 1"]),
("44054006","Type 2 diabetes with foot ulcer","Endocrine Disorder",["diabetic foot","pie diabetico"]),
("59621000","Essential hypertension","Cardiovascular",["hypertension","high BP","hipertension"]),
("399304003","Sustained hypertension","Cardiovascular",["chronic hypertension","hipertension cronica"]),
("53741008","Congestive heart failure","Cardiovascular",["CHF","heart failure","insuficiencia cardiaca"]),
("414545008","Ischemic heart disease","Cardiovascular",["coronary disease","cardiopatia isquemica"]),
("194828000","Angina pectoris","Cardiovascular",["angina","chest pain"]),
("57054005","Acute myocardial infarction","Cardiovascular",["heart attack","MI","infarto"]),
("195967001","Asthma","Respiratory",["bronchial asthma","asma"]),
("13645005","COPD","Respiratory",["chronic obstructive pulmonary disease","EPOC"]),
("233604007","Pneumonia","Respiratory",["lung infection","pneumonia"]),
("10509002","Acute bronchitis","Respiratory",["bronchitis","bronquitis"]),
("49727002","Chronic sinusitis","Respiratory",["sinus infection","sinusitis cronica"]),
("31387002","Fracture of forearm","Musculoskeletal",["radial fracture","broken arm"]),
("71620000","Fracture of femur","Musculoskeletal",["hip fracture","femur fracture"]),
("15773000","Torus fracture of radius","Musculoskeletal",["buckle fracture","greenstick"]),
("239873009","Osteoarthritis of knee","Musculoskeletal",["knee OA","artrosis rodilla"]),
("396275006","Osteoarthritis of hip","Musculoskeletal",["hip OA","coxarthrosis"]),
("201820007","Rheumatoid arthritis","Musculoskeletal",["RA","artritis reumatoide"]),
("26929004","Alzheimer disease","Neurologic",["Alzheimer dementia","EA","Alzheimer"]),
("54150009","Multiple sclerosis","Neurologic",["MS","esclerosis multiple"]),
("56727007","Cerebral palsy","Neurologic",["spastic CP","paralisis cerebral"]),
("230207008","Migraine without aura","Neurologic",["common migraine","migrana"]),
("7323001","Migraine with aura","Neurologic",["classic migraine","migrana con aura"]),
("84387000","Parkinson disease","Neurologic",["Parkinson","parkinsonismo"]),
("19298008","Epilepsy","Neurologic",["seizure disorder","convulsive disorder"]),
("416330003","Cerebrovascular accident","Neurologic",["stroke","CVA","ACV"]),
("230690007","Major depressive disorder","Mental Health",["MDD","depression","depresion mayor"]),
("13746004","Bipolar disorder","Mental Health",["manic depression","trastorno bipolar"]),
("58214004","Schizophrenia","Mental Health",["schizophrenia","esquizofrenia"]),
("191736004","Generalized anxiety disorder","Mental Health",["GAD","anxiety disorder","ansiedad"]),
("81308009","Post-traumatic stress disorder","Mental Health",["PTSD","trauma","estres post-traumatico"]),
("274951002","Acute upper respiratory infection","Infectious",["URI","common cold","resfriado"]),
("6142004","Influenza","Infectious",["flu","gripe","influenza"]),
("18624000","Urinary tract infection","Infectious",["UTI","cystitis","ITU"]),
("40748000","Chronic kidney disease","Renal",["CKD","renal failure","ERC"]),
("90688005","Acute renal failure","Renal",["AKI","acute kidney injury","IRA"]),
("46481004","Benign prostatic hyperplasia","Urologic",["BPH","prostate enlargement","HBP"]),
("72892002","Normal pregnancy","OB/GYN",["pregnancy","gestation","embarazo"]),
("363171000","Preeclampsia","OB/GYN",["pregnancy-induced hypertension"]),
("35489007","Depressive disorder in childbirth","OB/GYN",["postpartum depression"]),
("289184003","Anemia in pregnancy","OB/GYN",["anemia gestacional"]),
("3424008","Iron deficiency anemia","Hematologic",["microcytic anemia","anemia ferropenica"]),
("127295002","Acute appendicitis","Gastrointestinal",["appendicitis","apendicitis"]),
("266571003","Diverticulitis","Gastrointestinal",["diverticular disease"]),
("3738000","Hyperlipidemia","Metabolic",["high cholesterol","hiperlipidemia"]),
("440344006","Gastroesophageal reflux disease","Gastrointestinal",["GERD","reflux","reflujo"]),
("19660004","Gastritis","Gastrointestinal",["gastric inflammation","gastritis"]),
("89765005","Peptic ulcer disease","Gastrointestinal",["duodenal ulcer","gastric ulcer","ulcera"]),
("14760008","Benign neoplasm of skin","Dermatologic",["skin growth","nevus","lunar"]),
("254137008","Contact dermatitis","Dermatologic",["allergic rash","contact dermatitis"]),
("200936003","Atopic dermatitis","Dermatologic",["eczema","dermatitis atopica"]),
("924000","Early stage pressure ulcer","Dermatologic",["bed sore","pressure injury"]),
("34014006","Viral hepatitis type C","Infectious",["Hep C","hepatitis C","HCV"]),
("50711007","Viral hepatitis type B","Infectious",["Hep B","hepatitis B","HBV"]),
("18802000","Chronic hepatitis C","Infectious",["chronic HCV"]),
("722444007","COVID-19","Infectious",["coronavirus","SARS-CoV-2","COVID"]),
]
print(f'SNOMED entries: {len(SNOMED)}')

# =====================
# EXECUTION
# =====================
print('Building ICD-10...')
r1 = build('icd10', ICD10)
save('icd10', r1)

print('Building LOINC...')
r2 = build('loinc', LOINC)
save('loinc', r2)

print('Building RxNorm...')
r3 = build('rxnorm', RXNORM)
save('rxnorm', r3)

print('Building SNOMED CT...')
r4 = build('snomed', SNOMED)
save('snomed', r4)

print('Done!')
""")

print(f'append_all.py size: {os.path.getsize(script_path)} bytes')
