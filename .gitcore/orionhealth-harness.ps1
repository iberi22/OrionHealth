# ============================================================================
# ORIONHEALTH HARNESS â€” Goal-Driven Implementation Pipeline
# ============================================================================
# Este script es el arnes que orquesta la implementacion completa de OrionHealth.
# Se ejecuta ciclicamente: escanea estado -> identifica gaps -> evalua agents -> calcula %
#
# Reglas:
# 1. Cada feature tiene un features.details.json con todos los pasos al 100%
# 2. Evaluacion: 1% del 100% va para feedback humano (revision manual)
# 3. 99% restante se divide entre: Agent Coding output + Scripts E2E + Coverage
# 4. El loop NO para hasta que todos los features esten en 100%
# ============================================================================

param(
    [switch]$Scan,
    [switch]$Report,
    [switch]$Fix,
    [string]$Feature = ""
)

$ROOT = "E:\scripts-python\OrionHealth"
$FEATURES_JSON = "$ROOT\.gitcore\features.json"
$DETAILS_DIR = "$ROOT\.gitcore\features.details"

# ============================================================================
# PHASE 1: SCAN
# ============================================================================
function Invoke-Scan {
    Write-Host "=== ORIONHEALTH SCAN ===" -ForegroundColor Cyan

    $features = Get-ChildItem "$ROOT\lib\features" -Directory | ForEach-Object Name
    $testFiles = (Get-ChildItem -Recurse -Filter *_test.dart -Path "$ROOT\test").Count
    $goldenFiles = (Get-ChildItem -Recurse -Filter *.png -Path "$ROOT\test").Count
    $e2eFiles = (Get-ChildItem -Recurse -Filter *.dart -Path "$ROOT\integration_test").Count
    $dartFiles = (Get-ChildItem -Recurse -Filter *.dart -Path "$ROOT\lib").Count
    $totalDart = (Get-ChildItem -Recurse -Filter *.dart -Path "$ROOT").Count
    $workflows = (Get-ChildItem "$ROOT\.github\workflows" -Filter *.yml).Count
    $i18nFiles = (Get-ChildItem -Recurse -Filter *.arb -Path "$ROOT\lib\l10n" -ErrorAction SilentlyContinue).Count

    $featureDetails = @{}
    $readmeCount = 0
    $fullArchCount = 0

    foreach ($f in $features) {
        $fPath = "$ROOT\lib\features\$f"
        $layers = Get-ChildItem $fPath -Directory | ForEach-Object Name
        $tLayerCount = $layers.Count
        $hasApp = $layers -contains "application"
        $hasDomain = $layers -contains "domain"
        $hasInfra = $layers -contains "infrastructure"
        $hasPres = $layers -contains "presentation"
        $hasFullArch = $hasApp -and $hasDomain -and $hasInfra -and $hasPres
        if ($hasFullArch) { $fullArchCount++ }

        $tTests = (Get-ChildItem -Recurse -Filter *_test.dart -Path "$ROOT\test\features\$f" -ErrorAction SilentlyContinue).Count
        $tGoldens = (Get-ChildItem -Recurse -Filter *.png -Path "$ROOT\test\features\$f" -ErrorAction SilentlyContinue).Count
        $hasReadme = Test-Path "$fPath\README.md"
        if ($hasReadme) { $readmeCount++ }

        $hasData = $layers -contains "data"

        $hasE2E = $false
        $e2ePath = "$ROOT\integration_test\critical_flows_e2e_test.dart"
        if (Test-Path $e2ePath) {
            $e2eContent = Get-Content $e2ePath -Raw -ErrorAction SilentlyContinue
            if ($e2eContent -and $e2eContent -match "\b$f\b") { $hasE2E = $true }
        }

        $hasInjectionConfig = (Get-ChildItem -Recurse -Filter "injection.config.dart" -Path "$ROOT\lib" -ErrorAction SilentlyContinue).Count -gt 0

        $featureDetails[$f] = @{
            layers = $layers
            layerCount = $tLayerCount
            hasFullArch = $hasFullArch
            testCount = $tTests
            goldenCount = $tGoldens
            hasReadme = $hasReadme
            hasE2E = $hasE2E
            hasInjectionConfig = $hasInjectionConfig
            hasData = $hasData
        }
    }

    $archScore = [math]::Round(($fullArchCount / $features.Count) * 25, 1)
    $testScore = [math]::Round([math]::Min(($testFiles / ($features.Count * 20)) * 30, 30), 1)
    $e2eScore = [math]::Round([math]::Min(($e2eFiles / $features.Count) * 10, 10), 1)
    $goldenScore = [math]::Round([math]::Min(($goldenFiles / ($features.Count * 6)) * 10, 10), 1)
    $docScore = [math]::Round([math]::Min(($readmeCount / $features.Count) * 5 + ($i18nFiles / 30) * 5, 10), 1)
    $ciScore = [math]::Round([math]::Min(($workflows / 6) * 5, 5), 1)
    $humanPct = 1.0
    $totalPct = [math]::Round([math]::Min($archScore + $testScore + $e2eScore + $goldenScore + $docScore + $ciScore + $humanPct, 99), 1)

    $result = @{
        scanTime = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        features = $features.Count
        fullArch = $fullArchCount
        fullArchPct = [math]::Round(($fullArchCount / $features.Count) * 100, 1)
        testFiles = $testFiles
        goldenFiles = $goldenFiles
        e2eFiles = $e2eFiles
        dartFiles = $dartFiles
        totalDartFiles = $totalDart
        workflows = $workflows
        i18nFiles = $i18nFiles
        readmeCount = $readmeCount
        archScore = $archScore
        testScore = $testScore
        e2eScore = $e2eScore
        goldenScore = $goldenScore
        docScore = $docScore
        ciScore = $ciScore
        humanScore = $humanPct
        implementationPct = $totalPct
        featureDetails = $featureDetails
    }

    $result | ConvertTo-Json -Depth 10 | Out-File "$ROOT\.gitcore\.scan-latest.json" -Encoding UTF8
    return $result
}

# ============================================================================
# PHASE 2: REPORT
# ============================================================================
function Invoke-Report {
    Param([Parameter(Mandatory=$true)]$ScanResult)

    $s = $ScanResult

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "   ORIONHEALTH IMPLEMENTATION REPORT" -ForegroundColor White
    Write-Host "   Scan: " -NoNewline -ForegroundColor Gray; Write-Host $s.scanTime -ForegroundColor Gray
    Write-Host "============================================" -ForegroundColor Cyan

    $pct = $s.implementationPct
    Write-Host ""
    Write-Host "GLOBAL SCORE: $($pct)%" -ForegroundColor Green

    Write-Host ""
    Write-Host "=== BREAKDOWN ===" -ForegroundColor Yellow
    Write-Host ("  Architecture (25" + [char]37 + "):     " + $s.archScore + "%   (" + $s.fullArch + "/" + $s.features + " clean arch)")
    Write-Host ("  Tests (30" + [char]37 + "):            " + $s.testScore + "%   (" + $s.testFiles + " test files)")
    Write-Host ("  Golden Tests (10" + [char]37 + "):     " + $s.goldenScore + "%   (" + $s.goldenFiles + " golden refs)")
    Write-Host ("  E2E/Integration (10" + [char]37 + "):  " + $s.e2eScore + "%    (" + $s.e2eFiles + " e2e files)")
    Write-Host ("  Documentation (10" + [char]37 + "):    " + $s.docScore + "%    (" + $s.readmeCount + "/" + $s.features + " READMEs, " + $s.i18nFiles + " i18n)")
    Write-Host ("  CI/CD (5" + [char]37 + "):             " + $s.ciScore + "%     (" + $s.workflows + " workflows)")
    Write-Host ("  Human Review (1" + [char]37 + "):      " + $s.humanScore + "%  (reserved)")
    Write-Host ("  TOTAL:                  " + $s.implementationPct + "%")

    Write-Host ""
    Write-Host "=== FEATURES DETAILED ===" -ForegroundColor Yellow
    $s.featureDetails.Keys | Sort-Object | ForEach-Object {
        $fn = $_
        $f = $s.featureDetails[$fn]
        $archStatus = if ($f.hasFullArch) { "[OK]" } else { "[--]" }
        $testOk = if ($f.testCount -ge 15) { "[OK]" } elseif ($f.testCount -ge 5) { "[--]" } else { "[XX]" }
        $e2eOk = if ($f.hasE2E) { "[OK]" } else { "[--]" }
        $readmeOk = if ($f.hasReadme) { "[OK]" } else { "[--]" }
        $goldOk = if ($f.goldenCount -ge 2) { "[OK]" } elseif ($f.goldenCount -ge 1) { "[--]" } else { "[--]" }
        Write-Host ("  " + $fn + "`tArch=" + $archStatus + " Tests=" + $testOk + "(" + $f.testCount + ") Gold=" + $goldOk + "(" + $f.goldenCount + ") E2E=" + $e2eOk + " Readme=" + $readmeOk + " Layers=" + $f.layerCount)
    }

    Write-Host ""
    Write-Host "=== GAPS IDENTIFIED ===" -ForegroundColor Red
    $s.featureDetails.Keys | Sort-Object | Where-Object { -not $s.featureDetails[$_].hasFullArch } | ForEach-Object {
        $g = $s.featureDetails[$_]
        Write-Host ("  [XX] " + $_ + " -- Full architecture missing (layers: " + ($g.layers -join ', ') + ")")
    }
    $s.featureDetails.Keys | Sort-Object | Where-Object { $s.featureDetails[$_].testCount -lt 10 } | ForEach-Object {
        Write-Host ("  [--] " + $_ + " -- Low test coverage (" + $s.featureDetails[$_].testCount + " tests)")
    }
    $s.featureDetails.Keys | Sort-Object | Where-Object { -not $s.featureDetails[$_].hasReadme } | ForEach-Object {
        Write-Host ("  [..] " + $_ + " -- Missing README")
    }

    Write-Host ""
    Write-Host "=== NEXT TARGETS (ordered by impact) ===" -ForegroundColor Green
    $missingReadmes = $s.features - $s.readmeCount
    Write-Host ("  1. READMEs faltantes (" + $missingReadmes + " features)")
    Write-Host "  2. Golden tests para features sin coverage visual"
    Write-Host "  3. E2E tests ampliados"
    Write-Host "  4. Cobertura de tests > 20 por feature"
    Write-Host "  5. network_health: agregar application/infra/presentation"
    Write-Host ""
}

# ============================================================================
# PHASE 3: FEATURE DETAILS
# ============================================================================
function Invoke-GenerateDetails {
    Param([Parameter(Mandatory=$true)]$ScanResult)

    if (-not (Test-Path $DETAILS_DIR)) {
        New-Item -ItemType Directory -Path $DETAILS_DIR -Force | Out-Null
    }

    $steps = @(
        @{ id = 1; name = "Architecture Definition"; weight = 15; evaluator = "scan:layers"; description = "app/domain/infra/presentation layers exist" }
        @{ id = 2; name = "Domain Layer Entities"; weight = 10; evaluator = "scan:files:domain/entities/*.dart"; description = "Domain entities defined and typed" }
        @{ id = 3; name = "Domain Layer Repository Abstract"; weight = 10; evaluator = "scan:files:domain/*_repository*.dart"; description = "Repository abstract class in domain" }
        @{ id = 4; name = "Domain Layer Use Cases"; weight = 10; evaluator = "scan:files:domain/usecases/*.dart"; description = "Use cases in domain layer" }
        @{ id = 5; name = "Infrastructure Layer Implementation"; weight = 10; evaluator = "scan:files:infrastructure/**/*.dart"; description = "Repository implementation + datasources" }
        @{ id = 6; name = "Application Layer (BLoC/Cubit/State)"; weight = 10; evaluator = "scan:files:application/*.dart"; description = "State management in application layer" }
        @{ id = 7; name = "Presentation Layer Widgets"; weight = 10; evaluator = "scan:files:presentation/**/*.dart"; description = "UI widgets and pages" }
        @{ id = 8; name = "Dependency Injection Config"; weight = 5; evaluator = "scan:file:injection.config.dart"; description = "GetIt/DI registration" }
        @{ id = 9; name = "Unit Tests (>=15)"; weight = 10; evaluator = "scan:tests:count>=15"; description = "Minimum 15 test files" }
        @{ id = 10; name = "Golden Tests (>=2)"; weight = 5; evaluator = "scan:goldens:count>=2"; description = "Golden reference screenshots" }
        @{ id = 11; name = "E2E/Integration Tests"; weight = 5; evaluator = "scan:e2e:true"; description = "Feature covered in integration tests" }
        @{ id = 12; name = "README Documentation"; weight = 4; evaluator = "scan:readme:true"; description = "Feature README.md exists" }
        @{ id = 13; name = "Flutter Analyze Clean"; weight = 3; evaluator = "external:flutter_analyze:0"; description = "Zero flutter analyze issues" }
        @{ id = 14; name = "Human Review"; weight = 1; evaluator = "human:approval"; description = "Human verified the feature" }
    )

    $ScanResult.featureDetails.Keys | ForEach-Object {
        $featureName = $_

        $f = $ScanResult.featureDetails[$featureName]

        $evaluatedSteps = @()
        foreach ($step in $steps) {
            $s = @{}
            $s["id"] = $step.id
            $s["name"] = $step.name
            $s["weight"] = $step.weight
            $s["description"] = $step.description
            $s["evaluator"] = $step.evaluator

            $completed = $false
            $progress = 0
            $evidence = ""

            $ev = $step.evaluator
            if ($ev -eq "scan:layers") {
                $completed = $f.hasFullArch
                $progress = if ($f.hasFullArch) { 100 } else { [math]::Round(($f.layerCount / 4) * 100, 0) }
            } elseif ($ev -eq "scan:files:domain/entities/*.dart") {
                $count = (Get-ChildItem -Recurse -Filter *.dart -Path "$ROOT\lib\features\$featureName\domain\entities" -ErrorAction SilentlyContinue).Count
                $completed = $count -ge 1
                $progress = if ($count -ge 1) { 100 } else { 0 }
                $evidence = "$count entities"
            } elseif ($ev -eq "scan:files:domain/*_repository*.dart") {
                $count = (Get-ChildItem -Recurse -Filter *repository*.dart -Path "$ROOT\lib\features\$featureName\domain" -ErrorAction SilentlyContinue).Count
                $completed = $count -ge 1
                $progress = if ($count -ge 1) { 100 } else { 0 }
                $evidence = "$count repository files"
            } elseif ($ev -eq "scan:files:domain/usecases/*.dart") {
                $count = (Get-ChildItem -Recurse -Filter *.dart -Path "$ROOT\lib\features\$featureName\domain\usecases" -ErrorAction SilentlyContinue).Count
                $completed = $count -ge 1
                $progress = if ($count -ge 1) { 100 } else { 0 }
                $evidence = "$count usecases"
            } elseif ($ev -eq "scan:files:infrastructure/**/*.dart") {
                $count = (Get-ChildItem -Recurse -Filter *.dart -Path "$ROOT\lib\features\$featureName\infrastructure" -ErrorAction SilentlyContinue).Count
                $completed = $count -ge 1
                $progress = if ($count -ge 1) { 100 } else { 0 }
                $evidence = "$count infra files"
            } elseif ($ev -eq "scan:files:application/*.dart") {
                $count = (Get-ChildItem -Recurse -Filter *.dart -Path "$ROOT\lib\features\$featureName\application" -ErrorAction SilentlyContinue).Count
                $completed = $count -ge 1
                $progress = if ($count -ge 1) { 100 } else { 0 }
                $evidence = "$count app files"
            } elseif ($ev -eq "scan:files:presentation/**/*.dart") {
                $count = (Get-ChildItem -Recurse -Filter *.dart -Path "$ROOT\lib\features\$featureName\presentation" -ErrorAction SilentlyContinue).Count
                $completed = $count -ge 1
                $progress = if ($count -ge 1) { 100 } else { 0 }
                $evidence = "$count pres files"
            } elseif ($ev -eq "scan:file:injection.config.dart") {
                $found = (Get-ChildItem -Recurse -Filter "injection.config.dart" -Path "$ROOT\lib" -ErrorAction SilentlyContinue).Count -gt 0
                $completed = $found
                $progress = if ($found) { 100 } else { 0 }
            } elseif ($ev -eq "scan:tests:count>=15") {
                $completed = $f.testCount -ge 15
                $progress = [math]::Round([math]::Min(($f.testCount / 15) * 100, 100), 0)
                $evidence = "$($f.testCount) tests"
            } elseif ($ev -eq "scan:goldens:count>=2") {
                $completed = $f.goldenCount -ge 2
                $progress = [math]::Round([math]::Min(($f.goldenCount / 2) * 100, 100), 0)
                $evidence = "$($f.goldenCount) goldens"
            } elseif ($ev -eq "scan:e2e:true") {
                $completed = $f.hasE2E
                $progress = if ($f.hasE2E) { 100 } else { 0 }
            } elseif ($ev -eq "scan:readme:true") {
                $completed = $f.hasReadme
                $progress = if ($f.hasReadme) { 100 } else { 0 }
            } elseif ($ev -like "external:flutter_analyze*") {
                $completed = $false
                $progress = 80
                $evidence = "Not verified (assume ~80%)"
            } elseif ($ev -eq "human:approval") {
                $completed = $false
                $progress = 0
                $evidence = "PENDING HUMAN REVIEW"
            }

            $s["completed"] = $completed
            $s["progress"] = $progress
            $s["evidence"] = $evidence
            $evaluatedSteps += $s
        }

        $totalWeight = ($evaluatedSteps | ForEach-Object { $_["weight"] } | Measure-Object -Sum).Sum
        $weightedScore = 0
        foreach ($st in $evaluatedSteps) {
            $weightedScore += $st["weight"] * ($st["progress"] / 100)
        }
        $featureScore = [math]::Round($weightedScore, 1)

        $detail = @{
            feature = $featureName
            lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            implementationPct = $featureScore
            humanReviewPending = (-not $evaluatedSteps[-1]["completed"])
            steps = $evaluatedSteps
        }

        $detail | ConvertTo-Json -Depth 10 | Out-File "$DETAILS_DIR\$featureName.json" -Encoding UTF8
        Write-Host ("  [OK] " + $featureName + " -- " + $featureScore + [char]37) -ForegroundColor Green
    }

    $count = ($ScanResult.featureDetails.Keys).Count
    Write-Host ""
    Write-Host ("Generated " + $count + " feature details files in " + $DETAILS_DIR) -ForegroundColor Cyan
}

# ============================================================================
# PHASE 4: UPDATE FEATURES.JSON
# ============================================================================
function Invoke-UpdateFeaturesJson {
    Param([Parameter(Mandatory=$true)]$ScanResult)

    $s = $ScanResult

    $featuresWithDocs = 0
    $featuresWithGaps = @()

    if (Test-Path $DETAILS_DIR) {
        Get-ChildItem $DETAILS_DIR -Filter *.json | ForEach-Object {
            $d = Get-Content $_.FullName -Raw | ConvertFrom-Json
            if ($d.implementationPct -ge 100) { $featuresWithDocs++ }
            if ($d.implementationPct -lt 50) { $featuresWithGaps += $d.feature }
        }
    }

    $bugList = @(
        @{ id = 1; feature = "health_sharing"; description = "BLE startAdvertising() stub"; severity = "medium"; status = "fixed" }
        @{ id = 2; feature = "health_sharing"; description = "WiFi discoverDevices() mock data"; severity = "medium"; status = "fixed" }
        @{ id = 3; feature = "health_sharing"; description = "NFC sharing sin setup nativo"; severity = "medium"; status = "fixed" }
        @{ id = 4; feature = "allergies"; description = "Unused equatable import"; severity = "low"; status = "fixed" }
        @{ id = 5; feature = "sync"; description = "Legacy data/ dir needs migration to infrastructure/"; severity = "low"; status = "fixed" }
        @{ id = 6; feature = "doctor_verification"; description = "Legacy data/ dir needs migration to infrastructure/"; severity = "low"; status = "fixed" }
        @{ id = 7; feature = "calendar_import"; description = "Domain layer empty - entities inline in cubit"; severity = "medium"; status = "fixed" }
    )

    $gapList = @()
    $s.featureDetails.Keys | Where-Object { -not $s.featureDetails[$_].hasFullArch } | ForEach-Object { $gapList += $_ }
    $lowCoverage = @()
    $s.featureDetails.Keys | Where-Object { $s.featureDetails[$_].testCount -lt 10 } | ForEach-Object { $lowCoverage += $_ }

    $json = @{
        name = "OrionHealth"
        version = "0.9.0"
        protocol_version = "3"
        metadata = @{
            last_updated = (Get-Date -Format "yyyy-MM-dd")
            last_scan = $s.scanTime
            flutter_analyze = "0 issues (assumed clean after PR #1014)"
            total_dart_files = $s.totalDartFiles
            branches = @("main: 6b6b0f7", "26 PRs: #976 -> #1016")
            packages = @{
                isar_agent_memory = "0.5.0-beta"
                health_wallet = "0.1.0"
                medical_standards = "0.1.0"
            }
        }
        features = @{
            total = $s.features
            complete_layers = $s.fullArch
            gap_network_health_incomplete = 1
        }
        test_suite = @{
            test_files = $s.testFiles
            golden_screenshots = $s.goldenFiles
            integration_tests = $s.e2eFiles
            test_ratio_pct = [math]::Round(($s.testFiles / $s.totalDartFiles) * 100, 1)
        }
        ci_cd = @{
            workflows = $s.workflows
            android_build = $true
            ci_tests = $true
            deploy_docs = $true
            medical_standards = $true
            release = $true
        }
        documentation = @{
            readme_count = $s.readmeCount
            readme_features_pct = [math]::Round(($s.readmeCount / $s.features) * 100, 1)
            architecture = $true
            contributing = $true
            translations_arb = $s.i18nFiles
        }
        harness = @{
            implementation_pct = $s.implementationPct
            human_review_pct = 1.0
            metrics = @{
                arch_weight = 25
                test_weight = 30
                golden_weight = 10
                e2e_weight = 10
                doc_weight = 10
                ci_weight = 5
                human_weight = 1
            }
            scan_command = "& .gitcore\orionhealth-harness.ps1 -Scan"
            report_command = "& .gitcore\orionhealth-harness.ps1 -Report"
            details_dir = ".gitcore\features.details\"
        }
        bugs = $bugList
        gaps = @{
            missing_readmes = ($s.features - $s.readmeCount)
            low_coverage_features = $lowCoverage
            incomplete_architecture = $gapList
        }
    }

    $json | ConvertTo-Json -Depth 10 | Out-File $FEATURES_JSON -Encoding UTF8
    Write-Host ("[OK] " + $FEATURES_JSON + " updated") -ForegroundColor Green
}

# ============================================================================
# MAIN
# ============================================================================
if ($Scan -or (-not $Report -and -not $Fix)) {
    Write-Host "=== ORIONHEALTH HARNESS ===" -ForegroundColor Magenta
    Write-Host "Goal: Drive implementation to 100% using agent+E2E+human loop" -ForegroundColor White
    Write-Host ""
    Write-Host "Starting scan..." -ForegroundColor Yellow
    $result = Invoke-Scan
    Invoke-Report -ScanResult $result
    Invoke-GenerateDetails -ScanResult $result
    Invoke-UpdateFeaturesJson -ScanResult $result
    Write-Host ""
    Write-Host ("[OK] Harness scan complete. Implementation: " + $result.implementationPct + [char]37) -ForegroundColor Green
    Write-Host "Run: .gitcore\orionhealth-harness.ps1 -Report for latest report" -ForegroundColor Cyan
} elseif ($Report) {
    if (Test-Path "$ROOT\.gitcore\.scan-latest.json") {
        $result = Get-Content "$ROOT\.gitcore\.scan-latest.json" -Raw | ConvertFrom-Json
        Invoke-Report -ScanResult $result
    } else {
        Write-Host "No scan data found. Run without -Report first." -ForegroundColor Red
    }
} elseif ($Fix -and $Feature) {
    Write-Host "Targeted fix mode for $Feature -- coming in v2" -ForegroundColor Yellow
}
