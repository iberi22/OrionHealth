# Prompt para Agente 3: Inteligencia Artificial Local

Eres el **Especialista en IA** del proyecto OrionHealth. Tu objetivo es construir la interfaz de chat y la capa de servicio para el LLM local.

## 🛡️ Tus Responsabilidades (Scope)

Tienes permiso exclusivo para editar y crear archivos en:

- `lib/features/local_agent/` (Tu Feature asignada)

## 🚫 Restricciones

- **NO** toques `lib/main.dart` ni `lib/injection.dart`.
- **NO** toques `lib/features/health_record/`.

## 📋 Tus Tareas (Sprint C)

1. **Estructura:** Crea la estructura hexagonal dentro de `lib/features/local_agent/`.
2. **Modelo de Datos (Domain):**
    - Crea la entidad `ChatMessage` (id, role [user, assistant], content, timestamp, citations).
    - Esta entidad debe ser persistida en Isar para mantener el historial.
3. **Servicios (Infrastructure):**
    - Define la interfaz `LlmService` (método `Stream<String> generate(String prompt)`).
    - Implementa un `MockLlmService` que devuelva texto simulado con un delay (para probar la UI sin descargar el modelo aún).
    - *(Avanzado)* Si te sientes valiente, implementa `OnnxLlmService` que cargue un modelo `.onnx` usando `onnxruntime` (pero prioriza la UI primero).
4. **UI (Presentation):**
    - Crea `ChatPage`: Una interfaz tipo WhatsApp/ChatGPT.
    - Debe soportar **Markdown** (usa `flutter_markdown`) para que la IA pueda dar formato a las respuestas.
    - Debe mostrar un indicador de "Pensando..." mientras el Stream está activo.

## 🧪 Estrategia de Pruebas (Isolation)

Como no puedes editar `lib/main.dart`:

1. Crea `lib/features/local_agent/main_preview.dart`.
2. Configura un `MaterialApp` que lance directamente tu `ChatPage`.
3. Inyecta tus mocks manualmente en este `main_preview` para no depender del `GetIt` global todavía.
4. Ejecuta: `flutter run -t lib/features/local_agent/main_preview.dart`.

## 💡 Contexto Técnico

- Tu componente principal exportable es `ChatPage`.
- La UI es crítica: debe sentirse fluida y moderna.
- Asume que `GetIt` te proveerá las dependencias. Usa `@injectable`.
