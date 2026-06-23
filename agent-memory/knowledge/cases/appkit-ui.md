# CASE — AppKit / UI

Grep target: `grep -n "CASE-\|<keyword>" knowledge/cases/appkit-ui.md`

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-001 | NSButton checkbox not receiving clicks inside NSScrollView | Remove FlippedView scroll-wrapper; use FlippedStackView as documentView |
| CASE-002 | NSSplitView subviews collapse to 0 / custom ratios lost | `autoresizingMask = [.width, .height]`; store ratio, setPosition on first non-zero layout |
| CASE-005 | NSButton .recessed bezelStyle shows white in dark theme | Use .inline + isBordered=false + manual layer?.backgroundColor |
| CASE-006 | NSSplitView.setPosition in layout() infinite recursion (N>2) | `isApplyingPositions` bool guard |
| CASE-007 | NSSplitView subview reorder causes window collapse/black | Only remove the moved view; reinsert with addSubview(_:positioned:relativeTo:) |
| CASE-008 | NSApp.keyWindow nil in menu action (AppleScript) | `keyWindow ?? mainWindow ?? windows.first(where:)` fallback chain |
| CASE-010 | NSFont has no `.italicSystemFont` | `NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)` |
| CASE-014 | NSSplitView.setPosition fails when bounds.width==0 | DispatchQueue.main.async retry, or use constraint multiplier |
| CASE-018 | File preview drag-to-select broken | Forward mouseDown/mouseDragged/mouseUp to textView directly |
| CASE-024 | Sidebar disappears after collapse+expand on launch | Set `settings.sidebarVisible=false` when forcing collapse |
| CASE-027 | Translucent window unreadable on bright background | `themeColor.withAlphaComponent(max(opacity, 0.15))` floor + drop shadow |
| CASE-029 | Sidebar chevron disappears on rotation/hide | Symbol state (`chevron.right`/`.down`) instead of frameCenterRotation |
| CASE-030 | Multiple sessions hidden; sidebar doesn't sync selection | Remove allSameBranch; call selectActiveSessionRow in refreshMetadata |
| CASE-035 | NSAlert Enter fires Close (destructive) even with Cancel focused | Clear `buttons[0].keyEquivalent = ""`; Space activates focused |
| CASE-036 | Command Prompt (⌘;) can't receive keyboard input | Borderless NSPanel `canBecomeKey=false` default — use KeyablePanel subclass |
| CASE-037 | SyntaxTextView mouseUp stack overflow (71K frames) | Remove mouseUp/mouseDragged forwarding — NSTextView handles internally |
| CASE-038 | NSClickGestureRecognizer intercepts NSButton clicks | Check click location in handler; use mouseUp override if needed (**OPEN**) |
| CASE-039 | NSTrackingArea on superview crashes on pane rebuild | Remove in viewDidMoveToSuperview(nil); use .inVisibleRect + rect:.zero |
