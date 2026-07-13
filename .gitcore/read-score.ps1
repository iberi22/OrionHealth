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
