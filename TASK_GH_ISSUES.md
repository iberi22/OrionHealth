# OrionHealth: Comprehensive Development Backlog & Issues

This document lists all identified gaps and missing features required to reach the "Ultimate Holistic Health Assistant" vision.

---

## 🟢 DATA: MEDICAL KNOWLEDGE (The "Brain")

### [ISSUE-01] Massive Expansion of Medical Standards (UMLS Integration)
**Status:** 🟢 COMPLETED
- [x] Scripted extraction from NLM Clinical Tables API for 16,500+ codes.
- [x] Comprehensive coverage of Cardiology, Oncology, and Neurology.
- [x] Expanded RxNorm (3,000+) and LOINC (1,000+) datasets.

### [ISSUE-02] Hierarchical RAG (HiRAG) Support
**Status:** 🟢 COMPLETED
Current JSON is a flat list. The AI needs the hierarchy to summarize.
- [x] Add `parentCode` and `childCodes` fields to ICD-10 JSON.
- [x] Scripted building of hierarchy for 12,000+ ICD-10 codes.
- [x] Goal: Allow the AI to navigate from "Diabetes" (General) to "Type 2 with Neuropathy" (Specific).

### [ISSUE-03] Holistic Mapping (Physical-Mental Bridge)
**Status:** 🟢 IN PROGRESS
- **Task:** For all 5,000+ codes, generate `mentalHealthImpact` (for physical diseases) and `physicalManifestation` (for mental disorders).
- **Goal:** Enable the "Holistic Reasoning" feature requested by the user.

### [ISSUE-04] Global Reference Values for Labs (LOINC)
**Status:** 🟡 IMPORTANT
- **Task:** Standardize and add `referenceValues` for all LOINC codes including Age/Gender variations.
- **Goal:** Enable "Lab Result Interpretation" feature.

---

## 🔵 FEATURES: CORE AGENT

### [ISSUE-05] Drug-Drug Interaction (DDI) Engine
**Status:** 🔴 MISSING
The assistant cannot currently warn about dangerous medication combinations.
- **Task:** Integrate an RxNorm-based interaction dataset (JSON) and a local check in `MedicalKnowledgeRepository`.
- **Goal:** Patient safety and advanced pharmacy reasoning.

### [ISSUE-06] Evidence-Based Clinical Guidelines (Local RAG)
**Status:** 🟡 IMPORTANT
- **Task:** Vectorize PDF/Markdown summaries of WHO and CDC clinical guidelines.
- **Goal:** The AI should cite guidelines when suggesting wellness steps.

### [ISSUE-07] Symptom-to-Disease Knowledge Graph
**Status:** 🟡 IMPORTANT
- **Task:** Create a `symptoms_mapping.json` linking symptoms (SNOMED) to likely diagnoses (ICD-10) with "Relevance Scores".
- **Goal:** Diagnostic reasoning support.

---

## 🟣 UI/UX & INFRASTRUCTURE

### [ISSUE-08] Multi-language Knowledge Base (ES/EN)
**Status:** 🟡 IMPORTANT
Currently, definitions are mostly in English.
- **Task:** Implement a dual-language JSON schema or automatic local translation for `definition` and `searchTerms`.
- **Goal:** Native support for Spanish-speaking users.

### [ISSUE-09] Real-time Indexing Progress UI
**Status:** 🟢 IN PROGRESS
- **Task:** Add a progress bar in the `SyncStep` to show the % of the Vector Store re-indexing process.
- **Goal:** Improve UX during large data updates.

### [ISSUE-10] Documentation: "Medical Code Deep-Links"
**Status:** 🟢 COMPLETED
- [x] Create detail pages for all codes.
- [ ] Add "Related Codes" (Cross-linking) section in the detail page.

---

---

## 🛠️ COMPLETED & STABILIZED (v1.0.0)

### [ISSUE-11] 1.0.0 Production Stabilization
**Status:** 🟢 CLOSED
- [x] Fix syntax errors in `JsonMedicalKnowledgeRepository`.
- [x] Fix compilation errors in BLE and Asset repositories.
- [x] Regenerate DI (Dependency Injection) with `build_runner`.
- [x] Implement real OCR with ML Kit.
- [x] Implement real Report Generation service.
- [x] Full Spanish UI (typing indicators, welcome messages).

### [ISSUE-12] Wikipedia Data Enrichment (Quick Wins)
**Status:** 🔵 ACTIVE
- [x] Scrape definitions and Wikipedia URLs for existing ICD-10 codes (partial).
- [x] Scrape RxNorm definitions for the medication catalog (partial).
- [ ] Implement local caching for scraped data to avoid re-scraping.
- [ ] Finalize enrichment for all 600+ existing codes.

---

## 🛠️ EXTERNAL REPOS TO EXTRACT FROM:
1. [NXOntology Data](https://github.com/related-sciences/nxontology-data): For relationships and graph structures.
2. [Medplum ValueSets](https://github.com/medplum/medplum): For FHIR-compatible terminology lists.
3. [NLM Clinical Tables API](https://clinicaltables.nlm.nih.gov/): For official 2024 definitions.
