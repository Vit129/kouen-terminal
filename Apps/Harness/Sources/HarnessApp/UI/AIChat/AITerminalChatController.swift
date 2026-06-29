import AppKit
import HarnessCore
import HarnessTerminalKit

/// Manages the Warp-style inline AI chat overlay on a `TerminalHostView`.
///
/// Lifecycle:
///   - `toggle()` shows/hides the `AIQueryInputView`.
///   - On submit, spawns the agent CLI via `AgentProcessManager`, streams chunks
///     into a new `AIResponseBlockView` stacked above the input bar.
///   - `⌘I` again (or `toggle()`) clears all response blocks.
///   - `[▶ Run]` sends the code block text to the PTY as if typed.
///   - `[✕]` or Esc dismisses the input bar (response blocks stay).
@MainActor
final class AITerminalChatController {

    // MARK: - Dependencies

    private weak var hostView: TerminalHostView?
    private let processManager = AgentProcessManager()
    private var settings: HarnessSettings

    // MARK: - State

    private var queryInput: AIQueryInputView?
    private var responseBlocks: [AIResponseBlockView] = []
    private var isVisible = false
    private var activeTask: Task<Void, Never>?

    // MARK: - Layout constants

    private let inputHeight: CGFloat = 62
    private let blockHeight: CGFloat = 200
    private let horizontalPadding: CGFloat = 12
    private let bottomPadding: CGFloat = 8

    // MARK: - Init

    init(hostView: TerminalHostView, settings: HarnessSettings) {
        self.hostView = hostView
        self.settings = settings
    }

    func updateSettings(_ settings: HarnessSettings) {
        self.settings = settings
        queryInput?.configure(agent: settings.aiAgent.activeAgent,
                              model: settings.aiAgent.activeModel,
                              effort: settings.aiAgent.activeEffort)
    }

    // MARK: - Toggle

    /// ⌘I: show input if hidden; clear all blocks + hide if shown.
    func toggle() {
        if isVisible {
            dismiss(clearBlocks: true)
        } else {
            showInput()
        }
    }

    func askAI(prefill text: String) {
        if !isVisible { showInput() }
        queryInput?.prefill(text)
    }

    // MARK: - Show / Hide

    private func showInput() {
        guard let host = hostView else { return }
        isVisible = true

        let input = AIQueryInputView(frame: .zero)
        input.configure(agent: settings.aiAgent.activeAgent,
                        model: settings.aiAgent.activeModel,
                        effort: settings.aiAgent.activeEffort)
        input.onSubmit = { [weak self] text in self?.submit(text) }
        input.onDismiss = { [weak self] in self?.dismiss(clearBlocks: false) }
        input.onAgentChanged = { [weak self] kind in self?.changeAgent(kind) }
        input.onModelChanged = { [weak self] model in self?.changeModel(model) }
        input.onEffortChanged = { [weak self] effort in self?.changeEffort(effort) }

        host.addSubview(input, positioned: .above, relativeTo: nil)
        NSLayoutConstraint.activate(inputConstraints(for: input, in: host))
        queryInput = input
        input.focus()
    }

    private func dismiss(clearBlocks: Bool) {
        isVisible = false
        queryInput?.removeFromSuperview()
        queryInput = nil
        if clearBlocks {
            activeTask?.cancel()
            responseBlocks.forEach { $0.removeFromSuperview() }
            responseBlocks.removeAll()
        }
    }

    // MARK: - Agent / model / effort switching

    private func changeAgent(_ kind: AgentKind) {
        settings.aiAgent.activeAgent = kind
        // Clear model/effort when switching agents — each agent has different valid values
        settings.aiAgent.activeModel = nil
        settings.aiAgent.activeEffort = nil
        try? settings.save()
    }

    private func changeModel(_ model: String?) {
        settings.aiAgent.activeModel = model
        try? settings.save()
    }

    private func changeEffort(_ effort: String?) {
        settings.aiAgent.activeEffort = effort
        try? settings.save()
    }

    // MARK: - Submit

    private func submit(_ text: String) {
        guard let host = hostView else { return }

        // Context: last N visible lines from the pane (B-5)
        let context = host.captureVisibleLines(maxLines: settings.aiAgent.contextLines)

        // Build a new response block
        let block = AIResponseBlockView(frame: .zero)
        block.configure(agent: settings.aiAgent.activeAgent)
        block.onRun = { [weak self] code in self?.runInTerminal(code) }
        block.onDismiss = { [weak self] in self?.removeBlock(block) }

        host.addSubview(block, positioned: .above, relativeTo: nil)
        NSLayoutConstraint.activate(blockConstraints(for: block, in: host))
        responseBlocks.append(block)

        // Hide input while streaming, re-show after
        queryInput?.isHidden = true

        // Stream agent response
        let config = settings.aiAgent
        activeTask = Task {
            let stream = await processManager.query(text, context: context, config: config)
            for await chunk in stream {
                if Task.isCancelled { break }
                switch chunk {
                case .text(let s): block.appendChunk(s)
                case .done: block.markDone()
                case .error(let e): block.markError(e)
                }
            }
            queryInput?.isHidden = false
            queryInput?.focus()
        }
    }

    // MARK: - Run code block in PTY

    private func runInTerminal(_ code: String) {
        guard let host = hostView else { return }
        let text = code.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
        if let data = text.data(using: .utf8) {
            host.sendInput(data)
        }
    }

    // MARK: - Remove a single block

    private func removeBlock(_ block: AIResponseBlockView) {
        block.removeFromSuperview()
        responseBlocks.removeAll { $0 === block }
        repositionBlocks()
    }

    // MARK: - Layout helpers

    private func inputConstraints(for input: AIQueryInputView, in host: NSView) -> [NSLayoutConstraint] {
        [
            input.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: horizontalPadding),
            input.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -horizontalPadding),
            input.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -bottomPadding),
            input.heightAnchor.constraint(equalToConstant: inputHeight),
        ]
    }

    private func blockConstraints(for block: AIResponseBlockView, in host: NSView) -> [NSLayoutConstraint] {
        let bottomOffset = bottomPadding + inputHeight + 6 + CGFloat(responseBlocks.count - 1) * (blockHeight + 6)
        return [
            block.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: horizontalPadding),
            block.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -horizontalPadding),
            block.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -(bottomOffset + blockHeight)),
            block.heightAnchor.constraint(equalToConstant: blockHeight),
        ]
    }

    private func repositionBlocks() {
        // Rebuild bottom constraints after a block is removed
        for (i, block) in responseBlocks.enumerated() {
            guard let host = hostView else { break }
            // Remove existing bottom constraint and replace
            block.removeConstraints(block.constraints.filter { $0.firstAttribute == .bottom })
            let offset = bottomPadding + inputHeight + 6 + CGFloat(i) * (blockHeight + 6)
            block.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -(offset + blockHeight)).isActive = true
        }
    }
}
