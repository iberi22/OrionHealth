# Jules Integration Pipeline — OrionHealth

> **Design Document v1.0** | Created: 2026-05-07

---

## 1. Current State Analysis

### Jules Performance on OrionHealth
| Metric | Value |
|--------|-------|
| Total Sessions | 9 |
| Completed | 8 ✅ |
| Failed | 0 ❌ |
| Success Rate | **89%** |
| Session 6514800172078676102 | Planning (PR #112 conflicts) |

**Jules works well on OrionHealth!** The UX sprint (#143-#149) shows 100% success.

---

## 2. Jules Pipeline Design

### 2.1 Task Router Decision Tree

```
User Request
     │
     ▼
┌─────────────────────────────────────────┐
│ Is it code/engineering?                  │
│                                         │
│   NO → OpenCode (MiniMax-M2.7) direct    │
│   YES → Continue                        │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ How many files does it touch?             │
│                                         │
│   1-3 files → Jules (GUARANTEED SUCCESS) │
│   4-6 files → SPLIT into 2+ issues      │
│   7+ files → Epic = FAIL (don't do it)   │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ Is repo clean + pushed?                  │
│                                         │
│   NO → Clean up first, then Jules        │
│   YES → Continue                         │
└─────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│ Create issue + label `jules`             │
│ OR                                      │
│ jules new --repo iberi22/OrionHealth "..." │
└─────────────────────────────────────────┘
```

### 2.2 OrionHealth Task Categories

| Category | Examples | Tool | Size Limit |
|----------|----------|------|------------|
| **Bug Fix** | Fix layout bug, NPE | Jules | 1 file ✅ |
| **Feature (small)** | Add 1 widget, 1 method | Jules | 1-3 files ✅ |
| **Feature (large)** | Full E2EE, new module | **SPLIT** | 1-3 files each |
| **Docs** | Add page, update guide | OpenCode | Direct |
| **Quick fix** | Typo, small patch | OpenCode | Direct |
| **Analysis** | Security audit, perf | Gestalt Swarm | N/A |
| **Heavy refactor** | Modularize 100KB file | **SPLIT** | 1-3 files each |

---

## 3. Jules Issue Template for OrionHealth

```markdown
## [type] Short description

### Target Files (1-3 MAX)
- `lib/features/xxx/presentation/pages/xxx_page.dart`
- `lib/features/xxx/application/xxx_cubit.dart`

### Task
1. In `xxx_page.dart` (lines Y-Z): Do ABC
2. In `xxx_cubit.dart`: Add XYZ method

### Success Criteria
- `dart analyze` passes with 0 errors
- Feature works as expected
- No breaking changes

### Context
[Any extra context Jules needs]
```

---

## 4. Workflow Integration

### 4.1 Standard SWAL Pipeline for OrionHealth

```
1. USER REQUEST
        │
        ▼
2. ROUTE (me as orchestrator)
   - Quick/direct → OpenCode immediately
   - Complex/heavy → Create Jules issue
        │
        ▼
3. JULES EXECUTION (async)
   - 1-3 files per issue
   - Monitoring via: jules remote list --session
   - Status: Planning → In Progress → Completed/Failed
        │
        ▼
4. APPLY RESULTS
   - jules remote pull --session <ID> --apply
   - Review code
   - Run dart analyze
        │
        ▼
5. PR CREATION
   - Create PR with Jules changes
   - Label: `jules` if more work needed
   - Review and merge
```

### 4.2 Monitoring Commands

```bash
# Check all OrionHealth Jules sessions
jules remote list --session --repo iberi22/OrionHealth

# Check specific session status
jules remote pull --session <ID>

# Apply completed session
jules remote pull --session <ID> --apply

# List pending issues (without jules label)
gh issue list --repo iberi22/OrionHealth --state open --label "enhancement,bug"
```

---

## 5. Jules Ready Issues Queue

### Issues Already Created (Priority Order)

*No open issues currently.* Last batch completed via `#514-#520` (golden tests — all closed).

### Issues to Create (Updated 2026-06-10)

Based on latest coverage report (code-verified). Refer to [`coverage_report.md`](../coverage_report.md).

| Issue | Title | Files | Jules? | Priority |
|-------|-------|-------|--------|----------|
| — | feat(ai_assistant): add domain + application + infrastructure layers | 4-6 files | ⚠️ SPLIT into 2 issues | 🔴 CRITICAL |
| — | feat(about): add domain + application layers, migrate data→infra | 3-4 files | ✅ (1-3 files each after split) | 🔴 HIGH |
| — | feat(calendar_import): add application layer, migrate data→infra | 2-3 files | ✅ | 🟡 MEDIUM |
| — | feat(health_data_import): add infrastructure layer | 1 file | ✅ | 🟡 MEDIUM |
| — | test(golden): add golden screenshot tests for appointments | 1 file | ✅ | 🟢 LOW |
| — | test(golden): add golden screenshot tests for ssi | 1 file | ✅ | 🟢 LOW |
| — | test(golden): add golden screenshot tests for sync | 1 file | ✅ | 🟢 LOW |
| — | test(golden): add golden screenshot tests for vitals | 1 file | ✅ | 🟢 LOW |
| — | test: add unit tests for ai_assistant (domain) after layers created | 1 file | ✅ | 🔴 CRITICAL |
| — | fix: email-citas golden test — MissingPluginException (2 fails) | 1 file | ✅ | 🟡 MEDIUM |

---

## 6. Anti-Patterns (Jules Fails)

### ❌ NEVER DO
1. **Large epics** - "Implement full security E2EE" = FAIL
2. **Dirty repo** - Uncommitted changes = FAIL
3. **Vague issues** - "Fix the bug" = FAIL
4. **10+ files** - Single issue touching 10 files = FAIL

### ✅ ALWAYS DO
1. **Small bounded tasks** - 1-3 files = SUCCESS
2. **Clean repo** - `git status` clean = SUCCESS
3. **Specific prompts** - "Fix line 45 in cli.rs" = SUCCESS
4. **Multiple small issues** - 10 small issues > 1 epic

---

## 7. Capacity Planning

### Jules Capacity (15 concurrent)
| Status | Count |
|--------|-------|
| Planning/In Progress | 1 (#152) |
| Available | 14 |
| Max Used | 15 |

### OrionHealth Current Load
- 1 active Jules session (#152 - PR #112 conflicts)
- 0 queued Jules issues

### Recommendation
We can assign up to **14 more Jules issues** right now for OrionHealth.

---

## 8. Next Actions

### Immediate (Today)
- [ ] Monitor #152 (PR #112) - Jules is working on it
- [ ] Create #153 (Analytics) for Jules
- [ ] Create #154 (NFC fix) for Jules
- [ ] Split remaining work into small issues

### This Week
- [ ] Apply #152 when complete
- [ ] Create PR for #153, #154
- [ ] Monitor and apply completed sessions

### Ongoing
- [ ] Weekly: Review Jules sessions status
- [ ] Weekly: Create small issues for pending work
- [ ] Weekly: Apply completed sessions before expiry (7 days)

---

## 9. Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│  JULES FOR ORIONHEALTH - QUICK REF                      │
├─────────────────────────────────────────────────────────┤
│  ✅ 1-3 files = Jules success                          │
│  ❌ 7+ files = Jules fails                             │
│  ⚠️ Repo must be clean before Jules                     │
│  📊 jules remote list --session --repo iberi22/OrionHealth │
│  ✅ jules new --repo iberi22/OrionHealth "fix 1 file"  │
│  🏷️ gh issue edit <NUM> --add-label jules               │
│  ⏱️ Sessions expire after 7 days                        │
└─────────────────────────────────────────────────────────┘
```

---

*Document version: 1.0*
*Created by: SWAL Orchestrator*
*Last updated: 2026-05-07 17:57 GMT-5*
