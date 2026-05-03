#!/usr/bin/env node
/**
 * Download Gemma 4 model files for OrionHealth on-device AI.
 *
 * Gemma 4 models are available from Hugging Face:
 *   - E2B (2B params): ~1.2 GB (4-bit quantized)
 *   - E4B (4B params): ~2.4 GB (4-bit quantized)
 *
 * Usage:
 *   node scripts/download-gemma4.js [model]
 *     model: "e2b" (default, 2B params) or "e4b" (4B params)
 *
 * Environment:
 *   ORIONHEALTH_MODELS_DIR = output directory (default: assets/models/)
 *
 * Prerequisites:
 *   - Hugging Face CLI (hf_transfer) or direct download
 *   - 2-5 GB free disk space
 *   - Stable internet connection
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const { execSync } = require('child_process');

// ===== Configuration =====
const HF_BASE = 'https://huggingface.co/google/gemma-4-e2b-gguf/resolve/main';
const MODELS_DIR = process.env.ORIONHEALTH_MODELS_DIR ||
  path.join(__dirname, '..', 'assets', 'models');

const MODELS = {
  e2b: {
    name: 'Gemma 4 E2B',
    params: '2B',
    files: [
      {
        url: `${HF_BASE}/gemma-4-e2b-Q4_K_M.gguf`,
        filename: 'gemma-4-e2b-Q4_K_M.gguf',
        size: '~1.2 GB',
        sha256: 'abc123...', // Replace with actual SHA after download
      },
    ],
  },
  e4b: {
    name: 'Gemma 4 E4B',
    params: '4B',
    files: [
      {
        url: `${HF_BASE}/../gemma-4-e4b-gguf/gemma-4-e4b-Q4_K_M.gguf`,
        filename: 'gemma-4-e4b-Q4_K_M.gguf',
        size: '~2.4 GB',
        sha256: 'def456...',
      },
    ],
  },
};

// ===== Helpers =====
function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.log(`📁 Created directory: ${dir}`);
  }
}

function formatBytes(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function downloadFile(url, destPath) {
  return new Promise((resolve, reject) => {
    console.log(`  ⬇️  Downloading: ${url}`);
    console.log(`  📍 To: ${destPath}`);

    const file = fs.createWriteStream(destPath);
    let downloadedBytes = 0;
    let lastLog = Date.now();

    https.get(url, (response) => {
      if (response.statusCode !== 200) {
        reject(new Error(`HTTP ${response.statusCode}: ${response.statusMessage}`));
        return;
      }

      const totalBytes = parseInt(response.headers['content-length'] || '0', 10);

      response.on('data', (chunk) => {
        downloadedBytes += chunk.length;
        const now = Date.now();
        if (now - lastLog > 5000) { // Log every 5s
          const pct = totalBytes > 0
            ? ((downloadedBytes / totalBytes) * 100).toFixed(1)
            : '?';
          const speed = formatBytes(downloadedBytes / ((now - lastLog) / 1000));
          console.log(
            `     Progress: ${formatBytes(downloadedBytes)} / ${formatBytes(totalBytes)} (${pct}%) — ${speed}/s`
          );
          lastLog = now;
        }
      });

      response.pipe(file);
    });

    file.on('finish', () => {
      file.close();
      const finalSize = fs.statSync(destPath).size;
      console.log(`  ✅ Complete: ${formatBytes(finalSize)}`);
      resolve(destPath);
    });

    file.on('error', (err) => {
      fs.unlinkSync(destPath);
      reject(err);
    });
  });
}

// ===== Main =====
async function main() {
  const modelArg = (process.argv[2] || 'e2b').toLowerCase();
  const modelConfig = MODELS[modelArg];

  if (!modelConfig) {
    console.error(`❌ Unknown model: "${modelArg}"`);
    console.error(`   Available: ${Object.keys(MODELS).join(', ')}`);
    process.exit(1);
  }

  console.log(`\n🧠  ** Gemma 4 Downloader for OrionHealth **\n`);
  console.log(`Model: ${modelConfig.name} (${modelConfig.params} params)`);
  console.log(`Output: ${MODELS_DIR}\n`);

  // Ensure output directory exists
  ensureDir(MODELS_DIR);

  // Check for existing files first
  for (const file of modelConfig.files) {
    const filePath = path.join(MODELS_DIR, file.filename);
    if (fs.existsSync(filePath)) {
      const existingSize = fs.statSync(filePath).size;
      console.log(`  ⏭️  Already exists: ${file.filename} (${formatBytes(existingSize)})`);

      // Try Hugging Face Hub CLI if available (faster, multi-part download)
      console.log(`\n📦  Downloading ${modelConfig.name} model files...\n`);

      for (const file of modelConfig.files) {
        const filePath = path.join(MODELS_DIR, file.filename);
        const exists = fs.existsSync(filePath);

        if (exists && fs.statSync(filePath).size > 100_000_000) {
          // Already downloaded (>100MB)
          console.log(`  ⏭️  ${file.filename} ya existe (${file.size})`);
          continue;
        }

        if (!exists) {
          console.log(`  New file: ${file.filename} (${file.size})`);
          console.log(`  URL: ${file.url}`);

          // Try Hugging Face CLI first (faster)
          try {
            console.log('\n  🔄  Intentando Hugging Face Hub CLI (más rápido)...');
            execSync(
              `huggingface-cli download google/gemma-4-e2b-gguf gemma-4-e2b-Q4_K_M.gguf --local-dir "${MODELS_DIR}"`,
              { stdio: 'inherit', timeout: 600_000 }
            );
            console.log('  ✅ Descarga completada via Hugging Face CLI');
          } catch (hfError) {
            console.log('  ⚠️  Hugging Face CLI no disponible. Usando descarga directa HTTPS...\n');
            await downloadFile(file.url, filePath);
          }
        }
      }
    }
  }

  // Summary
  console.log(`\n📊  ** Download Summary **`);
  console.log(`────────────────────────────────`);

  let totalSize = 0;
  for (const file of modelConfig.files) {
    const filePath = path.join(MODELS_DIR, file.filename);
    const exists = fs.existsSync(filePath);
    const size = exists ? fs.statSync(filePath).size : 0;
    totalSize += size;

    console.log(
      `  ${exists ? '✅' : '❌'} ${file.filename}` +
      ` (${exists ? formatBytes(size) : 'no descargado'})`
    );
  }

  console.log(`────────────────────────────────`);
  console.log(`  Total: ${formatBytes(totalSize)} en ${MODELS_DIR}\n`);

  if (totalSize < 100_000_000) {
    console.log('⚠️  Los modelos no se descargaron completamente.');
    console.log('   Asegúrate de tener huggingface-cli instalado:');
    console.log('   $ pip install huggingface-hub');
    console.log('   $ huggingface-cli login');
    console.log('');
    console.log('   O descarga manualmente desde:');
    console.log('   https://huggingface.co/google/gemma-4-e2b-gguf');
    console.log('   https://huggingface.co/google/gemma-4-e4b-gguf');
  } else {
    console.log('🎉  ** Gemma 4 listo para usar en OrionHealth! **');
    console.log('');
    console.log('   Next steps:');
    console.log('   1. flutter pub get');
    console.log('   2. flutter run (Android 8+, AICore required)');
    console.log('   3. Verifica que GemmaLlmAdapter detecte el modelo');
  }
}

main().catch((err) => {
  console.error(`\n❌ Error: ${err.message}`);
  process.exit(1);
});
