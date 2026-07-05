# Remote SSH — Market Comparison

## Kouen vs Competitors (Remote Development over SSH)

| Feature | Kouen | VS Code Remote SSH | JetBrains Gateway | Warp | iTerm2 | Ghostty |
|---------|---------|-------------------|-------------------|------|--------|---------|
| **Architecture** | Daemon + SSH tunnel | Extension + remote server | Thin client + IDE backend | Cloud SSH profiles | Basic SSH sessions | No remote support |
| **Session persistence** | ✅ Daemon survives app quit | ❌ Dies with window | ✅ Backend persists | ❌ No persistence | ❌ No persistence | — |
| **CLI-driven remote** | ✅ `kouen-cli --host` | ❌ GUI only | ❌ GUI only | ❌ GUI only | ❌ Manual SSH | — |
| **Zero remote install** | ✅ Just needs running daemon | ❌ Installs vscode-server | ❌ Installs IDE backend | ✅ Nothing extra | ✅ Nothing extra | — |
| **Multi-host management** | ✅ Settings UI + CLI | ✅ SSH config integration | ✅ Connection manager | ✅ SSH profiles | ❌ Manual | — |
| **Jump host support** | ✅ `-J` proxy jump | ✅ ProxyJump config | ✅ Gateway UI | ❌ Not exposed | Manual config | — |
| **Tunnel forwarding** | ✅ Unix socket (IPC) | TCP port forwarding | TCP/custom | ❌ None | ❌ None | — |
| **Integrated terminal** | ✅ Same terminal window | Embedded terminal | Embedded terminal | Native terminal | ✅ (it IS the terminal) | — |
| **File browser on remote** | ✅ Sidebar file tree | ✅ Full explorer | ✅ Project view | ❌ No | ❌ No | — |
| **Agent detection remote** | ✅ Claude/Codex/etc. | ❌ Copilot only | ❌ AI Assistant only | ✅ Agent mode | ❌ No | — |
| **Speed to connect** | 2-4s (tunnel setup) | 10-30s (server install) | 15-45s (backend deploy) | 2-3s | <1s (direct) | — |
| **Resource on remote** | ~5MB daemon | ~200MB vscode-server | ~500MB+ IDE backend | N/A | N/A | — |
| **Offline reconnect** | ✅ Daemon keeps running | ❌ Reconnect from scratch | ✅ Backend persists | ❌ No | ❌ No | — |
| **Platform** | macOS (GUI), macOS/Linux (daemon) | Windows/macOS/Linux | Windows/macOS/Linux | macOS | macOS | macOS/Linux |

## Our Strengths

1. **Lightest remote footprint** — Only needs the Kouen daemon (~5MB) running on the remote. No 200MB VS Code server or 500MB JetBrains backend to install.

2. **CLI-first remote** — `kouen-cli --host devbox list-sessions` / `capture-pane` / `send-keys` works headless. No competitor offers full scriptable remote terminal control.

3. **Daemon persistence** — Remote sessions survive app quit AND network drops. Reconnect picks up where you left off. Only JetBrains Gateway matches this.

4. **Agent-aware remote** — Detect Claude Code, Codex, Goose etc. running remotely and surface notifications locally. Unique to Kouen.

5. **Unix socket IPC** — More secure than TCP tunnels (no port to scan). Socket is `chmod 0600`.

## Our Gaps (vs leaders)

1. **No Windows/Linux GUI** — VS Code and JetBrains work everywhere. Kouen GUI is macOS only.

2. **No SSH config file integration** — VS Code reads `~/.ssh/config` hosts automatically. We require manual entry.

3. **No port forwarding UI** — VS Code auto-detects listening ports and offers forwarding. We only do the daemon socket.

4. **No remote file editing** — VS Code gives you a full editor on remote files. Our file tree shows structure but editing is local-only.

5. **No workspace sync** — JetBrains syncs project settings, run configs, etc. We sync sessions but not project-level config.

## Roadmap Opportunities

- **Import from `~/.ssh/config`** — auto-populate hosts from SSH config (low effort, high value)
- **Port forwarding UI** — auto-detect + forward remote ports (medium effort)
- **Remote file editing** — open remote files in the editor panel via SFTP/scp (high effort)
- **Linux GUI** — GTK4 frontend sharing the same daemon/engine (very high effort)
