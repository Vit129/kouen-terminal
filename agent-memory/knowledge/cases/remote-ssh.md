# CASE — Remote SSH (P23)

Grep target: `grep -n "CASE-\|<keyword>" knowledge/cases/remote-ssh.md`

| ID | Trigger | Fix |
|----|---------|-----|
| CASE-041 | hitTest() on WindowTitleStripView swallows remoteBadge clicks | Check subviews for NSButton hits before returning self |
| CASE-042 | saveRemoteHostClicked rename silently overwrites existing host | Add duplicate-name check; reconnect if renaming active host |
| CASE-043 | connectRemoteHostClicked persists form values over saved config | Only addHost for brand-new (unsaved) hosts; existing use stored config |
| CASE-044 | sshArgValue(after:) fails for glued arg form (-p2222) | hasPrefix matching + dropFirst as fallback after exact-token match |
| CASE-045 | Connect button disabled for unsaved new hosts | Enable when form filled (name+target+socket) even without selection |
| CASE-046 | Settings VC never observes connection state changes | Add activeHostDidChange + connectionDidFail observers (stored tokens) |
| CASE-047 | Observer leak in buildRemotePage (block observer accumulates) | Store token in array; remove all old tokens before adding new ones |
| CASE-048 | Socket path placeholder suggests tilde (SSH doesn't expand ~) | Show absolute path: `/home/user/.config/harness/harness.sock` |
| CASE-049 | Concurrent connectToRemote calls → orphaned SSH processes | `isConnectingRemote` flag guards against concurrent spawns |
| CASE-050 | removeHost of active host leaves GUI on dead socket | Call `applyEndpointSwitch(.localControlSocket)` when active host removed |
| CASE-051 | Connect failure leaves status stuck on "Connecting…" | Post `connectionDidFail` notification with error; Settings shows ⚠️ msg |
| CASE-052 | disconnect() posts notification even when already nil | Guard: `guard let name else { return }` |
| CASE-053 | buildRemotePage width constraints accumulate on every visit | Guard: `if remoteNameField.constraints.isEmpty` before activating |
| CASE-054 | Hardcoded page index 6 for Remote settings | `SettingsWindowController.pageRemote` named constant |
| CASE-056 | Split pane (Cmd+D) lands on main instead of current worktree branch | Reorder CWD priority in SurfaceRegistry.newSplit: `worktreePath → sourceCwd → tab.cwd` |
