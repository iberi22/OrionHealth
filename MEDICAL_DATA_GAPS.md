# OrionHealth: Medical Knowledge Gap Analysis

This document outlines the current limitations of the medical standards database and provides a roadmap for "completación de la información" to reach production readiness.

## 1. Quantitative Gaps (Coverage)

Current datasets are **subsets** and lack the depth required for complex clinical reasoning.

| Standard | Current Count | Target (Base Coverage) | Status |
| :--- | :--- | :--- | :--- |
| **ICD-10** | 278 | 10,000+ (Core clinical) | 🔴 Sparse |
| **LOINC** | 145 | 2,000+ (Common Labs) | 🔴 Sparse |
| **RxNorm** | 118 | 5,000+ (Mainstream drugs) | 🔴 Sparse |
| **SNOMED CT** | 87 | 20,000+ (Clinical concepts) | ⭕ Critical |

### Missing Key Areas:
- **Cardiology**: Advanced diagnostic codes (arrhythmias, specific valvular diseases).
- **Neurology**: Neurodegenerative diseases, specific seizure types.
- **Pediatrics**: Developmental milestones and childhood-specific conditions.
- **Oncology**: Specific staging and tumor types.

---

## 2. Qualitative Gaps (Information Depth)

The current JSON structure is too shallow for "High-Reasoning" AI.

### Missing Fields per Code:
- `definition`: A 2-3 sentence clinical description.
- `commonSymptoms`: Array of symptoms (links to SNOMED).
- `riskFactors`: Environmental or lifestyle triggers.
- `mentalHealthImpact`: (Holistic Bridge) How this physical condition typically affects mental health.
- `referenceValues`: (For LOINC) Normal ranges by age/gender.

---

## 3. Structural Gaps (Relational)

To support **HiRAG (Hierarchical RAG)**, we need relationships between nodes.

- **Parent/Child Hierarchy**: (e.g., `E11` -> `E11.21`). This allows the AI to summarize at different levels of detail.
- **Cross-Standard Mapping**: Linking a LOINC test (Glucose) to an ICD-10 diagnosis (Diabetes).
- **Interactions**: RxNorm drug-drug interaction warnings (crucial for safety).

---

## 4. Roadmap for Data Completion

### Phase 1: Automated Extraction (Quick Wins)
- [ ] **UMLS / Metathesaurus**: Use NLM APIs to extract definitions and synonyms for the current 628 codes.
- [ ] **Medplum / FHIR**: Extract common `ValueSet` definitions for Labs and Meds.
- [ ] **WikiData / Wikipedia**: Scrape the `wikipediaUrl` already present in our JSON to extract the first paragraph as `definition`.

### Phase 2: Holistic Enrichment
- [ ] **Mental Health Mapping**: Use GPT-4o or similar to generate "Mental Health Impacts" for the top 500 chronic diseases based on medical literature.
- [ ] **Symptom Mapping**: Import the [Symptom-Disease Dataset](https://github.com/vohumana/Symptom-Disease-Dataset) and map it to our ICD-10 codes.

### Phase 3: Validation
- [ ] **Clinical Review**: Batch verification of definitions by medical professionals (or via gold-standard medical textbooks).
