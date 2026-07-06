# P25 — iOS/iPadOS Support

Status: **Planning**
Priority: **P1** — strategic platform expansion, not a current macOS release blocker
Owner surface: Package.swift, KouenCore, KouenTerminalEngine, KouenCopyMode, KouenTheme, KouenTerminalRenderer, new KouenTerminalUIKit, new KouenMobileApp
Created: 2026-06-19
Depends on: stable daemon IPC, remote host model, terminal renderer isolation

---

## Product Intent

Kouen on iPad should be a **remote-first terminal workstation**:

- attach to Kouen daemons running on a Mac, Linux box, or server
- render live sessions with the same terminal engine, themes, copy mode, panes, tabs, scrollback, and agent notifications
- provide iPad-native input: hardware keyboard, touch selection, pointer, command menus, Split View, Stage Manager, and Files integration
- preserve daemon-owned persistence; closing the iPad app must not kill sessions

The first iPad milestone is **not** a standalone local macOS-equivalent terminal. iOS/iPadOS sandboxing, background execution, launchd absence, PTY/process ownership, SSH tunneling, helper installation, Sparkle, AppKit, and service-provider APIs make a direct port the wrong first cut.

Core mental model:

```text
iPad Kouen app -> network transport -> KouenDaemon on Mac/Linux/server -> PTY sessions
```

---

## Current Architecture Fit

### Already portable or mostly portable

| Layer | Current role | iPadOS use |
|-------|--------------|------------|
| `KouenCore` | IPC schema, commands, settings, models, keybindings, agents, remote host store | Reuse models/codecs; add network endpoint support |
| `KouenTerminalEngine` | Pure Swift VT parser and grid model | Reuse directly |
| `KouenCopyMode` | UI-agnostic copy-mode reducer | Reuse directly |
| `KouenTheme` | Theme catalog and theme document format | Reuse directly |
| `KouenDaemonCore` | PTY/session authority | Stays off-device; remote target |
| `kouen-cli` | Automation and daemon management | Stays Mac/Linux-first; may provide pairing/bootstrap helper |

### macOS-specific today

| Layer | Constraint | iPadOS path |
|-------|------------|-------------|
| `KouenApp` | AppKit, NSWindow, NSView, menus, Sparkle, service provider, launchd helper install | Do not port directly; create new mobile app shell |
| `KouenTerminalKit` | AppKit host views and `NSEvent` mapping | Create UIKit sibling: `KouenTerminalUIKit` |
| `KouenTerminalRenderer` | Metal/CoreText renderer, likely salvageable but currently macOS-hosted | Extract platform-neutral renderer core; add UIKit/CAMetalLayer or MTKView host |
| `RemoteHostsService` / `SSHTunnelManager` | Uses local SSH process and Unix socket forwarding | Replace for mobile with network endpoint, gateway, or embedded SSH strategy |
| `CLIInstaller`, `SparkleUpdater`, `LaunchAgentInstaller` | macOS install/update lifecycle | Exclude from mobile |
| File editor / Quick Look / LSP | AppKit text views, local filesystem/process assumptions | Defer; remote read-only browser later |

---

## Required Architectural Decisions

### D1: Transport model (P0 gate)

The iPad app cannot depend on spawning `ssh -N -L` or attaching to a local Unix socket. Pick one supported remote transport before UI work expands:

1. **Daemon TCP/WebSocket endpoint** — preferred for iPad UX.
   - Add authenticated network listener to daemon or companion relay.
   - Reuse existing length-prefixed IPC and binary PTY frames over TLS/WebSocket.
   - Good for App Store, pairing, reconnect, and background-friendly networking.

2. **Embedded SSH tunnel** — possible but higher risk.
   - Requires SSH library, key management UI, known-hosts storage, and App Store review confidence.
   - Preserves current remote mental model but expands security surface.

3. **Mac companion gateway** — viable stepping stone.
   - Mac app/CLI exposes a local-network relay to the iPad.
   - Lower daemon churn, good for first TestFlight, but weaker for Linux/server-only workflows.

Decision target: choose one for MVP, document threat model, and avoid supporting all three initially.

### D2: Renderer reuse boundary (P0 gate)

Do not duplicate VT rendering logic. The goal is:

```text
KouenTerminalEngine -> TerminalFrame model -> shared Metal renderer core -> AppKit host or UIKit host
```

If `KouenTerminalRenderer` has AppKit-only color/font assumptions, introduce a small platform adapter rather than forking the renderer.

### D3: Local terminal support (explicitly deferred)

Local iPad shell sessions are out of MVP unless proven viable without private APIs and without pretending to own background PTYs like the macOS daemon. Treat local terminal as a future research track, not a dependency for remote attach.

---

## Feature Specs

### F1: Mobile Package Targets — P0

Add platform-gated targets:

- `KouenTerminalUIKit`
  - UIKit terminal host view
  - touch selection, scroll gestures, pointer hover, hardware keyboard mapping
  - consumes `KouenTerminalEngine`, `KouenCopyMode`, `KouenTheme`, `KouenTerminalRenderer`
- `KouenMobileApp`
  - iOS/iPadOS SwiftUI/UIKit app shell
  - remote host list, session browser, terminal workspace
  - no Sparkle, no launchd install, no AppKit services

Package direction:

```swift
#if os(iOS)
// KouenTerminalUIKit + KouenMobileApp
#endif
```

Keep macOS products unchanged. Do not weaken the existing Linux headless split.

### F2: Network Endpoint for IPC — P0

Add an `Endpoint` case that works on iPad:

```swift
case network(host: String, port: Int, security: NetworkSecurity)
case websocket(URL)
```

Implementation requirements:

- preserve current `IPCCodec` framing semantics
- support binary PTY output/input frames
- support reconnect with last seen surface/frame sequence where possible
- keep Unix socket path untouched for local macOS/Linux
- authenticate before exposing daemon commands
- expose precise errors: auth failed, host unreachable, incompatible daemon, unsupported transport

### F3: Pairing and Trust — P0

The iPad app needs a non-fragile trust flow:

- daemon or companion generates pairing code / QR code
- iPad stores host identity and token in Keychain
- daemon stores revocable client grants
- pairings are scoped by device and can be removed
- remote command permissions are explicit enough to avoid accidentally exposing shell access on LAN

Minimum daemon commands:

```bash
kouen-cli mobile pair
kouen-cli mobile list-clients
kouen-cli mobile revoke <client-id>
```

### F4: UIKit Terminal Surface — P0

Create a UIKit sibling of `TerminalHostView` and `KouenTerminalSurfaceView`:

- `UIView` / `MTKView` or `CAMetalLayer` backed rendering
- hardware keyboard input through `UIPress`, `UIKeyCommand`, and text input traits
- touch selection mapped into `KouenCopyMode`
- two-finger scrollback and inertial scrolling
- clipboard through `UIPasteboard`
- pointer interactions for iPad trackpad/mouse
- safe area and keyboard avoidance without resizing the daemon surface incorrectly

Preserve existing input boundary: UIKit maps platform events into engine/core key intent; `InputEncoder` remains AppKit-free.

### F5: iPad Workspace UX — P1

Build a mobile-native workspace, not a squeezed macOS window:

- sidebar host/session list optimized for Split View and Stage Manager
- terminal surface as the primary screen
- panes and tabs reachable through compact controls and keyboard shortcuts
- command palette adapted to iPad keyboard and touch
- remote host switcher with connection state
- agent notifications as a compact inbox, not macOS notch/panel chrome
- command menu entries for common session actions

Defer dense macOS-only surfaces:

- full settings window parity
- file editor/LSP
- git panel
- browser pane
- Sparkle/update UI
- macOS service provider workflows

### F6: Remote Session Lifecycle — P1

Support the workflows that make an iPad useful immediately:

- list remote workspaces/sessions
- attach/detach without killing sessions
- create a session on a remote host
- split panes and resize
- send keys and paste
- capture pane / copy mode
- reconnect after app backgrounding
- show daemon version mismatch clearly

The iPad app must assume the daemon owns truth. Local cached state is presentation-only.

### F7: Files and Sharing — P2

Once remote attach is stable:

- import/export `.kouentheme`
- import SSH keys or pairing bundles if the selected transport needs them
- share copied terminal text/images
- optional remote file preview through daemon-mediated read-only APIs

Do not expose arbitrary remote file browsing until the permission model is defined.

---

## Implementation Phases

### Phase 0 — Feasibility Spike (P0)

- [ ] Build a small iPadOS SwiftPM/Xcode target importing `KouenCore`, `KouenTerminalEngine`, `KouenCopyMode`, and `KouenTheme`
- [ ] Compile `KouenTerminalRenderer` for iOS or list exact AppKit/CoreText blockers
- [ ] Prototype one terminal grid rendered in a UIKit/Metal view
- [ ] Choose D1 transport model and write the security model
- [ ] Confirm App Store constraints for background networking, local network permission, key storage, and remote shell access
- [ ] Define minimum supported iPadOS version based on Metal/UIKit/SwiftUI needs

Exit criteria: one rendered static terminal frame on iPad simulator/device and a written transport decision.

### Phase 1 — Shared Renderer Extraction (P0)

- [ ] Split renderer host concerns from renderer core
- [ ] Introduce platform color/font/glyph rasterization adapters only where necessary
- [ ] Keep existing macOS renderer tests passing
- [ ] Add renderer parity fixtures comparing macOS and UIKit frame output where possible
- [ ] Avoid behavior drift in ligatures, inline image cells, selection overlays, and damage tracking

Exit criteria: macOS renderer remains unchanged from the app's perspective; iOS target compiles the shared renderer core.

### Phase 2 — Mobile IPC Transport (P0)

- [ ] Add network-capable `Endpoint`
- [ ] Add `EndpointConnector` implementation for the chosen transport
- [ ] Add daemon-side listener or companion gateway
- [ ] Add pairing, token storage, revocation, and version handshake
- [ ] Add tests for frame ordering, auth failure, reconnect, and binary PTY frames over the new transport

Exit criteria: iPad test client can request `list-sessions` from a paired daemon.

### Phase 3 — UIKit Terminal MVP (P0)

- [ ] Create `KouenTerminalUIKit`
- [ ] Implement live PTY output subscription
- [ ] Implement keyboard text, arrows, modifiers, paste, resize, and detach
- [ ] Implement touch scrollback and basic selection/copy
- [ ] Add snapshot/replay handling for reconnect after backgrounding
- [ ] Add simulator/device smoke tests for blank-frame prevention

Exit criteria: iPad app attaches to one remote session, displays live output, accepts keyboard input, scrolls, and reconnects.

### Phase 4 — iPad App Shell (P1)

- [ ] Create `KouenMobileApp`
- [ ] Remote host setup and pairing UI
- [ ] Session list and attach flow
- [ ] Terminal workspace with tab/pane controls
- [ ] Command palette subset
- [ ] Agent notification inbox subset
- [ ] Settings subset: theme, font size, key behavior, host management

Exit criteria: TestFlight-quality remote terminal client for one or more paired daemons.

### Phase 5 — Multiplexer Parity (P1)

- [ ] Split pane creation/removal
- [ ] Pane focus navigation
- [ ] Session rename/close
- [ ] Copy mode parity with macOS reducer
- [ ] Resize vote behavior across background/foreground transitions
- [ ] Remote host switching without stale session bleed

Exit criteria: core multiplexer workflows from `docs/MULTIPLEXER_GUIDE.md` work from iPad.

### Phase 6 — Polish and Platform Integration (P2)

- [ ] Stage Manager and external display layout
- [ ] Pointer hover affordances
- [ ] Keyboard shortcut discoverability
- [ ] Drag/drop terminal text
- [ ] Theme import/export through Files
- [ ] Push/local notifications for agent waits if allowed by user
- [ ] Accessibility pass: Dynamic Type strategy, VoiceOver labels for controls, reduced motion

Exit criteria: iPad app feels native under touch, keyboard, and pointer usage.

---

## Testing and Verification

### Build matrix

- [ ] `swift build` on macOS still passes
- [ ] `swift build` on Linux still excludes GUI/mobile surfaces and passes headless targets
- [ ] iOS simulator build passes for `KouenTerminalUIKit`
- [ ] iPadOS app archive or Xcode build passes for `KouenMobileApp`

### Unit tests

- [ ] `KouenCoreTests`: endpoint parsing, auth models, pairing persistence, network framing
- [ ] `KouenTerminalEngineTests`: unchanged
- [ ] `KouenCopyModeTests`: reused for touch selection paths
- [ ] Renderer parity tests: frame model / damage / color conversion where testable without AppKit

### Integration tests

- [ ] Paired iPad simulator connects to local daemon gateway
- [ ] Remote Linux daemon attach
- [ ] Background app for 30+ seconds, foreground, verify no lost resize/input state
- [ ] Network drop/reconnect during output burst
- [ ] Version mismatch and auth revoke flows

### Manual test checklist

- [ ] Hardware keyboard: text, arrows, Option, Control, Command shortcuts
- [ ] Magic Keyboard / trackpad pointer
- [ ] Touch selection and copy/paste
- [ ] Split View / Stage Manager resizing
- [ ] External display if supported by target OS
- [ ] Large scrollback session
- [ ] High-throughput command output
- [ ] Agent wait notification

---

## Security Notes

- Remote terminal access is shell access. Pairing and transport auth are product-critical, not polish.
- Never expose daemon network listener unauthenticated.
- Prefer explicit bind address defaults: loopback for companion mode, opt-in LAN/server mode.
- Store secrets in Keychain on iPad and permission-restricted config on daemon hosts.
- Include daemon command allow/deny policy before adding file read/write APIs.
- Log remote client identity for session creation, input, and revocation events.

---

## Non-goals

- Running `KouenDaemon` locally on iPad in MVP
- Porting `KouenApp` AppKit views through compatibility shims
- Sparkle/update flow on iOS/iPadOS
- Full file editor/LSP parity in the first release
- Git panel/browser pane parity in the first release
- Supporting every possible remote transport in MVP
- Replacing the macOS app architecture

---

## Risks

- Network transport and security can become larger than the UI work; keep MVP transport singular.
- Renderer extraction may reveal CoreText/AppKit coupling that needs a careful adapter layer.
- Hardware keyboard behavior differs between simulator, iPad, Magic Keyboard, and external keyboards.
- Backgrounding can break subscription semantics unless reconnect/replay is designed early.
- App Store review may scrutinize remote shell, SSH key handling, local network discovery, and executable-like workflows.
- Duplicating terminal UI behavior across AppKit and UIKit can drift; keep reducers/frame models shared.

---

## Open Questions

- Is the first release iPad-only, or should iPhone compile with a reduced layout?
- Should pairing be daemon-native or Mac-app-companion-first?
- Should the network transport be raw TLS, WebSocket, or HTTPS upgrade?
- Does remote daemon need multi-client permissions beyond all-or-nothing shell access?
- What is the minimum acceptable offline behavior when no daemon is reachable?
- Is TestFlight distribution enough for early users, or is App Store compliance a day-one requirement?

---

## First Implementation Slice

1. Create a throwaway iPadOS spike target that imports pure shared packages.
2. Render one static `TerminalFrame` through a UIKit-hosted Metal surface.
3. Add a tiny paired network proof-of-concept that calls `daemon-stats`.
4. Decide transport based on the spike, then replace the throwaway target with real `KouenTerminalUIKit` and `KouenMobileApp` targets.

