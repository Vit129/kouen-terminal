# P23 — SSH Remote Host Manager (PuTTY-style UI)

Status: **Active**
Priority: **P2** — remote workflow enabler
Owner surface: HarnessApp (Settings + toolbar), HarnessCore (already done)
Created: 2026-06-18
Depends on: none — all backend infra already exists

---

## Goal

Give the user a GUI to manage saved SSH remote hosts and connect/disconnect the Harness GUI
to a remote daemon — same mental model as PuTTY's Session Manager, but native macOS.

**TCP is suspended.** Native TCP transport requires a TLS layer first (see `EndpointConnector.swift:18`).
SSH tunnel is the right transport for now: it reuses the user's existing SSH trust with no new crypto.

---

## What Already Exists (do not rebuild)

| Layer | File | What it does |
|-------|------|--------------|
| Model | `HarnessCore/Remote/RemoteHost.swift` | `name`, `sshTarget`, `remoteSocketPath`, `sshArgs` |
| Store | `HarnessCore/Remote/RemoteHostStore.swift` | JSON CRUD, file-locked for concurrent CLI access |
| Tunnel | `HarnessCore/Remote/SSHTunnelManager.swift` | `ssh -N -L` lifecycle + `ping→pong` probe |
| Service | `HarnessApp/Services/RemoteHostsService.swift` | Facade: list/add/remove/connect/disconnect |
| CLI | `HarnessCLI/HarnessCLI+Server.swift` | `harness-cli remote list/add/remove` |

**Only the GUI is missing.**

---

## How to use SSH today (developer reference)

```swift
// 1. Add a host (persists to remote-hosts.json)
RemoteHostsService.shared.addHost(RemoteHost(
    name: "devbox",
    sshTarget: "user@192.168.1.10",
    remoteSocketPath: "/Users/user/.harness/harness.sock",
    sshArgs: ["-p", "2222", "-i", "~/.ssh/id_ed25519"]
))

// 2. Connect — blocking, call off main thread
let endpoint = try RemoteHostsService.shared.connect(named: "devbox")
// endpoint is Endpoint.unix(path: "<local tunnel socket>")
// DaemonClient/SessionCoordinator use this endpoint transparently

// 3. Disconnect — back to local daemon
RemoteHostsService.shared.disconnect()

// CLI equivalent:
// harness-cli remote add --name devbox --ssh user@192.168.1.10 --socket /Users/user/.harness/harness.sock --ssh-arg -p --ssh-arg 2222
// harness-cli remote list
// harness-cli remote remove --name devbox
```

**Socket path on remote:** run `harness-cli doctor` on the remote machine — it prints the socket path.

---

## UI Design (PuTTY-inspired, macOS-native)

### Entry point
- Settings → "Remote" tab (new tab, after existing tabs)
- Toolbar indicator showing connected remote host name (when active)

### Remote tab layout
```
┌─────────────────────────────────────────────────────┐
│  Remote Hosts                                        │
│  ┌────────────────────────────┐  ┌───────────────┐  │
│  │ devbox      user@10.0.0.1  │  │ Name          │  │
│  │ prod-server user@prod.host │  │ ___________   │  │
│  │                            │  │ SSH Target    │  │
│  │                            │  │ ___________   │  │
│  │                            │  │ Port          │  │
│  │                            │  │ ___________   │  │
│  │                            │  │ Identity File │  │
│  │                            │  │ ___________ … │  │
│  │                            │  │ Jump Host     │  │
│  │                            │  │ ___________   │  │
│  │                            │  │ Socket Path   │  │
│  └────────────────────────────┘  │ ___________   │  │
│  [+] [−] [Duplicate]             │               │  │
│                                  │  [Connect]    │  │
└─────────────────────────────────────────────────────┘
```

### Fields (maps directly to `RemoteHost`)
| UI Field | Maps to | Notes |
|----------|---------|-------|
| Name | `name` | Display label, used as tunnel socket basename |
| SSH Target | `sshTarget` | `user@host` or `~/.ssh/config` alias |
| Port | `sshArgs: ["-p", "…"]` | Optional, default 22 |
| Identity File | `sshArgs: ["-i", "…"]` | Optional, file picker |
| Jump Host | `sshArgs: ["-J", "…"]` | Optional |
| Socket Path | `remoteSocketPath` | Auto-hint: default Harness path; "Detect" button runs `harness-cli doctor` over SSH |

### Connection UX
- **Connect button** → spins while tunnel establishes → shows `[Connected: devbox]` in toolbar badge
- **Disconnect** → toolbar badge or menu item
- Connection runs on background thread; `SessionCoordinator` switches its endpoint after success
- Error surfaced as a sheet (e.g. `exitedEarly` → "SSH exited: check host/credentials")

---

## PBIs

### Phase 1 — Settings UI (core)
- [x] **PBI-SSH-001:** Add "Remote" tab to `SettingsViewController`
- [x] **PBI-SSH-002:** Host list (`NSTableView`) — list, select, delete, duplicate
- [x] **PBI-SSH-003:** Detail form — Name, SSH Target, Port, Identity File (file picker), Jump Host, Socket Path fields
- [x] **PBI-SSH-004:** Save/revert logic — write to `RemoteHostsService` on Save, discard on Cancel
- [x] **PBI-SSH-005:** Connect/Disconnect button in detail form — async tunnel setup via existing `SessionCoordinator.connectToRemote`; connection errors currently surface through the existing daemon reconnect toast path, not a dedicated sheet

### Phase 2 — Toolbar indicator
- [x] **PBI-SSH-006:** Toolbar badge showing active remote host name (nil = local, dim)
- [x] **PBI-SSH-007:** Click badge disconnects when remote is active; when local, it opens Settings → Remote. Popover deferred as polish.

### Phase 3 — Socket auto-detect (optional, later)
- [ ] **PBI-SSH-008:** "Detect" button — runs `ssh <target> harness-cli doctor` and parses socket path

---

## TCP — Suspended

`Endpoint.tcp` exists in the enum but `EndpointConnector` throws `notYetSupported`.
Supporting it properly requires TLS (Network.framework `NWConnection` + mTLS or certificate pinning)
plus daemon-side TCP listener. **No timeline.** SSH tunnel covers all current remote use cases.

Do not implement TCP as part of this plan.

---

## Out of Scope

- SSH key generation (use existing keys or `ssh-keygen` in terminal)
- Remote daemon installation (use `harness-cli install` on the remote)
- Multiple simultaneous remote connections (single active host model is intentional)
- TCP transport (suspended, see above)
