# OrionHealth UI/UX Improvement Plan

## Scope

This plan is based on the mocked Flutter screens rendered through golden tests in `test/widgets/golden_screenshots_test.dart` and the generated PNGs in `integration_test/screenshots/actual/`.

## Execution Log

1. Created a widget-only golden test at [`test/widgets/golden_screenshots_test.dart`](../../test/widgets/golden_screenshots_test.dart) by copying the mock pages from `integration_test/app_test.dart`.
1. Pointed all golden outputs to [`integration_test/screenshots/actual/`](../../integration_test/screenshots/actual/).
1. Ran `flutter test --update-goldens --tags=golden test/widgets/golden_screenshots_test.dart`.
1. The tag selector did not match any tests in this environment, so the fallback command was used: `flutter test --update-goldens test/widgets/golden_screenshots_test.dart`.
1. Golden generation succeeded on Windows desktop and produced 12 PNGs in the target directory.
1. Reviewed the rendered screenshots and translated the layout issues into the recommendations below.

## Summary

The current UI mock set is functional as a proof of navigation, but it is visually thin, overly repetitive, and not yet suitable as a health app experience. The main gaps are:

- Weak visual hierarchy.
- Inconsistent spacing and component treatment across screens.
- Low content density on some pages and over-dense lists on others.
- Missing loading, empty, and feedback states.
- Limited accessibility affordances for contrast, sizing, and semantics.
- Desktop responsive behavior is not yet intentional.

## Findings

### 1. Consistency of visual system

The screenshots show a mostly default Material surface with minimal styling differences between pages. App bars, cards, bubbles, buttons, and form fields do not yet share a strong design language.

Recommended direction:

- Define a shared OrionHealth theme with tokens for color roles, elevation, radius, and spacing.
- Use one primary accent and one secondary accent consistently across navigation, cards, and CTAs.
- Standardize page headers, section titles, and supporting text styles.
- Reduce the number of one-off widget treatments.

### 2. Accessibility

Several screens rely on low-information visual patterns and small icon-only controls. In a health product, this increases friction for older users and users on smaller screens.

Recommended direction:

- Enforce minimum touch target sizes of 44x44 px.
- Keep body text at 16 sp or larger for form-heavy and reading-heavy screens.
- Verify contrast for chat bubbles, secondary text, and chip-like elements.
- Add semantic labels for icon buttons and floating actions.
- Ensure keyboard focus states are visible on desktop.

### 3. Navigation clarity

The bottom navigation is clear, but each destination lands on a screen with little contextual framing. Users do not get enough "where am I" cues or next-step guidance.

Recommended direction:

- Add page-level summaries or hero headers to each destination.
- Preserve a consistent header structure with title, subtitle, and primary action.
- Consider a desktop rail or persistent sidebar for wide layouts.
- Add current-state indicators when navigation drives workflows.

### 4. Responsive design

The screenshots are dominated by large empty areas on some pages and wide single-column stacks on others. This is acceptable for a mock, but not for a production desktop/tablet experience.

Recommended direction:

- Introduce breakpoints for compact, medium, and wide layouts.
- Use two-column layouts on wide screens for profile and report pages.
- Constrain content width to improve readability.
- Avoid centering narrow content blocks inside large empty canvases.

### 5. Empty and loading states

The mock screens show only "happy path" content. There are no empty states, upload states, retry states, or in-progress indicators.

Recommended direction:

- Add dedicated empty states for no records, no reports, and no chat history.
- Show upload progress and processing states for health record ingestion.
- Add skeleton loading for lists and cards.
- Include error recovery actions such as retry, dismiss, and contact support.

### 6. Micro-interactions

The current UI has almost no transitional feedback. In a medical assistant, feedback is especially important because users are making high-trust interactions.

Recommended direction:

- Add animated state changes for selected navigation, expanded cards, and chat message send.
- Use inline progress indicators when the assistant is analyzing content.
- Animate newly added report cards and upload confirmations.
- Keep motion subtle and informative, not decorative.

## Prioritized Issues

### Issue 1: Define a shared OrionHealth design system

- Priority: High
- Problem: Screens use a generic Material look without a stable visual identity.
- Recommendation: Create a theme layer with named colors, typography scale, spacing tokens, and reusable card/button/input variants.
- Acceptance criteria:
  - One source of truth for colors and typography.
  - Shared button, card, and form field styles across the mock pages.
  - Consistent radius and elevation values.

### Issue 2: Improve page-level hierarchy on every destination

- Priority: High
- Problem: Several screens only show a title and a large empty body area.
- Recommendation: Add a header block with page title, short description, and a primary action or status summary.
- Acceptance criteria:
  - Each page has a visible title and supporting context.
  - The user can identify the next action within one glance.
  - Wide screens do not feel visually empty.

### Issue 3: Rework records upload into a guided flow

- Priority: High
- Problem: The upload screen presents three equal buttons without prioritization or explanation.
- Recommendation: Convert the page into a step-based upload card with primary action, secondary options, and helper copy.
- Acceptance criteria:
  - One clear primary CTA.
  - Clear descriptions for PDF, camera, and gallery intake.
  - Visible upload progress and success feedback.

### Issue 4: Group and structure profile form inputs

- Priority: Medium
- Problem: The profile form is a long vertical stack with no sectioning.
- Recommendation: Split personal data, metrics, and medical details into sections with helper text and units.
- Acceptance criteria:
  - Fields are grouped by meaning.
  - Units are shown inline where relevant.
  - The save action remains discoverable on desktop and mobile.

### Issue 5: Add conversation affordances to the chat assistant

- Priority: Medium
- Problem: The chat screen lacks timestamps, suggested prompts, typing feedback, and attachment affordances.
- Recommendation: Add a richer message composer, assistant state indicator, and quick prompt chips.
- Acceptance criteria:
  - Users can see whether the assistant is idle, thinking, or responding.
  - The composer supports keyboard and touch input cleanly.
  - Bubble contrast is verified in both sent and received states.

### Issue 6: Upgrade report list discoverability

- Priority: Medium
- Problem: The report list is visually repetitive and does not support filtering or prioritization.
- Recommendation: Add date grouping, status chips, filtering, and short summaries above the list.
- Acceptance criteria:
  - Reports can be scanned by status or recency.
  - Each card exposes an obvious action.
  - Empty and filtered-empty states are supported.

### Issue 7: Make desktop interactions explicit

- Priority: Medium
- Problem: The mock is not yet optimized for mouse, keyboard, and large-screen usage.
- Recommendation: Add hover states, keyboard focus outlines, and wider content layouts for desktop.
- Acceptance criteria:
  - Focus rings are visible.
  - Wide viewports use space intentionally.
  - Mouse and keyboard affordances are obvious.

## Suggested Next Build Slice

If the team wants to turn this into implementation work, the best first slice is:

1. Add a shared theme and reusable primitives.
1. Refactor the navigation and page headers around that theme.
1. Redesign the records upload flow and profile form.
1. Add empty/loading states and simple motion.

## Reference Artifacts

- [`test/widgets/golden_screenshots_test.dart`](../../test/widgets/golden_screenshots_test.dart)
- [`integration_test/screenshots/actual/01_main_navigation.png`](../../integration_test/screenshots/actual/01_main_navigation.png)
- [`integration_test/screenshots/actual/06_upload_buttons.png`](../../integration_test/screenshots/actual/06_upload_buttons.png)
- [`integration_test/screenshots/actual/08_chat_interface.png`](../../integration_test/screenshots/actual/08_chat_interface.png)
- [`integration_test/screenshots/actual/09_reports_list.png`](../../integration_test/screenshots/actual/09_reports_list.png)
