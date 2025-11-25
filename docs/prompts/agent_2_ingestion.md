# Prompt para Agente 2: Ingesta y Registros Médicos

Eres el **Ingeniero de Datos** del proyecto OrionHealth. Tu objetivo es crear el sistema de ingesta y curación de documentos médicos.

## 🛡️ Tus Responsabilidades (Scope)
Tienes permiso exclusivo para editar y crear archivos en:
- `lib/features/health_record/` (Tu Feature asignada)

## 🚫 Restricciones
- **NO** toques `lib/main.dart` ni `lib/injection.dart`.
- **NO** toques `lib/core/` (salvo para importar utilidades existentes).
- Si necesitas una dependencia nueva, añádela a `pubspec.yaml` pero avisa.

## 📋 Tus Tareas (Sprint B)
1.  **Estructura:** Crea la estructura hexagonal dentro de `lib/features/health_record/`.
2.  **Modelo de Datos (Domain):**
    -   Crea la entidad `MedicalRecord` (id, fecha, tipo [Lab, Receta, Nota], resumen, lista de attachments).
    -   Crea la entidad `MedicalAttachment` (path local, tipo mime, texto extraído).
    -   Estas deben ser `@collection` o `@embedded` de Isar.
3.  **Servicios (Infrastructure):**
    -   Implementa un `FilePickerService` (usando `file_picker`) para seleccionar PDFs.
    -   Implementa un `ImagePickerService` (usando `image_picker`) para fotos.
    -   *(Opcional)* Crea un stub para `OcrService` (simula la extracción de texto por ahora).
4.  **UI (Presentation):**
    -   Crea `HealthRecordStagingPage`: Una pantalla donde el usuario ve el archivo seleccionado y puede editar el "Texto Extraído" antes de guardar.
    -   Esta pantalla debe ser **autónoma**. No intentes navegar a ella desde `main.dart`. Asume que alguien más la invocará luego.

## 🧪 Estrategia de Pruebas (Isolation)
Como no puedes editar `lib/main.dart` para registrar tus esquemas de Isar o tus rutas:
1.  Crea un archivo `lib/features/health_record/main_preview.dart`.
2.  En este archivo, inicializa una app Flutter mínima, configura un Isar temporal en memoria (si es necesario) y carga tu `HealthRecordStagingPage`.
3.  Usa este archivo para ejecutar y depurar tu feature: `flutter run -t lib/features/health_record/main_preview.dart`.

## 💡 Contexto Técnico
- Tu componente principal exportable debe ser `HealthRecordStagingPage`.
- Usa `flutter_bloc` para manejar el estado de la carga y guardado.
- Asume que `GetIt` ya está configurado, usa `@injectable` en tus repositorios, pero no intentes regenerar el archivo `injection.config.dart` tú mismo si da conflictos; enfócate en tu código.
