import AppKit
import SwiftUI
import HarnessCore
import HarnessTerminalKit

/// Borderless panel that can still take key focus.
@MainActor
private final class DirectoryPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

@MainActor
public enum DirectoryPickerController {
    private static var panel: NSPanel?
    private static var windowDelegate: DirectoryWindowDelegate?

    fileprivate static func clearReferences() {
        panel = nil
        windowDelegate = nil
    }

    private static func zoxideRanked() async -> [String] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                task.arguments = ["zoxide", "query", "--list"]
                let pipe = Pipe()
                task.standardOutput = pipe
                task.standardError = Pipe()
                do {
                    try task.run()
                    task.waitUntilExit()
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let lines = String(data: data, encoding: .utf8)?
                        .split(separator: "\n").map(String.init).filter { !$0.isEmpty } ?? []
                    continuation.resume(returning: lines)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    public static func present(relativeTo parent: NSWindow?) {
        panel?.close()

        let dirs = FrecencyDirectoryStore.shared.ranked()
        let model = DirectoryPickerModel(directories: dirs, parentWindow: parent)
        Task {
            let zDirs = await zoxideRanked()
            guard !zDirs.isEmpty else { return }
            model.mergeZoxide(zDirs)
        }
        let controller = NSHostingController(rootView: DirectoryPickerView(model: model))

        let panel = DirectoryPanel(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 440),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isRestorable = false
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.contentViewController = controller
        panel.setContentSize(NSSize(width: 620, height: 440))

        let delegate = DirectoryWindowDelegate()
        delegate.panel = panel
        panel.delegate = delegate
        windowDelegate = delegate

        if let frame = parent?.frame {
            panel.setFrameOrigin(NSPoint(
                x: (frame.midX - panel.frame.width / 2).rounded(),
                y: (frame.midY - panel.frame.height / 2).rounded()
            ))
        } else if let screenFrame = (NSScreen.main ?? NSScreen.screens.first)?.visibleFrame {
            panel.setFrameOrigin(NSPoint(
                x: (screenFrame.midX - panel.frame.width / 2).rounded(),
                y: (screenFrame.midY - panel.frame.height / 2).rounded()
            ))
        } else {
            panel.center()
        }

        self.panel = panel
        model.panel = panel

        NSApp.activate(ignoringOtherApps: true)
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)

        HarnessMotion.animate(HarnessDesign.Motion.fast, timing: HarnessDesign.Motion.spring) { _ in
            panel.animator().alphaValue = 1
        }
    }
}

@MainActor
@Observable
final class DirectoryPickerModel {
    var query: String = ""
    var selectedIndex: Int = 0
    var filteredDirectories: [String] = []

    var allDirectories: [String]
    weak var parentWindow: NSWindow?
    weak var panel: NSPanel?

    init(directories: [String], parentWindow: NSWindow?) {
        self.allDirectories = directories
        self.parentWindow = parentWindow
        rebuildFiltered()
    }

    func updateQuery(_ newQuery: String) {
        query = newQuery
        rebuildFiltered()
    }

    func moveSelection(by offset: Int) {
        guard !filteredDirectories.isEmpty else { return }
        selectedIndex = (selectedIndex + offset + filteredDirectories.count) % filteredDirectories.count
    }

    func activateSelected() {
        guard filteredDirectories.indices.contains(selectedIndex) else { return }
        let path = filteredDirectories[selectedIndex]
        panel?.close()

        let coordinator = SessionCoordinator.shared
        if let surfaceID = coordinator.activeSurfaceID,
           let host = coordinator.terminalHostIfExists(for: surfaceID) {
            host.sendInput(("cd \(path)\n").data(using: .utf8) ?? Data())
        }
    }

    func activateSelectedInNewTab() {
        guard filteredDirectories.indices.contains(selectedIndex) else { return }
        let path = filteredDirectories[selectedIndex]
        panel?.close()

        let coordinator = SessionCoordinator.shared
        guard let wsID = coordinator.snapshot.activeWorkspace?.id else { return }
        coordinator.addTab(to: wsID, cwd: path)
    }

    func mergeZoxide(_ zDirs: [String]) {
        let zSet = Set(zDirs)
        allDirectories = zDirs + allDirectories.filter { !zSet.contains($0) }
        rebuildFiltered()
    }

    func close() {
        panel?.close()
    }

    private func rebuildFiltered() {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            filteredDirectories = allDirectories
        } else {
            filteredDirectories = allDirectories.filter { path in
                path.localizedCaseInsensitiveContains(trimmed)
            }
        }
        if selectedIndex >= filteredDirectories.count {
            selectedIndex = max(0, filteredDirectories.count - 1)
        }
    }
}

@MainActor
private struct DirectoryPickerView: View {
    @Bindable var model: DirectoryPickerModel
    @FocusState private var searchFocused: Bool

    var body: some View {
        let c = HarnessChrome.current
        VStack(spacing: 0) {
            TextField(text: $model.query, prompt: Text("Search recent directories...").foregroundStyle(Color(nsColor: c.textTertiary))) {
                EmptyView()
            }
            .textFieldStyle(.plain)
            .font(.system(size: 15))
            .foregroundStyle(Color(nsColor: c.textPrimary))
            .focused($searchFocused)
            .padding(.horizontal, 18)
            .frame(height: 52)
            .onSubmit { model.activateSelected() }
            .onChange(of: model.query) { _, newValue in
                model.updateQuery(newValue)
            }

            Divider()
                .overlay(Color(nsColor: c.border))

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(model.filteredDirectories.enumerated()), id: \.element) { index, path in
                            DirectoryItemRow(
                                path: path,
                                query: model.query,
                                isSelected: index == model.selectedIndex
                            )
                            .frame(height: 48)
                            .id(index)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                model.selectedIndex = index
                                model.activateSelected()
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .overlay {
                    if model.filteredDirectories.isEmpty {
                        Text("No matching directories")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(nsColor: c.textTertiary))
                    }
                }
                .onChange(of: model.selectedIndex) { _, newValue in
                    withAnimation(.easeOut(duration: HarnessDesign.Motion.fast)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }

            DirectoryPickerFooter()
                .frame(height: 40)
        }
        .background(OverlayBackground())
        .clipShape(RoundedRectangle(cornerRadius: HarnessDesign.Radius.overlay, style: .continuous))
        .onAppear {
            searchFocused = true
        }
        .onKeyPress(.upArrow) {
            model.moveSelection(by: -1)
            return .handled
        }
        .onKeyPress(.downArrow) {
            model.moveSelection(by: 1)
            return .handled
        }
        .onKeyPress(.escape) {
            model.close()
            return .handled
        }
        .onKeyPress(.return, phases: .down) { press in
            if press.modifiers.contains(.command) {
                model.activateSelectedInNewTab()
                return .handled
            }
            return .ignored
        }
    }
}

@MainActor
private struct DirectoryItemRow: View {
    let path: String
    let query: String
    let isSelected: Bool

    var body: some View {
        let c = HarnessChrome.current
        let folderName = (path as NSString).lastPathComponent
        let shortPath = HarnessDesign.shortenPath(path)
        
        HStack(spacing: HarnessDesign.Spacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: HarnessDesign.Radius.control, style: .continuous)
                    .fill(Color(nsColor: c.textPrimary.withAlphaComponent(c.isDark ? 0.06 : 0.07)))
                Image(systemName: "folder.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(nsColor: c.textSecondary))
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(highlightedTitle(title: folderName, primary: c.textPrimary, accent: c.accent))
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(Color(nsColor: c.textPrimary))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(shortPath)
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: HarnessDesign.Spacing.md)
        }
        .padding(.horizontal, HarnessDesign.Spacing.xl)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: HarnessDesign.Radius.control, style: .continuous)
                    .fill(Color(nsColor: c.accent.withAlphaComponent(c.isDark ? 0.16 : 0.13)))
                    .padding(.horizontal, HarnessDesign.Spacing.md)
                    .padding(.vertical, 3)
            }
        }
    }

    private func highlightedTitle(title: String, primary: NSColor, accent: NSColor) -> AttributedString {
        var result = AttributedString(title)
        guard !query.isEmpty else { return result }
        let lowerTitle = title.lowercased()
        let lowerQuery = query.lowercased()
        var searchStart = lowerTitle.startIndex
        for char in lowerQuery {
            guard searchStart < lowerTitle.endIndex else { break }
            guard let found = lowerTitle[searchStart...].firstIndex(of: char) else { break }
            let offset = lowerTitle.distance(from: lowerTitle.startIndex, to: found)
            let attributedIndex = result.index(result.startIndex, offsetByCharacters: offset)
            result[attributedIndex..<result.index(afterCharacter: attributedIndex)].foregroundColor = Color(nsColor: accent)
            result[attributedIndex..<result.index(afterCharacter: attributedIndex)].font = .system(size: 13.5, weight: .heavy)
            searchStart = lowerTitle.index(after: found)
        }
        return result
    }
}

@MainActor
private struct DirectoryPickerFooter: View {
    var body: some View {
        let c = HarnessChrome.current
        HStack(spacing: HarnessDesign.Spacing.lg) {
            hint(keys: "↑↓", label: "Navigate")
            hint(keys: "↩", label: "cd here")
            hint(keys: "⌘↩", label: "New tab")
            hint(keys: "esc", label: "Close")
        }
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: c.textPrimary.withAlphaComponent(c.isDark ? 0.04 : 0.05)))
    }

    private func hint(keys: String, label: String) -> some View {
        let c = HarnessChrome.current
        return HStack(spacing: 4) {
            Text(keys)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color(nsColor: c.textSecondary))
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color(nsColor: c.textPrimary.withAlphaComponent(c.isDark ? 0.08 : 0.10)))
                )
            Text(label)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color(nsColor: c.textTertiary))
        }
    }
}

private struct OverlayBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> HarnessOverlayBackground { HarnessOverlayBackground() }
    func updateNSView(_ v: HarnessOverlayBackground, context: Context) {}
}

@MainActor
private final class DirectoryWindowDelegate: NSObject, NSWindowDelegate {
    weak var panel: NSPanel?
    func windowDidResignKey(_ notification: Notification) { panel?.close() }
    func windowWillClose(_ notification: Notification) {
        DirectoryPickerController.clearReferences()
    }
}
