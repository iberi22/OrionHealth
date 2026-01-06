# GitHub Issues - OrionHealth Migration Plan

**Repository**: https://github.com/iberi22/OrionHealth  
**Created for**: Manual issue creation (gh CLI unavailable)

---

## Issue #1: Model Manager Core

**Title**: Implement Model Manager for local LLM downloads

**Labels**: `phase-1`, `enhancement`, `high-priority`

**Description**:
Sprint 1.1 - Create infrastructure for downloading and managing local GGUF models from HuggingFace Hub.

### Requirements
- [ ] ModelManager struct with download/cache/delete methods
- [ ] download_phi3_mini() for Microsoft Phi-3-mini-4k-instruct-q4
- [ ] Streaming downloads with progress callbacks
- [ ] Model caching in `~/.orionhealth/models/`
- [ ] list_available() and list_downloaded() methods
- [ ] Unit tests for manager operations

### Acceptance Criteria
- ✅ Rust code compiles without errors
- ✅ Can download 1.8GB model with progress tracking
- ✅ Models persist across app restarts
- ✅ Demo example shows full workflow

### Technical Notes
- Use reqwest with stream feature
- Target Android devices (Snapdragon 7 Gen 2+)
- Cache only metadata, not full model in memory

**Status**: ✅ **COMPLETED** (Commit: 34cec69)

---

## Issue #2: Candle LLM Integration

**Title**: Complete Candle integration for local inference

**Labels**: `phase-1`, `enhancement`, `high-priority`

**Description**:
Sprint 1.2 - Implement full GGUF model loading and text generation using Candle library.

### Requirements
- [ ] Load GGUF weights with Candle ModelWeights
- [ ] Implement Phi-3 model architecture (attention, MLP, layers)
- [ ] Tokenizer loading (tokenizer.json)
- [ ] Text generation with sampling (temperature, top_p, top_k)
- [ ] Optimize for <2s inference latency

### Acceptance Criteria
- [ ] Can load Phi-3-mini-4k-instruct-q4 successfully
- [ ] Text generation produces coherent Spanish medical summaries
- [ ] Inference latency <2s for 512 tokens on Snapdragon 7 Gen 2
- [ ] Memory usage <4GB during inference
- [ ] Unit tests for model loading and generation

### Technical Notes
- Use Candle's GGUF loader API
- Target CPU inference (Android compatibility)
- Cache loaded model to avoid repeated loading
- Consider memory-mapped file access

**Status**: ⏳ **TODO** (Next Sprint)

---

## Issue #3: Hybrid Local/Cloud LLM Adapter

**Title**: Create hybrid adapter with automatic fallback

**Labels**: `phase-1`, `enhancement`, `medium-priority`

**Description**:
Sprint 1.3 - Implement smart adapter that uses local LLM when available, falls back to Gemini API.

### Requirements
- [ ] HybridLlmAdapter struct with SwitchStrategy enum
- [ ] Strategies: AlwaysLocal, PreferLocal, CostOptimized
- [ ] Gemini 1.5 Flash integration via REST API
- [ ] Token usage tracking for cloud calls
- [ ] Flutter UI for strategy selection

### Acceptance Criteria
- [ ] Automatically uses local model when available
- [ ] Falls back to Gemini if local model unavailable/slow
- [ ] Tracks API costs (input/output tokens)
- [ ] User can configure strategy in settings
- [ ] Respects privacy mode (blocks cloud when disabled)

### Technical Notes
- Gemini API endpoint: https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest
- Free tier: 15 RPM, 1M TPM, 1500 RPD
- Store API key in secure_storage

**Status**: ⏳ **TODO** (Week 3)

---

## Issue #4: Material Design 3 UI Migration

**Title**: Migrate Flutter UI to Material Design 3

**Labels**: `phase-1`, `enhancement`, `medium-priority`

**Description**:
Sprint 1.4 - Update all Flutter widgets to use Material You (Material Design 3) with dynamic theming.

### Requirements
- [ ] Update theme in main.dart (useMaterial3: true)
- [ ] Create custom ColorScheme with medical theme
- [ ] Update all widgets (cards, buttons, inputs) to M3
- [ ] Add Glassmorphism effects for premium look
- [ ] Implement dynamic color adaptation

### Acceptance Criteria
- [ ] All screens use M3 components
- [ ] Theme follows Material You guidelines
- [ ] Glassmorphism on key surfaces (summaries, cards)
- [ ] Dark mode fully supported
- [ ] No deprecated widgets remain

### Technical Notes
- Use FilledButton, OutlinedButton (not deprecated ElevatedButton)
- Apply elevation tones for depth
- Use surface containers for cards
- Test on Android 12+ for dynamic colors

**Status**: ⏳ **TODO** (Week 4)

---

## Issue #5: SurrealDB Schema Implementation

**Title**: Design and implement SurrealDB schema for medical records

**Labels**: `phase-2`, `enhancement`, `high-priority`

**Description**:
Sprint 2.1 - Create complete database schema with tables, relationships, and indexes.

### Requirements
- [ ] Define tables: records, nodes, summaries, embeddings
- [ ] Add relationships (LINKS_TO, SUMMARIZES)
- [ ] Create indexes for common queries (patient_id, created_at, layer)
- [ ] Implement schema migration system
- [ ] Add validation rules (HIPAA compliance)

### Acceptance Criteria
- [ ] All queries from vector_store.rs work correctly
- [ ] Records support hierarchical layers (0-3)
- [ ] Full-text search on content field
- [ ] Foreign key constraints enforced
- [ ] Schema versioning for future migrations

### Technical Notes
- Use SurrealDB's DEFINE TABLE syntax
- Add SCHEMAFULL mode for strict validation
- Consider partitioning by patient_id for scaling
- Backup strategy for kv-mem database

**Status**: ⏳ **TODO** (Week 5)

---

## Issue #6: Vector Store & Embeddings

**Title**: Implement semantic search with vector embeddings

**Labels**: `phase-2`, `enhancement`, `high-priority`

**Description**:
Sprint 2.2 - Add embedding generation and vector similarity search to enable semantic queries.

### Requirements
- [ ] Choose embedding model (BERT-based, <100MB)
- [ ] Implement embed_text() in vector_store.rs
- [ ] Add cosine similarity search
- [ ] Optimize for multi-hop queries
- [ ] Cache embeddings in SurrealDB

### Acceptance Criteria
- [ ] Can find semantically similar records
- [ ] Embedding generation <100ms per record
- [ ] Vector search <50ms for top-10 results
- [ ] Supports Spanish medical terminology
- [ ] Unit tests for similarity calculations

### Technical Notes
- Consider: sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2
- Use Candle for embedding model loading
- Store embeddings as Vec<f32> in SurrealDB
- Index embeddings for fast nearest-neighbor search

**Status**: ⏳ **TODO** (Week 6)

---

## Issue #7: Smart Search Rust Migration

**Title**: Port smart search logic from Dart to Rust

**Labels**: `phase-2`, `enhancement`, `medium-priority`

**Description**:
Sprint 2.3 - Complete migration of smart search algorithms with all 4 strategies.

### Requirements
- [ ] Implement BM25 full-text search
- [ ] Add Diversity search with clustering
- [ ] Implement Recency-weighted scoring
- [ ] Complete MMR (Maximal Marginal Relevance)
- [ ] Port compare_strategies() method

### Acceptance Criteria
- [ ] All search strategies match Dart behavior
- [ ] Strategy auto-selection based on query keywords
- [ ] Search latency <50ms for 1000 records
- [ ] compare_strategies() returns 4 result sets
- [ ] Unit tests verify parity with Dart version

### Technical Notes
- Reference: specs/legacy_logic_reference.md
- Use tokenizers crate for text processing
- Consider tantivy for BM25 implementation
- Benchmark against Dart version

**Status**: ⏳ **TODO** (Week 7)

---

## Issue #8: MCP Server Core

**Title**: Implement Model Context Protocol server

**Labels**: `phase-3`, `enhancement`, `medium-priority`

**Description**:
Sprint 3.1 - Create MCP server for Zed/Claude Desktop integration with OrionHealth.

### Requirements
- [ ] JSON-RPC 2.0 server implementation
- [ ] SSE (Server-Sent Events) transport
- [ ] Expose tools: search_records, get_summary, analyze_trends
- [ ] Authentication via OAuth2 or API key
- [ ] Flutter toggle to enable/disable server

### Acceptance Criteria
- [ ] Zed Editor can connect to server
- [ ] Tools respond with valid JSON
- [ ] Server runs on localhost:8000
- [ ] Privacy mode blocks MCP access
- [ ] Logs all MCP requests for audit

### Technical Notes
- Use axum or actix-web for HTTP server
- Run MCP server in background thread
- Reference: Neural-Link Platform MCP implementation
- HIPAA compliance: log all data access

**Status**: ⏳ **TODO** (Week 8)

---

## Issue #9: Zed Editor Integration

**Title**: Create Zed configuration and tutorial for MCP

**Labels**: `phase-3`, `documentation`, `medium-priority`

**Description**:
Sprint 3.2 - Provide Zed Editor configuration template and user tutorial.

### Requirements
- [ ] Create zed-config.json template
- [ ] Write step-by-step setup tutorial
- [ ] Demo video showing MCP tools in action
- [ ] Troubleshooting guide
- [ ] Example queries for medical records

### Acceptance Criteria
- [ ] Config template works with latest Zed version
- [ ] Tutorial covers Windows/macOS/Linux
- [ ] Video demonstrates 3+ MCP use cases
- [ ] Troubleshooting covers common errors
- [ ] Examples show Spanish queries

### Technical Notes
- Zed config path: ~/.config/zed/settings.json
- Test on Zed v0.120+
- Include mcp-server-orionhealth command

**Status**: ⏳ **TODO** (Week 9)

---

## Issue #10: Flutter MCP Configuration UI

**Title**: Add UI for MCP server settings

**Labels**: `phase-3`, `enhancement`, `medium-priority`

**Description**:
Sprint 3.3 - Create Flutter settings page for MCP server configuration.

### Requirements
- [ ] Settings page: lib/features/settings/mcp_settings_page.dart
- [ ] Toggle to enable/disable MCP server
- [ ] Port configuration (default: 8000)
- [ ] API key generation/regeneration
- [ ] Connection status indicator

### Acceptance Criteria
- [ ] Can start/stop MCP server from UI
- [ ] Shows active connections count
- [ ] Displays API key with copy button
- [ ] Connection status updates in real-time
- [ ] Settings persist across restarts

### Technical Notes
- Use flutter_rust_bridge to control server
- Store settings in secure_storage
- Show QR code for easy Zed setup
- Add connection test button

**Status**: ⏳ **TODO** (Week 10)

---

## Issue #11: Models Dashboard UI

**Title**: Flutter UI for managing downloaded models

**Labels**: `phase-1`, `enhancement`, `medium-priority`

**Description**:
Create Flutter page for viewing, downloading, and deleting LLM models.

### Requirements
- [ ] Page: lib/features/ai_models/presentation/pages/models_page.dart
- [ ] List available models with download status
- [ ] Download button with progress bar
- [ ] Delete model action with confirmation
- [ ] Storage usage indicator

### Acceptance Criteria
- [ ] Shows Phi-3-mini with size and status
- [ ] Download shows real-time progress
- [ ] Delete frees disk space immediately
- [ ] Storage bar shows used/total space
- [ ] Works offline (shows cached models)

### Technical Notes
- Use flutter_rust_bridge to call ModelManager
- ProgressBar widget for download tracking
- Use FutureBuilder for async operations
- Test on Android with limited storage

**Status**: ⏳ **TODO** (Sprint 1.2)

---

## Issue #12: Integration Testing Suite

**Title**: Comprehensive integration tests for Rust backend

**Labels**: `phase-4`, `testing`, `high-priority`

**Description**:
Sprint 4.1 - Create end-to-end tests covering all modules.

### Requirements
- [ ] Test: Download model → Load → Generate text
- [ ] Test: Store record → Search → Retrieve
- [ ] Test: Create summary → Cache → Fetch
- [ ] Test: MCP server → Call tool → Return result
- [ ] Test: Hybrid adapter → Local → Fallback cloud

### Acceptance Criteria
- [ ] All tests pass on CI/CD
- [ ] Code coverage >80%
- [ ] Tests run in <5 minutes
- [ ] Mock external APIs (HuggingFace, Gemini)
- [ ] Integration tests documented

### Technical Notes
- Use cargo test with tokio-test
- Mock HTTP responses with wiremock
- Test database with in-memory SurrealDB
- Parallelize tests where possible

**Status**: ⏳ **TODO** (Week 11)

---

## Issue #13: Performance Optimization

**Title**: Android performance tuning and profiling

**Labels**: `phase-4`, `optimization`, `high-priority`

**Description**:
Sprint 4.2 - Profile and optimize for target Android devices.

### Requirements
- [ ] Benchmark inference latency (target: <2s)
- [ ] Optimize memory usage (target: <4GB)
- [ ] Reduce APK size (target: <100MB)
- [ ] Profile battery consumption
- [ ] Optimize cold start time (<3s)

### Acceptance Criteria
- [ ] Inference <2s on Snapdragon 7 Gen 2
- [ ] Memory stable during long sessions
- [ ] APK size <100MB (with model downloaded separately)
- [ ] Battery drain <5% per hour (idle with model loaded)
- [ ] Cold start <3s

### Technical Notes
- Use Android Profiler for memory analysis
- Test on physical device (not emulator)
- Consider model quantization (q4 vs q8)
- Profile with cargo flamegraph

**Status**: ⏳ **TODO** (Week 11)

---

## Issue #14: Documentation & API Reference

**Title**: Complete developer documentation

**Labels**: `phase-4`, `documentation`, `medium-priority`

**Description**:
Sprint 4.3 - Comprehensive docs for developers and users.

### Requirements
- [ ] API reference (rustdoc)
- [ ] Architecture diagrams (mermaid)
- [ ] Setup guide for developers
- [ ] User manual (Spanish)
- [ ] Troubleshooting FAQ

### Acceptance Criteria
- [ ] All public APIs documented
- [ ] Diagrams show module relationships
- [ ] Setup guide covers Windows/macOS/Linux
- [ ] User manual explains all features
- [ ] FAQ covers 20+ common issues

### Technical Notes
- Generate rustdoc: cargo doc --no-deps
- Host on GitHub Pages
- Use mdBook for user manual
- Include video tutorials

**Status**: ⏳ **TODO** (Week 12)

---

## Issue #15: Production Deployment

**Title**: Deploy OrionHealth v2.0 to production

**Labels**: `phase-4`, `deployment`, `high-priority`

**Description**:
Sprint 4.4 - Final testing and production release.

### Requirements
- [ ] Build release APK (signed)
- [ ] Test on 5+ Android devices
- [ ] Privacy audit (HIPAA compliance)
- [ ] Beta testing with real users
- [ ] Create release notes

### Acceptance Criteria
- [ ] APK passes Google Play validation
- [ ] No crashes in 100+ hours of testing
- [ ] Privacy audit approved
- [ ] Beta users report <3 critical bugs
- [ ] Release notes published

### Technical Notes
- Sign APK with production keystore
- Test devices: Samsung, Xiaomi, OnePlus, Motorola, Oppo
- Use Firebase Crashlytics for monitoring
- Rollout to 10% users initially

**Status**: ⏳ **TODO** (Week 12)

---

## Summary

**Total Issues**: 15  
**Completed**: 1  
**In Progress**: 0  
**TODO**: 14  

**Priority Distribution**:
- 🔴 High: 7 issues
- 🟡 Medium: 7 issues
- 🟢 Low: 1 issue

**Phase Distribution**:
- Phase 1 (Local LLM): 5 issues (1 complete)
- Phase 2 (Data Layer): 3 issues
- Phase 3 (MCP): 4 issues
- Phase 4 (Testing/Deploy): 3 issues

---

**Instructions for Manual Creation**:
1. Visit: https://github.com/iberi22/OrionHealth/issues/new
2. Copy title and description from each issue above
3. Add labels as specified
4. Submit issue
5. Repeat for all 15 issues

**Note**: Issue #1 is already completed but should be created for tracking purposes with "Status: Completed" in description.
