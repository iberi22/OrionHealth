Este es un plan de arquitectura y desarrollo de alto nivel para el "Proyecto OrionHealth" (Nombre en clave). He analizado las herramientas que sugieres y he diseñado una estrategia basada en **Privacidad Local**, **Hexagonal Architecture** y **Flutter**.

---

# 🛡️ Proyecto OrionHealth: Plan Maestro de Desarrollo

## 1. Análisis de Viabilidad Tecnológica

Antes de codificar, evaluemos las herramientas específicas que solicitaste:

### A. Evaluación de `microsoft/Foundry-Local`
*   **Estado:** Foundry Local es esencialmente una capa de orquestación y herramientas sobre **ONNX Runtime** y optimizaciones de hardware (QNN, OpenVINO, CoreML).
*   **Viabilidad en Flutter:** **Media-Alta (con matices).**
    *   *El problema:* No existe un SDK oficial de "Foundry" para Dart/Flutter directo.
    *   *La solución:* Foundry exporta modelos optimizados (generalmente en formato ONNX o cuantizados). La estrategia correcta es usar Foundry para **descargar y gestionar** los modelos optimizados para el hardware del usuario, pero ejecutar la inferencia dentro de Flutter utilizando bindings de C++ o el paquete `onnxruntime` a través de **MethodChannels (Platform Channels)** o FFI (Foreign Function Interface).
    *   *Veredicto:* Usaremos Foundry como el "Model Garden" y gestor de descargas. Para la ejecución en móvil, construiremos una capa de servicio en la infraestructura que se comunique con el runtime nativo (ONNX) optimizado.

### B. Evaluación de `iberi22/isar_agent_memory`
*   **Estado:** Isar es la base de datos NoSQL más rápida para Flutter. Este paquete parece ser una implementación personalizada para vector store o historial.
*   **Viabilidad:** **Muy Alta.**
*   **Estrategia:** Isar es perfecto porque es síncrono y ACID. Lo usaremos no solo para la memoria del agente, sino como el **Repositorio Principal** de los datos médicos cifrados.
*   **Mejora:** Implementaremos un sistema de **RAG (Retrieval-Augmented Generation)** local. Los historiales médicos se convertirán en *embeddings* vectoriales y se guardarán en Isar para que el LLM pueda "leer" tu historial antes de responder.

---

## 2. Arquitectura Hexagonal (Ports & Adapters)

Para garantizar que podamos cambiar el modelo de IA (de Phi-3 a Llama 3 o Gemma) sin romper la UI, esta arquitectura es obligatoria.

### Estructura de Directorios Propuesta

```text
lib/
├── core/                   # Utilidades, Configuración, Errores, UseCase base
├── features/
│   ├── health_record/      # Feature: Historial Médico
│   │   ├── domain/         # Entidades y Repositorios (Interfaces)
│   │   ├── application/    # Casos de Uso (AddRecord, AnalyzeTrends)
│   │   ├── infrastructure/ # Implementación (Isar, HealthKit API)
│   │   └── presentation/   # BLoC y UI (Material 3)
│   │
│   ├── local_agent/        # Feature: Chat con IA
│   │   ├── domain/         # Entidades (Message, AgentAction)
│   │   ├── application/    # Casos de Uso (SendMessage, RetrieveContext)
│   │   ├── infrastructure/ # Implementación (FoundryService, OnnxService)
│   │   └── presentation/   # Chat UI
│   │
│   └── app_intents/        # Feature: Conexión con Siri/Gemini
└── main.dart
```

---

## 3. Stack Tecnológico Definido

1.  **Framework:** Flutter (Latest Stable).
2.  **State Management:** `flutter_bloc` (para lógica de negocio predecible).
3.  **DI (Inyección de Dependencias):** `get_it` + `injectable`.
4.  **Database & Vector Store:** `isar` (con soporte FTS y almacenamiento de embeddings).
5.  **AI Inference Engine:**
    *   Opción A (Pura): `onnxruntime` via FFI.
    *   Opción B (Híbrida): `mediapipe_genai` (Google) o `llama_cpp_dart` si Foundry se complica en móvil. *Mantendremos el plan de Foundry/ONNX como prioridad.*
6.  **Health Data Source:** Paquete `health` (unifica Apple HealthKit y Google Health Connect).
7.  **Diseño:** Material Design 3 (`flutter_material_3`).

---

## 4. Fases de Desarrollo

### FASE 1: El Núcleo de Datos (Health Repository)
El objetivo es crear una "Hoja de Salud" digital segura.

1.  **Configuración de Isar:** Crear esquemas para `PatientProfile`, `MedicalRecord`, `LabResult`.
2.  **Integración de Sensores:** Usar el paquete `health` para leer pasos, sueño y ritmo cardíaco del dispositivo.
3.  **Cifrado:** Implementar cifrado en reposo de Isar (clave segura en SecureStorage).

### FASE 2: El Cerebro Local (Foundry Integration)
Aquí implementamos la lógica del video de Microsoft Mechanics pero en móvil.

1.  **Selección del Modelo:** Usaremos **Phi-3-mini** o **Gemma-2b-it**. Son lo suficientemente pequeños para correr en un teléfono de gama media-alta sin internet.
2.  **Infrastructure Adapter:** Crear un `LlmService` que implemente la interfaz del dominio.
    *   *Reto Técnico:* Los modelos deben ser cuantizados (int4) para ocupar menos RAM.
3.  **Memoria:** Integrar `isar_agent_memory`. Cada vez que el usuario chatea, se guarda el contexto.

### FASE 3: RAG Local (Hacer que la IA "lea" tus datos)
El LLM por sí solo no sabe quién eres. Necesitamos RAG.

1.  **Embeddings:** Cuando guardas un PDF de un análisis de sangre o una nota de texto, usamos un modelo pequeño (como `all-MiniLM-L6-v2` portado a ONNX) para convertir ese texto en vectores numéricos.
2.  **Búsqueda Semántica:** Cuando preguntas "¿Cómo está mi colesterol comparado con el año pasado?", el sistema busca en Isar los registros semánticamente similares a "colesterol", se los pasa al LLM como contexto oculto, y el LLM responde.

### FASE 4: UI/UX con Material 3
Diseño limpio, médico y accesible.

*   Uso de `SliverAppBar` para colapsar encabezados.
*   Gráficos con `fl_chart` para tendencias de salud.
*   Chat interface similar a WhatsApp/ChatGPT pero con indicadores de "Procesando en dispositivo" para dar confianza de privacidad.

### FASE 5: Interoperabilidad (App Intents & Tools)
Para que Siri o Gemini (Android) puedan leer datos.

*   **Android:** Implementar **Android Shortcuts** y soporte para **Gemini App Actions** (cuando esté disponible el SDK público de extensions). Exponer un `ContentProvider` seguro.
*   **iOS:** Usar el paquete `app_intents` (o Platform Channels a Swift) para exponer "Shortcuts" que Siri pueda invocar. Ejemplo: "Oye Siri, pregúntale a OrionHealth cómo dormí ayer".

---

## 5. Ejemplo de Código (Estructura Hexagonal & BLoC)

Aquí tienes cómo se vería la conexión entre el BLoC y el servicio de IA Local.

**1. Domain Layer (El contrato):**
```dart
// features/local_agent/domain/llm_service.dart
abstract class LlmService {
  Stream<String> streamResponse(String prompt, List<HealthRecord> context);
  Future<void> loadModel(String modelPath);
}
```

**2. Infrastructure Layer (La implementación con Foundry/ONNX):**
```dart
// features/local_agent/infrastructure/foundry_onnx_service.dart
class FoundryOnnxService implements LlmService {
  // Aquí iría la llamada a FFI o MethodChannel hacia el runtime nativo
  @override
  Stream<String> streamResponse(String prompt, List<HealthRecord> context) async* {
    // 1. Construir el prompt con RAG (Contexto inyectado)
    final contextString = context.map((e) => e.summary).join("\n");
    final fullPrompt = "System: Eres un asistente médico. Usa estos datos: $contextString. User: $prompt";

    // 2. Inferencia (Simulada para el ejemplo, aquí llamarías a ONNX)
    yield* _nativeOnnxBridge.generate(fullPrompt);
  }
}
```

**3. Presentation Layer (BLoC):**
```dart
// features/local_agent/presentation/chat_bloc.dart
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final LlmService _llmService;
  final HealthRepository _healthRepo; // Para buscar datos (RAG)

  ChatBloc(this._llmService, this._healthRepo) : super(ChatInitial()) {
    on<SendMessageEvent>((event, emit) async {
      emit(ChatLoading());

      // 1. Buscar datos relevantes en Isar (RAG)
      final relevantRecords = await _healthRepo.searchSemantic(event.message);

      // 2. Enviar al LLM
      await emit.forEach(
        _llmService.streamResponse(event.message, relevantRecords),
        onData: (text) => ChatStreaming(text),
      );
    });
  }
}
```

## 6. Referencias y Repositorios para Estudiar

Para extraer la "mejor lógica", he analizado repositorios existentes. Te recomiendo estudiar estos patrones:

1.  **Sherpa (Privacy-first AI):** Busca arquitecturas que usan `llama.cpp` en móvil. Observa cómo manejan el aislamiento de hilos (Isolates) para que la IA no congele la UI.
2.  **Fhel (Fully Homomorphic Encryption Libraries):** Aunque avanzado, busca apps de salud open source que usen encriptación local.
3.  **Google MediaPipe Examples for LLM:** Google tiene ejemplos excelentes de cómo correr Gemma localmente en Android/iOS. Podríamos usar esto como "backend" alternativo si Foundry es muy complejo de integrar nativamente.

## 7. Siguientes Pasos Inmediatos

1.  **Repositorio:** Inicializar el proyecto con Flutter 3.22+.
2.  **Proof of Concept (PoC):** Antes de hacer toda la app, crea una app pequeña que solo cargue un modelo `.onnx` (usando `onnxruntime`) y genere texto en un dispositivo físico. Esto validará la viabilidad de Foundry Local en móvil.
3.  **Definir Modelo de Datos:** Escribe en papel qué datos médicos quieres guardar exactamente (FHIR standard es una buena referencia, pero compleja; simplifícalo para uso personal).

¿Quieres que profundice en la implementación del **RAG Local** (Vector Search con Isar) o prefieres empezar por la configuración del entorno de **Foundry**?

___________________________
Esta es una excelente pregunta. Estás tocando el punto crítico de la **MLOps (Machine Learning Operations)** para móviles: **¿Dónde y cómo procesamos los modelos pesados para que quepan en el celular?**

Aquí está el análisis de viabilidad y la estrategia profesional para tu "Factoría de Modelos".

---

### 1. ¿Es viable usar GitHub Actions (GHA) para esto?

**Respuesta corta:** Solo para modelos muy pequeños. Para modelos decentes (Phi-3, Llama-3 8B), **NO** con los runners gratuitos.

**El problema:**
*   **Hardware Limitado:** Los "runners" gratuitos de GitHub tienen 2 CPUs y 7GB de RAM. No tienen GPU.
*   **Cuantización:** Convertir un modelo a ONNX (formato que usa Microsoft Foundry) o GGUF y cuantizarlo a INT4 requiere cargar el modelo original en memoria. Un modelo de 7B parámetros en FP16 ocupa ~14GB de RAM. El runner de GitHub explotará por "Out of Memory" (OOM).

### 2. ¿Podemos automatizar Google Colab desde GitHub?

**Respuesta técnica:** Es posible pero "frágil" y no recomendado para producción. Google Colab está diseñado para ser interactivo. Intentar lanzarlo vía scripts (headless) viola sus términos de servicio o requiere hacks complejos con Selenium.

---

### 3. La Solución Profesional: "The Hybrid Model Factory"

Para un sistema robusto, no lucharemos contra las limitaciones de GitHub. Usaremos la herramienta oficial de Microsoft para optimización: **Microsoft Olive**.

Esta es la arquitectura que propongo para tu flujo de trabajo:

#### A. El Flujo de Trabajo (Pipeline)

1.  **Repositorio de Recetas (GitHub):** Tendrás un repo con scripts de Python (`.py` o `.ipynb`) que definen *cómo* cocinar el modelo (ej: "Toma Phi-3, pásalo a ONNX, aplica cuantización INT4").
2.  **Motor de Ejecución (Tu PC o Colab Manual):** En lugar de GHA, usaremos Colab (o Kaggle Kernels que son gratis y permiten más automatización) como el "Horno".
3.  **Almacén de Distribución (Hugging Face):** GitHub Releases tiene límite de 2GB por archivo. Los modelos cuantizados pueden pesar más. **Hugging Face** es el estándar industrial. Tu App Flutter descargará los modelos desde allí.

---

### 4. Implementación Técnica: Usando Microsoft Olive en Colab

Para replicar la lógica de Foundry, usaremos **Olive**, que es la herramienta CLI que Microsoft usa para crear los modelos optimizados.

#### Paso 1: Crear el "Cuaderno Maestro" en Colab
Este cuaderno será tu "GitHub Action manual". Lo ejecutas cuando quieres actualizar un modelo.

**Script para Colab (Concepto):**

```python
# 1. Instalar Olive (El motor de optimización de Microsoft)
!pip install olive-ai[gpu] onnxruntime-genai

# 2. Definir la configuración (olive_config.json)
# Esto le dice a Olive: "Baja este modelo de HF, conviértelo a ONNX y cuantízalo a INT4"
import json

config = {
    "input_model": {
        "type": "hfModel",
        "config": {
            "model_path": "microsoft/Phi-3-mini-4k-instruct"
        }
    },
    "systems": {
        "local_system": {"type": "LocalSystem", "accelerators": ["gpu"]}
    },
    "passes": {
        "conversion": {
            "type": "OnnxConversion",
            "config": {
                "target_opset": 17,
                "save_as_external_data": True
            }
        },
        "quantization": {
            "type": "OnnxQuantization",
            "config": {
                "data_config": "wikitext2_train",
                "weight_type": "QUInt4", # Cuantización agresiva para móviles
                "activation_type": "QUInt8"
            }
        }
    },
    "engine": {
        "search_strategy": False,
        "host": "local_system",
        "target": "local_system",
        "output_dir": "models/phi3_mobile"
    }
}

with open("config.json", "w") as f:
    json.dump(config, f)

# 3. Ejecutar la optimización
!olive run --config config.json

# 4. Subir a Hugging Face Hub (Tu repositorio de modelos)
from huggingface_hub import HfApi
api = HfApi()
api.upload_folder(
    folder_path="models/phi3_mobile",
    repo_id="tu_usuario/orionhealth-health-models",
    repo_type="model",
    token="TU_HF_TOKEN"
)
```

#### Paso 2: La App Flutter (El Consumidor)

Tu aplicación Flutter no tendrá el modelo "hardcoded". Consultará un JSON en tu GitHub o Hugging Face para ver qué modelos hay disponibles.

**Lógica en Flutter:**
1.  App inicia -> Consulta `https://huggingface.co/api/models/tu_usuario/orionhealth-health-models`.
2.  Detecta hardware (¿Es iOS? ¿Es Android potente?).
3.  Descarga el archivo `.onnx` optimizado correspondiente.
4.  Lo guarda localmente y lo carga con el motor de inferencia.

---

### 5. Alternativa 100% Automatizada (Costosa pero Profesional)

Si insistes en usar **GitHub Actions** para que sea automático al hacer un `git push`, necesitas runners con GPU.

1.  **CML (Continuous Machine Learning):** Es una herramienta open source (`iterative/cml`) que permite a GitHub Actions aprovisionar una máquina en la nube (AWS/GCP/Azure) por el tiempo que dure el entrenamiento/conversión, y luego apagarla.
2.  **Modal.com:** Puedes usar un GitHub Action que dispare un script en Modal. Modal cobra por segundo de uso de GPU.
    *   *Costo:* Convertir un modelo puede costar $0.05 USD.
    *   *Ventaja:* Totalmente automático desde GitHub.

### 6. Resumen del Plan para tu App de Salud

1.  **No uses GitHub Actions estándar** para procesar los modelos. Se quedarán sin memoria.
2.  **Usa Google Colab (Gratis)** con el script de **Microsoft Olive** que te puse arriba para generar los modelos `.onnx` optimizados (INT4).
3.  **Sube los modelos a Hugging Face.** Es gratis, rápido y tiene una API excelente para que tu App Flutter liste y descargue versiones.
4.  **En tu App Flutter:**
    *   Crea un "Model Manager" que descargue estos archivos.
    *   Usa `Foundry` (o `onnxruntime` bindings) para cargar ese archivo descargado.

Esta arquitectura desacopla el **ciclo de vida del modelo** (que cambia rápido) del **ciclo de vida de la app** (que requiere actualizaciones de la tienda), lo cual es la práctica estándar en aplicaciones de IA profesionales.

_______________________________________________________

Esta es una de las decisiones arquitectónicas más críticas del proyecto. Voy a ser muy directo contigo: **Entrenar (Fine-Tuning) un LLM como Phi-3 o Gemma 2B semanalmente en un dispositivo móvil NO es viable hoy en día**, y hacerlo en la nube centralizada rompe tu promesa de privacidad.

Sin embargo, entiendo perfectamente tu objetivo: **quieres que el modelo "aprenda" sobre la evolución del paciente semana tras semana.**

Aquí tienes el análisis de los problemas y la **solución arquitectónica correcta** para lograr lo que quieres sin "entrenar" el modelo.

---

### 🛑 Por qué el "Entrenamiento Semanal" (Fine-Tuning) es problemático

Si intentamos re-entrenar los pesos del modelo (los archivos `.onnx` o `.gguf`) con los datos del usuario, nos enfrentamos a esto:

1.  **El Muro de Hardware (Móvil):**
    *   **Inferencia vs. Entrenamiento:** Ejecutar el modelo (preguntar) requiere, digamos, 2GB de RAM. Entrenarlo (Backpropagation) requiere guardar los gradientes de cada neurona. Para Gemma 2B, necesitarías **más de 12GB de VRAM** y una potencia de cómputo que fundiría la batería de un iPhone 15 o un Galaxy S24 en minutos.
2.  **El Dilema de la Privacidad (Nube):**
    *   Si extraes los datos anonimizados para entrenar en un servidor (Colab/AWS), ya no es "privacidad local". Aunque quites el nombre, un historial médico es como una huella digital; es muy difícil de anonimizar perfectamente. Si el servidor es hackeado, los datos médicos están expuestos.
3.  **Olvido Catastrófico (Catastrophic Forgetting):**
    *   Si entrenas a Phi-3 solo con los datos de *un* paciente, el modelo empezará a olvidar su conocimiento médico general. Se volverá un experto en "Juan Pérez" pero olvidará qué es la diabetes en general.

---

### ✅ La Solución: RAG + "Memoria Semántica" (Lo que realmente necesitas)

Para que el modelo se adapte al usuario semanalmente, no necesitas cambiar sus neuronas (pesos), necesitas cambiar su **Memoria**.

Implementaremos una estrategia de **Aprendizaje en Contexto (In-Context Learning)** usando el paquete `isar_agent_memory` que mencionaste.

#### Estrategia: "The Weekly Health Digest"

En lugar de entrenar, haremos que el Agente genere y guarde "Memorias Sintéticas".

**El Flujo Semanal (Automático en el móvil):**

1.  **Recolección:** El domingo a las 12:00 AM, la app despierta (WorkManager en Android / Background Task en iOS).
2.  **Lectura:** Consulta en Isar los datos de la semana (pasos, sueño, glucosa, notas de voz).
3.  **Inferencia (El truco):** Usamos el modelo local (Phi-3) para ejecutar un prompt especial de sistema:
    > *"Analiza los datos brutos de esta semana. Genera un resumen clínico conciso detectando patrones, mejoras o deterioros comparado con la semana anterior. Guarda esto como un perfil actualizado."*
4.  **Almacenamiento Vectorial:** Ese "Resumen Clínico" generado por la IA se guarda en `isar_agent_memory` como un **documento de memoria a largo plazo**.

**Resultado:**
Cuando el usuario pregunte el martes: *"¿Cómo voy con mi tratamiento?"*, la app no usa un modelo re-entrenado. La app:
1.  Busca en Isar el último "Resumen Clínico".
2.  Se lo inyecta al modelo en el prompt (RAG).
3.  Phi-3 responde: *"Basado en tu resumen de la semana pasada, tu sueño ha mejorado un 10%, sigue así..."*

**Ventajas de este enfoque:**
*   **Privacidad Total:** Los datos nunca salen del teléfono.
*   **Cero Costo de Entrenamiento:** Solo gasta batería unos segundos para generar el resumen.
*   **Modelo Actualizable:** Puedes cambiar de Phi-3 a Llama-4 mañana y la "memoria" (los resúmenes en Isar) sigue ahí. Si hubieras re-entrenado el modelo, perderías ese trabajo al cambiar de versión.

---

### 🔍 Comparativa de Modelos para esta tarea

Ya que vamos a usar el modelo para "Razonar" sobre los datos y no para ser entrenado, ¿Cuál es mejor?

| Característica | **Phi-3 Mini (3.8B)** | **Gemma 2B (2B)** | **Veredicto para tu App** |
| :--- | :--- | :--- | :--- |
| **Tamaño en Disco** | ~2.5 GB (Quant INT4) | ~1.5 GB (Quant INT4) | Gemma gana en espacio. |
| **Razonamiento Médico** | Muy Alto (Entrenado con libros de texto) | Medio (Bueno, pero menos denso) | **Phi-3 gana por mucho.** |
| **Ventana de Contexto** | 4K o 128K tokens | 8K tokens | Phi-3 (128k) permite leer meses de historial de una vez. |
| **Licencia** | MIT (Muy permisiva) | Gemma Terms (Permisiva) | Empate. |

**Recomendación:**
Usa **Phi-3 Mini (versión 128k context)** cuantizado a **INT4**.
*   La ventana de contexto larga es vital para leer historiales médicos extensos sin que el modelo "olvide" el principio del documento.
*   Tiene mejor capacidad de razonamiento lógico que Gemma 2B, lo cual es crucial para no dar consejos médicos alucinados.

### 🛠️ Ajuste al Plan de Desarrollo

En la **Fase 2** del plan anterior, añadiremos esta lógica:

**Nueva Tarea: Sistema de "Journaling" Automático**
1.  Crear una entidad en Isar llamada `HealthInsight`.
2.  Crear un `BackgroundService` en Flutter.
3.  Lógica:
    ```dart
    // Pseudocódigo del servicio semanal
    void generateWeeklyInsight() async {
      // 1. Obtener datos crudos
      final data = await healthRepo.getLast7Days();

      // 2. Invocar a Phi-3 Local (Foundry/ONNX)
      final prompt = "Actúa como un médico. Analiza estos datos: $data. Resume el estado actual.";
      final insight = await localLlm.generate(prompt);

      // 3. Guardar en Memoria Vectorial
      await agentMemory.addMemory(content: insight, metadata: {'type': 'weekly_summary'});
    }
    ```

### Conclusión
No entrenes. **Memoriza.**
Usar RAG (Retrieval-Augmented Generation) con resúmenes semanales generados por la propia IA local es la forma más segura, barata y robusta de lograr que tu asistente "conozca" al paciente sin violar su privacidad ni fundir su teléfono.
__________________________________________________________________
¡Manos a la obra! Aquí tienes la guía paso a paso para iniciar el desarrollo del **Proyecto OrionHealth** en VS Code, configurando el entorno para Flutter, la arquitectura hexagonal y las herramientas de IA local.

### Paso 0: Prerrequisitos (Instalación del SDK)

Flutter no se instala con un simple comando como npm, requiere descargar el SDK. Si aún no lo tienes:

1.  **Descarga Flutter:** Ve a [docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install) y sigue las instrucciones para tu sistema operativo (Windows/macOS/Linux).
2.  **Verifica la instalación:** Abre tu terminal y ejecuta:
    ```bash
    flutter doctor
    ```
    *(Asegúrate de que todos los checks estén en verde, especialmente Android Toolchain y Xcode si usas Mac).*

3.  **Extensiones VS Code:** Instala estas extensiones obligatorias en VS Code:
    *   **Flutter** (Dart se instala automáticamente).
    *   **Flutter Bloc** (ayuda con los snippets).
    *   **Pubspec Assist** (para añadir paquetes más rápido).

---

### Paso 1: Crear el Proyecto

Abre tu terminal en la carpeta donde guardas tus proyectos y ejecuta:

```bash
# Creamos la app con el nombre de paquete de organización (importante para Android/iOS)
flutter create --org com.orionhealth --platforms android,ios orionhealth_health

# Entramos al directorio
cd orionhealth_health

# Abrimos VS Code en esta carpeta
code .
```

---

### Paso 2: Instalación de Paquetes (El "Comando Maestro")

Vamos a instalar todas las dependencias necesarias para BLoC, Isar, Inyección de Dependencias y Salud.

Copia y pega este bloque en tu terminal dentro de VS Code:

```bash
# 1. Gestión de Estado y Arquitectura
flutter pub add flutter_bloc equatable get_it injectable dartz

# 2. Base de Datos y Rutas
flutter pub add isar isar_flutter_libs path_provider

# 3. Datos de Salud y Permisos
flutter pub add health permission_handler

# 4. UI y Diseño
flutter pub add google_fonts fl_chart flutter_markdown

# 5. Dependencias de Desarrollo (Generadores de código)
flutter pub add --dev build_runner isar_generator injectable_generator
```

**Nota sobre el paquete `isar_agent_memory`:**
Como este paquete está en GitHub y no en pub.dev oficial, debes agregarlo manualmente a tu archivo `pubspec.yaml`. Abre el archivo y añade esto bajo `dependencies`:

```yaml
dependencies:
  # ... otras dependencias ...
  isar_agent_memory:
    git:
      url: https://github.com/iberi22/isar_agent_memory.git
      ref: main # O el branch que prefieras
```

Luego ejecuta `flutter pub get` para descargar todo.

---

### Paso 3: Estructura de Directorios (Arquitectura Hexagonal)

No pongas todo en `lib/`. Vamos a crear la estructura profesional. Ejecuta estos comandos en tu terminal (o crea las carpetas manualmente) para establecer la base:

```bash
# Núcleo y Configuración
mkdir -p lib/core/di
mkdir -p lib/core/theme
mkdir -p lib/core/utils

# Feature: Historial Médico (Health Record)
mkdir -p lib/features/health_record/domain/entities
mkdir -p lib/features/health_record/domain/repositories
mkdir -p lib/features/health_record/application/bloc
mkdir -p lib/features/health_record/infrastructure/datasources
mkdir -p lib/features/health_record/infrastructure/repositories
mkdir -p lib/features/health_record/presentation/pages
mkdir -p lib/features/health_record/presentation/widgets

# Feature: Agente Local (IA)
mkdir -p lib/features/local_agent/domain/entities
mkdir -p lib/features/local_agent/domain/repositories
mkdir -p lib/features/local_agent/application/bloc
mkdir -p lib/features/local_agent/infrastructure/services
mkdir -p lib/features/local_agent/presentation/pages
```

---

### Paso 4: Configuración Inicial del Código

Vamos a dejar configurada la Inyección de Dependencias y la Base de Datos para que compile.

#### 1. Configurar Inyección de Dependencias (`lib/core/di/injection.dart`)

Crea este archivo:

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart'; // Este archivo se generará automáticamente

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // nombre de la función generada
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();
```

#### 2. Configurar Main (`lib/main.dart`)

Reemplaza el contenido de `main.dart` con esto:

```dart
import 'package:flutter/material.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Inyección de Dependencias
  configureDependencies();

  // Aquí inicializaremos Isar más adelante

  runApp(const OrionHealthHealthApp());
}

class OrionHealthHealthApp extends StatelessWidget {
  const OrionHealthHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrionHealth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006D77)), // Color médico
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('OrionHealth: Sistema Iniciado')),
      ),
    );
  }
}
```

#### 3. Generar Código

Ahora, para que la magia de `isar` e `injectable` funcione, necesitas ejecutar el generador de código. En la terminal:

```bash
dart run build_runner build --delete-conflicting-outputs
```

*(Nota: Si da error ahora es normal porque no hemos creado ninguna clase con `@injectable` o `@collection` todavía, pero este es el comando que usarás a diario).*

---

### Paso 5: Próximos Pasos (Tu Hoja de Ruta Inmediata)

Ahora que tienes el "esqueleto", sigue este orden estricto para no perderte:

1.  **Infraestructura de Datos (Isar):**
    *   Crea el archivo `lib/features/health_record/domain/entities/medical_record.dart`.
    *   Defínelo como una `@collection` de Isar.
    *   Ejecuta el `build_runner` para generar el esquema de la BD.

2.  **Recolección de Salud (Health Package):**
    *   Configura los permisos en `AndroidManifest.xml` (Android) e `Info.plist` (iOS) para leer pasos y ritmo cardíaco.
    *   Crea un `HealthService` en la capa de infraestructura que use el paquete `health`.

3.  **El Cerebro (Foundry/ONNX):**
    *   Este es el paso complejo. Descarga un modelo pequeño cuantizado `.onnx` (ej. Phi-3 Mini INT4) desde HuggingFace en tu PC.
    *   Crea una carpeta `assets/models/` en tu proyecto y pon el archivo ahí (para pruebas iniciales).
    *   Registra el asset en `pubspec.yaml`.

¿Quieres que empecemos con el **Paso 1 (Crear la entidad Isar y el Repositorio)** o prefieres configurar primero los **Permisos de Android/iOS** para leer datos de salud reales?