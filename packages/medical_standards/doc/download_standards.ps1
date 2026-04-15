#Requires -Version 5.1
<#
.SYNOPSIS
    Download official medical standards datasets for the medical_standards package.

.DESCRIPTION
    This script downloads full medical standards datasets from official sources.
    Some datasets require license agreements before download.

    Sources:
    - ICD-10-CM: CMS (free, public domain for US)
    - LOINC: Regenstrief Institute (free registration required)
    - SNOMED CT: SNOMED International (requires license)
    - RxNorm: NLM/NIH (public domain for US)

.NOTES
    Run from the repository root: ./doc/download_standards.ps1
    Output: packages/medical_standards/data/
#>

param(
    [switch]$SkipLicensed,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$DataDir = "packages/medical_standards/data"

# Ensure data directory exists
if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
}

function Write-Step {
    param([string]$Msg)
    Write-Host "`n==> $Msg" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Msg)
    Write-Host "[OK] $Msg" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Msg)
    Write-Host "[WARN] $Msg" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Msg)
    Write-Host "[FAIL] $Msg" -ForegroundColor Red
}

function Invoke-DownloadFile {
    param(
        [string]$Url,
        [string]$OutFile,
        [string]$Description
    )

    Write-Host "  Downloading: $Description" -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $Url -OutFile $OutFile -TimeoutSec 60 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Success " $OutFile"
            return $true
        }
    } catch {
        Write-Fail " $($_.Exception.Message)"
        return $false
    }
    return $false
}

Write-Host @"

==========================================
  Medical Standards Downloader
==========================================

"@ -ForegroundColor Magenta

# ============================================================
# 1. ICD-10-CM (CMS) — FREE, Public Domain
# ============================================================
Write-Step "ICD-10-CM (CMS — Free, Public Domain)"

$ICD10_Zip = "$DataDir/icd10cm_codes_2024.zip"
$ICD10_Csv  = "$DataDir/icd10cm_codes_2024.csv"

# CMS ICD-10-CM download URL (updated annually)
$ICD10_Url = "https://www.cms.gov/files/zip/2024-icd-10-cm-codes.zip"

if ((Test-Path $ICD10_Csv) -and -not $Force) {
    Write-Success "ICD-10-CM already present, skipping. Use -Force to re-download."
} else {
    $tempZip = "$DataDir/temp_icd10.zip"
    $ok = Invoke-DownloadFile -Url $ICD10_Url -OutFile $tempZip -Description "ICD-10-CM 2024 codes"
    if ($ok) {
        Expand-Archive -Path $tempZip -DestinationPath $DataDir -Force
        Remove-Item $tempZip -Force
        Write-Success "ICD-10-CM extracted to $DataDir"
    }
}

# ============================================================
# 2. LOINC — FREE with registration
# ============================================================
Write-Step "LOINC (Regenstrief — Free with Registration)"

Write-Host @"

  LOINC requires free registration at:
  https://loinc.org/downloads/loinc-downloads/

  After downloading manually:
  1. Register at https://loinc.org/downloads/
  2. Download 'LOINC Multihierarchy CSV' or 'LOINC Table CSV'
  3. Place files in: $DataDir/

  License: https://loinc.org/license/

"@ -ForegroundColor Yellow

$LoincCsv = "$DataDir/loinc.csv"
if ((Test-Path $LoincCsv) -and -not $Force) {
    Write-Success "LOINC CSV present"
} else {
    Write-Host "  Expected file: $LoincCsv" -ForegroundColor Gray
    Write-Host "  After downloading from loinc.org, place 'Loinc.csv' there." -ForegroundColor Gray
}

# ============================================================
# 3. SNOMED CT — REQUIRES LICENSE
# ============================================================
Write-Step "SNOMED CT (SNOMED International — Requires License)"

if ($SkipLicensed) {
    Write-Warn "Skipping SNOMED CT (use without -SkipLicensed to see details)"
} else {
    Write-Host @"

  *** SNOMED CT REQUIRES A LICENSE AGREEMENT ***

  SNOMED CT is not public domain. To obtain:

  1. Go to: https://www.snomed.org/get-snomed
  2. Accept the SNOMED CT License Agreement
  3. Choose your national extension (US, UK, etc.) or international edition
  4. Download the RF2 release (Snapshot or Full)

  Note: IHTSDO/SNOMED International holds copyright.
        A license is required but often free for non-commercial
        and low-resource settings.

  License: https://www.snomed.org/snomed-ct/get-snomed-ct/snomed-ct-license-faq

  After download, convert RF2 to JSON and place in:
    $DataDir/full_snomed.json

"@ -ForegroundColor Red
}

# ============================================================
# 4. RxNorm — FREE, Public Domain (US Government)
# ============================================================
Write-Step "RxNorm (NLM/NIH — Free, Public Domain)"

$RxNorm_Zip = "$DataDir/rxnorm.zip"
$RxNorm_Dir = "$DataDir/rxnorm"

# RxNorm monthly release from NLM
$RxNorm_Url = "https://download.nlm.nih.gov/rxnorm/RxNorm_full_2024-03-04.zip"

if ((Test-Path "$DataDir/rxnorm") -and -not $Force) {
    Write-Success "RxNorm already present. Use -Force to re-download."
} else {
    $tempZip = "$DataDir/temp_rxnorm.zip"
    $ok = Invoke-DownloadFile -Url $RxNorm_Url -OutFile $tempZip -Description "RxNorm full release"
    if ($ok) {
        Expand-Archive -Path $tempZip -DestinationPath $RxNorm_Dir -Force
        Remove-Item $tempZip -Force
        Write-Success "RxNorm extracted to $RxNorm_Dir"
    }
}

# ============================================================
# Summary
# ============================================================
Write-Step "Download Summary"

Write-Host @"

  License Status:
  ─────────────────────────────────────────────────────
  ICD-10-CM  : PUBLIC DOMAIN (US Gov) — Ready if downloaded
  LOINC      : FREE with registration — Check loinc.org
  SNOMED CT  : LICENSE REQUIRED — snomed.org
  RxNorm     : PUBLIC DOMAIN (US Gov) — Ready if downloaded
  ─────────────────────────────────────────────────────

  After downloading:
  1. Convert/extract files to JSON format
  2. Place in: $DataDir/
  3. Use: dart run medical_standards:sync to update cache

"@
