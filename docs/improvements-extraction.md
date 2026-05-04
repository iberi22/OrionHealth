# OrionHealth — Extracción de Mejoras UI/UX y Código

**Fecha:** 2026-05-03 | **Build:** 0 issues, 0 warnings

---

## ✅ Logrado en este sprint

### 1. LLM Local Real (GemmaLlmService)
- **Reemplazó MockLlmService** con `GemmaLlmService` con 3 modos de operación:
  1. **Local**: Gemma 4 vía AICore/ML Kit (completamente offline)
  2. **Cloud fallback**: Gemini API cuando local no disponible
  3. **Offline RAG fallback**: Responde solo con contexto vectorial sin LLM
- Streaming character-by-character preservado

### 2. VectorStore con Re-ranking (5 estrategias)
| Estrategia | Uso |
|-----------|-----|
| **MMR** | Balance entre relevancia y diversidad de resultados |
| **Diversity** | Agrupación por topic + round-robin |
| **Recency** | Prioriza contenido más reciente |
| **BM25** | Keyword matching puro |
| **None** | Resultados directos sin re-ranking |

### 3. OCR + Report Generation (Codex)
- `google_mlkit_text_recognition` reemplazando OcrServiceStub
- ReportGenerationService real usando Gemma/Gemini

---

## 🎯 Mejoras UI/UX Detectadas (Pendientes)

### Alta Prioridad
1. **MockLlmAdapter todavía registrado en DI** (`injection.config.dart` línea 223)
   - Usa `MockLlmAdapter` con `@Named('mock')` — sigue activo en el config generado
   - **Fix:** Re-generar `build_runner` para que use `GemmaLlmAdapter` como default

2. **Error handling en chat_page.dart** (línea 117)
   - Muestra error crudo: `'Error: ${error.toString()}'`
   - **Fix:** Mensaje amigable en español: "Lo siento, hubo un problema al procesar tu consulta. Intenta de nuevo."

3. **main_preview.dart** (línea 16) sigue usando `MockLlmService()`
   - **Fix:** Actualizar a `GemmaLlmService()`

4. **BLE Sharing Service** (3 TODOs)
   - `lib/features/auth/infrastructure/services/ble_medical_sharing_service.dart`
   - **Fix:** Implementar o limpiar

### Media Prioridad
5. **Health Wallet no integrado** (`sharing_cubit.dart:338`)
   - TODO: Integrate with HealthWalletService
   - **Fix:** Wire HealthWallet en el sharing flow

6. **Drug Interaction Checker** (2 stubs)
   - `lib/features/medical_assistant/infrastructure/analysis/drug_interaction_checker.dart`
   - Stub: usaría comprehensive drug database
   - **Fix:** Cargar drug DB o limpiar

7. **Risk Calculator** stub
   - `lib/features/medical_assistant/infrastructure/analysis/risk_calculator.dart`
   - Solo implementa cálculo base, no usa datos reales del perfil

8. **Landing page screenshots gallery** (comentada)
   - Layout horizontal pendiente de arreglar

### Baja Prioridad
9. **VectorStore multi-hop puede ser lento** — itera sobre todos los nodos por capa
   - **Fix:** Indexar por externalId para búsqueda O(1)

10. **Métricas de confianza no se muestran en UI**
    - El backend calcula confidence scores pero no se exponen al usuario

---

## 📋 Próximos Pasos

1. `dart run build_runner build --delete-conflicting-outputs` — regenerar DI
2. Reemplazar MockLlmAdapter registration en DI por GemmaLlmAdapter
3. Fix error handling en chat_page.dart
4. Wire HealthWallet con sharing flow
5. Decidir si mantener BLE stubs o limpiarlos
