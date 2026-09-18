import Foundation
import Security

public enum IssueKeychainStore {
    private static let servicePrefix = "com.vit129.kouen.issues."
    private static let account = "default"

    public static func saveToken(_ token: String, for tracker: IssueTrackerType) -> Bool {
        guard let data = token.data(using: .utf8) else { return false }
        let service = servicePrefix + tracker.rawValue.lowercased().replacingOccurrences(of: " ", with: "-")

        // Try deleting existing first
        deleteToken(for: tracker)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    public static func loadToken(for tracker: IssueTrackerType) -> String? {
        let service = servicePrefix + tracker.rawValue.lowercased().replacingOccurrences(of: " ", with: "-")

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    public static func deleteToken(for tracker: IssueTrackerType) -> Bool {
        let service = servicePrefix + tracker.rawValue.lowercased().replacingOccurrences(of: " ", with: "-")

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
