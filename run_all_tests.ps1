#!/usr/bin/env pwsh
# Script: run_all_tests.ps1
# Updates goldens first, then runs all tests, then coverage

$ErrorActionPreference = "Continue"
$projectRoot = "E:\scripts-python\orionhealth"

Write-Host "=== STEP 1: Update golden images ===" -ForegroundColor Yellow
Set-Location $projectRoot

# Find all golden test files
$goldenTests = @()
$dirs = @("about", "allergies", "calendar_import", "dashboard", "doctor_verification", 
          "email-citas", "eps_connection", "health_data_import", "health_record",
          "health_sharing", "home", "local_agent", "medical_research", "medications",
          "meditation", "network\governance", "network\incentives", "onboarding",
          "reports", "settings", "sync", "user_profile", "vitals", "voice_chat")

foreach ($dir in $dirs) {
    $tests = Get-ChildItem -Path "test\features\$dir" -Recurse -Filter "*golden*" -Name
    foreach ($t in $tests) {
        $goldenTests += "test\features\$dir\$t"
    }
}

Write-Host "Found $($goldenTests.Count) golden test files"
Write-Host "Updating goldens..."

# Run golden tests one by one to isolate issues
foreach ($test in $goldenTests) {
    $testName = Split-Path $test -Leaf
    Write-Host "  Updating golden: $testName" -ForegroundColor Cyan
    $result = flutter test --no-pub --update-goldens $test 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✅ $testName passed" -ForegroundColor Green
    } else {
        Write-Host "    ❌ $testName FAILED" -ForegroundColor Red
        Write-Host $result | Select-String "FAIL|ERROR" -Context 0,2
    }
}

Write-Host "`n=== STEP 2: Run ALL tests (no golden updates) ===" -ForegroundColor Yellow
$testResult = flutter test --no-pub --reporter expanded 2>&1 | Out-String

# Extract summary
$passed = [regex]::Match($testResult, '(\d+) \+(\d+)').Groups[2].Value
$failed = [regex]::Match($testResult, '(\d+) \-(\d+)').Groups[2].Value

Write-Host "Tests passed: $passed, failed: $failed" -ForegroundColor Green

# Show failures
$failures = $testResult | Select-String "FAILED|ERROR|Test failed" -Context 2,3
if ($failures) {
    Write-Host "FAILURES:" -ForegroundColor Red
    $failures
}

Write-Host "`n=== STEP 3: Run coverage ===" -ForegroundColor Yellow
$coverageResult = flutter test --no-pub --coverage 2>&1 | Out-String
$covPassed = [regex]::Match($coverageResult, '(\d+) \+(\d+)').Groups[2].Value
$covFailed = [regex]::Match($coverageResult, '(\d+) \-(\d+)').Groups[2].Value
Write-Host "Coverage tests passed: $covPassed, failed: $covFailed" -ForegroundColor Green

Write-Host "`n=== FINAL REPORT ===" -ForegroundColor Magenta
Write-Host "Goldens Updated: $($goldenTests.Count) files"
Write-Host "Overall Tests: $passed passed, $failed failed"
Write-Host "Coverage Tests: $covPassed passed, $covFailed failed"
