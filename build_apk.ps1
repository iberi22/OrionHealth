# OrionHealth APK Build Script
# Workaround for isar_flutter_libs resource verification issue with Material 3 attributes

Write-Host "🚀 Building OrionHealth APK Release..." -ForegroundColor Cyan
Write-Host "Issue: isar_flutter_libs uses Material 3 attributes that conflict with compileSdk" -ForegroundColor Yellow
Write-Host ""

# Step 1: Clean previous builds
Write-Host "Step 1: Cleaning previous builds..." -ForegroundColor Green
Remove-Item -Recurse -Force build, .dart_tool, android/app/build -ErrorAction SilentlyContinue
Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 2: Get dependencies
Write-Host "Step 2: Getting dependencies..." -ForegroundColor Green
& flutter pub get

# Step 3: Build runner (code generation)
Write-Host "Step 3: Running build_runner for DI code generation..." -ForegroundColor Green
& dart run build_runner build --delete-conflicting-outputs

# Step 4: Build APK using gradle directly with task exclusion
Write-Host "Step 4: Compiling APK (excluding problematic resource verification)..." -ForegroundColor Green
Push-Location android
& ./gradlew -x verifyReleaseResources :app:assembleRelease
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
