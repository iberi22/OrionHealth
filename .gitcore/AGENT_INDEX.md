# Agent Index — OrionHealth

This document describes how automated coding agents interact with this repository.

## Agent Integration

| Agent Type | Scope | Trigger | Activation |
|---|---|---|---|
| **AI Coding Agent** | Autonomous coding (features, bugs, enhancements) | GitHub Issue with agent label | Comment tag in issue |

## Label Convention

| Label | Agent Type | Action |
|---|---|---|
| `ai-task`, `enhancement`, `feature` | AI Agent | Creates branch → implements → PR → closes issue |
| `bug` | AI Agent | Via GitHub Issue |

## Workflow

1. Human creates GitHub Issue with clear description + scope (max 1-3 files)
2. Add appropriate label (`ai-task`, `enhancement`, `bug`)
3. Agent detects label, creates branch, implements, opens PR
4. Human reviews and merges PR
5. Agent auto-closes issue when PR merges

## Rules

- Max 1-3 files per issue
- One feature/task = one issue
- Large issues cause failures — split into smaller pieces
- Repository must be pushed to GitHub before assigning to agent
