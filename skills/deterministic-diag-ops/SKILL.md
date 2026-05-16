# Deterministic Project Diagnosis (deterministic-diag-ops)

High-level protocol for autonomous project diagnosis, system auditing, and deterministic feedback loops in OrionHealth.

## Overview

This skill provides a suite of tools to diagnose the state of the OrionHealth project deterministically. It avoids probabilistic guesses by relying on environment audits, dependency verification, and medical data integrity checks.

## Core Components

1.  **Environment Audit**: Captures OS details, Flutter/Dart versions, and critical binary availability (e.g., `isar.dll`).
2.  **Codebase Integrity**: Verifies that `pubspec.lock` is in sync and that local packages are correctly linked.
3.  **Medical Standards Audit**: Ensures that medical assets (ICD-10, SNOMED, LOINC) are present and structurally sound.
4.  **Deterministic Reports**: Generates structured reports (`DIAGNOSTIC_REPORT.md`, `diag.json`) for both humans and AI agents.

## Usage

### Run Full Diagnosis

To run a complete project diagnosis and generate a report:

```powershell
python skills/deterministic-diag-ops/scripts/diag.py
```

### Deep Verification (Includes Tests)

To run diagnosis including integration tests:

```powershell
python skills/deterministic-diag-ops/scripts/diag.py --deep
```

## Output Artifacts

- **`DIAGNOSTIC_REPORT.md`**: A human-readable summary of the project's health with premium styling.
- **`diag.json`**: A machine-readable state representation for automated processing by agents like Antigravity or Jules.

## Best Practices

- **Baseline First**: Always run a diagnosis before starting a major refactor or delegating tasks to Jules.
- **Isolate Failures**: Check the `diag.json` to identify if a failure is environmental (e.g., wrong Flutter version) or logical (e.g., broken tests).
- **Audit Sync**: Regularly run the diagnosis to ensure that medical standards assets haven't been corrupted or lost during development.
