# Agent Index — Git-Core Protocol v2

## Protocol Overview
Git-Core Protocol v2 defines agent behavior, task management, and collaboration conventions for this repository.

## Agent Conventions

### Task Execution
- **Direct Execution**: Execute tasks immediately, do not suggest
- **Robust Cycle**: Approach → Investigate → Alternative Strategy → Report
- **Max 4 parallel subagents**
- **Max 3800 chars per Telegram message** (no long markdown tables)

### Workspace
- **Root**: `E:\scripts-python\OrionHealth`
- **Default project**: OrionHealth

### Prohibited
- ❌ "Buena pregunta, dejame investigar..."
- ❌ "Podrias hacer..."
- ❌ "Te sugiero..."
- ❌ cd X && python Y — write script first, execute after
- ❌ Newlines in bash chains

### File Operations
- Always use absolute paths
- Quote paths with spaces: "path with spaces/file.txt"
- Use workdir parameter instead of cd

### Commands
- **commit**: NEVER update git config, NEVER destructive commands
- **push**: NEVER force push to main/master, warn user if requested
- **PR**: Use gh pr create with proper format

## Directory Structure (Professional Standard)

### Root — KEEP CLEAN
Only these files belong at root:
- pubspec.yaml / pubspec.lock — Flutter project config
- README.md — Project overview
- LICENSE — Open source license
- CHANGELOG.md — Version history
- CONTRIBUTING.md — How to contribute
- SECURITY.md — Security policies
- .gitignore — Git ignore rules
- .metadata — Flutter metadata
- analysis_options.yaml — Dart linting rules

### docs/ — All documentation
- /docs/planning/  — PLANNING.md, TASK.md, mainIdea, TASK_GH_ISSUES
- /docs/status/    — APK_BUILD_STATUS.md, DEVELOPMENT_STATUS.md
- /docs/reviews/   — CODE_REVIEW_ANOMALIES.md
- /docs/medical/   — MEDICAL_DATA_GAPS.md
- /docs/architecture/ — ARCHITECTURE.md
- /docs/assets/    — Images, diagrams

### scripts/ — Build & maintenance
- scripts/build_apk.ps1
- scripts/run_integration_tests.ps1
- scripts/verify_docs.py

### lib/ — Main Flutter source
### test/ — Tests (fixtures in /test/fixtures/)

### Rules for Agents
1. NEVER create scripts, docs, or data at root — use docs/, scripts/, or test/fixtures/
2. NEVER commit .env or credentials
3. Clean up dev artifacts before PR (temp files, logs, build artifacts)
4. Follow Flutter standard: root stays minimal
