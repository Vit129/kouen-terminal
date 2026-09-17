# Concurrency & Threading Constraints

- **Swift 6 strict concurrency**: `KouenCore` + `KouenTerminalEngine` use `-warnings-as-errors` — concurrency/deprecation warnings = build failures.
- **`@unchecked Sendable`**: `DaemonClient`, `DaemonServer`, `SurfaceRegistry`, `RealPty`, `DaemonLauncher`, `SurfaceIO`, `InputGate`, `SSHTunnelManager` — preserve lock/queue ownership.
- **Terminal output replay**: `TerminalHostView` uses `DispatchQueue.main.async` + `MainActor.assumeIsolated` to preserve FIFO byte order. `Task { @MainActor in }` can reorder bursty output.
