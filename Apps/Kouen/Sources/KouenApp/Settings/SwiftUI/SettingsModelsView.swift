import SwiftUI
import KouenCore

/// Set by the Phase 6.3 cross-link (an "Add API Key" button on an Agents-tab row) just before
/// opening the Models settings page, then consumed once so it doesn't stick across later,
/// unrelated visits to the page.
@MainActor
enum SettingsModelsFocus {
    private static var pending: ModelProvider?

    static func request(_ provider: ModelProvider) {
        pending = provider
    }

    static func consume() -> ModelProvider? {
        defer { pending = nil }
        return pending
    }
}

/// "Manage Models" — Phase 6.2 of the P45 plan. Generalizes the old single, plaintext
/// `KouenSettings.claudeAPIKey` field into a Keychain-backed key per `ModelProvider`, plus
/// arbitrary user-added custom endpoints. Feeds Kouen's own built-in AI features (chat sidebar,
/// inline completion) — never touches how a third-party agent CLI authenticates itself.
struct SettingsModelsView: View {
    /// Pre-selects a row when opened from the Phase 6.3 cross-link on an Agents-tab row.
    var focusedProvider: ModelProvider?

    @State private var keysByProvider: [ModelProvider: String] = [:]
    @State private var customEndpoints: [CustomModelEndpoint] = []
    @State private var newEndpointName = ""
    @State private var newEndpointURL = ""
    @State private var newEndpointKey = ""

    var body: some View {
        Form {
            Section("Providers") {
                ForEach(ModelProvider.allCases) { provider in
                    ProviderKeyRow(
                        provider: provider,
                        key: SwiftUI.Binding(
                            get: { keysByProvider[provider] ?? "" },
                            set: { keysByProvider[provider] = $0 }
                        ),
                        isFocused: provider == focusedProvider,
                        onSave: { save(provider: provider) },
                        onClear: { clear(provider: provider) }
                    )
                }
            }

            Section("Custom Endpoints") {
                ForEach(customEndpoints) { endpoint in
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(endpoint.name).font(.system(size: 13, weight: .medium))
                            Text(endpoint.baseURL)
                                .font(.system(size: 10.5, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Remove", role: .destructive) {
                            ModelKeyStore.removeCustomEndpoint(id: endpoint.id)
                            customEndpoints = ModelKeyStore.loadCustomEndpoints()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    TextField("Name", text: $newEndpointName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Base URL (e.g. https://api.example.com/v1)", text: $newEndpointURL)
                        .textFieldStyle(.roundedBorder)
                    SecureField("API Key", text: $newEndpointKey)
                        .textFieldStyle(.roundedBorder)
                    Button("Add Custom Endpoint") {
                        addCustomEndpoint()
                    }
                    .buttonStyle(.bordered)
                    // Base URL IS required, unlike Name/Key alone — it's the actual destination
                    // requests get sent to, the entire reason a "custom" entry exists (an
                    // unlisted/self-hosted provider the app has no built-in URL for). A saved
                    // name+key with no URL has nowhere to route a request.
                    .disabled(newEndpointName.isEmpty || newEndpointURL.isEmpty || newEndpointKey.isEmpty)
                }
                .padding(.top, 4)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Models")
        .task { loadAll() }
    }

    private func loadAll() {
        for provider in ModelProvider.allCases {
            keysByProvider[provider] = ModelKeyStore.loadKey(for: provider) ?? ""
        }
        customEndpoints = ModelKeyStore.loadCustomEndpoints()
    }

    private func save(provider: ModelProvider) {
        let key = keysByProvider[provider] ?? ""
        if key.isEmpty {
            ModelKeyStore.deleteKey(for: provider)
        } else {
            ModelKeyStore.saveKey(key, for: provider)
        }
    }

    private func clear(provider: ModelProvider) {
        keysByProvider[provider] = ""
        ModelKeyStore.deleteKey(for: provider)
    }

    private func addCustomEndpoint() {
        let endpoint = CustomModelEndpoint(name: newEndpointName, baseURL: newEndpointURL)
        ModelKeyStore.addCustomEndpoint(endpoint, key: newEndpointKey)
        customEndpoints = ModelKeyStore.loadCustomEndpoints()
        newEndpointName = ""
        newEndpointURL = ""
        newEndpointKey = ""
    }
}

private struct ProviderKeyRow: View {
    let provider: ModelProvider
    @SwiftUI.Binding var key: String
    let isFocused: Bool
    let onSave: () -> Void
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            if let kind = provider.agentKindForLogo {
                AgentBadgeView(kind: kind, iconSize: 18, fontSize: 13, showName: false)
                    .frame(width: 18, height: 18)
                Text(kind.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 100, alignment: .leading)
            } else {
                Image(systemName: provider.symbolName)
                    .frame(width: 18, height: 18)
                Text(provider.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .frame(width: 100, alignment: .leading)
            }
            SecureField("API key", text: $key)
                .textFieldStyle(.roundedBorder)
            Button("Save") { onSave() }
                .buttonStyle(.bordered)
                .disabled(key.isEmpty)
            if !key.isEmpty {
                Button("Clear", role: .destructive) { onClear() }
                    .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, isFocused ? 4 : 0)
        .background(isFocused ? Color.accentColor.opacity(0.08) : Color.clear)
    }
}
