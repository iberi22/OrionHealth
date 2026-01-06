# Model Manager Implementation

## Overview
Sprint 1.1 implementation - Model Manager Core for downloading and managing local LLM models.

## Features Implemented

### 1. ModelManager Structure
- **Path**: `rust/src/llm/model_manager.rs`
- **Purpose**: Manage local GGUF model downloads from HuggingFace Hub
- **Key Components**:
  - `ModelInfo`: Metadata about models (id, name, size, version, path, download status)
  - `DownloadProgress`: Real-time download progress tracking (bytes, percentage)
  - `ModelManager`: Core manager with caching and lifecycle management

### 2. Core Methods

#### `download_phi3_mini<F>(progress_callback: F)`
- Downloads Microsoft Phi-3-mini-4k-instruct-q4 (1.8GB GGUF)
- URL: `https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf`
- Provides real-time progress via callback
- Caches to `~/.orionhealth/models/` (or custom path)
- Skips download if file already exists

#### `download_model(repo_id, file_name, progress_callback)`
- Generic method for downloading any HuggingFace model
- Supports streaming download with progress tracking
- Validates HTTP status codes
- Automatic cache refresh after download

#### `list_available()`
- Returns predefined models (Phi-3-mini) plus any custom downloaded models
- Shows download status for each model

#### `list_downloaded()`
- Scans models directory for `.gguf` files
- Returns only downloaded models with paths

#### `get_model_path(model_id)`
- Retrieves filesystem path for a downloaded model
- Returns `NotFound` error if model doesn't exist

#### `delete_model(model_id)`
- Removes model file from disk
- Updates internal cache

### 3. CandleLlmAdapter Updates
- **Path**: `rust/src/llm.rs`
- **Purpose**: Integrate Candle library for local inference
- **Implementation Status**:
  - ✅ Structure created with model_path, tokenizer, device fields
  - ✅ `new()` constructor accepting PathBuf
  - ✅ `init()` method (tokenizer loading stubbed for now)
  - ✅ `generate_with_params()` with temperature/top_p support
  - ✅ `is_available()` checks model existence and tokenizer
  - ⏳ Full GGUF loading pending (requires Candle model architecture implementation)

### 4. Dependencies Added
```toml
reqwest = { version = "0.12", features = ["stream"] }
futures-util = "0.3"

[dev-dependencies]
tempfile = "3.13"  # For testing with temporary directories
```

## Usage Example

```rust
use rust_lib_orionhealth_rust::llm::{ModelManager, DownloadProgress};
use std::path::PathBuf;

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize manager
    let mut manager = ModelManager::new(PathBuf::from("./models"));
    manager.init().await?;
    
    // Download Phi-3-mini with progress
    let path = manager.download_phi3_mini(|progress| {
        println!("Progress: {:.1}%", progress.percentage);
    }).await?;
    
    // Use with Candle
    let mut adapter = CandleLlmAdapter::new(path);
    adapter.init().await?;
    
    if adapter.is_available().await {
        let response = adapter.generate_text("Health summary:").await?;
        println!("{}", response);
    }
    
    Ok(())
}
```

Run demo: `cargo run --example model_manager_demo`

## Testing

### Unit Tests
```bash
cd rust
cargo test model_manager
```

Tests included:
- `test_model_manager_init`: Directory creation
- `test_list_available_models`: Predefined model list
- `test_model_not_found`: Error handling

### Integration Test (Manual)
1. Run example: `cargo run --example model_manager_demo`
2. Verify download progress output
3. Check models directory for `.gguf` file
4. Re-run to verify caching (should skip download)

## Architecture Integration

### Current Module Structure
```
rust/src/
├── lib.rs              # Main entry point
├── error.rs            # Custom error types
├── models.rs           # Data structures
├── database.rs         # SurrealDB manager
├── vector_store.rs     # Semantic search
├── llm/
│   ├── mod.rs          # LLM module exports
│   └── model_manager.rs # Model Manager ✨ NEW
├── search.rs           # Smart search
└── health.rs           # Health summaries
```

### Flutter Integration (Next Sprint)
Create Flutter UI page: `lib/features/ai_models/presentation/pages/models_page.dart`
- List available models
- Download button with progress bar
- Delete downloaded models
- Storage usage indicator

## Performance Considerations

### Download Optimization
- Streaming download (no full buffer in memory)
- Progress tracking without blocking
- Automatic resume not implemented (restart download on failure)

### Storage Requirements
- Phi-3-mini-4k-q4: ~1.8 GB
- Total with tokenizer: ~2 GB
- Recommend minimum 5 GB free space for Android

### Memory Usage
- Model Manager: <1 MB (caching only metadata)
- Candle inference: ~2-4 GB RAM (model loaded in memory)
- Target devices: Snapdragon 7 Gen 2+ with 8GB RAM

## Known Limitations

1. **Tokenizer Loading**: Stubbed pending tokenizer.json file bundling
2. **GGUF Inference**: Candle integration incomplete (requires Phi-3 architecture implementation)
3. **Resume Downloads**: Not supported (restart on network failure)
4. **Multi-model**: Cache only tracks one active model at a time
5. **GPU Acceleration**: Disabled (uses CPU for Android compatibility)

## Next Steps (Sprint 1.2)

1. **Complete Candle Integration**
   - Implement Phi-3 model architecture in Candle
   - Load GGUF weights with proper quantization
   - Add sampling strategies (temperature, top_p, top_k)
   - Optimize for <2s latency on target hardware

2. **Flutter UI**
   - Models dashboard page
   - Download progress widget
   - Storage management
   - Model switching

3. **Testing**
   - Inference latency benchmarks
   - Memory profiling on Android
   - Download interruption handling
   - Offline mode validation

## References
- [HuggingFace Hub API](https://huggingface.co/docs/hub/index)
- [Candle Documentation](https://github.com/huggingface/candle)
- [Phi-3 Technical Report](https://arxiv.org/abs/2404.14219)
- Sprint Plan: `docs/ROADMAP_MCP_INTEGRATION.md` - Issue #3
