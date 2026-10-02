# Shared SWAL health fixtures

`valid/` and `invalid/` are copied verbatim from GOS's
`schemas/ecosystem/v1/fixtures/` at source commit **34b15de0**. Re-sync these files from the canonical contract;
do not edit the copied fixtures independently.

`ts-deep-link.json` is generated using the TS reference package's
`encodeDeepLink` and `valid/workout-session-01.json`. Its generator is
`generate_ts_fixture.mjs` (run with the source package built).
