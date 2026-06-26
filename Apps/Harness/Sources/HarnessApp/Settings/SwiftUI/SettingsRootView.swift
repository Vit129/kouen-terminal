import SwiftUI
import HarnessCore
import HarnessSettings

struct SettingsRootView: View {
    enum Page: Int, CaseIterable {
        case appearance = 0, colors, terminal, keys, agents, advanced, remote

        var title: String {
            switch self {
            case .appearance: return "Appearance"
            case .colors: return "Colors"
            case .terminal: return "Terminal"
            case .keys: return "Keys"
            case .agents: return "Agents"
            case .advanced: return "Advanced"
            case .remote: return "Remote"
            }
        }

        var symbol: String {
            switch self {
            case .appearance: return "paintbrush"
            case .colors: return "paintpalette"
            case .terminal: return "terminal"
            case .keys: return "keyboard"
            case .agents: return "sparkles"
            case .advanced: return "slider.horizontal.3"
            case .remote: return "network"
            }
        }

        init?(rawIndex: Int) {
            self.init(rawValue: rawIndex)
        }
    }

    var model: SettingsModel
    @State private var selection: Page

    init(model: SettingsModel, initialPage: Page = .appearance) {
        self.model = model
        self._selection = State(initialValue: initialPage)
    }

    var body: some View {
        NavigationSplitView {
            List(Page.allCases, id: \.self, selection: $selection) { page in
                Label(page.title, systemImage: page.symbol)
                    .tag(page)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 260)
            .navigationTitle("Settings")
        } detail: {
            NavigationStack {
                detailView
            }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .appearance: SettingsAppearanceView(model: model)
        case .colors:     SettingsColorsView(model: model)
        case .terminal:   SettingsTerminalView(model: model)
        case .keys:       SettingsKeysView(model: model)
        case .agents:     SettingsAgentsView(model: model)
        case .advanced:   SettingsAdvancedView(model: model)
        case .remote:     SettingsRemoteView()
        }
    }
}
