# Project History

## Sprint Timeline

| Version | Sprint | Key Deliverables |
|---------|--------|-----------------|
| v1.3.0 | IDE-like Sidebar | Files tab, Git tab, session tabs, recent projects |
| v1.4.0 | Git panel polish | Commit ▼ menu, Sync button with per-remote options |
| v1.5.0 | CMUX split panes | N-ary flatten, host reuse, split down removed |
| v2.0.0 | File preview | Sidebar polish, agent icon art |
| v2.1.0 | ACP Client + Git refresh | Real-time Git, history→editor, ACP (later shelved) |

## Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| Separate daemon process | PTY sessions survive GUI crashes; multiple clients can attach |
| Binary IPC frames for PTY | Avoid JSON overhead on hot path (terminal output) |
| NSSplitView for panes | Native resize handles; HarnessSplitView subclass adds ratio persistence |
| Metal renderer | GPU-accelerated terminal rendering; CoreText for glyph shaping |
| UserDefaults for ACP registry | Simple persistence; later moved to shelved status |
| Session = project concept | Tab bar shows sessions (one per project), not individual PTY tabs |

## Apple Platform Context — Transparency & Legibility

### iOS/macOS 26 — Liquid Glass introduction
Apple replaced `NSVisualEffectView` vibrancy with "Liquid Glass" — a new material system
that simulates real glass (translucency, refraction, depth, motion responsiveness) and
adapts to light/dark environments. Shipped with iOS 26 / macOS Tahoe (2025).

**Problem at launch:** Community feedback reported text legibility issues on pure transparent
backgrounds. Pure `UIBlurEffect + .clear` fails on bright backgrounds — the same problem
Omni Group documented in 2015 (see appkit-metal.md CASE-027).

### iOS/macOS 27 — Liquid Glass refinements (WWDC 2026)
Apple's response after legibility feedback:
- **Transparency slider in Settings** — continuous control from "ultra clear" to "fully
  tinted" (not a binary toggle). Lets users dial in the right balance.
- **Improved diffusion** — material more effectively diffuses complex content behind it.
- **Darkened edge + brighter specular** — adds depth and visual separation automatically.
- **Scroll toolbar** — uniform toolbar appears when content scrolls under floating bars,
  maintaining legibility automatically.
- Apps gain many improvements automatically without recompilation.

**Key lesson for Harness:** Apple's definitive answer is semi-opaque tinted glass, not pure
transparency. The `backgroundOpacity` slider in Harness Settings → Appearance → Window is
the same concept. CASE-027 applied this: `window.backgroundColor =
themeColor.withAlphaComponent(opacity)` instead of `.clear`.

## Known Issues (Current)

- CWD tracking: SurfaceShellTracker can't read daemon children's environment reliably
- Split right 4+ panes: slightly uneven due to NSSplitView default resize algorithm
- ACP: shelved — adapters not ready
