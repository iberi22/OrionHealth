---
title: "API Reference"
description: "Complete API reference for OrionHealth — services, RAG pipeline, blocs, and native Android plugins"
order: 4
---

# API & State Management

## Blocs / State Management

OrionHealth uses `flutter_bloc` with Cubit for most features.

-   **HealthRecordCubit:** Manages medical records CRUD
-   **ReportsCubit:** Analytics and export state
-   **LocalAgentCubit:** AI chat session management
-   **BleSharingCubit:** BLE connection and data transfer
-   **UserProfileCubit:** Profile and preferences state
-   **SettingsCubit:** LLM toggle, theme, model management
-   **AuthCubit:** Biometric authentication state
-   **HealthDataImportCubit:** Upload and OCR progress
-   **MedicalAssistantCubit:** FAB assistant state
-   **MedicalResearchCubit:** RAG search and results
-   **VitalsCubit:** Vital signs tracking state
-   **MedicationsCubit:** Prescription management

## Android Native

Kotlin platform code bridging Dart to Android AICore / ML Kit for on-device AI inference.
- `AicorePlugin.kt`
- `AicoreServiceKt.kt`

## Internal Packages

-   `isar_agent_memory`: Graph-based agent memory with vector search capabilities. Core of the RAG system.
-   `health_wallet`: Offline health record storage with military-grade encryption.
-   `medical_standards`: Embedded medical coding standards for professional data interoperability (ICD-10, LOINC, RxNorm, SNOMED CT).
