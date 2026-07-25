
## 2023-10-27 - [Optimize Calendar View Rendering]
**Learning:** In Flutter calendar or list views, `List.any()` checks inside the rendering loop (`itemBuilder`) lead to severe UI rendering bottlenecks (O(N*M) time complexity).
**Action:** Pre-compute collection lookups (e.g., a `Set` of relevant dates mapped by year, month, and day) outside the `itemBuilder` and use `Set.contains()` inside the loop for fast O(1) lookups.
