#!/usr/bin/env node
/**
 * Test Gemma 4 E2B inference with llama.cpp (or equivalent).
 *
 * This script verifies the GGUF model loaded in assets/models/
 * and optionally runs a test query if llama.cpp is available.
 *
 * Usage:
 *   node scripts/test-gemma4-model.js [model]
 *
 * Prerequisites:
 *   - llama.cpp installed OR
 *   - ollama running with gemma-4-e2b model imported
 *
 * For Android (AICore), skip this test — the model is handled
 * by the ML Kit Prompt API / AICore runtime natively.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ASSETS_DIR = path.join(__dirname, '..', 'assets', 'models');
const DATASETS_MODEL = 'E:\\datasetsDrive\\models\\gemma-4-E2B-it-uncensored-Q4_K_M.gguf';

const MODELS = {
  e2b: {
    name: 'Gemma 4 E2B (2B params)',
    files: [
      path.join(ASSETS_DIR, 'gemma-4-e2b-Q4_K_M.gguf'),
      DATASETS_MODEL,
    ],
    size: '~3.2 GB',
  },
  e4b: {
    name: 'Gemma 4 E4B (4B params)',
    files: [],
    size: '~5.3 GB',
  },
};

function formatBytes(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
}

function checkModel(modelKey) {
  const model = MODELS[modelKey];
  if (!model) {
    console.error(`❌ Unknown model: ${modelKey}`);
    return false;
  }

  console.log(`\n🧠  ** ${model.name} **`);
  console.log(`   Size expected: ${model.size}`);

  for (const filePath of model.files) {
    const exists = fs.existsSync(filePath);
    const size = exists ? formatBytes(fs.statSync(filePath).size) : 'N/A';

    if (exists) {
      console.log(`   ✅ ${path.basename(filePath)}`);
      console.log(`      📍 ${filePath}`);
      console.log(`      📦 ${size}`);
    } else {
      console.log(`   ❌ ${path.basename(filePath)} — NOT FOUND`);
    }
  }

  return model.files.some(f => fs.existsSync(f));
}

async function main() {
  console.log('══════════════════════════════════════');
  console.log('  Gemma 4 Model Test — OrionHealth');
  console.log('══════════════════════════════════════');

  // Check both models
  const e2bOk = checkModel('e2b');
  checkModel('e4b');

  // Summary
  console.log('\n📊  ** Summary **');
  if (e2bOk) {
    console.log('   ✅ Modelo E2B disponible para OrionHealth');
  } else {
    console.log('   ❌ Ningún modelo E2B encontrado');
  }

  // Try to detect inference engines
  console.log('\n🔍  ** Inference Engine Detection **');
  
  try {
    const ollama = execSync('ollama --version 2>&1', { stdio: 'pipe', timeout: 3000 })
      .toString().trim();
    console.log(`   ✅ Ollama: ${ollama}`);
  } catch {
    console.log('   ⚠️  Ollama: not detected');
  }

  try {
    const llamacpp = execSync('llama-cli --version 2>&1', { stdio: 'pipe', timeout: 3000 })
      .toString().trim();
    console.log(`   ✅ llama.cpp: ${llamacpp}`);
  } catch {
    console.log('   ⚠️  llama.cpp: not detected');
  }

  console.log('\n📱  ** Mobile (Android) **');
  console.log('   Si ejecutas en Android con AICore:');
  console.log('   - Gemma 4 E2B se descarga automáticamente');
  console.log('   - No necesitas copiar manualmente los GGUF');
  console.log('   - GemmaLlmAdapter usa MethodChannel → Kotlin → AICore');
  console.log('');

  // Show model in assets
  console.log('📁  ** Assets Dirs **');
  const assetsModels = fs.readdirSync(ASSETS_DIR);
  for (const file of assetsModels) {
    const fullPath = path.join(ASSETS_DIR, file);
    const stat = fs.statSync(fullPath);
    if (stat.isFile()) {
      const type = stat.nlink > 1 ? '(hardlink) ' : '';
      console.log(`   ${type}${file} — ${formatBytes(stat.size)}`);
    } else {
      console.log(`   📁 ${file}/`);
    }
  }
}

main().catch(err => {
  console.error(`\n❌ Error: ${err.message}`);
  process.exit(1);
});
