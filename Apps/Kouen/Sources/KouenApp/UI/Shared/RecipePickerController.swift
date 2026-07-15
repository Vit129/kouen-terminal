import AppKit
import SwiftUI
import KouenCore
import KouenTerminalEngine
import KouenTerminalKit

/// Borderless panel that can still take key focus.
@MainActor
private final class RecipePanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

/// One entry in the unified picker (P38 Phase C) — a saved `Recipe` (a command you might want to
/// run) or a `TerminalBlock` from a pane's captured command history (a command you already ran).
/// Merged into one flat, searchable list rather than two separate UIs — Recipes (⌘⇧R) and the
/// original standalone thread-view overlay (⌘⇧L) were consolidated here. A history block carries
/// its own `surfaceID` (so activating it jumps the pane it actually came from, not whatever pane
/// happens to be active) and a `paneLabel` (so the list can group history by originating pane —
/// Zed's "thread" framing, folded into this same picker instead of a dedicated UI).
enum PickerItem: Identifiable {
    case recipe(Recipe)
    case historyBlock(TerminalBlock, surfaceID: SurfaceID, paneLabel: String)

    var id: String {
        switch self {
        case .recipe(let r): return "recipe-\(r.id.uuidString)"
        case .historyBlock(let b, _, _): return "block-\(b.id)"
        }
    }

    var searchableText: String {
        switch self {
        case .recipe(let r): return "\(r.name) \(r.command)"
        case .historyBlock(let b, _, _): return b.command
        }
    }

    /// The pane this item's history came from — nil for recipes (they aren't part of any
    /// pane's thread). Consecutive items sharing a group label render one header between them.
    var groupLabel: String? {
        switch self {
        case .recipe: return nil
        case .historyBlock(_, _, let label): return label
        }
    }
}

@MainActor
public enum RecipePickerController {
    private static var panel: NSPanel?
    private static var windowDelegate: RecipeWindowDelegate?

    fileprivate static func clearReferences() {
        panel = nil
        windowDelegate = nil
    }

    public static func present(relativeTo parent: NSWindow?) {
        panel?.close()

        let recipes = RecipesStore.shared.recipes
        let coordinator = SessionCoordinator.shared
        // Every pane in the active tab is its own "thread" (Zed's framing, folded into this
        // picker instead of a dedicated UI) — not just whichever pane happens to be focused.
        let historyItems: [PickerItem] = (coordinator.snapshot.activeWorkspace?.activeTab?.rootPane.allLeaves() ?? [])
            .enumerated()
            .flatMap { index, leaf -> [PickerItem] in
                guard let surfaceID = leaf.activeSurfaceID ?? leaf.surfaceIDs.first,
                      let host = coordinator.terminalHostIfExists(for: surfaceID)
                else { return [] }
                let paneLabel = leaf.surfaces.first(where: { $0.id == surfaceID })?.label ?? "Pane \(index + 1)"
                // Most-recent-first — `TerminalBlock`s come oldest-first from the engine's capture order.
                return host.surfaceView.blocks.reversed().map { .historyBlock($0, surfaceID: surfaceID, paneLabel: paneLabel) }
            }
        let model = RecipePickerModel(recipes: recipes, historyItems: historyItems, parentWindow: parent)
        let controller = NSHostingController(rootView: RecipePickerView(model: model))

        let panel = RecipePanel(
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

        let delegate = RecipeWindowDelegate()
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

        KouenMotion.animate(KouenDesign.Motion.fast, timing: KouenDesign.Motion.spring) { _ in
            panel.animator().alphaValue = 1
        }
    }
}

@MainActor
@Observable
final class RecipePickerModel {
    var query: String = ""
    var selectedIndex: Int = 0
    var filteredItems: [PickerItem] = []

    let allItems: [PickerItem]
    weak var parentWindow: NSWindow?
    weak var panel: NSPanel?

    init(recipes: [Recipe], historyItems: [PickerItem], parentWindow: NSWindow?) {
        // History first (most-recent-first, already reversed by the caller) — "what you just
        // ran" is the more likely thing you're looking for than a saved recipe when the list is
        // unfiltered; search still reaches recipes regardless of position.
        self.allItems = historyItems + recipes.map(PickerItem.recipe)
        self.parentWindow = parentWindow
        rebuildFiltered()
    }

    func updateQuery(_ newQuery: String) {
        query = newQuery
        rebuildFiltered()
    }

    func moveSelection(by offset: Int) {
        guard !filteredItems.isEmpty else { return }
        selectedIndex = (selectedIndex + offset + filteredItems.count) % filteredItems.count
    }

    func activateSelected() {
        guard filteredItems.indices.contains(selectedIndex) else { return }
        let item = filteredItems[selectedIndex]
        panel?.close()

        let coordinator = SessionCoordinator.shared
        switch item {
        case .recipe(let recipe):
            if recipe.runImmediately {
                if let surfaceID = coordinator.activeSurfaceID,
                   let host = coordinator.terminalHostIfExists(for: surfaceID) {
                    host.sendInput((recipe.command + "\n").data(using: .utf8) ?? Data())
                }
            } else {
                coordinator.openComposer(withInitialText: recipe.command)
            }
        case .historyBlock(let block, let surfaceID, _):
            // Jump the pane the block actually came from — it may not be the one currently
            // focused, now that history spans every pane in the tab, not just the active one.
            if let host = coordinator.terminalHostIfExists(for: surfaceID) {
                coordinator.setActiveSurface(surfaceID)
                host.jumpToBlock(promptLine: block.promptLine)
            }
        }
    }

    func close() {
        panel?.close()
    }

    private func rebuildFiltered() {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        filteredItems = trimmed.isEmpty
            ? allItems
            : allItems.filter { $0.searchableText.localizedCaseInsensitiveContains(trimmed) }
        if selectedIndex >= filteredItems.count {
            selectedIndex = max(0, filteredItems.count - 1)
        }
    }
}

@MainActor
private struct RecipePickerView: View {
    @Bindable var model: RecipePickerModel
    @FocusState private var searchFocused: Bool

    var body: some View {
        let c = KouenChrome.current
        VStack(spacing: 0) {
            TextField(text: $model.query, prompt: Text("Search recipes & history...").foregroundStyle(Color(nsColor: c.textTertiary))) {
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
                    LazyVStack(spacing: 0, pinnedViews: []) {
                        ForEach(Array(model.filteredItems.enumerated()), id: \.element.id) { index, item in
                            if let label = item.groupLabel, model.filteredItems[safe: index - 1]?.groupLabel != label {
                                GroupHeaderRow(label: label)
                            }
                            PickerItemRow(
                                item: item,
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
                    if model.filteredItems.isEmpty {
                        Text("No matches")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(nsColor: c.textTertiary))
                    }
                }
                .onChange(of: model.selectedIndex) { _, newValue in
                    withAnimation(.easeOut(duration: KouenDesign.Motion.fast)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }

            RecipePickerFooter()
                .frame(height: 40)
        }
        .background(OverlayBackground())
        .clipShape(RoundedRectangle(cornerRadius: KouenDesign.Radius.overlay, style: .continuous))
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
    }
}

/// Marks where one pane's history ("thread") starts in the list — Zed's turn-by-turn framing,
/// folded into this single flat list instead of a dedicated thread UI.
@MainActor
private struct GroupHeaderRow: View {
    let label: String

    var body: some View {
        let c = KouenChrome.current
        Text(label.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .tracking(0.5)
            .foregroundStyle(Color(nsColor: c.textTertiary))
            .padding(.horizontal, KouenDesign.Spacing.xl)
            .padding(.top, KouenDesign.Spacing.sm)
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

@MainActor
private struct PickerItemRow: View {
    let item: PickerItem
    let query: String
    let isSelected: Bool

    var body: some View {
        let c = KouenChrome.current
        HStack(spacing: KouenDesign.Spacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: KouenDesign.Radius.control, style: .continuous)
                    .fill(Color(nsColor: c.textPrimary.withAlphaComponent(c.isDark ? 0.06 : 0.07)))
                Image(systemName: iconName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(iconColor(c))
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(highlightedTitle(primary: c.textPrimary, accent: c.accent))
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(Color(nsColor: c.textPrimary))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(subtitle)
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: KouenDesign.Spacing.md)

            Text(badgeText)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(badgeColor(c))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(nsColor: c.textPrimary.withAlphaComponent(0.08)))
                )
        }
        .padding(.horizontal, KouenDesign.Spacing.xl)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: KouenDesign.Radius.control, style: .continuous)
                    .fill(Color(nsColor: c.accent.withAlphaComponent(c.isDark ? 0.16 : 0.13)))
                    .padding(.horizontal, KouenDesign.Spacing.md)
                    .padding(.vertical, 3)
            }
        }
    }

    private var titleText: String {
        switch item {
        case .recipe(let recipe): return recipe.name
        case .historyBlock(let block, _, _): return block.command
        }
    }

    private var subtitle: String {
        switch item {
        case .recipe(let recipe): return recipe.command
        case .historyBlock(let block, _, _):
            guard let exitCode = block.exitCode else { return "running…" }
            return exitCode == 0 ? "done" : "exit \(exitCode)"
        }
    }

    private var iconName: String {
        switch item {
        case .recipe(let recipe): return recipe.runImmediately ? "play.fill" : "square.and.pencil"
        case .historyBlock: return "clock.arrow.circlepath"
        }
    }

    private func iconColor(_ c: KouenChromePalette) -> Color {
        if case .historyBlock(let block, _, _) = item, let exitCode = block.exitCode, exitCode != 0 {
            return .red
        }
        return Color(nsColor: c.textSecondary)
    }

    private var badgeText: String {
        switch item {
        case .recipe(let recipe): return recipe.runImmediately ? "Run" : "Composer"
        case .historyBlock: return "Jump"
        }
    }

    private func badgeColor(_ c: KouenChromePalette) -> Color {
        Color(nsColor: c.textTertiary)
    }

    private func highlightedTitle(primary: NSColor, accent: NSColor) -> AttributedString {
        var result = AttributedString(titleText)
        guard !query.isEmpty else { return result }
        let lowerTitle = titleText.lowercased()
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
private struct RecipePickerFooter: View {
    var body: some View {
        let c = KouenChrome.current
        HStack(spacing: KouenDesign.Spacing.lg) {
            hint(keys: "↑↓", label: "Navigate")
            hint(keys: "↩", label: "Select")
            hint(keys: "esc", label: "Close")
        }
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: c.textPrimary.withAlphaComponent(c.isDark ? 0.04 : 0.05)))
    }

    private func hint(keys: String, label: String) -> some View {
        let c = KouenChrome.current
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

private extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}

private struct OverlayBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> KouenOverlayBackground { KouenOverlayBackground() }
    func updateNSView(_ v: KouenOverlayBackground, context: Context) {}
}

@MainActor
private final class RecipeWindowDelegate: NSObject, NSWindowDelegate {
    weak var panel: NSPanel?
    func windowDidResignKey(_ notification: Notification) { panel?.close() }
    func windowWillClose(_ notification: Notification) {
        RecipePickerController.clearReferences()
    }
}
