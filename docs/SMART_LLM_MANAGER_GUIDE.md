# Smart LLM Manager - Usage Guide

## Overview

El **Smart LLM Manager** es un sistema inteligente que selecciona automáticamente entre modelos locales (Candle) y cloud (Gemini) basándose en:

- Disponibilidad de red
- Presupuesto de tokens cloud
- Complejidad del prompt
- Estrategia configurada por el usuario

---

## Quick Start

### 1. Basic Setup - Hybrid Strategy

```rust
use orionhealth::llm::{
    SmartLlmManager, SmartLlmConfig, LlmStrategy,
    CandleLlmAdapter, GeminiAdapter,
    ModelManager
};
use std::path::PathBuf;

#[tokio::main]
async fn main() -> Result<()> {
    // 1. Configure Smart Manager (Hybrid mode)
    let config = SmartLlmConfig {
        strategy: LlmStrategy::Hybrid,
        max_monthly_tokens: 1_000_000,  // 1M tokens/month
        prefer_local_under_tokens: 2048, // Use local for prompts < 2K
    };

    // 2. Setup Local Adapter
    let models_dir = PathBuf::from("./models");
    let mut model_manager = ModelManager::new(models_dir);
    model_manager.init().await?;

    // Download Phi-3-mini if not exists
    let model_path = model_manager.download_phi3_mini(|progress| {
        println!("Downloading: {}%", progress.percentage);
    }).await?;

    let local_adapter = CandleLlmAdapter::new(model_path);

    // 3. Setup Cloud Adapter
    let gemini_key = std::env::var("GEMINI_API_KEY")?;
    let cloud_adapter = GeminiAdapter::with_api_key(gemini_key);

    // 4. Create Smart Manager
    let manager = SmartLlmManager::new(config)
        .with_local_adapter(local_adapter)
        .with_cloud_adapter(cloud_adapter);

    // 5. Generate text (auto-selects adapter)
    let prompt = "Resumen de síntomas: dolor de cabeza, fiebre 38°C";
    let (response, adapter_used) = manager.generate_text(prompt).await?;

    println!("Used: {}", adapter_used); // "Local" or "Cloud"
    println!("Response: {}", response);

    Ok(())
}
```

---

## Strategy Configurations

### Local-Only Strategy
**Use case:** Maximum privacy, no internet, free forever

```rust
let config = SmartLlmConfig {
    strategy: LlmStrategy::LocalOnly,
    ..Default::default()
};

let manager = SmartLlmManager::new(config)
    .with_local_adapter(local_adapter);
```

**Behavior:**
- ✅ Always uses local model
- ❌ Never calls cloud API
- ✅ Works 100% offline
- ⚠️ Limited by device performance

---

### Cloud-Only Strategy
**Use case:** Best quality, always online, enterprise budget

```rust
let config = SmartLlmConfig {
    strategy: LlmStrategy::CloudOnly,
    max_monthly_tokens: 10_000_000, // 10M tokens
    ..Default::default()
};

let manager = SmartLlmManager::new(config)
    .with_cloud_adapter(cloud_adapter);
```

**Behavior:**
- ❌ Never uses local model
- ✅ Always uses Gemini API
- ⚠️ Requires internet connection
- ⚠️ Costs money after free tier

---

### Hybrid Strategy (Recommended)
**Use case:** Smart balance between cost, privacy, and quality

```rust
let config = SmartLlmConfig {
    strategy: LlmStrategy::Hybrid,
    max_monthly_tokens: 1_000_000,
    prefer_local_under_tokens: 2048,
};

let manager = SmartLlmManager::new(config)
    .with_local_adapter(local_adapter)
    .with_cloud_adapter(cloud_adapter);
```

**Decision Tree:**

```
┌──────────────────────────────────┐
│   New Request Arrives            │
└────────┬─────────────────────────┘
         │
    ┌────▼────┐
    │ Network │
    │  Check  │
    └────┬────┘
         │
    ┌────▼──────────────┐
    │ Cloud Available?  │
    │ Credits OK?       │
    └────┬─────┬────────┘
         │     │
      YES│     │NO
         │     │
    ┌────▼────┐│
    │ Prompt  ││
    │  Size?  ││
    └────┬────┘│
         │     │
   < 2048│>2048│
         │     │
    ┌────▼────┐│  ┌────▼────┐
    │  LOCAL  ││  │ FALLBACK│
    └─────────┘│  │  LOCAL  │
    ┌──────────▼──▼─────────┐
    │      CLOUD API        │
    └───────────────────────┘
```

---

## Usage Tracking

### Monitor Cloud Token Usage

```rust
// Get current month usage
let usage = manager.get_cloud_usage().await.unwrap();

println!("Total tokens: {}", usage.total_tokens);
println!("Requests: {}", usage.requests_count);
println!("Prompt tokens: {}", usage.prompt_tokens);
println!("Completion tokens: {}", usage.completion_tokens);

// Reset at beginning of month
manager.reset_cloud_usage().await?;
```

### Budget Alerts

```rust
let usage = manager.get_cloud_usage().await.unwrap();
let limit = 1_000_000;

if usage.total_tokens > limit * 0.8 {
    println!("⚠️ Warning: {}% of monthly budget used",
             (usage.total_tokens * 100) / limit);
}

if usage.total_tokens >= limit {
    println!("🚨 Budget exceeded! Forcing local-only mode");
    // Switch to local-only temporarily
}
```

---

## Network Awareness

### Simulate Offline Mode

```rust
// Simulate network disconnect
manager.set_network_available(false).await;

// This will now use local model even for large prompts
let (response, adapter) = manager.generate_text(large_prompt).await?;
assert_eq!(adapter, AdapterChoice::Local);

// Re-enable network
manager.set_network_available(true).await;
```

### Real Network Detection (Flutter Integration)

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rust_lib_orionhealth/rust_lib_orionhealth.dart';

Connectivity().onConnectivityChanged.listen((result) {
  bool hasInternet = result != ConnectivityResult.none;
  await rustSmartLlmManager.setNetworkAvailable(hasInternet);
});
```

---

## Medical Summary Generation

### Example: Weekly Health Summary

```rust
use orionhealth::models::SummaryType;

let medical_records = vec![
    "2024-01-01: Consulta general - Presión arterial 120/80".to_string(),
    "2024-01-03: Análisis de sangre - Glucosa 95 mg/dL".to_string(),
    "2024-01-05: Consulta seguimiento - Paciente reporta mejoría".to_string(),
];

let (summary, adapter) = manager.generate_summary(
    medical_records,
    SummaryType::Weekly
).await?;

println!("Weekly Summary (via {}):", adapter);
println!("{}", summary);
```

**Expected Output (Cloud):**

```
Weekly Summary (via Cloud):

Resumen Semanal de Salud

Principales Hallazgos:
- Presión arterial dentro de parámetros normales (120/80 mmHg)
- Glucosa en sangre en rango saludable (95 mg/dL)
- Evolución positiva del cuadro clínico

Recomendaciones:
- Mantener seguimiento de presión arterial
- Continuar con dieta balanceada para control glucémico
- Próxima consulta en 2 semanas
```

---

## Advanced: Custom Complexity Thresholds

```rust
let config = SmartLlmConfig {
    strategy: LlmStrategy::Hybrid,
    max_monthly_tokens: 500_000,
    prefer_local_under_tokens: 1024, // More aggressive local usage
};

// Force specific adapter for testing
let choice = manager.get_preferred_adapter(500).await?;
println!("For 500 tokens: {}", choice); // Output: "Local"

let choice = manager.get_preferred_adapter(3000).await?;
println!("For 3000 tokens: {}", choice); // Output: "Cloud"
```

---

## Error Handling

```rust
match manager.generate_text(prompt).await {
    Ok((response, adapter)) => {
        println!("Success via {}: {}", adapter, response);
    }
    Err(OrionError::Llm(msg)) => {
        eprintln!("LLM error: {}", msg);
        // Fallback to rule-based summary
    }
    Err(e) => {
        eprintln!("Unexpected error: {:?}", e);
    }
}
```

---

## Performance Benchmarks (Target)

| Scenario | Adapter | Latency | Cost |
|----------|---------|---------|------|
| Simple query (< 100 tokens) | Local | 200-500ms | Free |
| Medium prompt (500-2K tokens) | Local | 1-3s | Free |
| Complex summary (2K-4K tokens) | Cloud | 2-5s | $0.001-0.01 |
| Large context (> 4K tokens) | Cloud | 5-10s | $0.01-0.05 |

---

## Integration with Flutter UI

### Dart Side (auto-generated by flutter_rust_bridge)

```dart
import 'package:rust_lib_orionhealth/rust_lib_orionhealth.dart';

// In Settings Screen
class LlmSettingsScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Strategy selector
        DropdownButton<LlmStrategy>(
          value: currentStrategy,
          items: [
            DropdownMenuItem(value: LlmStrategy.localOnly, child: Text('Local Only')),
            DropdownMenuItem(value: LlmStrategy.cloudOnly, child: Text('Cloud Only')),
            DropdownMenuItem(value: LlmStrategy.hybrid, child: Text('Hybrid (Smart)')),
          ],
          onChanged: (strategy) async {
            await rustSetLlmStrategy(strategy);
          },
        ),

        // Usage dashboard
        FutureBuilder<UsageStats>(
          future: rustGetCloudUsage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final usage = snapshot.data!;
              return Card(
                child: Column(
                  children: [
                    Text('Cloud Usage This Month'),
                    LinearProgressIndicator(
                      value: usage.totalTokens / 1000000.0,
                    ),
                    Text('${usage.totalTokens} / 1M tokens'),
                  ],
                ),
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ],
    );
  }
}
```

---

## Cost Estimation (Gemini 1.5 Flash Pricing)

**As of January 2024:**
- Input: $0.075 per 1M tokens
- Output: $0.30 per 1M tokens

**Example Monthly Usage (Hybrid Strategy):**
- 70% queries → Local (free)
- 30% queries → Cloud (paid)
- Average 20 summaries/day × 500 output tokens = 10K tokens/day
- Monthly: 300K output tokens = **$0.09/month**

**Local-Only Strategy:**
- **$0/month** (but requires device compute)

---

## Troubleshooting

### Issue: "No LLM adapter available"
**Solution:** Ensure at least one adapter is configured
```rust
assert!(local_adapter.is_some() || cloud_adapter.is_some());
```

### Issue: "Cloud adapter not available but strategy is CloudOnly"
**Solution:** Check API key and network
```bash
export GEMINI_API_KEY="your-key-here"
curl https://generativelanguage.googleapis.com/v1beta/models
```

### Issue: Local model too slow on device
**Solution:** Use smaller quantization
```rust
// Instead of Q4 (1.8GB), use Q2 (1.2GB)
model_manager.download_model(
    "microsoft/Phi-3-mini-4k-instruct-gguf",
    "Phi-3-mini-4k-instruct-q2_k.gguf",
    |p| {}
).await?;
```

---

## Security Considerations

### 🔒 API Key Storage

**❌ Never do this:**
```rust
let api_key = "AIzaSy...hardcoded"; // WRONG!
```

**✅ Do this:**
```rust
// Use environment variables
let api_key = std::env::var("GEMINI_API_KEY")?;

// Or secure storage (Flutter)
final secureStorage = FlutterSecureStorage();
String apiKey = await secureStorage.read(key: 'gemini_api_key');
```

### 🔒 Medical Data Privacy

- Local model: Data never leaves device ✅
- Cloud model: Data sent to Google servers ⚠️
- **Recommendation:** Use Local-Only for sensitive records

### 🔒 HIPAA Compliance

⚠️ **Important:** Standard Gemini API is **NOT HIPAA compliant**.

For HIPAA compliance:
1. Use **Google Cloud Healthcare API** (requires business agreement)
2. Enable **zero-knowledge encryption** before sending
3. Get legal review and patient consent

---

## Roadmap

- [x] Basic Smart Manager implementation
- [x] Gemini API integration
- [x] Usage tracking
- [ ] Actual Candle inference (currently stub)
- [ ] Embedding models for context retrieval
- [ ] Multi-turn conversations
- [ ] Fine-tuned medical models (Phi-3-Medical)
- [ ] On-device quantization (GGUF → Q2)

---

## References

- [Gemini API Docs](https://ai.google.dev/docs)
- [Candle Framework](https://github.com/huggingface/candle)
- [Phi-3 Model Card](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct)
- [GGUF Format](https://github.com/ggerganov/ggml/blob/master/docs/gguf.md)

---

**Last Updated:** 2026-01-06
**Status:** ✅ Core Implementation Complete, Inference Pending
