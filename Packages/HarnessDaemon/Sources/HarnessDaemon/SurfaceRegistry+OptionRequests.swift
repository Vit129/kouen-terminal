import Foundation
import HarnessCore
import HarnessTerminalEngine

/// Request handlers that `handle(_:)` calls with `lock` held.
extension SurfaceRegistry {
    func setOptionLocked(scopeRaw: String, target: String?, key: String, raw: String) -> IPCResponse {
        guard let scope = OptionStore.Scope(rawValue: scopeRaw) else {
            return .error("Unknown option scope: \(scopeRaw)")
        }
        // The on-disk key joins scope:target:key with colons; a colon in the option name or
        // target would mis-parse on read-back. Option names and ID targets never contain one,
        // so reject it rather than silently corrupt the store.
        guard !key.contains(":"), !(target?.contains(":") ?? false) else {
            return .error("Option name/target must not contain ':'")
        }
        // Reject unknown option names loudly (a `@`-prefixed user option always passes), so a
        // typo like `moused` fails in every front-end instead of being silently persisted and
        // never read — the project's no-silent-failure invariant.
        guard OptionStore.isRecognizedOptionKey(key) else {
            return .error("unknown option: \(key)")
        }
        // Scoped reads resolve by exact target and only fall back toward broader scopes —
        // a nil-target non-global option is stored but unreachable by every read path.
        // Reject it (defense in depth behind the CLI's own -T requirement).
        guard scope == .global || target != nil else {
            return .error("\(scopeRaw) scope requires a target")
        }
        // `persist-scrollback` is read per pane (with global fallback) only — a tab/
        // session/workspace-scoped value would be stored but unreachable by every read
        // path (the OptionStore fallback widens with nil targets only): a silent no-op
        // on a security control. Reject loudly instead.
        if key == "persist-scrollback", scope != .pane, scope != .global {
            return .error("persist-scrollback is pane- or global-scoped")
        }
        optionStore.set(.init(parsing: raw), key: key, scope: scope, target: target)
        // Keep the monitor tick's lock-free precheck honest: silence arming changed.
        if key == "monitor-silence" { refreshSilenceArmedCache() }
        // Apply the secrets-at-rest toggle to live surfaces immediately: disabling wipes
        // the on-disk log synchronously (the user's intent is "gone now", not "gone at
        // the next spawn"); re-enabling resumes persistence from that point — including
        // for surfaces spawned while the option was off (they carry a suspended log
        // writer) — documented in docs/SECURITY-POSTURE.md.

        // Nudge snapshot subscribers (the attach-window compositor) so a runtime option
        // change — status-*, mouse, pane-style, mode-keys — reaches attached clients instead
        // of being stuck at their startup values. Re-uses the snapshot push as a generic
        // "re-read server state" signal (revision unchanged; clients re-pull options).
        onSnapshotCommitted?(editor.snapshot.revision)
        return .ok
    }

    func bindHookLocked(eventRaw: String, source: String, condition: String?) -> IPCResponse {
        guard let event = HookEvent(rawValue: eventRaw) else {
            return .error("Unknown hook event: \(eventRaw)")
        }
        do {
            let command = try CommandParser.parse(source)
            let id = hookRegistry.bind(event: event, command: command, conditionFormat: condition)
            return .hookID(id)
        } catch {
            return .error("Parse failed: \(error)")
        }
    }
}
