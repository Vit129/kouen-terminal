# IPC Architecture

## Overview

GUI ↔ Daemon ↔ CLI communicate over Unix-domain sockets. The daemon owns all PTY sessions; the GUI and CLI are thin clients.

## Framing

- **Control frames:** 4-byte big-endian length prefix + JSON body (`IPCCodec`)
- **PTY output (hot path):** Magic `0xF5` + sequence number + raw bytes
- **PTY input (hot path):** Magic `0xF6` + surface ID + raw bytes
- **Max payload:** 16 MiB (`IPCCodec.maxPayloadLength`)

## Security

- Socket is `chmod 0600` (owner-only)
- `DaemonServer` rejects peers whose kernel uid ≠ `geteuid()`
- No network exposure — Unix socket only

## Subscriptions

- Long-lived connections for resize, detach, real-time output
- Intercepted at fd layer in `DaemonServer` — not in `SurfaceRegistry`
- `wait-for`, subscriptions, resize, detach, and client lifecycle handled here

## Key Invariant

Binary magic bytes `0xF5`/`0xF6` must not collide with the high byte of a JSON frame length. Adding a new binary frame type needs a capability gate.

## Process Separation

Daemon runs as a separate process (not a child of the GUI app). The GUI reads `daemon.pid` file from `HarnessPaths` to locate it. `SurfaceShellTracker` must scan both GUI and daemon process trees to find shell cwds.
