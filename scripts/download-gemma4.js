#!/usr/bin/env node
/**
 * Download Gemma 4 model files for OrionHealth on-device AI.
 *
 * Gemma 4 models from Hugging Face:
 *   - E2B (2B params): ~1.2 GB (4-bit GGUF)
 *   - E4B (4B params): ~2.4 GB (4-bit GGUF)
 *
 * Usage:
 *   node scripts/download-gemma4.js [model]
 *     model: "e2b" (default) or "e4b"
 *
 * Prerequisites:
 *   - huggingface-cli (pip install huggingface-hub[cli])
 *   - Hugging Face token (huggingface-cli login)
 *   - 2-5 GB free disk space
 *
 * For Android on-device (AICore), the model downloads
 * via the AICore app — this script is for desktop/CI.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const MODELS_DIR = path.join(__dirname, '..', 'assets', 'models');

const MODELS = {
  e2b: {
    name: 'Gemma 4 E2B (2B params)',
    hf: 'google/gemma-4-E2B',
    ggufSize: '~1.2 GB (Q4_K_M)',
    use: 'Rápido, tareas cotidianas',
  },
  e4b: {
    name: 'Gemma 4 E4B (4B params)',
    hf: 'google/gemma-4-E4B',
    ggufSize: '~2.4 GB (Q4_K_M)',
    use: 'Precisión, análisis profundo',
  },
};

function checkTool(name, cmd) {
  try {
    execSync(`${cmd} --version`, { stdio: 'pipe', timeout: 5000 });
    return true;
  } catch {
    return false;
  }
}

function getDirSize(dir) {
  if (!fs.existsSync(dir)) return 0;
  let size = 0;
  walkDir(dir, f => { size += f.isFile() ? fs.statSync(path.join(dir, f)).size : 0; });
  return size;
}

function walkDir(dir, fn) {
  try {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (entry.isDirectory()) walkDir(path.join(dir, entry.name), fn);
      else fn(entry);
    }
  } catch {}
}

function formatBytes(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
}

async function main() {
  const modelKey = (process.argv[2] || 'e4b').toLowerCase();
  const model = MODELS[modelKey];

  if (!model) {
    console.error(`❌ Modelo desconocido: "${modelKey}"`);
    console.error(`   Opciones: ${Object.keys(MODELS).join(', ')}`);
    process.exit(1);
  }

  const modelDir = path.join(MODELS_DIR, `gemma-4-${modelKey}`);

  console.log('');
  console.log('🧠  Gemma 4 Downloader — OrionHealth');
  console.log('══════════════════════════════════════');
  console.log(`Modelo: ${model.name}`);
  console.log(`Tamaño: ${model.ggufSize}`);
  console.log(`Uso:    ${model.use}`);
  console.log(`Destino: ${modelDir}`);
  console.log('');

  // Detect tools
  const hasHfCli = checkTool('huggingface-cli', 'huggingface-cli');

  if (!hasHfCli) {
    console.log('⚠️  huggingface-cli no está instalado.');
    console.log('   Para instalar:');
    console.log('   pip install huggingface-hub[cli]');
    console.log('   huggingface-cli login');
    console.log('');
    console.log('📋  Descarga manual:');
    console.log(`   https://huggingface.co/${model.hf}`);
    console.log('');
    console.log('   Los archivos GGUF recomendados están en:');
    console.log(`   https://huggingface.co/unsloth/gemma-4-${modelKey.toUpperCase()}-GGUF`);
    console.log('');
    process.exit(1);
  }

  // Check if already downloaded
  if (fs.existsSync(modelDir)) {
    const size = getDirSize(modelDir);
    if (size > 100_000_000) {
      console.log(`✅ Ya existe: ${formatBytes(size)} en ${modelDir}`);
      console.log('   Para redescargar, borra el directorio y ejecuta de nuevo.');
      showNextSteps();
      return;
    }
  }

  // Ensure output dir
  fs.mkdirSync(modelDir, { recursive: true });

  console.log('⬇️  Descargando desde Hugging Face...');
  console.log('   (Esto puede tomar varios minutos)');
  console.log('');

  try {
    // Try GGUF first (smaller, quantized)
    const ggufRepo = `unsloth/gemma-4-${modelKey.toUpperCase()}-GGUF`;
    console.log(`[1/2] Intentando GGUF desde ${ggufRepo}...`);
    execSync(
      `huggingface-cli download ${ggufRepo} --local-dir "${modelDir}" --include "*.gguf" --resume-download`,
      { stdio: 'inherit', timeout: 900000 }
    );

    const size = getDirSize(modelDir);
    if (size > 50_000_000) {
      console.log(`\n✅ Modelo descargado: ${formatBytes(size)}`);
      showNextSteps();
      return;
    }

    // Fallback: full weights
    console.log('   GGUF no disponible, descargando weights completos...');
    execSync(
      `huggingface-cli download ${model.hf} --local-dir "${modelDir}" --resume-download`,
      { stdio: 'inherit', timeout: 1800000 }
    );

    const size2 = getDirSize(modelDir);
    if (size2 > 50_000_000) {
      console.log(`\n✅ Modelo descargado: ${formatBytes(size2)}`);
    } else {
      console.log('\n⚠️  El modelo parece incompleto.');
    }
  } catch (err) {
    console.error(`\n❌ Error: ${err.message}`);
    console.log('');
    console.log('📋  Descarga manual:');
    console.log(`   huggingface-cli download unsloth/gemma-4-${modelKey.toUpperCase()}-GGUF --include "*.gguf" --local-dir "${modelDir}"`);
    console.log('');
    console.log('   O desde el navegador:');
    console.log(`   https://huggingface.co/google/gemma-4-${modelKey.toUpperCase()}`);
    process.exit(1);
  }

  showNextSteps();
}

function showNextSteps() {
  console.log('');
  console.log('📱  Siguientes pasos:');
  console.log('   1. flutter pub get');
  console.log('   2. Asegura AICore en tu dispositivo Android');
  console.log('   3. flutter run');
  console.log('   4. GemmaLlmAdapter detectará automáticamente el modelo local');
  console.log('');
  console.log('   Para Android (AICore), el modelo se descarga automáticamente');
  console.log('   desde la app. Este script es para testing/desktop.');
}

main().catch(err => {
  console.error(`\n❌ Fatal: ${err.message}`);
  process.exit(1);
});
