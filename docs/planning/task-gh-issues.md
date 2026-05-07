# TASK_GH_ISSUES.md — OrionHealth Issue Tracker

## ✅ CLOSED

| # | Title | Commit |
|---|---|---|
| #01 | Massive Data Expansion — ICD-10 (12,549), RxNorm (3,022), LOINC (967) | `7b2a3e7` |
| #02 | Data Deduplication & Hierarchy Scripts | `ca3ca39` |
| #03 | Holistic Health Bridge — 9,588 cross-links | `ca3ca39` |
| #04 | Agentic Reasoning Loop — SymphonyClinicalReasonerService | `ca3ca39` |
| #05 | Reasoning Trace UI — Citations section (Referencias y Estándares) | `ca3ca39` |

---

## 🔴 HIGH PRIORITY — Open

### #06 · Real User Context Integration
**Status:** Open — `_getUserContext()` returns empty stubs  
**Required:** Wire `isar_agent_memory` to return real lab/vital/medication history  
**Blocked by:** None  

### #11 · injection.config.dart InvalidType Error
**Status:** Open — `InvalidType` at line 203 in generated DI config  
**Required:** Identify which `@injectable` service is causing invalid type generation  
**Blocked by:** None  

### #14 · Expand Unit Test Coverage
**Status:** Open — Only 2 tests (ClinicalReasonerService)  
**Required:** Tests for MedicalAssistantCubit, MedicalLlmAdapter, InsightCard widget  
**Blocked by:** None  

---

## 🟡 MEDIUM PRIORITY — Open

### #07 · Remove Dead Code: _refineWithLabInsights
**Status:** Open — W-02 in analyzer  
**Required:** Delete unused method from `medical_llm_adapter.dart`  

### #08 · Logger Service (replace print statements)
**Status:** Open — 3× `print()` in `isar_vector_store_service.dart`  
**Required:** Implement `AppLogger` class or use `package:logger`  

### #09 · BLE Scan Subscription Cleanup
**Status:** Open — `_scanSubscription` unused in `ble_sharing_service.dart`  
**Required:** Either implement BLE scan lifecycle or remove the field  

### #10 · Holistic Category Validation
**Status:** Open  
**Required:** Validate that `category == 'Mental'` correctly identifies all mental health codes in the 16,500+ ICD-10 dataset  

### #13 · PII Anonymizer Integration in Agentic Path
**Status:** Open  
**Required:** Ensure `PromptScrubber.scrub()` is called on the symptom text before it reaches the reasoner  

---

## 🟢 LOW PRIORITY — Open

### #12 · analyzeSymptoms Performance Optimization
**Status:** Open  
**Required:** O(n×m) full scan over all mappings per query — add BM25 token index for O(1) lookup  
**Estimate:** 2-3h  

---

## 📋 Phase 4 Scope (Next Session)

1. Fix #11 (DI InvalidType)
2. Implement #06 (Real user memory)
3. Address #07, #08, #09 cleanup
4. Start #14 (test coverage expansion)
5. Start #12 (performance indexing)
