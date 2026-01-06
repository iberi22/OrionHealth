# Pre-push check script for OrionHealth (PowerShell version)
# Runs all tests and checks before pushing to ensure CI will pass

$ErrorActionPreference = "Continue"

Write-Host "🚀 OrionHealth Pre-Push Check" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

$Failed = $false

function Print-Status {
    param(
        [bool]$Success,
        [string]$Message
    )

    if ($Success) {
        Write-Host "✅ $Message" -ForegroundColor Green
    } else {
        Write-Host "❌ $Message" -ForegroundColor Red
        $script:Failed = $true
    }
}

# 1. Flutter Analyze
Write-Host "📊 Running Flutter analyze..." -ForegroundColor Yellow
$analyzeResult = flutter analyze
if ($LASTEXITCODE -eq 0) {
    Print-Status $true "Flutter analyze"
} else {
    Print-Status $false "Flutter analyze"
}
Write-Host ""

# 2. Rust Format Check
Write-Host "🦀 Checking Rust format..." -ForegroundColor Yellow
Push-Location rust
$formatResult = cargo fmt --all -- --check
$formatSuccess = $LASTEXITCODE -eq 0
Pop-Location
if ($formatSuccess) {
    Print-Status $true "Rust format"
} else {
    Print-Status $false "Rust format (run: cargo fmt)"
}
Write-Host ""

# 3. Rust Clippy
Write-Host "🔬 Running Rust clippy..." -ForegroundColor Yellow
Push-Location rust
$clippyResult = cargo clippy --all-targets --all-features -- -D warnings
$clippySuccess = $LASTEXITCODE -eq 0
Pop-Location
if ($clippySuccess) {
    Print-Status $true "Rust clippy"
} else {
    Print-Status $false "Rust clippy"
}
Write-Host ""

# 4. Rust Tests
Write-Host "🧪 Running Rust tests..." -ForegroundColor Yellow
Push-Location rust
$rustTestResult = cargo test --all-features
$rustTestSuccess = $LASTEXITCODE -eq 0
Pop-Location
if ($rustTestSuccess) {
    Print-Status $true "Rust tests"
} else {
    Print-Status $false "Rust tests"
}
Write-Host ""

# 5. Flutter-Rust Bridge Sync Check
Write-Host "🌉 Checking flutter_rust_bridge sync..." -ForegroundColor Yellow
$bridgeCmd = Get-Command flutter_rust_bridge_codegen -ErrorAction SilentlyContinue
if ($bridgeCmd) {
    flutter_rust_bridge_codegen generate 2>&1 | Out-Null

    $diff = git diff --quiet lib/src/rust/
    if ($LASTEXITCODE -eq 0) {
        Print-Status $true "Bridge sync"
    } else {
        Print-Status $false "Bridge out of sync (run: flutter_rust_bridge_codegen generate)"
        Write-Host "ℹ️  Run: flutter_rust_bridge_codegen generate" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  flutter_rust_bridge_codegen not installed, skipping bridge check" -ForegroundColor Yellow
}
Write-Host ""

# 6. Flutter Tests
Write-Host "🧪 Running Flutter tests..." -ForegroundColor Yellow
$flutterTestResult = flutter test
if ($LASTEXITCODE -eq 0) {
    Print-Status $true "Flutter tests"
} else {
    Print-Status $false "Flutter tests"
}
Write-Host ""

# 7. Integration Tests (if exist)
if ((Test-Path "integration_test") -and (Get-ChildItem "integration_test\*.dart" -ErrorAction SilentlyContinue)) {
    Write-Host "🔗 Running integration tests..." -ForegroundColor Yellow
    $integrationTestResult = flutter test integration_test/
    if ($LASTEXITCODE -eq 0) {
        Print-Status $true "Integration tests"
    } else {
        Print-Status $false "Integration tests"
    }
    Write-Host ""
}

# Summary
Write-Host "==============================" -ForegroundColor Cyan
if (-not $Failed) {
    Write-Host "✅ All checks passed! Safe to push." -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Some checks failed. Fix issues before pushing." -ForegroundColor Red
    exit 1
}
