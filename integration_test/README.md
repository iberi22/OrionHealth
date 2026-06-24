# 🧪 OrionHealth - Integration Tests

## Descripción

Este directorio contiene **tests de integración automatizados** para la aplicación OrionHealth, inspirados en frameworks como **Playwright** pero adaptados para **Flutter**.

## 🎯 Características

- ✅ **Tests automatizados de UI** - Verifican la funcionalidad de la interfaz
- 📸 **Capturas de pantalla automáticas** - Usando Golden Tests de Flutter
- 🔄 **Regresión visual** - Detecta cambios no intencionales en la UI
- 🚀 **Fácil de ejecutar** - Un solo comando para correr todos los tests

## 📁 Estructura

```
integration_test/
├── screenshot_flow_e2e_test.dart  # 🆕 Flujo completo de capturas REALES
├── app_test.dart          # Tests de integración principales (mocks)
├── flows_test.dart        # Flujos críticos de usuario
├── smoke_injectable_test.dart  # Smoke test REAL sin mocks
├── screenshots/           # Capturas de pantalla (Golden Files)
│   └── 01_launch/        # Onboarding & launch
│   └── 02_auth/          # Auth, PIN setup
│   └── 03_dashboard/     # Dashboard & home
│   └── 04_records/       # Health records
│   └── 05_reports/       # Reports & analytics
│   └── 06_profile/       # User profile
│   └── 07_chat/          # AI Chat & voice
│   └── 08_medical/       # Medical research & standards
│   └── 09_medications/   # Medications
│   └── 10_appointments/  # Appointments
│   └── 11_sharing/       # P2P health sharing
│   └── 12_settings/      # Settings & LLM config
│   └── 13_vitals/        # Vital signs
│   └── 14_network/       # Governance & incentives
│   └── 15_sync/          # Sync & FHIR
│   └── 16_navigation/    # Full navigation tour
├── utils/
│   └── video_recorder.dart  # Utilidad de captura de screenshots
└── README.md              # Este archivo
```

## 🚀 Cómo Ejecutar

### Verificar Tests (Comparar con Golden Files)

```powershell
# Ejecutar en Windows Desktop
flutter test integration_test/app_test.dart -d windows

# O usar el script de automatización
.\run_integration_tests.ps1
```

### Generar/Actualizar Screenshots

```powershell
# Generar nuevos Golden Files (screenshots de referencia)
flutter test integration_test/app_test.dart -d windows --update-goldens

# O usar el script
.\run_integration_tests.ps1 -UpdateGoldens
```

### Ejecutar en Chrome (Web)

```powershell
flutter test integration_test/app_test.dart -d chrome --update-goldens
```

## 📋 Tests Incluidos

## 📸 Nuevo: screenshot_flow_e2e_test.dart

Test de integración que **flujee automáticamente por TODAS las pantallas** de OrionHealth y captura screenshots reales del UI corriendo en dispositivo real o desktop.

### Cómo ejecutar

```powershell
# En dispositivo Android conectado
flutter test integration_test/screenshot_flow_e2e_test.dart -d <device_id> --update-goldens

# En Windows (modo headless)
flutter test integration_test/screenshot_flow_e2e_test.dart -d windows --update-goldens

# Solo verificar (comparar con goldens existentes)
flutter test integration_test/screenshot_flow_e2e_test.dart -d windows
```

### Flujos capturados

| # | Flow | Descripción |
|---|------|-------------|
| 01 | Launch & Onboarding | Splash, welcome screens, profile setup |
| 02 | Auth & PIN | Login, PIN setup, locked states |
| 03 | Dashboard & Home | Health status grid, module cards |
| 04 | Health Records | Record list, upload options |
| 05 | Reports | Report list, detail view |
| 06 | User Profile | Profile view, edit mode |
| 07 | AI Chat & Voice | Chat interface, voice input |
| 08 | Medical Research | Search, ICD-10/LOINC/SNOMED browser |
| 09 | Medications | Medication list, tracking |
| 10 | Appointments | Calendar view, appointment cards |
| 11 | Health Sharing | P2P share, BLE/NFC/WiFi options |
| 12 | Settings & LLM | Settings menu, LLM model config |
| 13 | Vital Signs | Vitals monitor, heart rate tracking |
| 14 | Network & Governance | Governance, incentives, leaderboard |
| 15 | Sync & FHIR | Sync status, FHIR resource status |
| 16 | Navigation Tour | Full bottom nav tab tour |

### Requisitos

- **Dispositivo Android real**: `flutter devices` debe mostrar tu dispositivo
- **O Windows**: `flutter test -d windows` (no captura la app real completa, pero verifica que los tests compilan)

## 🔧 Configuración

### Requisitos

- Flutter SDK >= 3.10.0
- Windows Desktop habilitado (`flutter create . --platforms=windows`)

### Dependencias (ya incluidas)

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

## 📸 Golden Tests - Cómo Funcionan

Los **Golden Tests** son una técnica de testing visual donde:

1. **Generación**: Se ejecutan los tests con `--update-goldens` para crear imágenes de referencia
2. **Verificación**: Se ejecutan normalmente para comparar la UI actual con las referencias
3. **Detección**: Si hay diferencias visuales, el test falla y muestra las discrepancias

### Ventajas

- 🎯 Detecta regresiones visuales automáticamente
- 📝 Documentación visual del estado de la UI
- 🔄 Facilita code reviews con comparación visual

### Cuándo Actualizar Goldens

- Después de cambios intencionales en la UI
- Al agregar nuevas features visuales
- Cuando un test falla por un cambio esperado

## 🐛 Troubleshooting

### Error: "No Windows desktop project configured"

```powershell
flutter create . --platforms=windows
```

### Error: "Golden file not found"

```powershell
flutter test integration_test/app_test.dart -d windows --update-goldens
```

### Tests fallan después de actualizar Flutter

Regenera los golden files - pequeñas diferencias de renderizado son normales entre versiones:

```powershell
flutter test integration_test/app_test.dart -d windows --update-goldens
```

## 📊 CI/CD Integration

Para integrar en pipelines de CI/CD:

```yaml
# GitHub Actions example
- name: Run Integration Tests
  run: |
    flutter test integration_test/app_test.dart -d windows

- name: Upload Screenshots on Failure
  if: failure()
  uses: actions/upload-artifact@v3
  with:
    name: test-failures
    path: integration_test/failures/
```

## 📚 Referencias

- [Flutter Integration Tests](https://docs.flutter.dev/testing/integration-tests)
- [Golden File Testing](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)
- [Widget Testing](https://docs.flutter.dev/testing/overview#widget-tests)
