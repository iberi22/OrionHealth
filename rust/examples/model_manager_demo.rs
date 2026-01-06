/// Example demonstrating ModelManager usage
/// Run with: cargo run --example model_manager_demo

use rust_lib_orionhealth_rust::llm::{ModelManager, DownloadProgress, CandleLlmAdapter, LlmAdapter};
use std::path::PathBuf;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("=== OrionHealth Model Manager Demo ===\n");

    // 1. Initialize Model Manager
    let models_dir = PathBuf::from("./models");
    let mut manager = ModelManager::new(models_dir.clone());
    manager.init().await?;
    
    println!("📁 Models directory: {:?}\n", manager.models_dir());

    // 2. List available models
    println!("📋 Available models:");
    for model in manager.list_available() {
        let status = if model.is_downloaded { "✓ Downloaded" } else { "⏳ Not downloaded" };
        println!("  - {} ({}) - {:.1} GB - {}",
            model.name,
            model.id,
            model.size_bytes as f64 / 1_000_000_000.0,
            status
        );
    }
    println!();

    // 3. Download Phi-3-mini (if not already downloaded)
    if !manager.is_downloaded("Phi-3-mini-4k-instruct-q4") {
        println!("⬇️  Downloading Phi-3-mini-4k-instruct-q4...");
        
        let progress_callback = |progress: DownloadProgress| {
            print!("\r  Progress: {:.1}% ({:.1} MB / {:.1} MB)",
                progress.percentage,
                progress.downloaded_bytes as f64 / 1_000_000.0,
                progress.total_bytes as f64 / 1_000_000.0
            );
            use std::io::Write;
            std::io::stdout().flush().unwrap();
        };

        match manager.download_phi3_mini(progress_callback).await {
            Ok(path) => {
                println!("\n✅ Model downloaded to: {:?}\n", path);
            }
            Err(e) => {
                println!("\n❌ Download failed: {}\n", e);
                println!("💡 Note: This demo requires internet connection to download models.");
                println!("   The model will be cached for future use.\n");
            }
        }
    } else {
        println!("✅ Phi-3-mini already downloaded\n");
    }

    // 4. List downloaded models
    println!("💾 Downloaded models:");
    for model in manager.list_downloaded() {
        println!("  - {} at {:?}", model.name, model.path.as_ref().unwrap());
    }
    println!();

    // 5. Initialize Candle LLM Adapter (if model exists)
    if let Ok(model_path) = manager.get_model_path("Phi-3-mini-4k-instruct-q4") {
        println!("🤖 Initializing Candle LLM Adapter...");
        let mut adapter = CandleLlmAdapter::new(model_path.clone());
        adapter.init().await?;

        if adapter.is_available().await {
            println!("✅ LLM Adapter ready!");
            
            // Generate test text
            let prompt = "Resumen de salud del paciente: ";
            println!("\n📝 Test prompt: {}", prompt);
            
            match adapter.generate_text(prompt).await {
                Ok(response) => {
                    println!("🎯 Response: {}\n", response);
                }
                Err(e) => {
                    println!("❌ Generation failed: {}\n", e);
                }
            }
        } else {
            println!("⚠️  LLM Adapter not fully available (tokenizer/model loading pending)\n");
        }
    }

    // 6. Cleanup example (commented out to preserve downloads)
    // println!("🗑️  Cleaning up...");
    // if manager.is_downloaded("Phi-3-mini-4k-instruct-q4") {
    //     manager.delete_model("Phi-3-mini-4k-instruct-q4").await?;
    //     println!("✅ Model deleted\n");
    // }

    println!("✨ Demo complete!");
    Ok(())
}
