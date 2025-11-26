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
├── app_test.dart          # Tests de integración principales
├── screenshots/           # Capturas de pantalla (Golden Files)
│   ├── 01_main_navigation.png
│   ├── 02_profile_page.png
│   ├── 03_records_page.png
│   ├── 04_ai_assistant_page.png
│   ├── 05_reports_page.png
│   ├── 06_upload_buttons.png
│   ├── 07_profile_form.png
│   ├── 08_chat_interface.png
│   ├── 09_reports_list.png
│   └── 10_flow_*.png      # Screenshots del flujo de navegación
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

| Test | Descripción |
|------|-------------|
| Test 1 | Verifica que la navegación principal se renderiza correctamente |
| Test 2 | Página de Perfil de Usuario |
| Test 3 | Navegación a Registros Médicos |
| Test 4 | Navegación a Asistente IA |
| Test 5 | Navegación a Reportes |
| Test 6 | Botones de carga de archivos (PDF, Foto, Galería) |
| Test 7 | Formulario de perfil de usuario |
| Test 8 | Interfaz de chat del asistente |
| Test 9 | Lista de reportes de salud |
| Test 10 | Flujo completo de navegación |

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
