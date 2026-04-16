# Build Release APK for OrionHealth
# This script ensures the environment is clean and code generation is complete before building.

Write-Host "🚀 Starting OrionHealth APK Build Process..." -ForegroundColor Cyan

# 1. Pub Get
Write-Host "📦 Fetching dependencies..." -ForegroundColor Gray
flutter pub get

# 2. Build Runner
Write-Host "🏗️ Running code generation..." -ForegroundColor Gray
dart run build_runner build --delete-conflicting-outputs

# 3. Build APK
Write-Host "📱 Building Release APK..." -ForegroundColor Gray
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ APK Build Successful!" -ForegroundColor Green
    Write-Host "📍 Location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
} else {
    Write-Host "❌ APK Build Failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}
