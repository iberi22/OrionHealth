## 2026-07-24 - [AppointmentsPage GridView optimization]
**Learning:** Pre-computing a `Set` of items instead of repeatedly calling `.any()` inside a  loop yields a highly effective  vs  performance optimization in Flutter.
**Action:** Always look for O(N) operations inside  functions of long lists or grids and replace them with O(1) lookups using pre-computed Sets or Maps.
## 2026-07-24 - [AppointmentsPage GridView optimization]
**Learning:** Pre-computing a Set of items instead of repeatedly calling .any() inside a GridView.builder loop yields a highly effective O(1) vs O(N) performance optimization in Flutter.
**Action:** Always look for O(N) operations inside itemBuilder functions of long lists or grids and replace them with O(1) lookups using pre-computed Sets or Maps.
