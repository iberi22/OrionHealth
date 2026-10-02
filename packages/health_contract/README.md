# health_contract

Pure Dart receiver/producer for the canonical `swal.health/v1` contract.
The source is GOS `docs/ecosystem/CONTRATO-DATOS.md` and
`schemas/ecosystem/v1` (fixture baseline: `34b15de0`).

```dart
import 'package:health_contract/health_contract.dart';

final records = fromFile(jsonText); // validates every envelope
final data = records.first.data;
if (data is WorkoutSession) print(data.exercises.length);
final file = toFile(records);
final link = encodeDeepLink(records, 'https://orionhealth.example/import');
final restored = decodeDeepLink(link);
```

`validateRecord` returns `ValidationResult` (`ok`, immutable `errors`).
Model parsing and transports throw `ContractValidationError` with JSON Pointer
errors. Unknown fields are rejected. Dates remain strings and numbers remain
`num` so the original JSON values round-trip without offset/precision changes.
Nested collection constructors defensively copy to unmodifiable lists/maps.

Gzip works on Dart VM and web using `archive`. Deep link payloads are limited
to 8192 UTF-8 bytes and gzip inflation aborts above 1 MiB. `DeepLinkSizeError`
reports both the observed and allowed sizes and recommends file export.
HTTPS emits the payload in a fragment; the custom scheme emits it in a query.
TS's `j.` fallback is accepted. Data is neither encrypted nor authenticated.

The application must check subject identity, chronology and profile expiration,
and obtain consent before saving or sharing records.

Run `dart test`. Shared fixture tests check exact TS error parity, model/file/link
round-trips, TS gzip decoding, malformed transports and expansion/size limits.
