import AppKit
import Observation
import HarnessCore

// MARK: - Shared keyboard state (SwiftUI reads, AppKit writes)

@Observable
@MainActor
final class FileTreeKeyboardState {
    var focusedPath: String? = nil
    var filterFocused: Bool = false
    var visiblePaths: [String] = []
}

// MARK: - Navigator (AppKit side)

/// Handles keyboard events forwarded from WorkspaceFileTreeView.
/// Maintains a flat ordered list of currently visible nodes for j/k navigation.
@MainActor
final class FileTreeKeyboardNavigator {
    let state = FileTreeKeyboardState()
    var onOpenFile: ((String) -> Void)?
    var onPreviewFile: ((String) -> Void)?
    var onToggleExpand: ((String) -> Void)?
    var onFocusFilter: (() -> Void)?

    /// Returns true if the event was consumed.
    func handle(_ event: NSEvent) -> Bool {
        let key = event.charactersIgnoringModifiers ?? ""
        let ctrl = event.modifierFlags.contains(.control)

        switch key {
        case "j", "\u{F701}":
            moveCursor(by: 1); return true
        case "k", "\u{F700}":
            moveCursor(by: -1); return true
        case "h", "\u{F702}":
            // h: collapse current node
            if let p = state.focusedPath { onToggleExpand?(p + "__collapse") }; return true
        case "l", "\u{F703}":
            // l: expand current node
            if let p = state.focusedPath { onToggleExpand?(p + "__expand") }; return true
        case "\r", "\n":
            if let p = state.focusedPath { onOpenFile?(p) }; return true
        case "o":
            if let p = state.focusedPath { onPreviewFile?(p) }; return true
        case "/":
            onFocusFilter?(); return true
        case "g":
            state.focusedPath = state.visiblePaths.first; return true
        case "G":
            state.focusedPath = state.visiblePaths.last; return true
        default:
            if ctrl && key == "d" { moveCursor(by: 10); return true }
            if ctrl && key == "u" { moveCursor(by: -10); return true }
            return false
        }
    }

    private func moveCursor(by delta: Int) {
        let paths = state.visiblePaths
        guard !paths.isEmpty else { return }
        if let current = state.focusedPath, let idx = paths.firstIndex(of: current) {
            let newIdx = max(0, min(paths.count - 1, idx + delta))
            state.focusedPath = paths[newIdx]
        } else {
            state.focusedPath = delta > 0 ? paths.first : paths.last
        }
    }
}
