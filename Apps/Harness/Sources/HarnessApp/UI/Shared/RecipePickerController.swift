import AppKit
import SwiftUI
import HarnessCore
import HarnessTerminalKit

/// Borderless panel that can still take key focus.
@MainActor
private final class RecipePanel: NSPanel {
    override var canBecomeKey: Bool { true }
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
        let model = RecipePickerModel(recipes: recipes, parentWindow: parent)
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

        HarnessMotion.animate(HarnessDesign.Motion.fast, timing: HarnessDesign.Motion.spring) { _ in
            panel.animator().alphaValue = 1
        }
    }
}

@MainActor
@Observable
final class RecipePickerModel {
    var query: String = ""
    var selectedIndex: Int = 0
    var filteredRecipes: [Recipe] = []

    let allRecipes: [Recipe]
    weak var parentWindow: NSWindow?
    weak var panel: NSPanel?

    init(recipes: [Recipe], parentWindow: NSWindow?) {
        self.allRecipes = recipes
        self.parentWindow = parentWindow
        rebuildFiltered()
    }

    func updateQuery(_ newQuery: String) {
        query = newQuery
        rebuildFiltered()
    }

    func moveSelection(by offset: Int) {
        guard !filteredRecipes.isEmpty else { return }
        selectedIndex = (selectedIndex + offset + filteredRecipes.count) % filteredRecipes.count
    }

    func activateSelected() {
        guard filteredRecipes.indices.contains(selectedIndex) else { return }
        let recipe = filteredRecipes[selectedIndex]
        panel?.close()

        let coordinator = SessionCoordinator.shared
        if recipe.runImmediately {
            if let surfaceID = coordinator.activeSurfaceID,
               let host = coordinator.terminalHostIfExists(for: surfaceID) {
                host.sendInput((recipe.command + "\n").data(using: .utf8) ?? Data())
            }
        } else {
            coordinator.openComposer(withInitialText: recipe.command)
        }
    }

    func close() {
        panel?.close()
    }

    private func rebuildFiltered() {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            filteredRecipes = allRecipes
        } else {
            filteredRecipes = allRecipes.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(trimmed) ||
                recipe.command.localizedCaseInsensitiveContains(trimmed)
            }
        }
        if selectedIndex >= filteredRecipes.count {
            selectedIndex = max(0, filteredRecipes.count - 1)
        }
    }
}

@MainActor
private struct RecipePickerView: View {
    @Bindable var model: RecipePickerModel
    @FocusState private var searchFocused: Bool

    var body: some View {
        let c = HarnessChrome.current
        VStack(spacing: 0) {
            TextField(text: $model.query, prompt: Text("Search recipes...").foregroundStyle(Color(nsColor: c.textTertiary))) {
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
                        ForEach(Array(model.filteredRecipes.enumerated()), id: \.element.id) { index, recipe in
                            RecipeItemRow(
                                recipe: recipe,
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
                    if model.filteredRecipes.isEmpty {
                        Text("No matching recipes")
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

            RecipePickerFooter()
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
    }
}

@MainActor
private struct RecipeItemRow: View {
    let recipe: Recipe
    let query: String
    let isSelected: Bool

    var body: some View {
        let c = HarnessChrome.current
        HStack(spacing: HarnessDesign.Spacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: HarnessDesign.Radius.control, style: .continuous)
                    .fill(Color(nsColor: c.textPrimary.withAlphaComponent(c.isDark ? 0.06 : 0.07)))
                Image(systemName: recipe.runImmediately ? "play.fill" : "square.and.pencil")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(nsColor: c.textSecondary))
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(highlightedTitle(primary: c.textPrimary, accent: c.accent))
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(Color(nsColor: c.textPrimary))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(recipe.command)
                    .font(.system(size: 11.5, weight: .regular))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: HarnessDesign.Spacing.md)

            Text(recipe.runImmediately ? "Run" : "Composer")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color(nsColor: c.textTertiary))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(nsColor: c.textPrimary.withAlphaComponent(0.08)))
                )
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

    private func highlightedTitle(primary: NSColor, accent: NSColor) -> AttributedString {
        var result = AttributedString(recipe.name)
        guard !query.isEmpty else { return result }
        let lowerTitle = recipe.name.lowercased()
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
        let c = HarnessChrome.current
        HStack(spacing: HarnessDesign.Spacing.lg) {
            hint(keys: "↑↓", label: "Navigate")
            hint(keys: "↩", label: "Select")
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
private final class RecipeWindowDelegate: NSObject, NSWindowDelegate {
    weak var panel: NSPanel?
    func windowDidResignKey(_ notification: Notification) { panel?.close() }
    func windowWillClose(_ notification: Notification) {
        RecipePickerController.clearReferences()
    }
}
