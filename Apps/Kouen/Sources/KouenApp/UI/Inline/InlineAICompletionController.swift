import AppKit
import KouenCore
import KouenTerminalKit

/// Manages the ⌥Space inline AI command-suggestion overlay for one terminal pane.
///
/// Usage (per `TerminalHostView`):
/// 1. Create one controller.
/// 2. Call `install(in:)` to add the overlay, wire ⌥Space, and set up key interception.
/// 3. The controller captures the last 20 visible lines, sends them to Claude, and shows
///    a ghost-text banner. Tab/Return accepts; Esc dismisses.
@MainActor
final class InlineAICompletionController {
    // MARK: - Public

    let completionView = InlineAICompletionView()

    // MARK: - Private

    private weak var terminalHost: TerminalHostView?

    // MARK: - Install

    /// Attach the overlay to `host`, wire ⌥Space and Tab/Esc interception, and set up the
    /// accept handler (which sends the accepted command to the PTY via `onInput`).
    func install(in host: TerminalHostView) {
        self.terminalHost = host

        // Overlay sits above the bottom of the pane shell.
        completionView.translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(completionView)
        NSLayoutConstraint.activate([
            completionView.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 12),
            completionView.trailingAnchor.constraint(lessThanOrEqualTo: host.trailingAnchor, constant: -12),
            completionView.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -36),
        ])

        // Accept: send command text + newline to the PTY via the host's input path.
        completionView.onAccept = { [weak host] cmd in
            guard let host else { return }
            // Send the command followed by a newline so the shell executes it.
            let bytes = Data((cmd + "\n").utf8)
            host.sendInput(bytes)
        }

        // ⌥Space: capture visible output and trigger Claude fetch.
        host.onOptionSpace = { [weak self, weak host] in
            guard let self, let host else { return false }
            let output = host.captureVisibleLines(maxLines: 20)
            let cwd = host.currentCWD
            self.trigger(paneOutput: output, cwd: cwd, settings: SessionCoordinator.shared.settings)
            return true
        }

        // Tab/Return/Esc while overlay is visible.
        host.onKeyIntercept = { [weak self] event in
            guard let self else { return false }
            return self.completionView.handleKeyDown(with: event)
        }
    }

    // MARK: - Trigger

    func trigger(paneOutput: String, cwd: String?, settings: KouenSettings) {
        // Inline AI completion disabled — no backend client.
    }
}
