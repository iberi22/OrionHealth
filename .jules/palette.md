## 2025-02-14 - Add tooltip to page_header IconButton
**Learning:** `IconButton` widgets used for navigation (like back buttons) need explicit `tooltip` properties to provide semantic labels for screen readers when they don't have text. Flutter provides standard localized tooltips via `MaterialLocalizations.of(context).backButtonTooltip`.
**Action:** Always verify that `IconButton` or other icon-only interactive elements include a `tooltip` attribute, preferring built-in localizations for standard actions.
