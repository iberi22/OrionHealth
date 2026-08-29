## 2026-08-29 - O(1) Calendar Grid Lookup

**Learning:** Iterating over lists with `List.any()` or `List.where()` inside calendar grid `itemBuilder` (which runs for 42 days/cells per frame) causes linear lookups O(42 * N) per render frame. For lists with many items (>50 appointments), this causes frame drops and sluggish scrolling.

**Action:** Pre-compute a `Map<DateTime, List<T>>` indexed by normalized `DateTime(year, month, day)` keys whenever the source data updates (in `initState` or when loading state), reducing cell lookup complexity from O(N) to O(1) per frame.
