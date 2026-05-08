# API Documentation Index

OrionHealth uses a modular package system to encapsulate core functionalities. Below is the documentation for the internal packages located in `packages/`.

## 📦 Internal Packages

### 1. `isar_agent_memory`
The core engine for the AI Assistant's memory.
- **Purpose**: Provides a hybrid Vector + Graph database using Isar.
- **Key Features**:
  - `MemoryGraph`: Manage nodes and semantic edges.
  - `HierarchicalRAG`: Multi-hop context retrieval.
  - `VectorSearch`: Similarity search for health history.
- **Documentation**: [packages/isar_agent_memory/README.md](../../packages/isar_agent_memory/README.md)

### 2. `medical_standards`
The interface between the app and global medical knowledge.
- **Purpose**: Parsers and loaders for standardized medical codes.
- **Supported Standards**: ICD-10, LOINC, RxNorm, SNOMED CT.
- **Key Features**:
  - `MedicalKnowledgeRepository`: Asynchronous lookup of codes and definitions.
  - `StandardParser`: Converts raw JSON into domain entities.

### 3. `health_wallet`
Secure, encrypted storage for personal health records.
- **Purpose**: Defines the domain entities and encryption logic for medical data.
- **Key Entities**:
  - `HealthRecord`: Base entity for medical history.
  - `VitalSign`: Time-series data for metrics (BP, Heart Rate).
  - `EncryptionService`: AES-256-GCM implementation for local data.

## 🔌 Core Services (lib/core/services)

### `AicoreService`
Manages native AI inference and device capability detection.
- **MethodChannels**: `com.orionhealth/aicore`, `com.orionhealth/llama`.
- **Capabilities**: RAM detection, GPU support, model recommendation.

### `LlmService`
The abstraction layer for LLM interactions.
- **Adapters**: Gemma (Native), Gemini (Cloud), Local (Ollama).
- **Functionality**: Streaming responses, prompt engineering, RAG integration.

---

*For detailed API references, please refer to the source code doc comments (`///`).*
