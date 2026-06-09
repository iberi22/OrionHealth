@echo off
cd /d E:\scripts-python\orionhealth
echo Merging PR 459 - Phase 3 BLE P2P...
gh pr merge 459 --repo iberi22/OrionHealth --merge --admin -t "Phase 3: Complete BLE P2P sharing implementation"
echo ---
echo Merging PR 460 - Phase 3 WiFi Direct...
gh pr merge 460 --repo iberi22/OrionHealth --merge --admin -t "Phase 3: Complete WiFi Direct P2P sharing"
echo ---
echo Merging PR 461 - Phase 4 Doctor Verification...
gh pr merge 461 --repo iberi22/OrionHealth --merge --admin -t "Phase 4: Doctor Verification - Persistence, BLoC, and Presentation"
echo ---
echo Merging PR 462 - Cleanup ble_sharing...
gh pr merge 462 --repo iberi22/OrionHealth --merge --admin -t "Chore: Consolidate ble_sharing into health_sharing feature"
echo ---
echo Merging PR 463 - Phase 5 Medical Concept...
gh pr merge 463 --repo iberi22/OrionHealth --merge --admin -t "Phase 5: Medical Concept + Timeline + FHIR Export"
echo ---
echo Merging PR 464 - Phase 6 Network Discovery...
gh pr merge 464 --repo iberi22/OrionHealth --merge --admin -t "Phase 6: Network node discovery + distributed cache"
echo ---
echo All merges attempted.
