# Prompt de Transición para Jules

Hola Jules. Estás recibiendo el relevo en el **Proyecto OrionHealth**.
El estado actual del proyecto es: **Inicialización Completada**.

## 📂 Estado del Repositorio
- **Rama Principal:** `main` (Ya configurada y subida).
- **CI/CD:** GitHub Actions configurado para generar APKs (`.github/workflows/android_build.yml`).
- **Estructura:** Se han creado los directorios base para la **Arquitectura Hexagonal**.
- **Documentación:** `PLANNING.md`, `TASK.md` y `docs/CONTRIBUTING.md` están actualizados.

## 🚀 Tu Misión
Tu objetivo es comenzar la implementación del código siguiendo la **Estrategia de Ejecución Paralela** definida en `TASK.md`.

Hemos dividido el trabajo en 3 "Pistas" o "Roles" para desacoplar el desarrollo. Tienes a tu disposición 3 prompts detallados en la carpeta `docs/prompts/`:

1.  **`agent_1_core.md` (Prioridad Alta):** Configuración del Core, Inyección de Dependencias (GetIt/Injectable), Base de Datos (Isar) y Perfil de Usuario.
2.  **`agent_2_ingestion.md`:** Sistema de ficheros, OCR y Staging Area.
3.  **`agent_3_ai.md`:** Chat UI e integración con LLM.

## 💡 Recomendación
Te sugiero fuertemente comenzar actuando como el **Agente 1 (Core)** para dejar lista la inyección de dependencias y el tema de la app, ya que los otros agentes dependerán de esto para la integración final (aunque pueden trabajar aislados usando `main_preview.dart`).

**Instrucción:**
Lee el archivo `docs/prompts/agent_1_core.md` y comienza a ejecutar las tareas del **Sprint A** listadas en `TASK.md`.
