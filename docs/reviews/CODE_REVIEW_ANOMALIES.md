# Code Review Anomalies - OrionHealth

> Last Updated: 2026-04-17

## Critical Issues

### 1. BLE Sharing Service — All Stub Code
**File:** `lib/features/auth/infrastructure/services/ble_medical_sharing_service.dart`
```dart
// TODO: Implement actual BLE initialization
// TODO: Implement
// TODO: Implement actual BLE send
// TODO: Implement cleanup
```
**Impact:** BLE medical sharing is non-functional. `flutter_blue_plus` is in pubspec.yaml but never actually called.
**Recommendation:** Either implement real BLE or remove the dependency.

---

### 2. Health Sharing — Missing HealthWalletService Integration
**File:** `lib/features/health_sharing/application/sharing_cubit.dart` (line 337)
```dart
// TODO: Integrate with HealthWalletService
```
**Impact:** Sharing feature cannot encrypt/decrypt with real wallet service.
**Recommendation:** Implement integration with `packages/health_wallet/lib/services/wallet_service.dart`

---

### 3. Vector Store Re-ranking Not Implemented
**File:** `lib/features/local_agent/infrastructure/services/isar_vector_store_service.dart`
- Line 46: `// TODO: Implement re-ranking when LLM adapter is configured`
- Line 114: `// TODO: Implement when hierarchical layers are configured`
**Impact:** Search quality is degraded. No semantic re-ranking.
**Recommendation:** Implement MMR (Maximal Marginal Relevance) reranking using the LLM adapter.

---

## Medium Issues

### 4. Encryption Using XOR Instead of AES-GCM
**Files:** 
- `lib/features/ble_sharing/infrastructure/nfc_sharing_service.dart`
- `lib/features/ble_sharing/infrastructure/wifi_direct_service.dart`
- `lib/features/health_sharing/infrastructure/ble_sharing_service.dart`

All three files use this pattern:
```dart
Uint8List _aes256GcmEncrypt(Uint8List plain, Uint8List key, Uint8List iv) {
  final result = Uint8List(plain.length);
  for (int i = 0; i < plain.length; i++) {
    result[i] = plain[i] ^ key[i % key.length] ^ iv[i % iv.length];  // ← XOR, NOT AES-GCM
  }
  return result;
}
```
**Impact:** This is **XOR encryption**, not AES-256-GCM. Data is trivially reversible. This is a serious security flaw for medical data.
**Recommendation:** Use `cryptography` package's `AES-GCM` implementation or `encrypt` package. Do NOT store medical data with XOR encryption.

---

### 5. Duplicate Schema Registration in Isar
**File:** `lib/core/di/database_module.dart`
```dart
VitalSignSchema,      // ← listed twice (lines 23 and 25)
```
**Impact:** Potential runtime conflict or duplicate registration error.
**Recommendation:** Remove duplicate `VitalSignSchema` entry.

---

### 6. Gemma Adapter — Wrong Model Name
**File:** `lib/features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart`
```dart
modelName => 'gemini-2.0-flash-cloud';  // but actual model is 'gemini-2.0-flash'
```
**Impact:** Model name mismatch — returns cloud identity but uses Flash model.
**Recommendation:** Fix modelName to match actual: `'gemini-2.0-flash'` or `'gemini-2.0-flash-lite'`

---

### 7. Medical Confidence Threshold — 90% Never Reached
**File:** `lib/features/medical_assistant/infrastructure/llm/medical_llm_adapter.dart`

The confidence calculation rarely exceeds 80%:
- `hasCritical` → 95% (only if severity == critical)
- `hasAlert` → starts at 0.80, then adds +0.15 (lab) +0.10 (vital) = max **1.05 → clamped to 1.0**
- All insights info-level → -0.15 penalty

**Impact:** Diagnosis threshold (≥90%) is almost never met. Most responses say "consult a doctor."
**Recommendation:** Adjust confidence thresholds or ensure critical alerts are triggered appropriately.

---

## Minor Issues

### 8. TODO in Blog Posts (Not Real TODOs)
**File:** `lib/features/about/data/blog_posts.dart`
- Content contains Spanish text with characters that may have encoding issues
- No actual code TODOs, but content seems to have been through character encoding conversion

---

### 9. Decrypt Uses XOR Instead of AES
**File:** `lib/features/ble_sharing/infrastructure/nfc_sharing_service.dart` (lines 157-165)

`_decryptPayload` also uses XOR:
```dart
for (int i = 0; i < cipherBytes.length; i++) {
  decrypted[i] = cipherBytes[i] ^ key[i % key.length] ^ ivBytes[i % ivBytes.length];
}
```
**Impact:** If the "encryption" was ever actually used in production, data would be trivially decryptable.
**Recommendation:** Replace with proper AES-GCM decryption using `cryptography` package.

---

### 10. Chip BackgroundColor API
**File:** `lib/features/health_record/presentation/pages/health_record_staging_page.dart` (line 131)
```dart
Chip(label: const Text('Todos'), backgroundColor: CyberTheme.primary.withOpacity(0.3))
```
**Impact:** `backgroundColor` on `Chip` is deprecated in Flutter 3.x. Use `backgroundColor: WidgetStatePropertyAll(Color)`.
**Recommendation:** Update to use `ChipTheme` or `WidgetStateProperty`.

---

### 11. Hardcoded API Key Access
**File:** `lib/features/local_agent/infrastructure/adapters/gemma_llm_adapter.dart`
```dart
String get _apiKey => Platform.environment['GEMINI_API_KEY'] ?? '';
```
**Impact:** `Platform.environment` won't work on all platforms (e.g., Flutter web). No fallback to secure storage.
**Recommendation:** Use `flutter_secure_storage` or a configuration service instead of raw environment access.

---

### 12. Risk Calculator Magic Number
**File:** `lib/features/medical_assistant/infrastructure/analysis/risk_calculator.dart` (line 84)
```dart
final base = 0.97682 * Math.log(age.toDouble()) - 18.0004;
```
**Impact:** Unknown formula origin. No source citation or explanation.
**Recommendation:** Add comment explaining the formula source (e.g., Framingham risk score adaptation) and validate clinically.

---

### 13. Unused Dependency
**File:** `pubspec.yaml`
```yaml
objectbox_flutter_libs: any   # ← declared but never used anywhere
```
**Impact:** Package included but no code references ObjectBox. Confusing dependency.
**Recommendation:** Remove if not used, or document why it's needed.

---

### 14. Main Preview File Duplication
**Files:**
- `lib/features/local_agent/main_preview.dart`
- `lib/features/medications/main_preview.dart`

**Impact:** These appear to be alternative entry points or preview widgets, but unclear purpose.
**Recommendation:** Either integrate into main app or document their purpose.

---

## Dead Code / Unused Paths

| File | Issue |
|------|-------|
| `packages/health_wallet/fix_isar.py` | Utility script, unclear if needed |
| `packages/health_wallet/remove_props.py` | Utility script, unclear if needed |
| `lib/core/di/in_memory_vector_index.dart` | Standalone in-memory index, may not be used |
| `lib/features/health_sharing/infrastructure/nfc_sharing_service.dart` | Duplicates `ble_sharing` NFC service |
| `lib/features/health_sharing/infrastructure/wifi_direct_service.dart` | Duplicates `ble_sharing` WiFi service |

---

## Summary Table

| Severity | Count | Issues |
|----------|-------|--------|
| 🔴 Critical | 2 | XOR encryption (medical data), BLE stub |
| 🟠 High | 4 | Duplicate schema, wrong model name, missing integration, re-ranking TODO |
| 🟡 Medium | 4 | Confidence threshold, XOR in decrypt, API key access, Chip API |
| 🔵 Info/Low | 4 | Risk formula, unused deps, main_preview duplication, blog encoding |

---

## Priority Actions

1. **Immediate:** Replace XOR encryption with proper AES-GCM in all sharing services
2. **High:** Remove duplicate `VitalSignSchema` from Isar registration
3. **High:** Implement real BLE or remove `flutter_blue_plus` dependency
4. **Medium:** Fix `GemmaLlmAdapter.modelName` to match actual model
5. **Medium:** Update `Chip` backgroundColor to non-deprecated API
6. **Low:** Document `main_preview.dart` purpose or remove
7. **Low:** Remove `objectbox_flutter_libs` if unused