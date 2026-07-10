# Investigación: MedicalAssistantCubit Test Failures

## Problema Identificado

El test `diagnostic insights capture ICD-10 evidence from reasoner matches` falla porque:

1. `_buildCubit()` setea `analyzeSymptoms → []` por default
2. Cuando el test overridea `mockReasoner.analyzeSymptoms`, el stub no se respeta
3. El test recibe `[]` insights vacíos

## Root Cause Analysis

### Flujo Actual

```dart
// _buildCubit helper (test setup)
when(() => mockReasoner.analyzeSymptoms(any()))
    .thenAnswer((_) async => []);  // ← Default stub
```

```dart
// Test intento 1
final mockReasoner = MockClinicalReasonerService();
when(() => mockReasoner.analyzeSymptoms(any())).thenAnswer((_) async => [/*...*/]);
final cubit = _buildCubit(reasoner: mockReasoner);  // ← Sobrescribe stubs!
```

### Por qué falla

`_buildCubit` recibe `mockReasoner` pero DENTRO de la función vuelve a setear stubs:

```dart
MedicalAssistantCubit _buildCubit({MockClinicalReasonerService? reasoner, ...}) {
  final mockReasoner = reasoner ?? MockClinicalReasonerService();  // ← Usa el mock
  // ... pero luego:
  when(() => mockReasoner.analyzeSymptoms(any()))
      .thenAnswer((_) async => []);  // ← Sobrescribe el stub del test!
  // ...
}
```

## Soluciones Possibles

### Opción A: API Change a Stream (Recomendado para futuro)

```dart
// Cambiar signature
Stream<MedicalAssistantState> submitQuery(String question, {String? userId}) async* {
  emit(const MedicalAssistantLoading(message: '...'));
  yield state;
  // ...
  final response = await _llmAdapter.generateResponse(...);
  final finalState = MedicalAssistantResponse(response: response, query: query);
  emit(finalState);
  yield finalState;
}
```

**Pros:** Tests pueden usar `emitsThrough()`
**Cons:** Breaking API change, requiere actualizar TODOS los callers

### Opción B: Factory Method en Cubit (Middleware approach)

```dart
class MedicalAssistantCubit {
  // Factory que acepta stubs directamente
  factory MedicalAssistantCubit.withMocks({
    required MedicalLlmAdapter llmAdapter,
    MedicalAnalysisService? analysisService,
    ClinicalReasonerService? reasoner,
    // ... todos los deps
  }) {
    return MedicalAssistantCubit._internal(
      llmAdapter: llmAdapter,
      analysisService: analysisService ?? getIt<MedicalAnalysisService>(),
      reasoner: reasoner ?? getIt<ClinicalReasonerService>(),
      // ...
    );
  }
  
  MedicalAssistantCubit._internal({/*...*/});  // Private constructor
}
```

**Pros:** No API change, tests controlan todos los deps
**Cons:** Más código, necesidad de constructor privado

### Opción C: Test Helper Refactorizado (Quick Fix)

```dart
// En vez de _buildCubit, crear helper específico por test
MedicalAssistantCubit buildCubitWithReasoner({
  MockClinicalReasonerService? reasoner,
  MockMedicalLlmAdapter? adapter,
  // Solo override los que el test necesita
}) {
  final mockReasoner = reasoner ?? MockClinicalReasonerService();
  when(() => mockReasoner.analyzeSymptoms(any()))
      .thenAnswer((_) async => []);  // Default
  
  // NO sobreescribir si ya tiene stubs
  // El test configura ANTES de pasarlo
  return MedicalAssistantCubit(
    llmAdapter: adapter ?? MockMedicalLlmAdapter(),
    reasoner: mockReasoner,
    // ...
  );
}
```

### Opción D: Skip + Tech Debt (Conservador)

```dart
test('diagnostic insights...', () => markTestSkipped('Issue #157'));
```

Crear issue separado para fix.

## Recomendación Profesional

### Phase 1: Quick Win (Ahora)
1. **Skip el test** con referencia a issue #157
2. **Documentar** el problema técnico
3. **Crear issue** para API refactor

### Phase 2: Medium Term
1. **Crear factory constructor** en MedicalAssistantCubit (Opción B)
2. **Refactorizar tests** para usar el factory
3. **Verificar** que todos los tests pasan

### Phase 3: Future Enhancement
1. **Considerar Stream API** si hay necesidad de real-time UI updates
2. **Evaluar** si el beneficio justifica el breaking change

## Archivos Involucrados

| Archivo | Cambio Requerido |
|---------|------------------|
| `lib/features/medical_assistant/application/medical_assistant_cubit.dart` | Factory constructor |
| `test/features/medical_assistant/application/medical_assistant_cubit_test.dart` | Refactor tests |

## Risk Assessment

| Solución | Risk | Effort | Timeline |
|----------|------|--------|----------|
| Opción A (Stream) | 🔴 High (breaking) | High | 2-3 days |
| Opción B (Factory) | 🟡 Medium | Medium | 1-2 days |
| Opción C (Helper) | 🟢 Low | Low | 2-4 hours |
| Opción D (Skip) | 🟢 Low | Low | 15 min |

## Conclusión

Para **continuar de forma robusta y profesional**:

1. **Immediate:** Skip test + documentar #157
2. **Short term:** Implementar Opción B (Factory) - no es breaking change
3. **Long term:** Evaluar Opción A (Stream) si hay necesidad real de streaming UI

La clave: **No forzar un cambio de API si no hay justificación de negocio**.
