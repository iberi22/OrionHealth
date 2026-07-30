## 2025-02-12 - Missing Tooltips on IconButtons
**Learning:** In Flutter, providing a `tooltip` property on an `IconButton` is critical for accessibility. It acts as both a visual hint on hover (or long-press) and a semantic label for screen readers. Using `MaterialLocalizations.of(context).backButtonTooltip` is a reliable way to get standard, localized labels for common actions like 'Back'.
**Action:** Always verify that `IconButton` and similar icon-only interactive widgets include a `tooltip` property, preferring built-in `MaterialLocalizations` where applicable.
