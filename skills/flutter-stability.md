# Flutter Stability & Release Specialist Skill

## Objective
Diagnose and prevent release-mode failures (Black Screens, startup crashes) and ensure consistent performance across hardware.

## Black Screen (Release Mode) Troubleshooting
1. **The "Silent Fail" Diagnosis**:
   - Run `flutter run --release` while connected to see hidden runtime exceptions.
2. **Graphics & Rendering (Impeller)**:
   - On some Android hardware, **Impeller** causes black screens.
   - *Test Fix*: Disable Impeller in `AndroidManifest.xml` via `<meta-data android:name="io.flutter.embedding.android.EnableImpeller" android:value="false" />`.
3. **R8/ProGuard Code Stripping**:
   - Verify that necessary classes (especially those used in reflection or native interop) are not being stripped.
   - Check `proguard-rules.pro`.
4. **Initialization Deadlocks**:
   - Audit `main()` for `await` calls that might hang indefinitely if a service (like Firebase or a local DB) fails to respond in release mode.
5. **Native Permissions**:
   - Ensure `INTERNET` and other critical permissions are in the main `AndroidManifest.xml`, not just the debug one.
6. **Binary/Native Incompatibility**:
   - Check if native libs (like Isar or ONNX) support the specific architecture of the tablet (ARMv7 vs ARM64).

## Startup Robustness Checklist
- [ ] Wrap `main()` initialization in a global `try-catch`.
- [ ] Initialize `WidgetsFlutterBinding.ensureInitialized()` before any plugin call.
- [ ] Verify SHA-1/SHA-256 keys for Firebase/API services in release builds.
- [ ] Check for `MissingPluginException` in logs (indicates plugin not registered or stripped).
