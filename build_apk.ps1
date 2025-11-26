# OrionHealth APK Build Script
# Workaround for isar_flutter_libs resource verification issue with Material 3 attributes
# and Kotlin daemon cross-drive path issues (C: pub cache vs E: project)

Write-Host "🚀 Building OrionHealth APK Release..." -ForegroundColor Cyan
Write-Host "Workarounds applied:" -ForegroundColor Yellow
Write-Host "  - isar_flutter_libs Material 3 attribute conflict" -ForegroundColor Yellow
Write-Host "  - Kotlin daemon cross-drive path issues" -ForegroundColor Yellow
Write-Host "  - integration_test plugin in release builds" -ForegroundColor Yellow
Write-Host ""

# Step 1: Set PUB_CACHE on same drive as project to avoid Kotlin path issues
$projectDrive = (Get-Location).Path.Substring(0,1)
$env:PUB_CACHE = "${projectDrive}:\pub-cache"
Write-Host "Step 1: Setting PUB_CACHE to $env:PUB_CACHE (same drive as project)..." -ForegroundColor Green

# Step 2: Kill any existing Kotlin/Java processes and clean
Write-Host "Step 2: Cleaning previous builds and stopping Kotlin daemons..." -ForegroundColor Green
Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force build, .dart_tool, android/app/build, "android\.gradle" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:USERPROFILE\AppData\Local\kotlin" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 3: Get dependencies (using local PUB_CACHE)
Write-Host "Step 3: Getting dependencies..." -ForegroundColor Green
& flutter pub get

# Step 4: Build runner (code generation)  
Write-Host "Step 4: Running build_runner for DI code generation..." -ForegroundColor Green
& dart run build_runner build --delete-conflicting-outputs

# Step 5: Build APK using gradle directly with --no-daemon and task exclusions
Write-Host "Step 5: Compiling APK (using --no-daemon with task exclusions)..." -ForegroundColor Green
Push-Location android
& ./gradlew.bat :app:assembleRelease -x verifyReleaseResources -x lintVitalAnalyzeRelease --no-daemon
$buildSuccess = $?
Pop-Location

if ($buildSuccess) {
    $apkPath = "build/app/outputs/apk/release/app-release.apk"
    $file = Get-Item $apkPath -ErrorAction SilentlyContinue
    if ($file) {
        $sizeMB = [math]::Round($file.Length/1MB, 2)
        Write-Host ""
        Write-Host "✅ APK Build Successful!" -ForegroundColor Green
        Write-Host "📱 APK Path: $($file.FullName)" -ForegroundColor Cyan
        Write-Host "📊 APK Size: $sizeMB MB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Test on device: adb install -r build/app/outputs/apk/release/app-release.apk"
        Write-Host "2. Create release: git tag v1.0.0 && git push --tags"
        Write-Host "3. Upload to Play Store or GitHub Releases"
    } else {
        Write-Host "❌ APK not found at expected location!" -ForegroundColor Red
    }
} else {
    Write-Host "❌ APK build failed!" -ForegroundColor Red
    exit 1
}
