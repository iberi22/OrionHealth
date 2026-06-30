# OrionHealth Protocol — GitCore v3.6.0-SWAL

> Adaptación de GitCore Protocol para flujo Jules + Claw

## Repositorio
- **url:** `iberi22/OrionHealth`
- **Rama única:** `main`
- **Workflow:** GitHub Flow simplificado (main + feature branches temporales)

## Flujo de Trabajo

```
1. CREAR ISSUE en GitHub con label `jules`
2. JULES detecta label → crea branch feat/... → implementa → PR
3. CI corre en PR (requiere pasar para merge)
4. CLAW revisa → resuelve conflictos → squash merge con --admin
5. CLAW cierra issue
6. JULES actualizó FEATURES.json en su PR
```

## Creación de Issues para Jules

### Reglas
- **1 issue = 1 feature = max 3-4 archivos modificados**
- Issues grandes → dividir en partes pequeñas
- El título debe ser descriptivo: `[feat] feature-name: specific task`
- **Siempre** incluir en el body: `"Update FEATURES.json with new implementation metrics"`
- Label obligatorio: `jules`

### Template
```
## Tarea
[descripción concisa]

## Archivos a modificar
- `lib/features/xxx/...` (si aplica)
- `test/features/xxx/...` (si aplica)

## Criterios de aceptación
- [ ] dart analyze lib/ test/ → 0 errors
- [ ] Tests existentes pasan
- [ ] FEATURES.json actualizado con métricas
```

## Labels del Proyecto

| Label | Propósito | Agente destino |
|-------|-----------|----------------|
| `jules` | 🎯 Feature task for Jules AI | Jules AI |
| `fix` | 🔧 Bug fix or stabilization | Claw |
| `enhancement` | ✨ Feature request | Jules AI |
| `bug` | 🐛 Bug report | Jules AI |
| `documentation` | 📚 Docs update | Jules AI |
| `dependencies` | 📦 Dependabot | Claw |

## Resolución de Conflictos

| Archivo | Estrategia |
|---------|-----------|
| `lib/core/di/injection.config.dart` | `--ours` (main) — auto-generado por injectable |
| `pubspec.yaml` / `pubspec.lock` | `-X theirs` para dependabot; resolver manual para features |
| `FEATURES.json` | `--ours` (main) — solo Jules actualiza métricas |
| `.gitcore/features.json` | `--ours` (main) — solo Claw actualiza |

## Comandos de Merge

```bash
# Squash merge de PR de Jules
gh pr merge <NUM> --squash --admin

# Resolver injection.config.dart
git checkout --ours lib/core/di/injection.config.dart
git add lib/core/di/injection.config.dart

# Push con bypass
git push origin main
```

## Estabilización (Claw)

Después de cada merge batch:
```bash
cd E:\scripts-python\OrionHealth
dart analyze lib/ test/         # 0 errors required
flutter test --no-pub            # all tests pass
```

## FEATURES.json (Raíz del Proyecto)

- **Formato:** JSON con array `features[]`
- **Cada feature tiene:** `name`, `implementationPct`, `files`, `layersComplete`
- **Jules DEBE** actualizar `implementationPct` de la feature que trabajó en cada PR
- **Claw** recalcula `averageImplPct` después de merges batch

## CI/CD

| Aspecto | Configuración |
|---------|---------------|
| Flutter SDK | 3.41.9 (pinned) |
| Flags CI | `--no-fatal-infos --no-fatal-warnings` |
| Workflows | OrionHealth CI + Android Build |
| Test unitarios | `flutter test --no-pub` |
| Analyze | `dart analyze lib/ test/` → 0 errors |
| Golden tests | Via `--update-goldens` (cuando sea necesario) |

## Mejoras sobre GitCore Original

| Aspecto | GitCore Original | OrionHealth |
|---------|-----------------|-------------|
| Agentes | 7 roles (architect, codex, claude, etc.) | 2 agentes (Jules + Claw) |
| SDLC | 4 fases (ANALYSIS→DESIGN→IMPLEMENT→TEST) | Simplificado: feature + merge |
| SRC | Requirements documentación | No usado (features chicos directo a código) |
| Cortex sync | Obligatorio post-cada-decisión | Reemplazado por xavier (puerto 8006) |
| Ramas | Develop + features | Solo main (GitHub Flow) |
| FEATURES.json | `.gitcore/features.json` del protocolo | `FEATURES.json` en raíz (para Jules) |
| TASK.md | Formato tabla detallada | Formato tabla simplificada |
| Planning | PLANNING.md adjunto | Resumen en TASK.md solamente |

## Directorio de Referencia

```
.gitcore/
  AGENT_INDEX.md       - Routing de agentes
  ARCHITECTURE.md      - Decisiones de arquitectura
  features.json        - Estado del proyecto (Solo Claw)
  planning/TASK.md     - Tareas activas
  planning/PLANNING.md - Scope y fases del proyecto

FEATURES.json          - Raíz del repo (Jules actualiza)
PROTOCOL.md            - Este archivo
ORIONHEALTH-ROADMAP.md - Roadmap del proyecto
```
