import AppKit
import HarnessCore
import HarnessTerminalKit

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
    private var inFlight = false

    private static let systemPrompt =
        "You are a shell command assistant. Given recent terminal output, suggest ONE shell " +
        "command that the user would logically run next. Reply with ONLY the command, no " +
        "explanation, no backticks."

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

    /// Fetch a suggestion from Claude and populate the overlay.
    func trigger(paneOutput: String, cwd: String?, settings: HarnessSettings) {
        guard !inFlight else { return }
        guard settings.inlineAICompletion else { return }

        guard let client = ClaudeDirectClient(settings: settings) else {
            completionView.suggestion = "(no API key — set Claude API key in Settings)"
            return
        }

        inFlight = true
        completionView.suggestion = "…"

        let context: String
        if let dir = cwd, !dir.isEmpty {
            context = "cwd: \(dir)\n\n\(paneOutput)"
        } else {
            context = paneOutput
        }

        Task { [weak self] in
            guard let self else { return }
            let result = await client.complete(
                messages: [.init(role: "user", content: context)],
                systemPrompt: Self.systemPrompt,
                maxTokens: 256
            )
            await MainActor.run {
                self.inFlight = false
                switch result {
                case .success(let cmd):
                    let trimmed = cmd.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.completionView.suggestion = trimmed.isEmpty ? nil : trimmed
                case .failure:
                    self.completionView.suggestion = nil
                }
            }
        }
    }
}
