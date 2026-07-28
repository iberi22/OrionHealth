## 2024-05-23 - Avoid Groundedness Violations by Fetching Explicit Code Context

**Learning:** Relying on truncated terminal output (`grep` or `cat`) to make assumptions about code structure leads to incorrect plans and Groundedness Rule violations. Specifically, assuming line contents or widget properties without explicit confirmation is unsafe.
**Action:** Always fetch the explicit, necessary context using targeted commands (e.g., `sed -n '<start>,<end>p' <file>`) when terminal output is truncated before finalizing plans or code modifications.
