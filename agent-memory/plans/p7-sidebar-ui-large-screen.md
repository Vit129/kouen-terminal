# P7: Sidebar UI Polish — Large Screen Layout

## Problems
1. **Session group header** — `+` and `...` buttons missing or misaligned on
   large displays. The group header ("cpi-qa-automation" with chevron) doesn't
   show action buttons consistently.
2. **Session card** — spacing/padding not proportional on large screens. Card
   content (title, meta line) looks cramped or misaligned.
3. **File editor tab bar overlap** — tab bar still slightly overlaps terminal
   tab bar on some screen sizes (partially fixed with `constant: 2`).

## Fix Approach
1. Session group header: ensure `+` (add session to group) and `...` (group
   options) buttons are always visible with fixed widths, pinned trailing.
2. Session card: use fixed padding/margins that don't scale with sidebar width.
3. File editor tab bar: verify alignment at multiple window sizes.

## Status
- [ ] Identify session group header view class and button layout
- [ ] Fix button visibility/alignment on large screens
- [ ] Test at various sidebar widths
