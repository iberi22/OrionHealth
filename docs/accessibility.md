# Accessibility Statement — OrionHealth

Last reviewed: 2026-08-29
Effective: 2026-08-29

## Conformance

OrionHealth aims to conform to **WCAG 2.1 Level AA** standards.

OrionHealth is built with Flutter, which has built-in support for screen
readers and other assistive technologies. We follow Flutter's accessibility
guidelines and use semantic widgets throughout the app.

## Accessibility features

### Screen reader support

- **VoiceOver** (iOS) and **TalkBack** (Android) are fully supported.
- All interactive elements have descriptive labels in Spanish.
- Page transitions and dynamic content changes are announced.

### Keyboard navigation

- All interactive elements are focusable.
- Visible focus indicators on focusable widgets.
- Tab order follows visual reading order.

### Tooltips and labels

- All icon-only buttons (`IconButton`, `FloatingActionButton`) include
  a `tooltip` property which doubles as the semantic label.
- Wave 7 introduced the `SWALTooltip` wrapper (in `lib/core/widgets/swal_tooltip.dart`)
  to centralize accessible tooltip styling.
- Wave 9 (in progress) is adding explicit `semanticLabel` to remaining
  IconButtons without tooltips.

### Dynamic text scaling

- Supports system font size preferences (no hardcoded font sizes).
- Layouts reflow correctly up to 200% scaling.

### Color contrast

- Meets WCAG AA contrast ratios (4.5:1 for normal text, 3:1 for large text).
- Color is never the sole means of conveying information.
- Status indicators use icons + color, not color alone.

### Forms and input

- All form fields have associated labels.
- Error messages are announced by screen readers via `Semantics`.
- Required fields are clearly marked.

### Touch targets

- Minimum touch target size of 48x48 logical pixels (Material Design guideline).
- Adequate spacing between interactive elements.

## Known limitations

We are continuously improving accessibility. Currently identified areas:

- **External audit pending**: This is a self-assessment. A formal WCAG 2.1 AA
  audit by a third-party accessibility consultant has not yet been performed.
- **Some 3rd-party packages** may not be fully accessible. We mitigate this by
  wrapping them with accessibility-aware widgets when possible.
- **Dynamic charts** (vital signs trends, medication schedules) may need
  additional tabular alternatives for full screen-reader support.

## Reporting accessibility barriers

If you encounter accessibility barriers or have suggestions for improvement,
please report them via:

- **GitHub Issues**: https://github.com/iberi22/OrionHealth/issues
  (use the `a11y` label)
- **Email**: [contact info — to be added]

When reporting, please include:

1. Device model and operating system version
2. Assistive technology used (e.g., VoiceOver version, TalkBack version)
3. Steps to reproduce the barrier
4. Expected vs actual behavior

## Compatibility

OrionHealth supports:

| Platform | OS Version | Assistive Tech |
|----------|------------|----------------|
| Android | 8.0+ (API 26+) | TalkBack, Switch Access |
| iOS | 14.0+ | VoiceOver, Switch Control |
| Windows | 10+ | Narrator, NVDA (planned) |
| macOS | 11+ | VoiceOver (planned) |

## Standards referenced

- [WCAG 2.1](https://www.w3.org/TR/WCAG21/) — Web Content Accessibility Guidelines
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Material Accessibility](https://m3.material.io/foundations/accessible-design/accessibility-basics)
- [iOS Accessibility](https://developer.apple.com/accessibility/)
- [Android Accessibility](https://developer.android.com/guide/topics/ui/accessibility)

## Feedback

We welcome feedback on this accessibility statement. Please open an issue
with the `a11y` label or contact us directly.

Last updated: 2026-08-29 — Wave 9 (orchestrator)