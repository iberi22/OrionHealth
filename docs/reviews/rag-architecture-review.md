# OrionHealth RAG Architecture Review

**Date:** 2026-05-03
**Project:** OrionHealth (`E:\scripts-python\orionhealth`)
**Package:** `isar_agent_memory v0.5.0-beta`
**Analyst:** OpenClaw Subagent

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Architecture Overview](#2-architecture-overview)
3. [`isar_agent_memory` Package Deep Dive](#3-isar_agent_memory-package-deep-dive)
4. [Embedding Pipeline](#4-embedding-pipeline)
5. [Vector Store Architecture](#5-vector-store-architecture)
6. [Health Data Storage (`health_wallet`)](#6-health-data-storage-health_wallet)
7. [Medical Standards Indexing Pipeline](#7-medical-standards-indexing-pipeline)
8. [Search & Retrieval Pipeline](#8-search--retrieval-pipeline)
9. [Python Data Generation Scripts](#9-python-data-generation-scripts)
10. [Ollama / Gemma Integration](#10-ollama--gemma-integration)
11. [Critical Bottlenecks & Issues](#11-critical-bottlenecks--issues)
12. [Recommendations](#12-recommendations)

---

## 1. Executive Summary

OrionHealth implements a **local-first, privacy-centric RAG architecture** built on the `isar_agent_memory` package (v0.5.0-beta). The system uses:
- **Graph-based Agent Memory** (`MemoryGraph`) — a hybrid vector + knowledge graph built on IsarDB
- **Hierarchical RAG** (HiRAG) — multi-layer summarization and multi-hop search
- **Medical Standards Data** — ICD-10, LOINC, RxNorm, SNOMED CT embedded as vector nodes
- **Hybrid Search** — combining semantic vector search with BM25-style keyword matching via Reciprocal Rank Fusion (RRF)

**Overall Assessment:** The architecture is well-designed for a **local-first mobile health agent**. however, there are several critical issues in the current implementation that must be addressed before production.

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                    Flutter App                        │
│  ┌─────────────────────────────────────────────────┐ │
│  │            Application Layer (lib/)               │ │
│  │  ┌──────────────┐  ┌───────────────────────┐    │ │
│  │  │ SmartSearch   │  │  MedicalIndexingService │   │ │
│  │  │ UseCase       │  │                        │   │ │
│  │  └──────┬───────┘  └──────────┬────────────┘    │ │
│  │         │                      │                  │ │
│  │  ┌──────▼──────────────────────▼────────────┐     │ │
│  │  │   VectorStoreService (Domain Interface)    │     │ │
│  │  │   IsarVectorStoreService (Implementation)  │     │ │
│  │  └──────────────────┬───────────────────────┘     │ │
│  │                     │                              │ │
│  │  ┌──────────────────▼───────────────────────┐     │ │
│  │  │          isar_agent_memory package          │     │ │
│  │  │  ┌─────────────┐  ┌──────────────────┐    │     │ │
│  │  │  │ MemoryGraph  │  │  HiRAG Extension │    │     │ │
│  │  │  └──────┬──────┘  └────────┬─────────┘    │     │ │
│  │  │         │                   │              │     │ │
│  │  │  ┌──────▼───────────────────▼──────────┐  │     │ │
│  │  │  │  IsarDB (Embedded Object DB)         │  │     │ │
│  │  │  └────────────────────────────────────┘  │     │ │
│  │  └──────────────────────────────────────────┘     │ │
│ └─────────────────────────────────────────────────┘  │
│                                                        │
│  ┌─────────────────────────────────────────────────┐  │
│  │            health_wallet package                  │  │
│  │  ┌──────────┐ ┌────────────────┐               │  │
│  │  │Wallet    │ │EncryptionService│               │  │
│  │  │Service   │ │ AES-256-GCM    │               │  │
│  │  └──────────┘ └────────────────┘               │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Data Flow

```
User Query (Spanish/English)
       │
       ▼
SmartSearchUseCase ──► Strategy Detection ──► BM25/MMR/Diversity/Recency
       │
       ▼
IsarVectorStoreService.search()
       │
       ├──► MemoryGraph.hybridSearch()
       │       ├── 1. Embedding → GeminiEmbeddingsAdapter / FallbackEmbeddingsAdapter
       │       ├── 2. Vector Search → InMemoryVectorIndex (cosine similarity)
       │       ├── 3. Text Search → Isar filter (contentContains, case-insensitive)
       │       └── 4. Fusion → Weighted scoring (alpha=0.5 vector + 0.5 text)
       │
       └──► MedicalIndexingService.search()
               ├── 1. Vector Search (see above)
               ├── 2. Text Index Fallback → MedicalKnowledgeRepository.searchByTerm()
               └── 3. Merge → Deduplicate by code, rank by score
       │
       ▼
RagLlmService.generate()
       ├── 1. Retrieve context from VectorStoreService
       ├── 2. Enrich with MedicalResearchService (web — if cloud allowed)
       └── 3. Stream response (simulated — currently fixed text template)
```

---

## 3. `isar_agent_memory` Package Deep Dive

### 3.1 Core Classes

| Class | File | Role |
|-------|------|------|
| `MemoryGraph` | `src/memory_graph.dart` | Main API — CRUD, semantic search, hybrid search, explainability |
| `MemoryNode` | `src/models/memory_node.dart` | Graph node — content, embedding, type, layer, metadata, degree |
| `MemoryEdge` | `src/models/memory_edge.dart` | Graph edge — source→target with relation type |
| `MemoryEmbedding` | `src/models/memory_embedding.dart` | Embedding wrapper — vector, provider, dimension |
| `Degree` | `src/models/degree.dart` | Activation scores — recency, frequency, importance |
| `VectorIndex` | `src/vector_index.dart` | Abstract vector index interface |
| `Float32List` | | On-device/Memory vector storage |

### 3.2 Key Features (v0.5.0-beta)

| Feature | Status | Detail |
|---------|--------|--------|
| **Semantic Search** | ✅ Working | Cosine similarity via InMemoryVectorIndex |
| **Hybrid Search** | ✅ Working | Vector + Isar text filter with RRF fusion |
| **HiRAG Layer Summarization** | ✅ Implemented | Auto-summarize via LLMAdapter (requires configured LLM) |
| **Multi-Hop Search** | ✅ Implemented | Upward traversal through summary edges |
| **Explainability** | ✅ Implemented | `explainRecall()` — distance, activation, BFS path |
| **Memory Consolidation** | ✅ Implemented | Cluster + LLM-merge similar memories |
| **Forgetting Mechanism** | ✅ Implemented | Age-based, importance-based, LRU, temporal decay |
| **Embeddings Cache** | ✅ Implemented | LRU cache (default 1000 entries) with stats |
| **Sync Manager** | ✅ Implemented | Firebase RTDB + WebSocket backends |
| **Cross-Device Sync** | ✅ Implemented | UUID-based dedup with LWW conflict resolution |
| **On-Device Embeddings** | 🟡 Partial | ONNX Runtime adapter exists but blocked by `onnxruntime` dependency |
| **ObjectBox Vector Index** | ❌ Disabled | Code exists but commented out — generator unavailable |
| **Multi-Modal Memory** | 🟡 Implemented | `multi_modal_adapter.dart` exists but not wired in |

### 3.3 Critical: `SimpleEmbeddingsAdapter` is the Active Implementation

**The DI module (`lib/core/di/memory_module.dart`) wires `SimpleEmbeddingsAdapter` as the singleton `EmbeddingsAdapter`:**

```dart
@lazySingleton
EmbeddingsAdapter get embeddingsAdapter => SimpleEmbeddingsAdapter();
```

`SimpleEmbeddingsAdapter` generates **deterministic pseudo-random embeddings** using `text.hashCode`:

```dart
Future<List<double>> embed(String text) async {
  final seed = text.hashCode;
  return List.generate(dimension, (i) {
    final rng = ((seed + i * 31) % 0x7FFFFFFF) / 0x7FFFFFFF;
    return rng;
  });
}
```

**This is a MAJOR ISSUE.** The Gemini and ONNX embedding adapters exist in the `isar_agent_memory` package but are **never wired into the DI container**. All semantic search is currently using hash-based fake embeddings.

### 3.4 MemoryNode Structure

```dart
@collection
class MemoryNode {
  @Index(unique: true, replace: true)
  String? uuid;              // Global unique ID for sync
  late String content;       // Main text/content
  String? type;              // Classification (fact, message, goal, etc.)
  late DateTime createdAt;   // Creation timestamp
  int accessCount;           // Access tracking
  DateTime? modifiedAt;      // LWW conflict resolution
  String? version;           // Sync version
  bool isDeleted;            // Soft delete tombstone
  int layer;                 // HiRAG: 0=base, >0=summary
  MemoryEmbedding? embedding; // Vector embedding
  Degree? degree;            // Activation scores
  @ignore
  Map<String, dynamic>? metadata; // Non-persisted extensible data
}
```

**Issue:** `metadata` is marked `@ignore` — it is NOT persisted in IsarDB. Metadata is lost on app restart unless serialized elsewhere.

---

## 4. Embedding Pipeline

### 4.1 Available Embedding Adapters

| Adapter | Provider | Dimension | Status | Notes |
|---------|----------|-----------|--------|-------|
| `GeminiEmbeddingsAdapter` | `gemini` | 768 (cached) | ✅ Working | Uses `text-embedding-004` API, retry with backoff |
| `OnDeviceEmbeddingsAdapter` | `on_device_onnx` | 384 (default) | ❌ Blocked | Depends on `onnxruntime` package + BERT model files |
| `FallbackEmbeddingsAdapter` | `primary->fallback` | Runtime | ✅ Working | Primary→fallback or On-device→Gemini |
| `SimpleEmbeddingsAdapter` | `simple_hash` | 768 | ✅ WIRED | **ACTIVE** — hash-based, semantically meaningless |

### 4.2 Gemini Embeddings (`GeminiEmbeddingsAdapter`)

```dart
class GeminiEmbeddingsAdapter implements EmbeddingsAdapter {
  final String apiKey;
  final String model = 'text-embedding-004';
  final int maxRetries = 2;
  final Duration retryBaseDelay = Duration(milliseconds: 300);
  final Duration timeout = Duration(seconds: 15);
```

**Pros:**
- Real semantic embeddings
- Retry logic with exponential backoff
- Dimension caching after first call

**Cons:**
- **Requires network** — violates local-first design for embedding generation
- 15-second timeout may fail on slow connections
- API key management (exposed in `Platform.environment`)

### 4.3 On-Device Embeddings (`OnDeviceEmbeddingsAdapter`)

```dart
class OnDeviceEmbeddingsAdapter implements EmbeddingsAdapter {
  final String modelPath;
  final String vocabPath;
  final int _dimension;  // 384 for all-MiniLM-L6-v2
```

**Design Review:**
- Proper ONNX Runtime integration with BERT models
- Mean pooling for sentence embeddings
- WordPiece tokenizer implementation
- Manual resource management (OrtEnv.init/release)

**Critical Issue:** The `onnxruntime` Dart package is listed as a dependency in `pubspec.yaml` but:
1. The generated `.g.dart` files reference it
2. ObjectBox vector index (also depends on `flat_buffers`) is disabled
3. No model files (`*.onnx`, `vocab.txt`) are bundled in the project
4. Build will fail if `onnxruntime` is not properly configured for Android

### 4.4 Fallback Chain

The `FallbackEmbeddingsAdapter` chains primary→fallback:
```
OnDeviceEmbeddingsAdapter (primary) → GeminiEmbeddingsAdapter (fallback)
```

**But this is never instantiated in DI.** The DI module uses `SimpleEmbeddingsAdapter` directly.

---

## 5. Vector Store Architecture

### 5.1 Vector Index Options

| Implementation | Status | Notes |
|---------------|--------|-------|
| `InMemoryVectorIndex` | ✅ **ACTIVE** | `DI wire — cosine similarity, not persisted, all data lost on restart` |
| `ObjectBoxVectorIndex` | ❌ DISABLED | HNSW index with 768-dimensional vectors, fully commented out |
| `RemoteVectorIndex` | ❌ Not implemented | — |

### 5.2 InMemoryVectorIndex (Active)

```dart
class InMemoryVectorIndex implements VectorIndex {
  final Map<String, _DocEntry> _docs = {};
  // Cosine similarity via linear scan O(n) — no HNSW/ANN index
}
```

**Problem:**
- **Not persisted** — vectors disappear on restart
- **Linear scan** — O(n) search. For 10K+ medical codes, search will be slow
- No HNSW indexing for approximate nearest neighbor

### 5.3 ObjectBoxVectorIndex (Disabled)

```dart
// @Entity()
// class ObxVectorDoc {
//   @HnswIndex(dimensions: 768, distanceType: VectorDistanceType.cosine)
//   @Property(type: PropertyType.floatVector)
//   List<double>? vector;
// }
```

The HNSW vector index with ObjectBox would provide O(log n) approximate nearest neighbor search. It's disabled because the ObjectBox generator (build_runner + objectbox_generator) is not configured.

---

## 6. Health Data Storage (`health_wallet`)

### 6.1 WalletService

The `WalletService` in `packages/health_wallet/lib/services/` provides a comprehensive local-first health data store:

| Data Type | Isar Collection | Query Methods |
|-----------|----------------|---------------|
| **Lab Results** | `labResults` | By LOINC code, by recency (30 days) |
| **Vital Signs** | `vitalSigns` | By type, by date range |
| **Medications** | `medicationEntrys` | Active (no end date), by RxNorm code |
| **Medical Events** | `medicalEvents` | By type, by date range (timeline) |
| **Documents** | `medicalDocuments` | By type (with encryption) |
| **Health Record** | `healthRecords` | Full record (single) |

### 6.2 Encryption Service

**Solid implementation** using:
- **AES-256-GCM** — authenticated encryption
- **PBKDF2** — key derivation (100K iterations)
- **HKDF** — key derivation structure
- **HMAC-SHA256** — data integrity signing
- **Per-field encryption** for `MedicalDocument` metadata

### 6.3 Integration Gap

**The health_wallet data is NOT connected to the RAG pipeline.** VectorStoreService stores medical codes and agent memories, but the actual health data (lab results, vitals, medications, events) lives in separate Isar collections that are not indexed or searchable via the RAG system.

---

## 7. Medical Standards Indexing Pipeline

### 7.1 Flow

```
JSON Files (ICD-10, LOINC, RxNorm, SNOMED)
    │
    ▼
MedicalKnowledgeRepository
    ├── initialize() → Parse JSON files
    ├── getAllCodes() → Return all MedicalCodes
    └── searchByTerm() → Text-based search fallback
    │
    ▼
MedicalIndexingService.indexAll()
    │
    ├── For each MedicalCode:
    │   ├── addDocument(id="med:standard:code", content=embeddingText, metadata={type,standard,category,code,displayName})
    │   │
    │   └── IsarVectorStoreService.addDocument()
    │       └── MemoryGraph.storeNodeWithEmbedding()
    │           ├── embeddingsAdapter.embed(content) → [GEMINI API CALL or HASH]
    │           └── index.addDocument(id, content, vector) → InMemoryVectorIndex
    │
    ▼
Search: MedicalIndexingService.search("fiebre")
    ├── Vector search → InMemoryVectorIndex (cosine — but hash-based!)
    ├── Supplement with text search → MedicalKnowledgeRepository.searchByTerm()
    └── Merge + Deduplicate
```

### 7.2 Problem: Indexing on Every Startup

```dart
@PostConstruct(preResolve: true)
Future<void> indexMedicalStandards() async {
  for (final code in allCodes) {
    await _memoryGraph.storeNodeWithEmbedding(
      content: code.embeddingText,
      deduplicate: true, // Uses embedding distance threshold of 0.05
    );
  }
}
```

**Issues:**
1. **Called on every startup** — re-embeds all medical standards via Gemini API (costly)
2. **Deduplication via hash-based embeddings is useless** — random vectors distance distribution is uniform, not semantically meaningful
3. **Medical standards pre-embedded from JSON are never loaded** — just regenerated
4. **`deduplicate: true` with threshold 0.05** means nearly all imports are treated as unique -> duplicates accumulate

---

## 8. Search & Retrieval Pipeline

### 8.1 SmartSearchUseCase — Strategy Selection

The `SmartSearchUseCase.execute()` selects a re-ranking strategy based on query characteristics:

| Strategy | Trigger | Purpose |
|----------|---------|---------|
| **BM25** | Medical terms (diagnóstico, síntoma, diabetes...) | Precise keyword matching |
| **Recency** | Temporal keywords (reciente, último, hoy...) | Recent records first |
| **Diversity** | Exploratory keywords (todos, diferentes, opciones...) | Maximize result variety |
| **MMR** | Default | Balanced relevance + diversity |

### 8.2 RAG Generation (RagLlmService)

```dart
Stream<String> generate(String prompt) async* {
  // 1. Retrieve context from vector store
  final contextDocs = await _vectorStoreService.search(prompt);
  
  // 2. Medical Research Enrichment (if context is weak)
  if (contextDocs.length < 2 && allowCloud) {
    research = await _medicalResearchService.performResearch(prompt);
  }
  
  // 3. Return TEMPLATE TEXT — no real LLM generation!
  yield "Entendido. Basado en tu consulta '$prompt'...";
}
```

**Critical Issue:** The `RagLlmService.generate()` returns a **hardcoded template string**, not actual LLM-generated content. The response is preformatted regardless of context content. There is no actual LLM integration in the RAG response generation — the "generate" step is simulated.

### 8.3 Multi-Hop Search

```dart
Future<List<({MemoryNode node, List<MemoryNode> context})>> multiHopSearch({
  required List<double> queryEmbedding,
  int maxHops = 2,
  int topK = 5,
}) async {
  // 1. Semantic search on layer 0
  // 2. Traverse 'summary_of' edges upward
  // 3. Return base node + parent context
}
```

HiRAG multi-hop search is structurally implemented but requires:
1. Real embeddings (not hash-based)
2. A configured LLM adapter for auto-summarization
3. Actually populated hierarchical layers

---

## 9. Python Data Generation Scripts

### 9.1 Script Inventory (29 files)

| Script | Purpose |
|--------|---------|
| `generate_medical_standards.py` | **Main generator** — 300+ ICD-10 codes (all chapters) |
| `build_standards.py` | Aggregates generated standards |
| `append_icd10_more.py` | Extends ICD-10 with more codes |
| `append_loinc.py` | LOINC codes (lab tests) |
| `append_rxnorm.py` | RxNorm codes (medications) |
| `append_snomed.py` | SNOMED CT codes |
| `combine_all.py` | Merges all standards into single output |
| `check_current.py` | Validates current state |
| `fix_truncated.py` | Repairs truncated data files |
| `convert_medical_standards.py` | Conversion utility |
| Various `append_ch*.py` | Chapter-based ICD-10 extensions |

### 9.2 Observations

- **29 scripts** suggests an iterative, fragile generation process
- Scripts like `fix_truncated.py` indicate data corruption issues
- No single unified pipeline — scripts were created incrementally
- The JSON output format should match what `MedicalKnowledgeRepository.initialize()` expects
- No script bundling or validation pipeline

---

## 10. Ollama / Gemma Integration

### 10.1 GemmaLlmAdapter

```dart
@LazySingleton(as: LlmAdapter)
@Named('gemma')
class GemmaLlmAdapter implements LlmAdapter {
  static const _channel = MethodChannel('com.orionhealth/gemma4');
  
  // Strategy:
  // 1. Try local Gemma 4 via AICore/ML Kit MethodChannel
  //    - Gemma 4 E2B (2B params) ~1.2 GB
  //    - Gemma 4 E4B (4B params) ~2.4 GB
  // 2. Fallback: Gemini cloud (gemini-2.0-flash)
}
```

### 10.2 AICore Integration

The Gemma integration uses **Android AICore** (ML Kit GenAI Prompt API):
- **Requires**: Android 8+, AICore beta, Pixel 7+/Samsung S25+
- **Channel**: `MethodChannel('com.orionhealth/gemma4')`
- **Models**: Gemma 4 E2B (fast) or E4B (precise)

### 10.3 Critical Problem: **No Native Plugin Exists**

The `MethodChannel` calls (e.g., `_channel.invokeMethod('isAvailable')`, `_channel.invokeMethod('generate')`) require a **native Android plugin** that is NOT implemented:

- `MainActivity.kt` references `AicorePlugin()` — file does not exist
- `AicoreService` uses `MethodChannel('com.orionhealth/aicore')` — no native handler
- `GemmaLlmAdapter` uses `MethodChannel('com.orionhealth/gemma4')` — no native handler

**Without the native plugin:**
- `IsAvailable` returns `false`
- `generate()` falls to cloud Gemini fallback
- Download progress streaming is non-functional
- **The build will crash at runtime** if `AicorePlugin()` is called in `MainActivity.configureFlutterEngine()`

*(See separate report: `docs/aicore-status.md`)*

### 10.4 No Ollama Integration

There is no direct Ollama integration in the codebase. The "Ollama" reference in project context refers to the `GemmaLlmAdapter`'s ability to run local models via AICore, which is Android-native, not Ollama.

---

## 11. Critical Bottlenecks & Issues

### 🔴 P0 — Blocker

| # | Issue | File | Impact |
|---|-------|------|--------|
| 1 | **AicorePlugin.kt missing** | `MainActivity.kt` | Build crashes at runtime |
| 2 | **SimpleEmbeddingsAdapter wired instead of Gemini** | `memory_module.dart` | All semantic search is hash-based — meaningless vectors |
| 3 | **RagLlmService returns hardcoded template** | `rag_llm_service.dart` | No actual LLM-generated responses |

### 🟡 P1 — Major

| # | Issue | File | Impact |
|---|-------|------|--------|
| 4 | **InMemoryVectorIndex not persisted** | `in_memory_vector_index.dart` | All vectors lost on app restart |
| 5 | **InMemoryVectorIndex O(n) search** | `in_memory_vector_index.dart` | Slow with 10K+ medical codes |
| 6 | **Medical standards indexed on every startup** | `isar_vector_store_service.dart` | Costly Gemini API calls on every cold start |
| 7 | **health_wallet disconnected from RAG** | `wallet_service.dart` | User health data not searchable via semantic search |
| 8 | **ObjectBox vector index disabled** | `vector_index_objectbox.dart` | No persistent ANN index — comments say "generator unavailable" |

### 🔵 P2 — Minor/Optimization

| # | Issue | File | Impact |
|---|-------|------|--------|
| 9 | `MemoryNode.metadata` is `@ignore` — not persisted | `memory_node.dart` | Tags, source info lost on restart |
| 10 | RAG response is Spanish-only template | `rag_llm_service.dart` | English users get mixed responses |
| 11 | No LLM integration in response generation | `rag_llm_service.dart` | Template response not contextual |
| 12 | `MedicalIndexingService._parseCodeFromContent()` is best-effort | `medical_indexing_service.dart` | May fail to find codes from vector results |
| 13 | 29 Python scripts — no unified pipeline | `scripts/` | Fragile, hard to maintain |
| 14 | `onnxruntime` dependency not configured for Android | `pubspec.yaml` | On-device embeddings blocked |

---

## 12. Recommendations

### Immediate (P0)

1. **Create `AicorePlugin.kt`** — See `docs/aicore-status.md` for full spec
2. **Wire `GeminiEmbeddingsAdapter` in DI**:
   ```dart
   @lazySingleton
   EmbeddingsAdapter get embeddingsAdapter => GeminiEmbeddingsAdapter(
     apiKey: Platform.environment['GEMINI_API_KEY'] ?? '',
   );
   ```
3. **Replace `RagLlmService` template with real LLM** — Connect to Gemma/Gemini for actual RAG generation

### Short-Term (P1)

4. **Implement persistent vector index** — Fix ObjectBox generator or implement Isar-backed vector storage
5. **Pre-compute and cache medical standard embeddings** — Embed once, store as JSON, load on startup
6. **Connect health_wallet to RAG** — Index labs, vitals, medications as `MemoryNode` type=health_record
7. **Add deduplication check by standard+code** before indexing medical standards

### Medium-Term (P2)

8. **Unify Python data pipeline** — Single `generate_all.py` with validation
9. **Implement `FallbackEmbeddingsAdapter` chain** — On-device primary → Gemini fallback
10. **Configure ObjectBox HNSW index** — Enable `objectbox_generator` for persistent ANN search
11. **Persist `metadata` in Isar** — Either as JSON string field or separate collection
12. **Add Ollama REST API support** — For desktop/server deployments as alternative to AICore

### Architecture Diagram — Recommended Final State

```
┌──────────┐    ┌──────────────────────┐
│  User    │    │  AICore / Ollama     │
│  Query   │    │  Gemma 4 E2B/E4B     │
└────┬─────┘    └──────────┬───────────┘
     │                      │
     ▼                      ▼
SmartSearchUseCase    GemmaLlmAdapter
     │                      │
     ▼                      ▼
IsarVectorStoreService  RagLlmService
     │                      │
     ▼                      ▼
MemoryGraph          [Template] → [REAL LLM]
(EmbeddingsAdapter)
     │
     ├── GeminiEmbeddingsAdapter (cloud)
     ├── FallbackEmbeddingsAdapter
     │   ├── OnDeviceEmbeddingsAdapter (ONNX)
     │   └── GeminiEmbeddingsAdapter (fallback)
     │
     └── VectorIndex
         └── ObjectBoxVectorIndex (HNSW, persistent)
```

---

*End of Report — RAG Architecture Review*
