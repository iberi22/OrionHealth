<#
.SYNOPSIS
    Download Gemma 4 E2B and E4B models for OrionHealth on-device integration.
.DESCRIPTION
    Downloads Gemma 4 models from Hugging Face using huggingface-cli.
    For Android on-device use, AICore handles model download automatically.
    This script is for:
    - Local testing on desktop
    - Model evaluation before mobile deployment
    - GGUF format for llama.cpp / LM Studio testing

.PREREQUISITES
    - Python 3.8+
    - huggingface-hub: pip install huggingface-hub[cli]
    - Git LFS: git lfs install (for full weights only)

.NOTES
    Author: OrionHealth / SWAL
    Date: 2026-05-03
    License: Apache 2.0
#>

param(
    [ValidateSet("all", "e2b", "e4b")]
    [string]$Model = "all",

    [string]$OutputDir = (Join-Path $PSScriptRoot ".." "models"),

    [ValidateSet("gguf", "full")]
    [string]$Format = "gguf",

    [switch]$UseKaggle,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ── Model definitions ──────────────────────────────────────────────
$models = @(
    @{
        Name    = "gemma-4-e2b"
        Params  = "2B effective (5.1B total)"
        HF      = "google/gemma-4-E2B"
        Kaggle  = "google/gemma-4/E2B"
        GGUFSrc = "unsloth/gemma-4-E2B-GGUF"   # Common GGUF mirror
        Size    = "~1.2 GB (Q4_K_M)"
        RAM     = "4 GB min"
        Use     = "Fast, everyday tasks"
    },
    @{
        Name    = "gemma-4-e4b"
        Params  = "4.5B effective (8.0B total)"
        HF      = "google/gemma-4-E4B"
        Kaggle  = "google/gemma-4/E4B"
        GGUFSrc = "unsloth/gemma-4-E4B-GGUF"
        Size    = "~2.4 GB (Q4_K_M)"
        RAM     = "8 GB min"
        Use     = "Precision, deep analysis"
    }
)

# Filter models if specific one requested
$targetModels = if ($Model -eq "all") { $models } else { $models | Where-Object { $_.Name -eq "gemma-4-$Model" } }

# ── Preflight checks ───────────────────────────────────────────────
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Gemma 4 Download Script - OrionHealth          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Detect tools
$hasHuggingFaceCli = $null -ne (Get-Command "huggingface-cli" -ErrorAction SilentlyContinue)
$hasGitLfs = $null -ne (Get-Command "git" -ErrorAction SilentlyContinue)
$hasKaggleCli = $null -ne (Get-Command "kaggle" -ErrorAction SilentlyContinue)

Write-Host "[✓] Python/huggingface-cli: $(if($hasHuggingFaceCli){'YES'}else{'NO (pip install huggingface-hub[cli])'})" -ForegroundColor $(if($hasHuggingFaceCli){'Green'}else{'Yellow'})
Write-Host "[✓] Git LFS:               $(if($hasGitLfs){'YES'}else{'NO (run: git lfs install)'})" -ForegroundColor $(if($hasGitLfs -or $Format -eq 'gguf'){'Green'}else{'Yellow'})
Write-Host "[✓] Kaggle CLI:            $(if($hasKaggleCli){'YES'}else{'NO (optional)'})" -ForegroundColor $(if($hasKaggleCli -or -not $UseKaggle){'Green'}else{'Yellow'})
Write-Host ""

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Host "[+] Created output directory: $OutputDir" -ForegroundColor Green
}

# ── Download loop ──────────────────────────────────────────────────
foreach ($m in $targetModels) {
    $modelDir = Join-Path $OutputDir $m.Name
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "Model: $($m.Name) ($($m.Params))" -ForegroundColor Cyan
    Write-Host "Size:  $($m.Size)  |  RAM: $($m.RAM)  |  Use: $($m.Use)" -ForegroundColor White
    Write-Host ""

    if ($DryRun) {
        Write-Host "[DRY-RUN] Would download:" -ForegroundColor Yellow
        switch ($Format) {
            "gguf" {
                Write-Host "  huggingface-cli download $($m.GGUFSrc) --local-dir $modelDir" -ForegroundColor Gray
            }
            "full" {
                Write-Host "  git clone $($m.HF).git $modelDir" -ForegroundColor Gray
            }
        }
        if ($UseKaggle -and $hasKaggleCli) {
            Write-Host "  kaggle models download $($m.Kaggle) --path $modelDir" -ForegroundColor Gray
        }
        Write-Host ""
        continue
    }

    try {
        # ── Method 1: Hugging Face GGUF (recomendado para mobile/testing) ──
        if ($Format -eq "gguf" -and $hasHuggingFaceCli) {
            Write-Host "[↓] Downloading GGUF from Hugging Face ($($m.GGUFSrc))..." -ForegroundColor Green
            $hfArgs = @(
                "download"
                $m.GGUFSrc
                "--local-dir"
                $modelDir
                "--resume-download"
            )
            if ($Format -eq "gguf") {
                # Download only .gguf files (much smaller)
                $hfArgs += @("--include", "*.gguf")
            } else {
                $hfArgs += "--local-dir-use-symlinks", "False"
            }
            
            & huggingface-cli @hfArgs 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[✓] $($m.Name) descargado exitosamente en: $modelDir" -ForegroundColor Green
                continue
            } else {
                Write-Host "[!] GGUF download failed, falling back to full weights..." -ForegroundColor Yellow
            }
        }

        # ── Method 2: Hugging Face full weights (Git LFS) ──
        if ($Format -eq "full" -and $hasGitLfs) {
            Write-Host "[↓] Cloning full weights from Hugging Face ($($m.HF))..." -ForegroundColor Green
            & git clone $($m.HF).git $modelDir 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

            if ((Test-Path $modelDir) -and (Get-ChildItem $modelDir -Recurse -File | Measure-Object).Count -gt 0) {
                Write-Host "[✓] $($m.Name) full weights descargados en: $modelDir" -ForegroundColor Green
                continue
            } else {
                Write-Host "[!] Git clone failed, trying alternative..." -ForegroundColor Yellow
            }
        }

        # ── Method 3: Kaggle (alternative source) ──
        if ($UseKaggle -and $hasKaggleCli) {
            Write-Host "[↓] Downloading from Kaggle ($($m.Kaggle))..." -ForegroundColor Green
            & kaggle models download $($m.Kaggle) --path $modelDir 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        }

        # ── Fallback: Hugging Face CLI without GGUF filter ──
        if ($hasHuggingFaceCli -and -not (Test-Path (Join-Path $modelDir "*.safetensors"))) {
            Write-Host "[↓] Trying full download via huggingface-cli..." -ForegroundColor Green
            & huggingface-cli download $($m.HF) --local-dir $modelDir --resume-download
        }

        # Verify download
        $files = Get-ChildItem $modelDir -Recurse -File -ErrorAction SilentlyContinue
        if ($files.Count -gt 0) {
            $totalSizeMB = [math]::Round(($files | Measure-Object Length -Sum).Sum / 1MB, 1)
            Write-Host "[✓] $($m.Name) descargado ($totalSizeMB MB, $($files.Count) archivos)" -ForegroundColor Green
        } else {
            Write-Host "[✗] $($m.Name) no se pudo descargar. Verifica conexión y credenciales." -ForegroundColor Red
            Write-Host "    Prueba manual:" -ForegroundColor Yellow
            Write-Host "    huggingface-cli download $($m.HF) --local-dir $modelDir" -ForegroundColor Yellow
        }

    } catch {
        Write-Host "[✗] Error descargando $($m.Name): $_" -ForegroundColor Red
        Write-Host "    Prueba manual:" -ForegroundColor Yellow
        Write-Host "    huggingface-cli download $($m.HF) --local-dir $modelDir" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# ── Summary ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Download Complete                                    ║" -ForegroundColor Cyan
Write-Host "╠══════════════════════════════════════════════════════╣" -ForegroundColor Cyan

foreach ($m in $targetModels) {
    $modelDir = Join-Path $OutputDir $m.Name
    $status = if (Test-Path $modelDir) {
        $files = Get-ChildItem $modelDir -Recurse -File -ErrorAction SilentlyContinue
        if ($files.Count -gt 0) { "[✓]" } else { "[ ]" }
    } else { "[ ]" }
    Write-Host "║  $status  $($m.Name.PadRight(14)) $($m.Size.PadRight(16))  ║" -ForegroundColor White
}
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Android on-device: Unirse a AICore Developer Preview (ver docs/gemma4-integration.md)" -ForegroundColor White
Write-Host "  2. Implementar Method Channel en Kotlin/Flutter" -ForegroundColor White
Write-Host "  3. Modificar GemmaLlmAdapter para hybrid local/cloud" -ForegroundColor White
Write-Host ""

# ── Manual instructions if nothing worked ──
Write-Host "Manual alternative (any OS):" -ForegroundColor Yellow
Write-Host "  pip install huggingface-hub[cli]" -ForegroundColor Gray
Write-Host "  huggingface-cli login  (necesitas token de Hugging Face)" -ForegroundColor Gray
Write-Host "  huggingface-cli download google/gemma-4-E2B --local-dir ./models/gemma-4-e2b" -ForegroundColor Gray
Write-Host "  huggingface-cli download google/gemma-4-E4B --local-dir ./models/gemma-4-e4b" -ForegroundColor Gray
Write-Host ""
Write-Host "For GGUF (recomendado para testing):" -ForegroundColor Yellow
Write-Host "  huggingface-cli download unsloth/gemma-4-E2B-GGUF --include '*.gguf' --local-dir ./models/gemma-4-e2b" -ForegroundColor Gray
Write-Host "  huggingface-cli download unsloth/gemma-4-E4B-GGUF --include '*.gguf' --local-dir ./models/gemma-4-e4b" -ForegroundColor Gray
