@echo off
cd /d E:\scripts-python\orionhealth

echo Creating Phase 4: Doctor Verification issue...
gh issue create --repo iberi22/OrionHealth ^
  --title "[feat] Phase 4: Doctor Verification - Isar persistence + BLoC + presentation" ^
  --label "jules" ^
  --body "## Objective
Complete the Doctor Verification feature (Phase 4). Domain layer exists: DoctorProfile, DoctorRating, DoctorProfileRepository, RatingRepository interfaces, LicenseVerifier, LicenseRegistryLocal.

## Files to create
1. lib/features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart
2. lib/features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart
3. lib/features/doctor_verification/application/doctor_verification_cubit.dart
4. lib/features/doctor_verification/application/doctor_verification_state.dart
5. lib/features/doctor_verification/presentation/pages/doctor_search_page.dart
6. lib/features/doctor_verification/presentation/pages/doctor_profile_page.dart
7. lib/features/doctor_verification/presentation/pages/doctor_list_page.dart
8. lib/features/doctor_verification/presentation/widgets/doctor_card.dart
9. lib/features/doctor_verification/presentation/widgets/rating_widget.dart
10. lib/features/doctor_verification/presentation/widgets/license_badge.dart

## Files to modify
1. lib/core/di/database_module.dart (add DoctorProfileSchema, DoctorRatingSchema)
2. lib/core/di/injection.dart (register new services)
3. lib/features/home/presentation/pages/main_navigation_page.dart (add nav entries)

## Pattern to follow
- health_record feature: Cubit + Isar repository + presentation
- reports feature: BLoC with ReportBloc pattern
- auth feature: Cubit with AuthCubit pattern

## Acceptance criteria
- Doctor profiles save/load from Isar
- Doctor ratings save/query by doctorId
- License verification with local hash registry
- Doctor search by name/specialty/location
- Doctor profile page with details + ratings
- Rating input widget (1-5 stars with categories)
- License badge (verified/unverified/unknown)"
echo Phase 4 issue created.

echo Creating Phase 3: P2P BLE completion issue...
gh issue create --repo iberi22/OrionHealth ^
  --title "[feat] Phase 3: Complete BLE P2P sharing with real flutter_blue_plus implementation" ^
  --label "jules" ^
  --body "## Objective
Complete the Phase 3 P2P sharing implementation. Infrastructure stubs exist in lib/features/health_sharing/ but use // In production: comments instead of real flutter_blue_plus calls.

## Files to modify
1. lib/features/health_sharing/infrastructure/ble_sharing_service.dart (connect real flutter_blue_plus)
2. lib/features/health_sharing/infrastructure/nfc_sharing_service.dart (connect real nfc_manager)
3. lib/features/health_sharing/application/sharing_cubit.dart (wire real services)
4. lib/features/health_sharing/presentation/pages/share_page.dart (real UI)
5. lib/features/health_sharing/presentation/pages/receive_page.dart (real UI)

## Cleanup task
- Merge lib/features/ble_sharing/ into lib/features/health_sharing/ (duplicate feature)
- Remove lib/features/ble_sharing/ after merge

## Pattern to follow
- Existing health_sharing infrastructure (already has correct architecture)
- Replace // In production: comments with real flutter_blue_plus calls
- Use BluetoothGatt, BluetoothDevice, scan, connect, discoverServices, read/write characteristic

## Technical details
- BLE service UUID: 4fafc201-1fb5-459e-8fcc-c5c9c331914b
- TX characteristic: beb5483e-36e1-4688-b7f5-ea07361b26a8
- RX characteristic: beb5483e-36e1-4688-b7f5-ea07361b26a9
- Use flutter_blue_plus: startScan, stopScan, connect, disconnect, read, write
- NFC use nfc_manager: NdefMessage, NdefRecord

## Acceptance criteria
- BLE scan discovers nearby OrionHealth devices
- BLE connect + GATT service discovery works
- Encrypted health package transfer over BLE characteristic
- NFC tap-to-share works (NDEF beam)
- Wire it through sharing_cubit with proper state management
- Remove duplicate ble_sharing feature folder"
echo Phase 3 issue created.

echo Creating Phase 3: P2P WiFi completion issue...
gh issue create --repo iberi22/OrionHealth ^
  --title "[feat] Phase 3: Complete WiFi Direct P2P sharing" ^
  --label "jules" ^
  --body "## Objective
Complete the WiFi Direct P2P sharing. The WifiDirectService in lib/features/health_sharing/infrastructure/wifi_direct_service.dart has real HTTP server code but uses stub device discovery.

## Files to modify
1. lib/features/health_sharing/infrastructure/wifi_direct_service.dart (real device discovery)
2. lib/features/health_sharing/presentation/pages/share_page.dart (WiFi tab)
3. lib/features/health_sharing/presentation/pages/receive_page.dart (WiFi tab)

## Technical details
- HTTP server on port 9124 already implemented
- POST /orion/share endpoint works with SharedHealthPackage
- Replace stub device list with real connectivity_plus or wifi_iot scan
- Add PIN verification flow for WiFi transfers
- Add connection timeout handling

## Acceptance criteria
- WiFi Direct device discovery works
- HTTP server starts on port 9124
- Package transfer via POST /orion/share
- PIN verification before transfer
- Reconnection on timeout"
echo Phase 3 WiFi issue created.

echo Creating Phase 5: Medical Concept feature...
gh issue create --repo iberi22/OrionHealth ^
  --title "[feat] Phase 5: Medical Concept feature - doctor notes + timeline + FHIR export" ^
  --label "jules" ^
  --body "## Objective
Create the Medical Concept feature (Phase 5) from scratch following the existing feature patterns.

## Files to create

### Domain
1. lib/features/medical_concept/domain/entities/medical_concept.dart
2. lib/features/medical_concept/domain/entities/doctor_note.dart
3. lib/features/medical_concept/domain/entities/timeline_entry.dart
4. lib/features/medical_concept/domain/repositories/medical_concept_repository.dart
5. lib/features/medical_concept/domain/services/timeline_service.dart

### Infrastructure
6. lib/features/medical_concept/infrastructure/repositories/isar_medical_concept_repository.dart
7. lib/features/medical_concept/infrastructure/services/concept_to_fhir_mapper.dart

### Application
8. lib/features/medical_concept/application/medical_concept_cubit.dart
9. lib/features/medical_concept/application/medical_concept_state.dart

### Presentation
10. lib/features/medical_concept/presentation/pages/concept_dashboard_page.dart
11. lib/features/medical_concept/presentation/pages/timeline_page.dart
12. lib/features/medical_concept/presentation/pages/doctor_note_page.dart
13. lib/features/medical_concept/presentation/widgets/concept_card.dart
14. lib/features/medical_concept/presentation/widgets/timeline_entry_widget.dart
15. lib/features/medical_concept/presentation/widgets/fhir_export_button.dart

### Database
16. Add MedicalConceptSchema, DoctorNoteSchema, TimelineEntrySchema to lib/core/di/database_module.dart

## Patterns to follow
- reports feature: domain/entities/report.dart, infrastructure/repositories/, application/bloc/, presentation/
- health_record feature: domain/entities/medical_record.dart with Attachments
- Appointments feature: domain/entities/appointment.dart pattern

## Technical details
- MedicalConcept links DoctorNotes, TimelineEntries, FHIR resources
- Timeline shows chronological view of all medical events
- FHIR export uses lib/features/sync/data/fhir_mapper.dart pattern
- DoctorNote supports markdown text + structured fields (diagnosis, prescription, visitDate)
- Use Isar for persistence with @collection decorators
- Run dart run build_runner build after creation

## Acceptance criteria
- Doctor notes can be created/saved/edited/deleted
- Timeline view shows chronological medical history
- FHIR R4 export for notes and concepts
- External data import from health_record feature
- Concept dashboard with summary cards"
echo Phase 5 issue created.

echo Creating Phase 6: Network Discovery issue...
gh issue create --repo iberi22/OrionHealth ^
  --title "[feat] Phase 6: Network node discovery + distributed cache" ^
  --label "jules" ^
  --body "## Objective
Create the Network Expansion feature (Phase 6) foundation: node discovery, distributed cache for medical standards, and governance mechanisms.

## Files to create

### Domain
1. lib/features/network/domain/entities/network_node.dart
2. lib/features/network/domain/entities/node_discovery_result.dart
3. lib/features/network/domain/repositories/node_repository.dart
4. lib/features/network/domain/services/discovery_service.dart
5. lib/features/network/domain/services/distributed_cache_service.dart

### Infrastructure
6. lib/features/network/infrastructure/services/mdns_discovery_service.dart
7. lib/features/network/infrastructure/services/ipfs_cache_service.dart (stub)
8. lib/features/network/infrastructure/repositories/isar_node_repository.dart

### Application
9. lib/features/network/application/network_cubit.dart
10. lib/features/network/application/network_state.dart

### Presentation
11. lib/features/network/presentation/pages/network_dashboard_page.dart
12. lib/features/network/presentation/widgets/node_card.dart
13. lib/features/network/presentation/widgets/cache_status_widget.dart

### Database
14. Add NetworkNodeSchema to lib/core/di/database_module.dart

## Pattern to follow
- health_sharing feature for discovery patterns
- medical_standards package for cache patterns

## Technical details
- Use mDNS for local network node discovery
- Nodes advertise via service type _orionhealth._tcp
- Cache system downloads public medical standards on-demand
- Node status flags: online, offline, syncing, error

## Acceptance criteria
- Local network node discovery via mDNS
- Node list with online/offline status
- Distributed cache service stub (IPFS/Filecoin interface)
- Network dashboard with node list"
echo Phase 6 issue created.

echo Creating repo cleanup issue...
gh issue create --repo iberi22/OrionHealth ^
  --title "[chore] Cleanup: consolidate ble_sharing feature + update ARCHITECTURE.md" ^
  --label "jules" ^
  --body "## Objective
Cleanup technical debt: consolidate duplicate ble_sharing/health_sharing features and update documentation to match current codebase state.

## Tasks

### Feature consolidation
1. Verify lib/features/ble_sharing/ and lib/features/health_sharing/ are duplicates
2. Migrate any unique code from ble_sharing/ to health_sharing/
3. Remove lib/features/ble_sharing/ folder
4. Update all imports referencing ble_sharing to health_sharing
5. Update lib/core/di/injection.dart and injection.config.dart
6. Run flutter analyze to confirm zero issues

### Documentation updates
1. docs/ARCHITECTURE.md:
   - features/health_report -> features/reports
   - Remove references to ble_sharing
   - Update doctor_verification status from TODO to In Progress
   - Add medical_concept to package structure
2. docs/ORIONHEALTH-ROADMAP.md:
   - Update version from 1.0.0 to 0.8.1
   - Update Phase 3 status from In Progress to complete
   - Update Phase 4 status from TODO to In Progress

## Acceptance criteria
- ble_sharing/ folder removed
- No broken imports
- flutter analyze passes with zero issues
- ARCHITECTURE.md matches actual codebase
- ROADMAP.md version and status accurate"
echo Cleanup issue created.

echo All 5 issues created successfully!
