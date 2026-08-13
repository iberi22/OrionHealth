class MedicalBenchmarkDoc {
  final String id;
  final String content;
  const MedicalBenchmarkDoc({required this.id, required this.content});
}

class MedicalBenchmarkQuery {
  final String query;
  final List<String> expectedIds;
  const MedicalBenchmarkQuery({required this.query, required this.expectedIds});
}

const List<MedicalBenchmarkDoc> medicalBenchmarkDocuments = [
  MedicalBenchmarkDoc(
    id: 'doc_diabetes',
    content:
        'Management of Type 2 Diabetes Mellitus includes lifestyle modifications, metformin therapy, monitoring HbA1c levels, and potential insulin therapy to prevent diabetic ketoacidosis and retinopathy.',
  ),
  MedicalBenchmarkDoc(
    id: 'doc_hypertension',
    content:
        'Essential hypertension treatment guidelines recommend lifestyle changes, sodium restriction, and pharmacological options such as ACE inhibitors (lisinopril), ARBs (losartan), or calcium channel blockers (amlodipine).',
  ),
  MedicalBenchmarkDoc(
    id: 'doc_asthma',
    content:
        'Acute asthma exacerbation is treated with inhaled short-acting beta2-agonists (albuterol) and systemic corticosteroids. Long-term control uses inhaled corticosteroids (fluticasone) and long-acting bronchodilators.',
  ),
  MedicalBenchmarkDoc(
    id: 'doc_stroke',
    content:
        'Ischemic stroke occurs due to cerebral artery occlusion. Emergency management requires intravenous tissue plasminogen activator (tPA) within 3 to 4.5 hours of symptom onset if no contraindications exist.',
  ),
  MedicalBenchmarkDoc(
    id: 'doc_heart_attack',
    content:
        'Myocardial infarction (heart attack) presents with chest pain radiating to the left arm, dyspnea, and diaphoresis. Treatment includes aspirin, nitroglycerin, beta-blockers, and emergent coronary angiography or PCI.',
  ),
  MedicalBenchmarkDoc(
    id: 'doc_appendicitis',
    content:
        'Acute appendicitis presents with right lower quadrant abdominal pain, fever, and leukocytosis. McBurney\'s point tenderness is a classic sign. Diagnostic imaging is ultrasound or CT, followed by appendectomy.',
  ),
  MedicalBenchmarkDoc(
    id: 'doc_pneumonia',
    content:
        'Community-acquired pneumonia causes cough, fever, pleuritic chest pain, and sputum production. Diagnosis is confirmed by chest X-ray showing lobar consolidation. Treated with antibiotics like azithromycin or amoxicillin.',
  ),
  MedicalBenchmarkDoc(
    id: 'doc_covid19',
    content:
        'COVID-19 is a viral respiratory illness caused by SARS-CoV-2. Symptoms range from mild cough and fever to severe acute respiratory distress syndrome (ARDS). Vaccines and antivirals (paxlovid) are key mitigations.',
  ),
  MedicalBenchmarkDoc(
    id: 'doc_anemia',
    content:
        'Iron deficiency anemia leads to fatigue, pallor, and microcytic hypochromic red blood cells. Diagnosed by low serum ferritin and iron levels. Treated with oral ferrous sulfate supplementation.',
  ),
  MedicalBenchmarkDoc(
    id: 'doc_migraine',
    content:
        'Migraine headaches are unilateral, throbbing, moderate-to-severe headaches often accompanied by nausea, vomiting, photophobia, and phonophobia. Triptans (sumatriptan) are used for acute abortive therapy.',
  ),
];

const List<MedicalBenchmarkQuery> medicalBenchmarkQueries = [
  MedicalBenchmarkQuery(
    query: 'elevated blood pressure and hypertension drugs',
    expectedIds: ['doc_hypertension'],
  ),
  MedicalBenchmarkQuery(
    query: 'high blood sugar levels and HbA1c control',
    expectedIds: ['doc_diabetes'],
  ),
  MedicalBenchmarkQuery(
    query: 'emergency therapy for blood clot in brain',
    expectedIds: ['doc_stroke'],
  ),
  MedicalBenchmarkQuery(
    query: 'chest pain, shortness of breath, left arm pain',
    expectedIds: ['doc_heart_attack'],
  ),
  MedicalBenchmarkQuery(
    query: 'difficulty breathing, wheezing, albuterol inhaler',
    expectedIds: ['doc_asthma'],
  ),
  MedicalBenchmarkQuery(
    query: 'lower right side stomach pain, McBurney tenderness',
    expectedIds: ['doc_appendicitis'],
  ),
  MedicalBenchmarkQuery(
    query: 'lung infection, cough, chest consolidation',
    expectedIds: ['doc_pneumonia'],
  ),
  MedicalBenchmarkQuery(
    query: 'low iron count, feeling tired, pale skin',
    expectedIds: ['doc_anemia'],
  ),
];
