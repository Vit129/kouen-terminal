import AppKit

public enum ViInputMode: Sendable { case insert, normal }

extension KouenTerminalSurfaceView {
    // Called from _keyDown — returns true if the event was consumed.
    func handleViMode(_ event: NSEvent) -> Bool {
        guard viModeEnabled else { return false }
        // Esc in insert mode → enter normal
        if viModeState == .insert, event.keyCode == 53 /* Esc */ {
            setViMode(.normal); return true
        }
        // Normal mode: ⌘ shortcuts still reach the app; all other keys are dispatched here
        guard viModeState == .normal,
              !event.modifierFlags.contains(.command) else { return false }
        let ch = event.charactersIgnoringModifiers ?? ""
        switch ch {
        case "h": emit([0x1B, 0x5B, 0x44]); return true  // ←
        case "l": emit([0x1B, 0x5B, 0x43]); return true  // →
        case "j": emit([0x1B, 0x5B, 0x42]); return true  // ↓
        case "k": emit([0x1B, 0x5B, 0x41]); return true  // ↑
        case "w": emit([0x1B, 0x66]); return true          // Meta+f (word fwd)
        case "b": emit([0x1B, 0x62]); return true          // Meta+b (word back)
        case "0": emit([0x01]); return true                // ^A (line start)
        case "$": emit([0x05]); return true                // ^E (line end)
        case "x": emit([0x7F]); return true                // DEL char
        case "i": setViMode(.insert); return true
        case "a": emit([0x1B, 0x5B, 0x43]); setViMode(.insert); return true  // move right → insert
        case "A": emit([0x05]); setViMode(.insert); return true               // ^E → insert
        default: return true  // swallow unrecognized normal-mode keys
        }
    }

    public func setViMode(_ mode: ViInputMode) {
        viModeState = mode
        onViModeChanged?(mode)
    }
}
