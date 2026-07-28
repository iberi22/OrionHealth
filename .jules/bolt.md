## 2024-05-18 - Pre-compute collections for calendar O(1) lookups
**Learning:** Found a memory constraint note regarding: 'To prevent UI lag in Flutter calendar or list views, pre-compute collection lookups outside the `itemBuilder` (e.g., using a `Set<DateTime>` normalized to year, month, and day for `O(1)` `contains()` checks) rather than using computationally expensive `List.any()` checks inside the rendering loop.'
**Action:** Extract list checks to sets outside builder.
