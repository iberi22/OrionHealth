# read-score.ps1
param($RepoPath = "E:\scripts-python\OrionHealth")

$j = Get-Content (Join-Path $RepoPath .xavier/real-score.json) -Raw | ConvertFrom-Json
$overall = $j.overallScore
$ok = $j.okCount
$total = $j.totalFeatures
$w = $j.features | Where-Object { $_.score -lt 100 }

Write-Host ("SCORE: " + $overall + "% (OK=" + $ok + "/" + $total + ")")
if ($w -and $w.Count -gt 0) {
    $w | ForEach-Object { Write-Host ("  " + $_.name + ": " + $_.score + "%") }
} else {
    Write-Host "ALL FEATURES AT 100%"
}
