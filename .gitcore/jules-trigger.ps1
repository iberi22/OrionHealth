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
$details = $scan.featureDetails
$createdIssues = @()
$repo = "iberi22/OrionHealth"

Write-Host "=== JULES AUTO-TRIGGER ==="
Write-Host "Analyzing $($details.PSObject.Properties.Name.Count) features for gaps..."

# Priority 1: Architecture incomplete (highest impact)
$allProps = $details.PSObject.Properties
$incompleteFeat = $allProps | Where-Object { !$_.Value.hasFullArch }
foreach ($feat in $incompleteFeat) {
    $name = $feat.Name
    $data = $feat.Value
    $layersStr = $data.layers -join ', '
    $title = "[jules-harness] $name : complete architecture - missing application/presentation layers"
    $body = @"
Feature '$name' has $($data.layerCount)/4 layers (current: $layersStr).

Task: Add the missing layers (application and presentation) at:
lib/features/$name/

Steps:
1. Create application/ directory with BLoC/cubit + state classes
2. Create infrastructure/ directory with datasources + repository implementations
3. Create presentation/ directory with pages + widgets

Auto-detected by harness scan at $($scan.scanTime).
"@
    
    $issue = gh issue create --repo $repo --title "$title" --body "$body" --label "jules,enhancement" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $createdIssues += "$name (arch): $issue"
        Write-Host "  [JULES] $name -> Architecture issue created"
    }
    Start-Sleep -Seconds 1
}

# Priority 2: Golden tests
$allProps = $details.PSObject.Properties
$noGoldens = $allProps | Where-Object { $_.Value.goldenCount -eq 0 -and $_.Value.hasFullArch }
foreach ($feat in $noGoldens) {
    $name = $feat.Name
    $data = $feat.Value
    $title = "[jules-harness] $name : add golden tests"
    $body = @"
Feature '$name' has 0 golden tests.

Task: Create 2-4 golden test files for this feature in:
test/features/$name/presentation/golden/

Reference existing goldens in the golden test directories of other features.

Auto-detected by harness scan at $($scan.scanTime).
"@
    
    $issue = gh issue create --repo $repo --title "$title" --body "$body" --label "jules,enhancement" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $createdIssues += "$name (goldens): $issue"
        Write-Host "  [JULES] $name -> Golden tests issue created"
    }
    Start-Sleep -Seconds 1
}

# Priority 3: E2E tests missing
$allProps = $details.PSObject.Properties
$noE2E = $allProps | Where-Object { !$_.Value.hasE2E -and $_.Value.hasFullArch }
foreach ($feat in $noE2E) {
    $name = $feat.Name
    $title = "[jules-harness] $name : add e2e test"
    $body = @"
Feature '$name' has no E2E tests.

Task: Create an E2E test file for this feature.
Reference: integration_test/ directory for existing patterns.

Auto-detected by harness scan at $($scan.scanTime).
"@
    
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
