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
- ❌ "Buena pregunta, déjame investigar..."
- ❌ "Podrías hacer..."
- ❌ "Te sugiero..."
- ❌ `cd X && python Y` — write script first, execute after
- ❌ Newlines in bash chains

### File Operations
- Always use absolute paths
- Quote paths with spaces: `"path with spaces/file.txt"`
- Use `workdir` parameter instead of `cd`

### Commands
- **commit**: NEVER update git config, NEVER destructive commands
- **push**: NEVER force push to main/master, warn user if requested
- **PR**: Use `gh pr create` with proper format

## Task Templates

### Planning (`PLANNING.md`)
- Context
- Goals
- Architecture decisions
- Implementation plan

### Task (`TASK.md`)
- Objective
- Steps
- Verification
- Notes

## Directory Structure
```
.gitcore/
├── version           # Protocol version
├── AGENT_INDEX.md    # This file
├── planning/         # Planning templates
│   ├── PLANNING.md
│   └── TASK.md
├── features/         # Feature documentation
└── src/             # Source documentation
```

## CI/CD Integration
All workflows must check for `.gitcore/version` and validate protocol compliance.
