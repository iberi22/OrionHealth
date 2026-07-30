## 2025-02-14 - Add tooltip to page_header IconButton
**Learning:** `IconButton` widgets used for navigation (like back buttons) need explicit `tooltip` properties to provide semantic labels for screen readers when they don't have text. Flutter provides standard localized tooltips via `MaterialLocalizations.of(context).backButtonTooltip`.
**Action:** Always verify that `IconButton` or other icon-only interactive elements include a `tooltip` attribute, preferring built-in localizations for standard actions.
## 2024-07-26 - Add Tooltips to IconButton for Accessibility
**Learning:** In Flutter, `IconButton` widgets do not automatically announce their context to screen readers unless specifically configured. Missing `tooltip` parameters on icon-only buttons create major accessibility gaps.
**Action:** Always provide a semantic `tooltip` attribute for `IconButton` widgets. For standard actions, prefer using `MaterialLocalizations.of(context)` (e.g., `MaterialLocalizations.of(context).backButtonTooltip`), otherwise provide descriptive, localized text. This serves as the ARIA equivalent for screen reader context in this design system.
