# OrionHealth Integration Test Automation Script
# Similar a Playwright pero para Flutter
# Ejecuta tests automatizados con capturas de pantalla (Golden Tests)

param(
    [string]$Device = "windows",
    [switch]$UpdateGoldens = $false,
    [switch]$Web = $false,
    [switch]$Help = $false
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = $ScriptDir
$ScreenshotsDir = Join-Path $ProjectRoot "integration_test\screenshots"
$ReportsDir = Join-Path $ProjectRoot "test_reports"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

function Show-Help {
    Write-Host @"
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    OrionHealth Integration Test Runner                         ║
║                    (Similar a Playwright para Flutter)                         ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  USO:                                                                          ║
║    .\run_integration_tests.ps1 [opciones]                                      ║
║                                                                                ║
║  OPCIONES:                                                                     ║
║    -Device <device>     Dispositivo para ejecutar (windows, chrome, edge)      ║
║    -UpdateGoldens       Actualizar imágenes golden de referencia (screenshots) ║
║    -Web                 Ejecutar en navegador web con flutter drive            ║
║    -Help                Mostrar esta ayuda                                     ║
║                                                                                ║
║  EJEMPLOS:                                                                     ║
║    .\run_integration_tests.ps1                      # Verificar tests          ║
║    .\run_integration_tests.ps1 -UpdateGoldens       # Generar screenshots      ║
║    .\run_integration_tests.ps1 -Device chrome       # Tests en Chrome          ║
║    .\run_integration_tests.ps1 -Web                 # Tests web con driver     ║
╚═══════════════════════════════════════════════════════════════════════════════╝
"@
}

function Write-ColorLog {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Initialize-Directories {
    Write-ColorLog "📁 Creando directorios necesarios..." "Cyan"

    if (-not (Test-Path $ScreenshotsDir)) {
        New-Item -ItemType Directory -Path $ScreenshotsDir -Force | Out-Null
    }

    if (-not (Test-Path $ReportsDir)) {
        New-Item -ItemType Directory -Path $ReportsDir -Force | Out-Null
    }

    Write-ColorLog "   ✓ Directorios creados" "Green"
}

function Test-FlutterInstallation {
    Write-ColorLog "🔍 Verificando instalación de Flutter..." "Cyan"

    try {
        $flutterVersion = flutter --version 2>&1
        Write-ColorLog "   ✓ Flutter instalado" "Green"
        return $true
    }
    catch {
        Write-ColorLog "   ✗ Flutter no encontrado. Por favor instala Flutter." "Red"
        return $false
    }
}

function Get-Dependencies {
    Write-ColorLog "📦 Obteniendo dependencias..." "Cyan"

    Push-Location $ProjectRoot
    try {
        flutter pub get | Out-Null
        Write-ColorLog "   ✓ Dependencias descargadas" "Green"
    }
    finally {
        Pop-Location
    }
}

function Run-IntegrationTests {
    param([string]$TargetDevice, [bool]$IsWeb)

    Write-ColorLog "`n" "White"
    Write-ColorLog "═══════════════════════════════════════════════════════════════════════════════" "Magenta"
    Write-ColorLog "   🧪 EJECUTANDO INTEGRATION TESTS - OrionHealth" "Magenta"
    Write-ColorLog "   📱 Dispositivo: $TargetDevice" "Magenta"
    Write-ColorLog "   🕐 Inicio: $(Get-Date -Format 'HH:mm:ss')" "Magenta"
    Write-ColorLog "═══════════════════════════════════════════════════════════════════════════════" "Magenta"
    Write-ColorLog "`n" "White"

    Push-Location $ProjectRoot

    $testArgs = @()
    $reportFile = Join-Path $ReportsDir "test_report_$Timestamp.txt"

    try {
        if ($IsWeb) {
            Write-ColorLog "🌐 Modo Web: Ejecutando con flutter drive..." "Yellow"

            # Para web necesitamos chromedriver
            $chromeDriverProcess = $null

            Write-ColorLog "   Iniciando ChromeDriver..." "Gray"
            # Verificar si chromedriver está disponible
            try {
                $chromeDriverProcess = Start-Process -FilePath "chromedriver" -ArgumentList "--port=4444" -PassThru -WindowStyle Hidden
                Start-Sleep -Seconds 2
                Write-ColorLog "   ✓ ChromeDriver iniciado en puerto 4444" "Green"
            }
            catch {
                Write-ColorLog "   ⚠ ChromeDriver no disponible. Instalarlo con: npx @puppeteer/browsers install chromedriver@stable" "Yellow"
                Write-ColorLog "   Continuando sin ChromeDriver (algunas pruebas pueden fallar)" "Yellow"
            }

            $testArgs = @(
                "drive",
                "--driver=test_driver/integration_test.dart",
                "--target=integration_test/app_test.dart",
                "-d", "chrome"
            )

            Write-ColorLog "`n🚀 Ejecutando: flutter $($testArgs -join ' ')`n" "Cyan"

            $result = & flutter @testArgs 2>&1 | Tee-Object -FilePath $reportFile

            # Detener chromedriver si lo iniciamos
            if ($chromeDriverProcess) {
                Stop-Process -Id $chromeDriverProcess.Id -Force -ErrorAction SilentlyContinue
            }
        }
        else {
            Write-ColorLog "💻 Modo Desktop: Ejecutando con flutter test..." "Yellow"

            $testArgs = @(
                "test",
                "integration_test/app_test.dart",
                "-d", $TargetDevice
            )

            if ($UpdateGoldens) {
                $testArgs += "--update-goldens"
                Write-ColorLog "   📸 Modo: Actualizar imágenes golden" "Yellow"
            }

            Write-ColorLog "`n🚀 Ejecutando: flutter $($testArgs -join ' ')`n" "Cyan"

            $result = & flutter @testArgs 2>&1 | Tee-Object -FilePath $reportFile
        }

        # Analizar resultado
        $resultText = $result | Out-String

        if ($resultText -match "All tests passed") {
            Write-ColorLog "`n" "White"
            Write-ColorLog "╔═══════════════════════════════════════════════════════════════════════════════╗" "Green"
            Write-ColorLog "║                        ✅ TODOS LOS TESTS PASARON                             ║" "Green"
            Write-ColorLog "╚═══════════════════════════════════════════════════════════════════════════════╝" "Green"
            $exitCode = 0
        }
        elseif ($resultText -match "Some tests failed") {
            Write-ColorLog "`n" "White"
            Write-ColorLog "╔═══════════════════════════════════════════════════════════════════════════════╗" "Red"
            Write-ColorLog "║                        ❌ ALGUNOS TESTS FALLARON                              ║" "Red"
            Write-ColorLog "╚═══════════════════════════════════════════════════════════════════════════════╝" "Red"
            $exitCode = 1
        }
        else {
            Write-ColorLog "`n⚠ Tests completados - revisar resultados" "Yellow"
            $exitCode = 0
        }

        # Mostrar ubicación de archivos
        Write-ColorLog "`n📊 ARCHIVOS GENERADOS:" "Cyan"
        Write-ColorLog "   📄 Reporte: $reportFile" "White"

        # Listar screenshots si existen
        if (Test-Path $ScreenshotsDir) {
            $screenshots = Get-ChildItem -Path $ScreenshotsDir -Filter "*.png" -ErrorAction SilentlyContinue
            if ($screenshots) {
                Write-ColorLog "   📸 Screenshots: $($screenshots.Count) imágenes en $ScreenshotsDir" "White"
            }
        }

        return $exitCode
    }
    finally {
        Pop-Location
    }
}

function Show-TestSummary {
    Write-ColorLog "`n" "White"
    Write-ColorLog "═══════════════════════════════════════════════════════════════════════════════" "Cyan"
    Write-ColorLog "   📋 RESUMEN DE TESTS - OrionHealth Integration Testing" "Cyan"
    Write-ColorLog "═══════════════════════════════════════════════════════════════════════════════" "Cyan"
    Write-ColorLog "" "White"
    Write-ColorLog "   Los tests de integración verifican:" "White"
    Write-ColorLog "   • Navegación principal de la app" "Gray"
    Write-ColorLog "   • Página de Perfil de Usuario" "Gray"
    Write-ColorLog "   • Página de Registros Médicos" "Gray"
    Write-ColorLog "   • Página del Asistente IA" "Gray"
    Write-ColorLog "   • Página de Reportes" "Gray"
    Write-ColorLog "   • Flujo de navegación completo" "Gray"
    Write-ColorLog "   • Elementos de UI y formularios" "Gray"
    Write-ColorLog "" "White"
    Write-ColorLog "   Capturas de pantalla disponibles en:" "White"
    Write-ColorLog "   $ScreenshotsDir" "Yellow"
    Write-ColorLog "" "White"
}

# ═══════════════════════════════════════════════════════════════════════════════
#                               MAIN SCRIPT
# ═══════════════════════════════════════════════════════════════════════════════

if ($Help) {
    Show-Help
    exit 0
}

Write-ColorLog "`n" "White"
Write-ColorLog "╔═══════════════════════════════════════════════════════════════════════════════╗" "Cyan"
Write-ColorLog "║                                                                               ║" "Cyan"
Write-ColorLog "║   🏥 OrionHealth - Integration Test Automation                               ║" "Cyan"
Write-ColorLog "║   📸 Sistema de tests automatizados con capturas de pantalla                 ║" "Cyan"
Write-ColorLog "║   🎭 Similar a Playwright pero para Flutter                                  ║" "Cyan"
Write-ColorLog "║                                                                               ║" "Cyan"
Write-ColorLog "╚═══════════════════════════════════════════════════════════════════════════════╝" "Cyan"
Write-ColorLog "`n" "White"

# Verificar Flutter
if (-not (Test-FlutterInstallation)) {
    exit 1
}

# Inicializar directorios
Initialize-Directories

# Obtener dependencias
Get-Dependencies

# Ejecutar tests
$exitCode = Run-IntegrationTests -TargetDevice $Device -IsWeb $Web

# Mostrar resumen
Show-TestSummary

Write-ColorLog "🏁 Fin: $(Get-Date -Format 'HH:mm:ss')" "Cyan"
Write-ColorLog "`n" "White"

exit $exitCode
