#!/usr/bin/env pwsh
# OrionHealth ADB Smoke Test
param(
  [string]$deviceId = "",
  [int]$waitSeconds = 30
)
$ErrorActionPreference = "Stop"
$serial = if ($deviceId) { "-s $deviceId" } else { "" }
function Write-Step($s) { Write-Host "`n==> $s" -ForegroundColor Cyan }
function Write-Pass($s) { Write-Host "  [PASS] $s" -ForegroundColor Green }
function Write-Fail($s) { Write-Host "  [FAIL] $s" -ForegroundColor Red; exit 1 }

Write-Host "==============================" -ForegroundColor Cyan
Write-Host " OrionHealth ADB Smoke Test" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

Write-Step "Checking ADB device..."
$devices = adb devices | Select-String -Pattern "device$"
if (-not $devices) { Write-Fail "No ADB device found" }
Write-Pass "Device connected"

Write-Step "Checking app installation..."
$installed = adb $serial shell pm list packages com.orionhealth.orionhealth_health
if (-not $installed) { Write-Fail "App not installed. Install APK first." }
Write-Pass "App installed"

Write-Step "Clearing logcat..."
adb $serial shell logcat -c
Write-Pass "Logcat cleared"

Write-Step "Launching app..."
adb $serial shell am start -n com.orionhealth.orionhealth_health/.MainActivity
Write-Pass "App launched"

Write-Step "Waiting $waitSeconds seconds for initialization..."
$i = 0
while ($i -lt $waitSeconds) {
  Write-Host "  ... $($waitSeconds - $i)s remaining" -NoNewline
  Start-Sleep 5
  $i += 5
  $pid = adb $serial shell pidof com.orionhealth.orionhealth_health 2>$null
  if (-not $pid) { Write-Host ""; Write-Fail "App process died during init" }
  Write-Host " (pid: $pid)"
}
Write-Pass "Initialization time elapsed"

Write-Step "Checking for initialization errors..."
$appPid = adb $serial shell pidof com.orionhealth.orionhealth_health 2>$null
if (-not $appPid) { Write-Fail "App not running" }
$errorLog = adb $serial shell logcat -d --pid=$appPid 2>$null | Select-String -Pattern "ORIONHEALTH_INIT_ERROR|FlutterError|Unhandled Exception" | Select-Object -First 5
if ($errorLog) {
  Write-Host "`n--- ERROR LOG ---" -ForegroundColor Red
  $errorLog | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
  Write-Fail "Initialization error detected!"
} else {
  Write-Pass "No initialization errors found"
}

Write-Host "`n==============================" -ForegroundColor Green
Write-Host " SMOKE TEST PASSED" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
exit 0
