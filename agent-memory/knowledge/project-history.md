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

## Known Issues (Current)

- CWD tracking: SurfaceShellTracker can't read daemon children's environment reliably
- Split right 4+ panes: slightly uneven due to NSSplitView default resize algorithm
- ACP: shelved — adapters not ready
