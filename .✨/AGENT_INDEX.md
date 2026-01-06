---
title: "Agent & Skill Index"
type: INDEX
id: "index-agents"
created: 2025-12-01
updated: 2025-12-01
agent: copilot
model: auto-generated
requested_by: system
summary: |
  Index of available agent roles and skills for this flutter project.
keywords: [agents, index, skills, roles, dart]
tags: ["#index", "#agents", "#flutter"]
project: orionhealth
---

# 🧠 Agent & Skill Index

## 🔍 Project Detection
- **Type:** flutter
- **Language:** dart
- **Framework:** flutter

## 🚦 Routing Logic

When the user prompts for a task, identify the **Domain** and **Role**.
Then, run the `equip-agent` script to load that persona.

---
## 📂 Domain: Flutter/Dart Development

| Role | Description | Recommended Skills |
|------|-------------|-------------------|
| **Flutter Architect** | App architecture, state management, Clean Architecture | `clean-arch`, `bloc`, `di` |
| **Widget Builder** | Custom widgets, animations, responsive UI | `widgets`, `animations`, `responsive` |
| **State Manager** | BLoC/Cubit, Riverpod, Provider patterns | `bloc`, `cubit`, `state-management` |
| **Platform Integrator** | Native code, method channels, plugins | `platform-channels`, `plugins` |
| **Test Engineer** | Widget tests, integration tests, golden tests | `widget-test`, `integration-test` |
| **Performance Optimizer** | DevTools, memory leaks, build optimization | `devtools`, `performance` |

### 🔧 Flutter-Specific Commands
```bash
# Run widget tests
flutter test

# Run integration tests
flutter test integration_test/

# Analyze code
flutter analyze

# Build release APK
flutter build apk --release
```

---

## 📂 Domain: Product & Design

| Role | Description | Recommended Skills |
|------|-------------|-------------------|
| **UI Designer** | Visual interface design | `figma`, `tailwind` |
| **UX Researcher** | User flows, empathy mapping | `user-interviews` |
| **Sprint Prioritizer** | Backlog management, sprint planning | `agile-scrum` |

---

## 🛠️ How to Equip an Agent

```powershell
# PowerShell
.\scripts\equip-agent.ps1 -Role "Flutter Architect"
```

```bash
# Bash
./scripts/equip-agent.sh --role "Flutter Architect"
```

After equipping, the agent context will be written to `.✨/CURRENT_CONTEXT.md`.

