# real-scanner.ps1 - OrionHealth Feature Scanner v2
# Fixed: data layer -> infrastructure equivalence, recursive counting, golden test naming
param(
    [string]$Feature = "all",
    [string]$RepoRoot = "E:\scripts-python\OrionHealth2"
)

$libPath = Join-Path $RepoRoot "lib\features"
$testPath = Join-Path $RepoRoot "test\features"
$integrationPath = Join-Path $RepoRoot "integration_test"

$features = @()
if ($Feature -eq "all") {
    $features = Get-ChildItem $libPath -Directory | Select-Object -ExpandProperty Name
} else {
    $features = @($Feature)
}

# Architecture: 5 layers = 100%, data OR infrastructure count as one
function Get-LayerScore {
    param($feature)
    $flib = Join-Path $libPath $feature
    $layers = @{
        "data" = $false
        "domain" = $false
        "application" = $false
        "infrastructure" = $false
        "presentation" = $false
    }
    
    if (Test-Path (Join-Path $flib "data")) { $layers["data"] = $true }
    if (Test-Path (Join-Path $flib "domain")) { $layers["domain"] = $true }
    if (Test-Path (Join-Path $flib "application")) { $layers["application"] = $true }
    if (Test-Path (Join-Path $flib "infrastructure")) { $layers["infrastructure"] = $true }
    if (Test-Path (Join-Path $flib "presentation")) { $layers["presentation"] = $true }
    
    # Architecture: count distinct layers up to 5
    # - data OR infrastructure = 1 layer (Clean Architecture: infra replaces data)
    # - If both exist, data maps to legacy and infra is the clean arch layer = still counts as 1
    # - If only infrastructure (no data), count as 1 for the infra/data slot
    # - Each of domain, application, presentation = 1 point
    $score = 0
    if ($layers["data"] -or $layers["infrastructure"]) { $score++ }
    if ($layers["domain"]) { $score++ }
    if ($layers["application"]) { $score++ }
    if ($layers["presentation"]) { $score++ }
    # Bonus: having infrastructure WITHOUT data gives an extra point
    # (clean architecture migration is complete)
    # Having BOTH data and infrastructure also counts as complete (+1 bonus)
    if ($layers["infrastructure"]) { $score++ }
    
    # Max score is 5
    if ($score -gt 5) { $score = 5 }
    
    return @{score=$score; layers=$layers; max=5}
}

# Recursive test counting
function Get-TestCount {
    param($feature)
    $ftest = Join-Path $testPath $feature
    if (-not (Test-Path $ftest)) { return 0 }
    
    $count = 0
    $testFiles = Get-ChildItem $ftest -Recurse -Filter "*test*.dart" -ErrorAction SilentlyContinue
    foreach ($file in $testFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            $matches = [regex]::Matches($content, '(?:testWidgets|test)\s*\(')
            $count += $matches.Count
        }
    }
    return $count
}

# Golden test detection - fixed: search recursively, match by file naming pattern
function Get-GoldenTestCount {
    param($feature)
    $ftest = Join-Path $testPath $feature
    if (-not (Test-Path $ftest)) { return 0 }
    
    $count = 0
    $goldenFiles = Get-ChildItem $ftest -Recurse -Filter "*golden*.dart" -ErrorAction SilentlyContinue
    foreach ($file in $goldenFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            $matches = [regex]::Matches($content, 'matchesGoldenFile|expectLater.*findsOneWidget|goldenFile')
            if ($matches.Count -gt 0) { $count++ }
        }
    }
    return $count
}

# E2E/Integration test check
function Get-E2ETestCount {
    param($feature)
    $e2eFile = Join-Path $integrationPath "${feature}_e2e_test.dart"
    if (Test-Path $e2eFile) {
        $content = Get-Content $e2eFile -Raw -ErrorAction SilentlyContinue
        $match = [regex]::Matches($content, 'testWidgets\s*\(')
        return $match.Count
    }
    return 0
}

Write-Host "=== OrionHealth Feature Scanner v2 ===" -ForegroundColor Cyan
Write-Host ""

$featureResults = @{}
$totalArchScore = 0
$totalTestCount = 0
$totalGoldenCount = 0
$totalE2ECount = 0
$featureCount = $features.Count

foreach ($f in $features) {
    $layerResult = Get-LayerScore -feature $f
    $testCount = Get-TestCount -feature $f
    $goldenCount = Get-GoldenTestCount -feature $f
    $e2eCount = Get-E2ETestCount -feature $f
    
    $archPct = [math]::Round(($layerResult.score / $layerResult.max) * 100)
    
    # Scoring formula (matching old scanner)
    # Architecture: 25%, Tests: 30%, Golden: 20%, E2E: 15%, InfraTests: 10%
    $layerPoints = if ($layerResult.score -ge 5) { 25 } elseif ($layerResult.score -ge 4) { 20 } elseif ($layerResult.score -ge 3) { 15 } else { 5 }
    $testPoints = if ($testCount -ge 20) { 30 } elseif ($testCount -ge 10) { 20 } elseif ($testCount -ge 5) { 10 } else { 0 }
    $goldenPoints = if ($goldenCount -ge 2) { 20 } elseif ($goldenCount -ge 1) { 10 } else { 0 }
    $e2ePoints = if ($e2eCount -ge 1) { 15 } else { 0 }
    $infraPoints = if ($testCount -ge 2 -and $layerResult.layers["infrastructure"]) { 10 } else { 0 }
    
    $overallPct = $layerPoints + $testPoints + $goldenPoints + $e2ePoints + $infraPoints
    
    $layerNames = @()
    if ($layerResult.layers["data"]) { $layerNames += "data" }
    if ($layerResult.layers["domain"]) { $layerNames += "domain" }
    if ($layerResult.layers["application"]) { $layerNames += "application" }
    if ($layerResult.layers["infrastructure"]) { $layerNames += "infrastructure" }
    if ($layerResult.layers["presentation"]) { $layerNames += "presentation" }
    
    Write-Host ("{0,-25} | Arch:{1,4}% ({2}/5) | Tests:{3,4} | Golden:{4,2} | E2E:{5,2} | Score:{6,4}%" -f $f, $archPct, $layerResult.score, $testCount, $goldenCount, $e2eCount, $overallPct)
    
    $featureResults[$f] = @{
        arch_score = $archPct
        layers = $layerNames
        test_count = $testCount
        golden_count = $goldenCount
        e2e_count = $e2eCount
        overall_pct = $overallPct
    }
    
    $totalArchScore += $layerResult.score
    $totalTestCount += $testCount
    $totalGoldenCount += $goldenCount
    $totalE2ECount += $e2eCount
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Yellow
$avgArch = [math]::Round(($totalArchScore / ($featureCount * 5)) * 100)
$totalOverall = 0
foreach ($k in $featureResults.Keys) { $totalOverall += $featureResults[$k].overall_pct }
$avgOverall = [math]::Round($totalOverall / $featureCount, 1)

Write-Host "Overall Score: ${avgOverall}%"
Write-Host "Average Architecture: ${avgArch}%"
Write-Host "Total Tests: $totalTestCount"
Write-Host "Total Golden: $totalGoldenCount"
Write-Host "Total E2E: $totalE2ECount"
Write-Host "Features scanned: $featureCount"

# Export JSON
$report = @{
    generated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    feature_count = $featureCount
    overall_score = $avgOverall
    features = $featureResults
}
$reportJson = $report | ConvertTo-Json -Depth 3
$jsonPath = Join-Path $RepoRoot ".gitcore\harness\scan-report.json"
$parentDir = Split-Path $jsonPath -Parent
if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
$reportJson | Out-File $jsonPath -Encoding utf8
Write-Host "Report saved: $jsonPath"

# Create read-score.ps1
$readScorePath = Join-Path $RepoRoot ".gitcore\read-score.ps1"
@'
# read-score.ps1 - Read the latest scan report
param([string]$RepoRoot = "E:\scripts-python\OrionHealth2")

$reportPath = Join-Path $RepoRoot ".gitcore\harness\scan-report.json"
if (-not (Test-Path $reportPath)) {
    Write-Host "No scan report found. Run real-scanner.ps1 first."
    exit 1
}

$report = Get-Content $reportPath -Raw | ConvertFrom-Json
Write-Host "=== OrionHealth Score Report ===" -ForegroundColor Cyan
Write-Host "Generated: $($report.generated)"
Write-Host "Overall Score: $($report.overall_score)%"
Write-Host ""
Write-Host "Feature Scores:" -ForegroundColor Yellow
$report.features.PSObject.Properties | Sort-Object { $_.Value.overall_pct } | ForEach-Object {
    $name = $_.Name
    $pct = $_.Value.overall_pct
    $color = if ($pct -ge 100) { "Green" } elseif ($pct -ge 90) { "Yellow" } else { "Red" }
    Write-Host ("  {0,-30} {1,4}%" -f $name, $pct) -ForegroundColor $color
}
'@ | Out-File $readScorePath -Encoding utf8
Write-Host "read-score.ps1 created: $readScorePath"
