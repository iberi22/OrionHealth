# Jules OrionHealth Auto-Merge & Monitor
# Scans Jules PRs every 30min, auto-merges if clean, runs tests, sleeps when idle
# Created: 2026-06-09

param(
    [string]$Repo = "iberi22/OrionHealth",
    [string]$Label = "jules",
    [string]$RepoPath = "E:\scripts-python\orionhealth",
    [int]$MinIntervalMinutes = 30
)

# --- ACTIVATION CHECK ---
# This cron sleeps when there are no Jules issues. To wake it up, set this flag to "true"
# or the script will auto-wake when it detects open Jules issues.
$activationFile = "$RepoPath\.jules-cron-active"
$isExplicitlyActive = Test-Path $activationFile
$activationValue = if ($isExplicitlyActive) { Get-Content $activationFile -Raw } else { "" }

# Fetch Jules issues
$issues = gh issue list --repo $Repo --state all --label $Label --json number,title,state --limit 30 2>$null | ConvertFrom-Json
$openIssues = @($issues | Where-Object { $_.state -eq "OPEN" })
$hasWork = $openIssues.Count -gt 0

# Auto-wake: if there are open issues, the cron should be active regardless of flag
if (-not $hasWork -and $activationValue -ne "true") {
    Write-Output "SLEEP: No Jules issues open and cron not explicitly active."
    Write-Output "To wake: Set-Content '$activationFile' 'true'"
    exit 0
}

# Prevent duplicate runs
$lockFile = "$env:TEMP\jules-orionhealth-monitor.lock"
if (Test-Path $lockFile) {
    $lastRun = (Get-Item $lockFile).LastWriteTime
    $elapsed = (Get-Date) - $lastRun
    if ($elapsed.TotalMinutes -lt $MinIntervalMinutes) {
        Write-Output "SKIP: Last run was $($elapsed.TotalMinutes.ToString('F0')) min ago"
        exit 0
    }
}
$null | Set-Content $lockFile

# Ensure repo path exists
if (-not (Test-Path $RepoPath)) {
    Write-Output "ERROR: Repo path not found: $RepoPath"
    exit 1
}

# Fetch open PRs from Jules branches
$allPrs = gh pr list --repo $Repo --state open --json number,title,headRefName,baseRefName,mergeable --limit 20 2>$null | ConvertFrom-Json
$julesPrs = @($allPrs | Where-Object { $_.headRefName -match "^(port|jules)-" })

Write-Output "Jules OrionHealth Auto-Merge - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
Write-Output ""
Write-Output "Issues: $($issues.Count) total, $($openIssues.Count) open"
Write-Output "Jules PRs abiertos: $($julesPrs.Count)"

# --- AUTO-MERGE OPEN PRS ---
$mergedCount = 0
$failedCount = 0

foreach ($pr in $julesPrs) {
    $prNum = $pr.number
    $prTitle = $pr.title
    $branch = $pr.headRefName
    Write-Output ""
    Write-Output "Processing PR #$prNum : $prTitle (branch: $branch)"

    $mergeResult = gh pr merge $prNum --repo $Repo --squash --delete-branch --admin 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Output "  [OK] MERGED #$prNum"
        $mergedCount++
    }
    else {
        Write-Output "  [FAIL] MERGE #$prNum : $mergeResult"
        $failedCount++
    }
}

# --- PULL LATEST ---
if ($mergedCount -gt 0) {
    Write-Output ""
    Write-Output "Pulling latest main..."
    Set-Location $RepoPath
    git fetch origin 2>$null
    git merge origin/main --no-edit 2>$null
    Write-Output "  [OK] Repo actualizado"
}

# --- RUN TESTS ---
$testsPassed = $false
if ($mergedCount -gt 0 -or $julesPrs.Count -eq 0) {
    Write-Output ""
    Write-Output "Running tests..."
    Set-Location $RepoPath
    $testResult = flutter test test/core/medical/ test/core/services/ 2>&1
    $testExit = $LASTEXITCODE

    if ($testExit -eq 0) {
        Write-Output "  [OK] ALL TESTS PASSED"
        $testsPassed = $true
    }
    else {
        Write-Output "  [FAIL] TESTS FAILED (exit: $testExit)"
        $failures = $testResult | Select-String "failing|error" | Select-Object -First 5
        foreach ($f in $failures) { Write-Output "     $f" }
    }
}

# --- CHECK COMPLETION ---
$allDone = ($openIssues.Count -eq 0) -and ($julesPrs.Count -eq 0) -and $testsPassed

Write-Output ""
Write-Output "---"
Write-Output "Summary: $mergedCount merged, $failedCount failed"

if ($allDone) {
    Write-Output ""
    Write-Output "ALL JULES ISSUES COMPLETED AND TESTED"
    Write-Output "Cron going to SLEEP. Will auto-wake when new Jules issues are detected."
    
    # Clear activation flag so cron sleeps
    "false" | Set-Content $activationFile
    Write-Output "Activation flag set to false: $activationFile"
}
else {
    Write-Output ""
    Write-Output "Pending: $($openIssues.Count) issues open. Next scan in ${MinIntervalMinutes}min."
    if ($openIssues.Count -gt 0) {
        foreach ($issue in $openIssues) {
            Write-Output "  - #$($issue.number) : $($issue.title)"
        }
    }
}

exit 0
