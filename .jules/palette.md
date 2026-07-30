## 2025-02-14 - Add tooltip to page_header IconButton
**Learning:** `IconButton` widgets used for navigation (like back buttons) need explicit `tooltip` properties to provide semantic labels for screen readers when they don't have text. Flutter provides standard localized tooltips via `MaterialLocalizations.of(context).backButtonTooltip`.
**Action:** Always verify that `IconButton` or other icon-only interactive elements include a `tooltip` attribute, preferring built-in localizations for standard actions.
## 2024-07-26 - Add Tooltips to IconButton for Accessibility
**Learning:** In Flutter, `IconButton` widgets do not automatically announce their context to screen readers unless specifically configured. Missing `tooltip` parameters on icon-only buttons create major accessibility gaps.
**Action:** Always provide a semantic `tooltip` attribute for `IconButton` widgets. For standard actions, prefer using `MaterialLocalizations.of(context)` (e.g., `MaterialLocalizations.of(context).backButtonTooltip`), otherwise provide descriptive, localized text. This serves as the ARIA equivalent for screen reader context in this design system.
## 2024-05-23 - Avoid Groundedness Violations by Fetching Explicit Code Context

**Learning:** Relying on truncated terminal output (`grep` or `cat`) to make assumptions about code structure leads to incorrect plans and Groundedness Rule violations. Specifically, assuming line contents or widget properties without explicit confirmation is unsafe.
**Action:** Always fetch the explicit, necessary context using targeted commands (e.g., `sed -n '<start>,<end>p' <file>`) when terminal output is truncated before finalizing plans or code modifications.
