## 2024-07-22 - [Avoid O(n) lookups in Flutter builder methods]
**Learning:** In Flutter, doing O(n) lookups like `List.any()` inside `itemBuilder` loops (like in `GridView.builder` or `ListView.builder`) can cause UI lag because they run for every rendered item. In `appointments_page.dart`, `_allAppointments.any()` was called for every day in the calendar grid.
**Action:** Always pre-compute a lookup structure like a `Set` (O(1)) before the builder to improve rendering performance.
