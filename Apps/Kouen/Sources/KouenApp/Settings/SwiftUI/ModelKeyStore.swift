import Foundation
import Security
import KouenCore

/// Keychain-backed API key storage for `ModelProvider`s and user-added custom endpoints —
/// same `SecItemAdd`/`SecItemCopyMatching` pattern as `IssueKeychainStore`
/// (`Apps/Kouen/Sources/KouenApp/UI/Issues/IssueKeychainStore.swift`), generalized from one
/// tracker enum to one model-provider enum plus arbitrary custom endpoint ids.
public enum ModelKeyStore {
    private static let servicePrefix = "com.vit129.kouen.models."
    private static let account = "default"
    private static let customEndpointsFile = "model-endpoints.json"

    // MARK: - Provider keys

    @discardableResult
    public static func saveKey(_ key: String, for provider: ModelProvider) -> Bool {
        saveKey(key, service: servicePrefix + provider.rawValue.lowercased())
    }

    public static func loadKey(for provider: ModelProvider) -> String? {
        loadKey(service: servicePrefix + provider.rawValue.lowercased())
    }

    @discardableResult
    public static func deleteKey(for provider: ModelProvider) -> Bool {
        deleteKey(service: servicePrefix + provider.rawValue.lowercased())
    }

    // MARK: - Custom endpoint keys

    @discardableResult
    public static func saveKey(_ key: String, forCustomEndpointID id: String) -> Bool {
        saveKey(key, service: servicePrefix + "custom." + id)
    }

    public static func loadKey(forCustomEndpointID id: String) -> String? {
        loadKey(service: servicePrefix + "custom." + id)
    }

    @discardableResult
    public static func deleteKey(forCustomEndpointID id: String) -> Bool {
        deleteKey(service: servicePrefix + "custom." + id)
    }

    // MARK: - Custom endpoint metadata (non-secret; JSON file, same convention as agents.json)

    public static func loadCustomEndpoints() -> [CustomModelEndpoint] {
        let url = KouenPaths.applicationSupport.appendingPathComponent(customEndpointsFile)
        guard let data = try? Data(contentsOf: url),
              let endpoints = try? JSONDecoder().decode([CustomModelEndpoint].self, from: data)
        else { return [] }
        return endpoints
    }

    public static func saveCustomEndpoints(_ endpoints: [CustomModelEndpoint]) {
        let url = KouenPaths.applicationSupport.appendingPathComponent(customEndpointsFile)
        guard let data = try? JSONEncoder().encode(endpoints) else { return }
        try? data.write(to: url, options: .atomic)
    }

    public static func addCustomEndpoint(_ endpoint: CustomModelEndpoint, key: String) {
        var endpoints = loadCustomEndpoints()
        endpoints.append(endpoint)
        saveCustomEndpoints(endpoints)
        saveKey(key, forCustomEndpointID: endpoint.id)
    }

    public static func removeCustomEndpoint(id: String) {
        saveCustomEndpoints(loadCustomEndpoints().filter { $0.id != id })
        deleteKey(forCustomEndpointID: id)
    }

    // MARK: - One-time migration off the old plaintext field

    /// `KouenSettings.claudeAPIKey` used to be the only way to configure a model key, stored in
    /// plain text in settings.json. Called once at settings-load time (`SettingsModel.init`);
    /// idempotent — a second call finds the field already cleared and does nothing.
    public static func migrateLegacyClaudeKeyIfNeeded(legacyKey: String?, clearLegacy: (String?) -> Void) {
        guard let legacyKey, !legacyKey.isEmpty else { return }
        if saveKey(legacyKey, for: .anthropic) {
            clearLegacy(nil)
        }
    }

    // MARK: - Shared Keychain primitives

    private static func saveKey(_ key: String, service: String) -> Bool {
        guard let data = key.data(using: .utf8) else { return false }
        deleteKey(service: service)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    private static func loadKey(service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    private static func deleteKey(service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
