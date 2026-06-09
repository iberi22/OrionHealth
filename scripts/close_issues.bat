@echo off
cd /d E:\scripts-python\orionhealth
gh issue close 458 -c "Completado via PR #462 (cleanup). ARCHITECTURE.md actualizado, ble_sharing consolidado."
gh issue close 453 -c "Completado via PRs #461, #365, #366 (Doctor Verification: Isar persistence + BLoC + rating + license)."
gh issue close 456 -c "Completado via PR #463 (Phase 5: Medical Concept - notes, timeline, FHIR export)."
gh issue close 457 -c "Completado via PR #464 (Phase 6: Network node discovery + distributed cache)."
gh issue close 455 -c "Completado via PR #460 (Phase 3: WiFi Direct P2P sharing implementation)."
gh issue close 454 -c "Completado via PR #459 (Phase 3: BLE P2P sharing with flutter_blue_plus)."
echo "All issues closed"
