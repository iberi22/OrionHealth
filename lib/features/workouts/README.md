# Workouts

Receives validated `swal.health/v1/workout-session` envelopes through the health data import feature. A local `WorkoutSession` Isar collection keeps embedded exercise references and sets, energy provenance, and the original envelope for lossless portability. Import checks consent and device subject identity before saving; storage also rejects reversed time ranges. The unique record ID makes repeat imports idempotent.

`WorkoutRepository` separates persistence from the list/detail UI. Open workout history from the fitness icon on the vitals page. Active energy is displayed in kcal by the vitals model.

The existing Reports → Export FHIR flow appends workout activity Observations to the wallet bundle. The panel uses LOINC 73985-4, with duration (55411-3, UCUM seconds) and optional energy (41981-2, kcal). The local pseudonymous subject is retained as an identifier. Source exercise references and set details remain in the original ecosystem envelope, not in the FHIR panel.

Imported workouts, meals, and dietary profiles are included in the user-requested GDPR ZIP export and removed by the existing right-to-erasure operation. Ecosystem sharing continues to export only dietary profiles with explicit consent.

Verification: `flutter test test/features/workouts/workout_contract_test.dart` covers nested records, timestamps, FHIR components, existing bundle retention, and list/detail navigation.
