# AICore Android Plugin Status — Critical Missing File

**Date:** 2026-05-03
**Project:** OrionHealth (`E:\scripts-python\orionhealth`)

---

## 1. Executive Summary

The OrionHealth Android app has a **critical build-time vulnerability**: `MainActivity.kt` references the class `AicorePlugin()` in its `configureFlutterEngine()` method, but **no `AicorePlugin.kt` file exists anywhere in the project**.

**Impact:**
- ❌ **The app WILL crash at runtime** with `ClassNotFoundException` when AicorePlugin() is instantiated
- ❌ All MethodChannel calls from Dart (`com.orionhealth/aicore`, `com.orionhealth/gemma4`) will return `MissingPluginException`
- ❌ Gemma 4 local inference and AICore functionality are completely broken

**Severity:** 🔴 **P0 — Blocker**

---

## 2. Current State Analysis

### 2.1 What Exists

#### `MainActivity.kt` — One file, no plugin

```
com/orionhealth/orionhealth_health/
    └── MainActivity.kt  ← Reference AicorePlugin() but file does not exist
```

**Current content of `android/app/src/main/kotlin/com/orionhealth/orionhealth_health/MainActivity.kt`:**

```kotlin
package com.orionhealth.orionhealth_health

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(AicorePlugin())  // ← CRASH: class not found
    }
}
```

### 2.2 What References AICore (Dart Side)

| File | MethodChannel | Methods Called |
|------|--------------|---------------|
| `lib/core/services/aicore_service.dart` | `com.orionhealth/aicore` | `initialize`, `checkAvailability`, `downloadModel`, `generateContent`, `generateContentStream`, `warmup` |
| `lib/features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart` | `com.orionhealth/gemma4` | `isAvailable`, `generate` |

### 2.3 What's Missing

| Missing File | Purpose |
|-------------|---------|
| ❌ `AicorePlugin.kt` | Main Flutter plugin class |
| ❌ `AicoreService.kt` | AICore/ML Kit interaction (model download, Gemma inference) |
| ❌ Any Kotlin source files | No files exist at all in the Kotlin source directory except `MainActivity.kt` |

### 2.4 Build System Files Missing

| Missing File | Purpose |
|-------------|---------|
| ❌ `android/app/build.gradle` AICore dependency | `implementation "com.google.ai.client.generativeai:generativeai:x.y.z"` |
| ❌ `android/settings.gradle` AICore repository | May need Google Maven or specific AICore repository |

---

## 3. Dart Service (`AicoreService`) — Full API Contract

The Dart `lib/core/services/aicore_service.dart` expects the following MethodChannel API:

```dart
static const _channel = MethodChannel('com.orionhealth/aicore');

// ==================== METHODS ====================

// 1. initialize(useFullModel: bool) → bool
Future<bool> initialize({bool useFullModel = false})

// 2. checkAvailability() → String (one of: 'available', 'downloadable', 'unavailable', 'downloading')
Future<AicoreStatus> checkAvailability()

// 3. downloadModel() → bool
Future<bool> downloadModel()

// 4. generateContent(prompt: String) → String
Future<String> generateContent(String prompt)

// 5. generateContentStream(prompt: String) — triggers events
Future<void> generateContentStream(String prompt)

// 6. warmup() → bool
Future<bool> warmup()

// ==================== EVENTS (Streaming) ====================

_Channel.setMethodCallHandler:
- 'onDownloadProgress' → arguments: { progress: int }
- 'onToken' → arguments: { token: String }
- 'onComplete' → no arguments
- 'onError' → arguments: { error: String }
```

### AicoreStatus Enum

```dart
enum AicoreStatus {
  available,     // Model is downloaded and ready
  downloadable,  // Model can be downloaded
  unavailable,   // Device doesn't support AICore
  downloading,   // Download in progress
}
```

---

## 4. Gemma 4 Dart Service (`GemmaLlmAdapter`) — Full API Contract

The Dart `GemmaLlmAdapter` uses a **separate** MethodChannel:

```dart
static const _channel = MethodChannel('com.orionhealth/gemma4');

// 1. isAvailable() → bool
_channel.invokeMethod<bool>('isAvailable')

// 2. generate(prompt: String, model: String) → String
_channel.invokeMethod<String>('generate', {
  'prompt': prompt,
  'model': 'gemma-4-e2b', // or 'gemma-4-e4b'
})
```

---

## 5. Required Files — Complete Specification

### File 1: `AicorePlugin.kt`

**Path:** `android/app/src/main/kotlin/com/orionhealth/orionhealth_health/AicorePlugin.kt`

This is the main Flutter plugin class that implements `FlutterPlugin` and `MethodCallHandler`. It handles **both** MethodChannels (`com.orionhealth/aicore` AND `com.orionhealth/gemma4`).

```kotlin
package com.orionhealth.orionhealth_health

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AicorePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channelAicore: MethodChannel
    private lateinit var channelGemma4: MethodChannel
    private lateinit var context: Context
    private var aicoreService: AicoreServiceKt? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channelAicore = MethodChannel(flutterPluginBinding.binaryMessenger, "com.orionhealth/aicore")
        channelGemma4 = MethodChannel(flutterPluginBinding.binaryMessenger, "com.orionhealth/gemma4")
        channelAicore.setMethodCallHandler(this)
        channelGemma4.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            // AICore channel methods
            "initialize" -> handleInitialize(call, result)
            "checkAvailability" -> handleCheckAvailability(result)
            "downloadModel" -> handleDownloadModel(result)
            "generateContent" -> handleGenerateContent(call, result)
            "generateContentStream" -> handleGenerateContentStream(call)
            "warmup" -> handleWarmup(result)
            // Gemma4 channel methods
            "isAvailable" -> handleIsAvailable(result)
            "generate" -> handleGemmaGenerate(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val useFullModel = call.argument<Boolean>("useFullModel") ?: false
        // 1. Check if AICore is available on device
        // 2. Load Gemma 4 model (E2B or E4B based on useFullModel)
        // 3. Return success/failure
        result.success(true) // Placeholder — see implementation notes below
    }

    private fun handleCheckAvailability(result: Result) {
        // Return one of: "available", "downloadable", "unavailable", "downloading"
        result.success("unavailable") // Placeholder
    }

    private fun handleDownloadModel(result: Result) {
        // Start model download, emit progress events
        // On success: emit onDownloadProgress 100, then onComplete
        // On failure: emit onError
        result.success(false) // Placeholder
    }

    private fun handleGenerateContent(call: MethodCall, result: Result) {
        val prompt = call.argument<String>("prompt") ?: ""
        // Run Gemma 4 inference
        result.success("") // Placeholder
    }

    private fun handleGenerateContentStream(call: MethodCall) {
        val prompt = call.argument<String>("prompt") ?: ""
        // Stream tokens via channelAicore.invokeMethod("onToken", mapOf("token" to token))
        // On complete: channelAicore.invokeMethod("onComplete", null)
    }

    private fun handleWarmup(result: Result) {
        // Warm up the model (first inference is slower)
        result.success(false) // Placeholder
    }

    private fun handleIsAvailable(result: Result) {
        // Check if AICore + Gemma 4 model is installed
        result.success(false) // Placeholder
    }

    private fun handleGemmaGenerate(call: MethodCall, result: Result) {
        val prompt = call.argument<String>("prompt") ?: ""
        val model = call.argument<String>("model") ?: "gemma-4-e2b"
        // Run local inference
        result.success("") // Placeholder
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channelAicore.setMethodCallHandler(null)
        channelGemma4.setMethodCallHandler(null)
    }
}
```

### File 2: `AicoreService.kt` (Optional — Helper Class)

**Path:** `android/app/src/main/kotlin/com/orionhealth/orionhealth_health/AicoreService.kt`

A helper class that actually interfaces with the Android AICore / ML Kit APIs.

```kotlin
package com.orionhealth.orionhealth_health

import android.content.Context
import com.google.mlkit.genai.googleai.GenerativeModel
import com.google.mlkit.genai.googleai.GenerativeModelFutures

class AicoreServiceKt(private val context: Context) {
    companion object {
        private const val GEMINI_API_KEY = "" // From build config or secure storage
    }

    private var generativeModel: GenerativeModelFutures? = null

    suspend fun initialize(useFullModel: Boolean): Boolean {
        return try {
            val modelName = if (useFullModel) "gemma-4-e4b" else "gemma-4-e2b"
            val model = GenerativeModel(modelName, GEMINI_API_KEY)
            generativeModel = GenerativeModelFutures.from(model)
            generativeModel != null
        } catch (e: Exception) {
            false
        }
    }

    fun isModelDownloaded(): Boolean {
        // Check if Gemma 4 model is downloaded via AICore
        return false // Implementation depends on AICore SDK version
    }

    fun getDownloadStatus(): String {
        // Check AICore download status
        return "unavailable"
    }

    suspend fun generateContent(prompt: String): String {
        // val response = generativeModel?.generateContent(prompt)
        // return response?.text ?: ""
        return "" // Placeholder
    }
}
```

**Dependency (in `android/app/build.gradle`):**

```gradle
dependencies {
    implementation "com.google.mlkit:genai-android:0.1.0" // Check latest version
    // Or for AICore directly:
    // implementation "com.google.ai.client.generativeai:generativeai:0.7.0"
}
```

---

## 6. Implementation Roadmap

### Phase 1: Create Plugin Skeleton (Blocker Fix)

| Step | File | Description |
|------|------|-------------|
| 1 | `AicorePlugin.kt` | Create with both MethodChannel handlers |
| 2 | `build.gradle` | Add AICore/ML Kit dependency |
| 3 | `AndroidManifest.xml` | Add required permissions if any |
| 4 | Test | Build and verify no crashes |

### Phase 2: Implement AICore Integration

| Step | Description |
|------|-------------|
| 1 | Implement `checkAvailability()` — query AICore SDK for Gemma model status |
| 2 | Implement `downloadModel()` — trigger model download with progress events |
| 3 | Implement `initialize()` — load model into memory |
| 4 | Implement `generateContent()` — run Gemma 4 inference |
| 5 | Implement `warmup()` — run dummy inference to load model |

### Phase 3: Streaming & Production Polish

| Step | Description |
|------|-------------|
| 1 | Implement `generateContentStream()` — token-by-token streaming |
| 2 | Add download progress reporting |
| 3 | Error handling & retry logic |
| 4 | Model management (check for updates, storage cleanup) |

---

## 7. Dependencies & Requirements

### AICore/ML Kit for On-Device Gemma 4

| Requirement | Detail |
|-------------|--------|
| Android API | 24+ (8.0) |
| Google Play Services | Required for AICore |
| Supported Devices | Pixel 7+, Samsung S25+, select others |
| Model Downloads | Gemma 4 E2B ~1.2 GB, E4B ~2.4 GB |
| AICore Version | Beta — API may change |

### Gradle Dependencies (To Be Added)

**`android/app/build.gradle`:**

```gradle
dependencies {
    implementation 'com.google.mlkit:genai-android:0.1.0'
    // Optional: for direct AICore API
    // implementation 'com.google.ai.client.generativeai:generativeai:0.7.0'
}
```

**`android/settings.gradle`:** (may already be configured)

```gradle
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
```

---

## 8. Integration Points with `isar_agent_memory` Embedding Strategy

### 8.1 Current State (HASH-based — broken)

The `isar_agent_memory` package provides multiple embedding strategies, but the DI container uses `SimpleEmbeddingsAdapter` (hash-based).

```dart
@lazySingleton
EmbeddingsAdapter get embeddingsAdapter => SimpleEmbeddingsAdapter();
```

### 8.2 Available Embedding Adapters in `isar_agent_memory`

| Adapter | Model | Provider | Dimension | Status |
|---------|-------|----------|-----------|--------|
| `GeminiEmbeddingsAdapter` | `text-embedding-004` | Gemini Cloud | 768 | ✅ Works (needs API key) |
| `OnDeviceEmbeddingsAdapter` | `all-MiniLM-L6-v2` | ONNX Runtime | 384 | ❌ Blocked (no ONNX config) |
| `FallbackEmbeddingsAdapter` | on-device→cloud | Combo | Runtime | ✅ Works if both configured |
| `SimpleEmbeddingsAdapter` | Hash | simple_hash | 768 | ✅ Works but MEANINGLESS |

### 8.3 Recommended Setup with AICore

Once AICore plugin is implemented:

```
Priority 1: OnDeviceEmbeddingsAdapter (local BERT)
  └── Requires ONNX model + vocab files bundled in assets/
  └── Dimension: 384

Priority 2: FallbackEmbeddingsAdapter
  ├── primary: OnDeviceEmbeddingsAdapter (384-dim)
  └── fallback: GeminiEmbeddingsAdapter (768-dim from cloud)

Priority 3 (current): SimpleEmbeddingsAdapter ← REMOVE THIS
```

**Critical:** If `OnDeviceEmbeddingsAdapter` is used with `OnDeviceEmbeddingsAdapter` at 384 dimensions and `GeminiEmbeddingsAdapter` at 768 dimensions as fallback, the `FallbackEmbeddingsAdapter` will produce vectors of different dimensions depending on which provider was used. The `VectorIndex` must handle mixed dimensions.

### 8.4 Vector Index Considerations

The `InMemoryVectorIndex` (current) is a simple in-memory map. For production:

| Index | Dimension Compatibility | Persistence |
|-------|------------------------|-------------|
| `InMemoryVectorIndex` | Any (configurable at creation) | ❌ None |
| `ObjectBoxVectorIndex` | Fixed at 768 (hardcoded HNSW config) | ✅ Persistent |

The ObjectBox HNSW index is hardcoded to 768 dimensions. If switching to ONNX (384-dim), the ObjectBox schema must be updated.

---

## 9. Failure Scenarios & Mitigations

### Scenario 1: AICorePlugin.kt Not Created

**Failure:** `java.lang.ClassNotFoundException: com.orionhealth.orionhealth_health.AicorePlugin`
**When:** During `MainActivity.configureFlutterEngine()` — immediately on app launch
**Mitigation:** **CRITICAL** — must create `AicorePlugin.kt` before any production build

### Scenario 2: AICore Not Available on Device

**Failure:** All MethodChannel calls return null/exception
**When:** When `GemmaLlmAdapter` tries `_channel.invokeMethod('isAvailable')`
**Current behavior:** Falls to Gemini cloud — but `GeminiEmbeddingsAdapter` is never wired either

### Scenario 3: Build Fails Due to Missing Dependencies

**Failure:** Gradle build error — `cannot find symbol class GenerativeModel`
**When:** Adding ML Kit dependency without proper Gradle configuration
**Mitigation:** Test with empty plugin first (all stubs), add ML Kit later

---

## 10. Checklist for AICore Plugin Implementation

- [ ] **Create `AicorePlugin.kt`** — Handle both `com.orionhealth/aicore` and `com.orionhealth/gemma4` channels
- [ ] **Add `implementation 'com.google.mlkit:genai-android:0.1.0'`** to `android/app/build.gradle`
- [ ] **Create `AicoreService.kt`** — Helper class for AICore SDK interaction
- [ ] **Wire `GeminiEmbeddingsAdapter`** in `lib/core/di/memory_module.dart` as the active embeddings adapter
- [ ] **Test build** — `cd android && ./gradlew assembleDebug`
- [ ] **Test on physical device** — AICore requires real hardware (not emulator)
- [ ] **Create fallback path** — If AICore unavailable, use Gemini cloud with user consent
- [ ] **Bundle ONNX model files** for `OnDeviceEmbeddingsAdapter` (optional — future enhancement)
- [ ] **Document device requirements** — Pixel 7+/Samsung S25+ for AICore, all devices for fallback

---

*End of Report — Aicore Status & Required Implementation*
