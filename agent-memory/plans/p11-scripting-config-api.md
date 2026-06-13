# P11 — Scripting & Config API (WezTerm parity)

Status: **idea / not started**
Priority: **P3** — strategic, no user request yet
Depends on: none
Gap source: WezTerm vs Harness comparison (2026-06-13) — WezTerm's Lua config/event-hook API is the
clearest capability Harness lacks relative to a "self-built renderer + mux" peer.

---

## Goal

Give Harness a **scriptable config layer**: users (and eventually agents) can register event
hooks (`on session created`, `on title changed`, `on exit`, `on output idle`) and call a small
API to manipulate panes/sessions/tabs — the equivalent of WezTerm's `wezterm.on(...)` plus
`mux`/`window`/`pane` Lua objects, but without adopting Lua.

## Current State

- `HarnessSettings` (JSON struct, `HarnessCore/Settings/HarnessSettings.swift`) — static config only
- `KeybindingsStore` (JSON, `HarnessCore/Keybindings/`) — static keymap, no conditionals/scripting
- `NotificationEvent` (`HarnessCore/Settings/NotificationEvent.swift`) — event *types* already
  enumerated, just not scriptable/hookable yet
- No embedded scripting runtime exists anywhere in the package

## Architecture

```
~/.config/harness/harness.js   (or .harness/init.js)
        │  hot-reload via existing FSEvents single-file watcher pattern (RL-011)
        ▼
ScriptRuntime (JavaScriptCore — built into macOS, zero new deps)
        │
        ├── HarnessAPI.session  → list/spawn/select sessions (wraps DaemonClient/CommandIPCTranslator)
        ├── HarnessAPI.pane     → split/close/sendText/readOutput
        ├── HarnessAPI.events   → on('sessionCreated' | 'titleChanged' | 'exit' | ..., handler)
        └── HarnessAPI.config   → read/override HarnessSettings fields
```

JavaScriptCore over Lua: native on macOS (no SwiftPM dependency), `JSExport` protocols give a
typed bridge, and JS is a more familiar scripting language for the target audience than Lua.

## PBIs

### PBI-SCRIPT-001: ScriptRuntime + hot-reload
- Embed `JSContext`, load `~/.config/harness/init.js`
- Reuse single-file `DispatchSource` watcher (RL-011) to reload on save
- Surface script errors via existing toast/notification path

### PBI-SCRIPT-002: HarnessAPI bridge (read-only first)
- `JSExport` protocols for `Session`, `Pane`, `Workspace` — read title/cwd/branch/state
- `HarnessAPI.events.on(name, handler)` registered against existing `NotificationEvent` /
  `NotificationBus.shared.snapshotChanged` dispatch points

### PBI-SCRIPT-003: Mutating actions via CommandIPCTranslator
- Expose `pane.split()`, `pane.sendText()`, `session.spawn()`, `pane.close()` — translate
  through the same `IPCRequest` path GUI menu actions already use
- No new daemon surface — scripts ride the existing client IPC connection

### PBI-SCRIPT-004: Config surface
- `HarnessAPI.config.set("theme", "...")`, `keybind(...)` — merge into `HarnessSettings` via
  existing `JSONMerge.swift`

## Key Files (New)

```
Packages/HarnessCore/Sources/HarnessCore/Scripting/
├── ScriptRuntime.swift       — JSContext lifecycle, error surfacing, hot-reload
├── HarnessAPI.swift           — top-level JSExport namespace object
├── ScriptSession.swift        — JSExport: Session/Pane/Workspace wrappers
└── ScriptEvents.swift          — event registry bridging NotificationBus → JS handlers

Apps/Harness/Sources/HarnessApp/Services/
└── ScriptHookCoordinator.swift — owns ScriptRuntime instance, wires app lifecycle events
```

## Risks

- User scripts run with full app privilege (same trust model as WezTerm Lua / shell rc files —
  acceptable for local config)
- Must not block main thread on script execution — run handlers off `@MainActor` where possible,
  hop back for UI mutations

## Estimate

3–4 sessions (runtime + read-only bridge + mutating actions + config merge)
