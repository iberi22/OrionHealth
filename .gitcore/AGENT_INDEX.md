# Agent Index — OrionHealth

| Agent | Role | Trigger | CLI/Tool |
|-------|------|---------|----------|
| **Jules AI** | Autonomous coding (features, bugs, enhancements) | GitHub Issue with label `jules` | `@jules-ai` in issue comment |
| **Claw** | Orquestador humano + merge + estabilización | Telegram commands | `claude -p`, `opencode run`, `codex exec` |
| **Gemini** | Deep research, análisis de codebase, migraciones | Telegram: analysis/research | `gemini -p "..."` |
| **OpenCode (MiniMax)** | Heavy coding, refactors, infrastructure | Telegram: heavy coding | `opencode run --model minimax/MiniMax-M2.7` |

## Routing Rules

| Etiqueta | Agente | Acción |
|----------|--------|--------|
| `jules` | **Jules AI** | Crea branch → implementa → PR → cierra issue |
| `fix` | **Claw** | Fix manual o subagente |
| `enhancement`, `feature` | Jules | Via GitHub Issue |
| `bug` | Jules | Via GitHub Issue |
| `research`, `analysis` | Gemini | Via Gemini CLI |

## Protocolo de Startup

1. Leer `.gitcore/features.json` → estado actual del proyecto
2. Leer `.gitcore/planning/TASK.md` → tareas activas
3. Revisar GitHub Issues con label `jules` → PRs creados
4. Ejecutar `dart analyze lib/ test/` → 0 errors requerido
5. Guardar decisión en xavier: `POST /memory/add`
