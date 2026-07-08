# real-scanner.ps1 â€” Real codebase analyzer for OrionHealth
param([string]$RepoPath = "E:\scripts-python\OrionHealth")
Set-Location $RepoPath

Write-Host "=== OrionHealth REAL Codebase Scanner ==="
Write-Host ""

# Get features from lib/features/ folders
$featureDirs = Get-ChildItem "lib/features" -Directory -ErrorAction SilentlyContinue
$featureNames = $featureDirs | ForEach-Object { $_.Name }
$totalFeatures = ($featureNames | Measure-Object).Count
Write-Host "Found $totalFeatures feature folders"
Write-Host ""

# Track all results
$results = @()

foreach ($name in $featureNames) {
    $base = "lib/features/$name"
    
    # 1. LAYERS
    $domainDir = Get-ChildItem "$base/domain" -Recurse -Filter *.dart -ErrorAction SilentlyContinue
    $appDir = Get-ChildItem "$base/application" -Recurse -Filter *.dart -ErrorAction SilentlyContinue
    $infraDir = Get-ChildItem "$base/infrastructure" -Recurse -Filter *.dart -ErrorAction SilentlyContinue
    $presDir = Get-ChildItem "$base/presentation" -Recurse -Filter *.dart -ErrorAction SilentlyContinue
    
    # Also check sub-features (network/governance, network/incentives, network/network_health)
    $subDirs = Get-ChildItem "$base" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin @('domain','application','infrastructure','presentation') }
    foreach ($sub in $subDirs) {
        $sb = "$base/$($sub.Name)"
        $d = Get-ChildItem "$sb/domain" -Recurse -Filter *.dart -ErrorAction SilentlyContinue
        if ($d) { $domainDir += $d }
        $a = Get-ChildItem "$sb/application" -Recurse -Filter *.dart -ErrorAction SilentlyContinue
        if ($a) { $appDir += $a }
        $i = Get-ChildItem "$sb/infrastructure" -Recurse -Filter *.dart -ErrorAction SilentlyContinue
        if ($i) { $infraDir += $i }
        $p = Get-ChildItem "$sb/presentation" -Recurse -Filter *.dart -ErrorAction SilentlyContinue
        if ($p) { $presDir += $p }
    }
    
    $hasDomain = ($domainDir.Count -gt 0)
    $hasApp = ($appDir.Count -gt 0)
    $hasInfra = ($infraDir.Count -gt 0)
    $hasPres = ($presDir.Count -gt 0)
    
    # Goldens: check golden files in presentation
    $goldenFiles = Get-ChildItem "test/features/$name/presentation/golden" -Recurse -Filter "*golden*" -ErrorAction SilentlyContinue; if ($goldenFiles.Count -eq 0) { $goldenFiles = $presDir | Where-Object { $_.Name -match "golden" } }
    $hasGolden = ($goldenFiles.Count -gt 0)
    
    $layerCount = 0
    foreach ($l in @($hasDomain,$hasApp,$hasInfra,$hasPres,$hasGolden)) { if ($l) { $layerCount++ } }
    $layerPct = [math]::Round(($layerCount/5)*100, 0)
    
    # 2. TESTS
    $safeName = $name -replace '-', '_' -replace '\s', '_'
    $allTests = Get-ChildItem "test" -Recurse -Filter *_test.dart -ErrorAction SilentlyContinue
    
    $featTests = $allTests | Where-Object { $_.FullName -match "test[\\/]features[\\/]$name" -or $_.FullName -match "test[\\/]$name" -or $_.FullName -match "test[\\/]features[\\/]$safeName" -or $_.FullName -match "test[\\/]$safeName" }
    $unitCount = ($featTests | Measure-Object).Count
    $widgetTests = $featTests | Where-Object { $_.FullName -match "presentation" -or $_.FullName -match "widget" }
    $widgetCount = ($widgetTests | Measure-Object).Count
    $domainTests = $featTests | Where-Object { $_.FullName -match "domain" -and $_.FullName -notmatch "presentation" }
    $domainTestCount = ($domainTests | Measure-Object).Count
    $infraTests = $featTests | Where-Object { $_.FullName -match "infrastructure" }
    $infraTestCount = ($infraTests | Measure-Object).Count
    $goldenTestFiles = Get-ChildItem "test" -Recurse -Filter "*$name*golden*" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "golden" }
    $goldenTestCount = ($goldenTestFiles | Measure-Object).Count
    
    # Integration tests
    $intTests = Get-ChildItem "integration_test","test/integration" -Recurse -Filter { $_.Name -match $safeName } -ErrorAction SilentlyContinue
    $intCount = ($intTests | Measure-Object).Count
    # Also check integration_test files containing feature keyword
    if ($intCount -eq 0) {
        $featSlug = $name -replace '-', '_' -replace '\s', '_'
        $intAll = Get-ChildItem "integration_test","test/integration" -Recurse -Filter *_test.dart -ErrorAction SilentlyContinue
    $intTests = $intAll | Where-Object { $_.Name -match $featSlug -or $_.FullName -match $name }
        $intCount = ($intTests | Measure-Object).Count
    }
    
    $totalTests = $unitCount + $widgetCount + $intCount + $goldenTestCount
    
    # 3. SCORE CALCULATION
    # Layers 45%, Tests 35%, Docs 10%, Variety 10%
    $layerScore = $layerPct * 0.45
    
    # Test volume score (max 25)
    $testVolumeScore = 0
    if ($totalTests -ge 10) { $testVolumeScore = 25 }
    elseif ($totalTests -ge 5) { $testVolumeScore = 20 }
    elseif ($totalTests -ge 3) { $testVolumeScore = 15 }
    elseif ($totalTests -ge 1) { $testVolumeScore = 8 }
    
    # Test variety (max 10)
    $hasDomainTest = ($domainTestCount -gt 0)
    $hasWidgetTest = ($widgetCount -gt 0)
    $hasInfraTest = ($infraTestCount -gt 0)
    $hasIntTest = ($intCount -gt 0)
    $varietyCount = 0
    foreach ($h in @($hasDomainTest,$hasWidgetTest,$hasInfraTest,$hasIntTest)) { if ($h) { $varietyCount++ } }
    $varietyScore = $varietyCount * 2.5
    
    $testScoreFinal = [Math]::Min($testVolumeScore + $varietyScore, 35)
    
    # Base docs score (10%)
    $docsScore = 5  # base
    if (Test-Path "README.md") { $docsScore += 5 }
    
    $finalScore = [Math]::Round($layerScore + $testScoreFinal + $docsScore, 1)
    
    $results += @{
        name = $name
        layerCount = $layerCount
        hasDomain = $hasDomain
        hasApp = $hasApp
        hasInfra = $hasInfra
        hasPres = $hasPres
        hasGolden = $hasGolden
        domainTests = $domainTestCount
        widgetTests = $widgetCount
        infraTests = $infraTestCount
        integrationTests = $intCount
        goldenTests = $goldenTestCount
        totalTests = $totalTests
        score = $finalScore
    }
}

# Overall score
$overallScore = [math]::Round(($results | ForEach-Object { $_.score } | Measure-Object -Average).Average, 1)
$okCount = ($results | Where-Object {$_.score -ge 90}).Count
$partialCount = ($results | Where-Object {$_.score -ge 50 -and $_.score -lt 90}).Count
$lowCount = ($results | Where-Object {$_.score -lt 50}).Count

Write-Host "======================================"
Write-Host "OVERALL REAL SCORE: $overallScore%"
Write-Host "Features >=90%: $okCount/$totalFeatures"
Write-Host "Features 50-89%: $partialCount/$totalFeatures"
Write-Host "Features <50%: $lowCount/$totalFeatures"
Write-Host "======================================"
Write-Host ""

$results | Sort-Object score -Descending | ForEach-Object { Write-Host ("$($_.name.PadRight(25)) Score:$($_.score.ToString().PadLeft(6))%  L:$($_.layerCount)   UT:$($_.domainTests.ToString().PadLeft(3))  WT:$($_.widgetTests.ToString().PadLeft(3))  InfT:$($_.infraTests.ToString().PadLeft(3))  IntT:$($_.integrationTests.ToString().PadLeft(3))  GT:$($_.goldenTests.ToString().PadLeft(3))  TotT:$($_.totalTests.ToString().PadLeft(3))") }

Write-Host ""
Write-Host "=== WEAKEST FEATURES ==="
$results | Sort-Object score | Select-Object -First 3 | ForEach-Object { Write-Host "  $($_.name.PadRight(25)) score=$($_.score)% layers=$($_.layerCount)/5 tests=$($_.totalTests)" }

# Save
$report = @{
    timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    overallScore = $overallScore
    totalFeatures = $totalFeatures
    okCount = $okCount
    partialCount = $partialCount
    lowCount = $lowCount
    features = $results | Sort-Object score -Descending
}
$report | ConvertTo-Json -Depth 3 | Out-File -Encoding utf8 -FilePath ".xavier/real-score.json"
Write-Host ""
Write-Host "Saved to .xavier/real-score.json"


