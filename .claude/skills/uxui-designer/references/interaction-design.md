# Interaction Design

## The Eight Interactive States

| State | When | Visual Treatment |
|-------|------|------------------|
| Default | At rest | Base styling |
| Hover | Pointer over (not touch) | Subtle lift, color shift |
| Focus | Keyboard/programmatic | Visible ring |
| Active | Being pressed | Pressed in, darker |
| Disabled | Not interactive | Reduced opacity, no pointer |
| Loading | Processing | Spinner, skeleton |
| Error | Invalid state | Red border, icon, message |
| Success | Completed | Green check, confirmation |

## Focus Rings

Never `outline: none` without replacement. Use `:focus-visible`:

```css
button:focus { outline: none; }
button:focus-visible {
  outline: 2px solid var(--color-accent);
  outline-offset: 2px;
}
```

Focus ring: high contrast (3:1 min), 2-3px thick, offset from element, consistent everywhere.

## Form Design

- Placeholders aren't labels — always use visible `<label>`
- Validate on blur, not every keystroke (except password strength)
- Place errors below fields with `aria-describedby`

## Loading States

- Optimistic updates for low-stakes actions (likes, follows)
- Skeleton screens > spinners

## Modals: The Inert Approach

```html
<main inert><!-- Can't be focused --></main>
<dialog open><h2>Modal Title</h2></dialog>
```

Or use native `<dialog>` with `dialog.showModal()`.

## The Popover API

```html
<button popovertarget="menu">Open menu</button>
<div id="menu" popover>
  <button>Option 1</button>
</div>
```

Light-dismiss, proper stacking, no z-index wars, accessible by default.

## Dropdown Positioning

Dropdowns in `overflow: hidden` containers get clipped. Solutions:
1. CSS Anchor Positioning (Chrome 125+)
2. Popover + Anchor combo (top layer)
3. Portal/Teleport pattern (React `createPortal`, Vue `<Teleport>`)
4. `position: fixed` with manual coordinates

Anti-patterns: `position: absolute` inside `overflow: hidden`, arbitrary `z-index: 9999`.

## Destructive Actions: Undo > Confirm

Undo is better than confirmation dialogs. Remove from UI immediately, show undo toast, actually delete after toast expires.

## Keyboard Navigation

Roving tabindex for component groups. Skip links for keyboard users. Don't rely on gestures as the only way to perform actions.
