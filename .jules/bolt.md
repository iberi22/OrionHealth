## 2025-01-20 - Optimize Collection Lookups in Flutter itemBuilder
**Learning:** Using `List.any()` inside Flutter's `itemBuilder` for calendar or list views causes UI lag because it performs computationally expensive O(N) operations inside a frequently executed rendering loop.
**Action:** Pre-compute collection lookups outside the `itemBuilder` (e.g., using a `Set<DateTime>` normalized to year, month, and day for O(1) `contains()` checks) to avoid rendering bottlenecks.
