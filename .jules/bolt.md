## 2026-07-27 - Optimize Calendar Rendering
**Learning:** Checking list properties continuously in an `itemBuilder` or nested loop for collection checking causes high complexity inside rendering, slowing down Flutter lists/grid/calendars. Pre-computing a `Set<DateTime>` of normalized dates outside `GridView.builder` turns an O(N*M) lookup into an O(1) hash lookup per day.
**Action:** Always pre-compute lookup collections outside rendering loops for list/grid items instead of iterating the entire list for each UI element.
