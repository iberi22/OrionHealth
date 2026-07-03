# Local Agent Feature

## Propósito
Proporciona un asistente de inteligencia artificial que se ejecuta localmente en el dispositivo (On-Device AI). Su objetivo es responder consultas médicas, analizar datos de salud y asistir al usuario de forma privada y segura sin depender de la nube.

## Capas

### Domain
- `LocalModelDescriptor`: Define las capacidades y metadatos de los modelos de lenguaje locales.
- `MedicalCode`: Representación de códigos clínicos para el análisis.
- `LlmAdapter`: Interfaz para la comunicación con motores de inferencia.
- `VectorStoreService`: Interfaz para la gestión de memoria semántica y RAG (Retrieval-Augmented Generation).

### Application
- `ChatCubit` (opcional): Gestiona la interacción en tiempo real con el asistente.
- `GenerateReport`: Caso de uso para la creación de resúmenes médicos.

### Infrastructure
- `GemmaLlmService`: Implementación de inferencia utilizando el modelo Gemma de Google.
- `SherpaOnnxAsrService`: Servicio de reconocimiento de voz local.
- `RagLlmService`: Implementación que combina LLM con recuperación de documentos locales.
- `AssetMedicalKnowledgeRepository`: Acceso a la base de conocimientos médica almacenada en los assets de la app.

### Presentation
- `ChatPage`: Interfaz de chat con el agente local.
- `LlmSettingsPage`: Configuración de modelos y descarga de recursos.

## Dependencias con otras features
- `health_record`: El agente analiza la historia clínica para dar respuestas contextualizadas.
- `vitals`: El agente puede interpretar tendencias en los signos vitales.
- `settings`: Integración de la configuración del modelo en los ajustes globales.
- `reports`: Generación de informes automáticos basados en IA.

## Estado de completitud
- **Tests**: Amplia cobertura de tests unitarios para servicios LLM y RAG.
- **Data Layer**: Soporte para modelos ONNX y almacenamiento vectorial local.
- **Modelos**: Soporte para Gemma y otros modelos ligeros compatibles con ejecución móvil.

## Ejemplos de uso

### Realizar una consulta al agente
```dart
final llmService = getIt<LlmService>();
final response = await llmService.generateResponse("¿Qué significan mis niveles de glucosa actuales?");
print(response.content);
```

### Iniciar el chat
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ChatPage()),
);
```
