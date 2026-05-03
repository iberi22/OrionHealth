# Features — OrionHealth

## Feature List

| ID | Feature | Status | Priority | Components |
|----|---------|--------|----------|------------|
| F-001 | Authentication & Medical Identity | ✅ Complete | P0 | auth/, encryption_service, secure_storage |
| F-002 | Local RAG Agent (isar_agent_memory) | ✅ Complete | P0 | local_agent/, isar_agent_memory package |
| F-003 | Medical Data Sharing (BLE/NFC/WiFi) | ✅ Complete | P0 | health_sharing/, ble_sharing/ |
| F-004 | Health Wallet (Offline Storage) | ✅ Complete | P0 | packages/health_wallet |
| F-005 | On-Device LLM (Gemma 4) | ⚠️ AICore Plugin | P1 | aicore_service, GemmaLlmAdapter |
| F-006 | Medical Standards (ICD-10, LOINC, RxNorm) | ✅ Complete | P0 | packages/medical_standards |
| F-007 | RAG Query Engine | ✅ Complete | P1 | rag_llm_service, MemoryGraph |
| F-008 | Health Data Import | 🚧 Scaffolded | P2 | health_data_import/ |
| F-009 | User Profile & Settings | ✅ Complete | P1 | user_profile/, settings/ |

## Feature Dependencies

```
F-001 (Auth) ──► F-003 (Sharing) ──► F-008 (Import)
F-001 ├─► F-004 (Health Wallet)
F-002 (RAG) ──► F-005 (LLM)
F-002 ──► F-006 (Standards)
F-002 ──► F-007 (Query Engine)
F-004 ──► F-009 (Profile)
```

## Known Gaps
- F-005: AicorePlugin.kt created (placeholder) — needs ML Kit GenAI SDK + real Gemma 4 inference
- F-008: health_data_import has no UI, only cubit scaffold with unused imports
