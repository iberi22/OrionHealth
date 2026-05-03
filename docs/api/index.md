# OrionHealth API Documentation

## Dart Services

### Core Services
- [AicoreService](../lib/core/services/aicore_service.dart) — MethodChannel bridge for on-device LLM
- [DeviceCapabilityService](../lib/core/services/device_capability_service.dart) — Device profile detection
- [PrivacyAnonymizer](../lib/core/services/privacy_anonymizer.dart) — PII scrubbing for medical prompts

### RAG Pipeline
- [RagLlmService](../lib/features/local_agent/infrastructure/rag_llm_service.dart) — RAG query engine
- [MockLlmAdapter](../lib/features/local_agent/infrastructure/adapters/mock_llm_adapter.dart) — Test adapter
- [GemmaLlmAdapter](../lib/features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart) — On-device Gemma 4 adapter

### Android Native
- [AicorePlugin.kt](../android/app/src/main/kotlin/com/orionhealth/orionhealth_health/AicorePlugin.kt) — Flutter plugin
- [AicoreServiceKt.kt](../android/app/src/main/kotlin/com/orionhealth/orionhealth_health/AicoreServiceKt.kt) — ML Kit helper
