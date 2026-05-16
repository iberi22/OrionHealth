# Tablet & Large Screen Optimization Skill

## Objective
Implement adaptive, constraint-based UIs that provide a premium experience on tablets and foldable devices.

## Core Principles
1. **Constraints over Screen Size**: Use `LayoutBuilder` and `BoxConstraints` to decide layouts, not device detection.
2. **Master-Detail Efficiency**:
   - Mobile: Navigation-based flow.
   - Tablet: Side-by-side multi-pane view.
3. **Modular Widgets**: Break UI into self-contained panels that can be rearranged dynamically in a `Row` (tablet) or `Column` (mobile).
4. **Typography & Spacing**: Use `flutter_screenutil` or relative scaling to ensure text doesn't look tiny on high-res tablets.

## Tablet Optimization Checklist
- [ ] **Multi-Pane Layouts**: Ensure list and detail are visible simultaneously on wide screens.
- [ ] **Input Methods**: Support for external keyboards and mice (hover effects, keyboard shortcuts).
- [ ] **Safe Area & Display Cutouts**: Proper handling of notches on large screens.
- [ ] **Content Width Limiting**: Use `ConstrainedBox` to wrap content so lines of text don't become too long and unreadable on very wide tablets.
- [ ] **Orientation Handling**: Verify UI doesn't break when rotating between Portrait and Landscape.
