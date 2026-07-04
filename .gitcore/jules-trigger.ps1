# Jules Auto-Trigger Script
# This script runs alongside the harness scan to delegate heavy gaps to Jules

param(
    [switch]$Trigger = $true
)

$scanPath = ".gitcore\.scan-latest.json"
if (!(Test-Path $scanPath)) {
    Write-Host "[JULES] No scan data found. Run harness scan first."
    exit 1
}

$scan = Get-Content $scanPath | ConvertFrom-Json
$details = $scan.featureDetails.PSObject.Properties
$createdIssues = @()
$repo = "iberi22/OrionHealth"

Write-Host "=== JULES AUTO-TRIGGER ==="
Write-Host "Analyzing $($details.Count) features for gaps..."

foreach ($feat in $details) {
    $name = $feat.Name
    $data = $feat.Value

    # Priority 1: Golden tests (highest impact)
    if ($data.goldenCount -eq 0 -and $data.hasFullArch) {
        $title = "[jules-harness] $name : add golden tests"
        $body = "Feature `$name` has 0 golden tests.`n`nTask: Create 2-4 golden test files in the golden test directory for this feature.`n`nReference existing goldens in: test/goldens/`n`nAuto-detected by harness scan at $($scan.scanTime)."
        
        $issue = gh issue create --repo $repo --title "$title" --body "$body" --label "jules,enhancement" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $createdIssues += "$name (goldens): $issue"
            Write-Host "  [JULES] $name -> Golden tests issue created"
        }
        Start-Sleep -Seconds 1  # rate limit
    }

    # Priority 2: Tests coverage < 15
    if ($data.testCount -lt 15 -and $data.hasFullArch) {
        $title = "[jules-harness] $name : increase test coverage to 20+"
        $body = "Feature `$name` has only $($data.testCount) tests.`n`nTask: Add unit tests to reach at least 20 test files.`n`nExisting tests located in: test/features/$name/`n`nAuto-detected by harness scan at $($scan.scanTime)."
        
        $issue = gh issue create --repo $repo --title "$title" --body "$body" --label "jules,enhancement" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $createdIssues += "$name (tests): $issue"
            Write-Host "  [JULES] $name -> Test coverage issue created"
        }
        Start-Sleep -Seconds 1
    }
}

# Priority 3: Architecture incomplete
$incompleteFeat = $details | Where-Object { !$_.Value.hasFullArch }
foreach ($feat in $incompleteFeat) {
    $name = $feat.Name
    $data = $feat.Value
    $title = "[jules-harness] $name : complete architecture — missing application/presentation layers"
    $body = "Feature `$name` has $($data.layerCount)/4 layers (current: $($data.layers -join ', ')).`n`nTask: Add the missing layers (application and presentation).`n`nReference: lib/features/$name/`n`nAuto-detected by harness scan at $($scan.scanTime)."
    
    $issue = gh issue create --repo $repo --title "$title" --body "$body" --label "jules,enhancement" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $createdIssues += "$name (arch): $issue"
        Write-Host "  [JULES] $name -> Architecture issue created"
    }
    Start-Sleep -Seconds 1
}

# Priority 4: E2E tests missing
$noE2E = $details | Where-Object { !$_.Value.hasE2E -and $_.Value.hasFullArch }
foreach ($feat in $noE2E) {
    $name = $feat.Name
    $title = "[jules-harness] $name : add e2e test"
    $body = "Feature `$name` has no E2E tests.`n`nTask: Create an E2E test file for this feature using Playwright.`n`nReference: e2e/ directory for existing patterns.`n`nAuto-detected by harness scan at $($scan.scanTime)."
    
    $issue = gh issue create --repo $repo --title "$title" --body "$body" --label "jules,enhancement" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $createdIssues += "$name (e2e): $issue"
        Write-Host "  [JULES] $name -> E2E test issue created"
    }
    Start-Sleep -Seconds 1
}

Write-Host "=== JULES SUMMARY ==="
Write-Host "Created $($createdIssues.Count) issues for Jules."
if ($createdIssues.Count -gt 0) {
    $createdIssues | ForEach-Object { Write-Host "  $_" }
}
Write-Host "Done."
