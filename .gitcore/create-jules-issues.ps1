# ============================================================================
# create-jules-issues.ps1 — Issue Creator for OrionHealth Harness
# ============================================================================
# OBJETIVO: Crear issues solo si NO EXISTE ya uno abierto con el mismo título.
# Usa un lock file para evitar ejecución concurrente.
# ============================================================================

param(
    [string]$Type = "golden"  # "golden" | "e2e" | "all"
)

$ErrorActionPreference = "Continue"
$LOCK_FILE = ".gitcore\.create-issues.lock"
$REPO = "iberi22/OrionHealth"

# === LOCK: evitar ejecución concurrente ===
if (Test-Path $LOCK_FILE) {
    $lockAge = (Get-Date) - (Get-Item $LOCK_FILE).LastWriteTime
    if ($lockAge.TotalMinutes -lt 30) {
        Write-Host "[LOCK] create-jules-issues.ps1 ya se ejecutó hace $([int]$lockAge.TotalMinutes) min. Abortando."
        exit 0
    } else {
        Write-Host "[LOCK] Anterior murió hace $([int]$lockAge.TotalMinutes) min. Ignorando."
    }
}
"locked $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Set-Content $LOCK_FILE -NoNewline

function Get-ExistingOpenIssues {
    $issues = gh issue list --repo $REPO --state open --json title --limit 500 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Host "ERROR fetching issues: $issues"; return @() }
    try {
        $parsed = $issues | ConvertFrom-Json
        return ($parsed | ForEach-Object { $_.title })
    } catch {
        Write-Host "ERROR parsing issues JSON: $_"
        return @()
    }
}

function New-IssueIfNotExists {
    param([string]$Title, [string]$Body, [string]$Label = "jules")
    
    $existingTitles = Get-ExistingOpenIssues
    if ($Title -in $existingTitles) {
        Write-Host "  ⏭️ Ya existe: $Title"
        return $null
    }
    
    $result = gh issue create --repo $REPO --title $Title --body $Body --label $Label 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Creado: $result"
        return $result
    } else {
        Write-Host "  ❌ Error creando '$Title': $result"
        return $null
    }
}

$created = 0

if ($Type -eq "golden" -or $Type -eq "all") {
    $features = @("about","allergies","auth","dashboard","eps_connection","home","local_agent","medications","onboarding","settings","user_profile","vitals","voice_chat")
    Write-Host "=== Creando issues de golden tests ==="
    foreach ($f in $features) {
        $title = "[jules] $f : add golden tests"
        $body = "Crear golden tests de referencia para el feature $f.`n`nUsar test/golden_test_utils.dart como base.`nCrear screenshots de referencia PNG en test/features/$f/presentation/golden/goldens/.`nTest file: test/features/$f/presentation/golden/${f}_page_golden_test.dart"
        $result = New-IssueIfNotExists -Title $title -Body $body
        if ($result) { $created++ }
        Start-Sleep -Milliseconds 500
    }
}

if ($Type -eq "e2e" -or $Type -eq "all") {
    $features = @("about","allergies","calendar_import","doctor_verification","eps_connection","health_data_import","health_record","health_sharing","local_agent","medical_research","meditation","reports","user_profile","vitals","voice_chat","network")
    Write-Host "=== Creando issues de E2E tests ==="
    foreach ($f in $features) {
        $title = "[jules-harness] $f : add e2e test"
        $body = "Feature '$f' has no E2E tests.`n`nTask: Create an E2E test file for this feature.`n`nReference: integration_test/ directory for existing patterns.`n`nAuto-detected by harness scan."
        $result = New-IssueIfNotExists -Title $title -Body $body
        if ($result) { $created++ }
        Start-Sleep -Milliseconds 500
    }
}

Remove-Item $LOCK_FILE -Force -ErrorAction SilentlyContinue
Write-Host "`nCreados $created issues nuevos."
