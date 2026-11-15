#if canImport(Network)
import Foundation
import Network

/// Validate browser trust boundaries independently of credentials and routing.
enum HTTPRequestPolicy {
    static func permits(headers: [String: String], bindHost: String, port: UInt16) -> Bool {
        guard let authority = headers["host"]?.lowercased(),
              let url = URLComponents(string: "http://" + authority),
              let requestHost = url.host?.lowercased(), url.user == nil, url.password == nil,
              url.path.isEmpty, url.query == nil, url.fragment == nil,
              (url.port ?? 80) == Int(port) else { return false }

        let loopback = ["localhost", "127.0.0.1", "[::1]", "::1"]
        let bind = bindHost.lowercased()
        if loopback.contains(bind) {
            guard loopback.contains(requestHost) else { return false }
        } else if bind == "0.0.0.0" || bind == "::" {
            // Wildcard binds are explicit remote opt-ins. Never trust arbitrary DNS names.
            let literal = requestHost.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            guard loopback.contains(requestHost) || IPv4Address(literal) != nil || IPv6Address(literal) != nil else { return false }
        } else {
            guard requestHost.trimmingCharacters(in: CharacterSet(charactersIn: "[]")) == bind.trimmingCharacters(in: CharacterSet(charactersIn: "[]")) else { return false }
        }

        if let origin = headers["origin"] {
            guard let url = URLComponents(string: origin),
                  let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme),
                  let host = url.host?.lowercased(), loopback.contains(host),
                  url.user == nil, url.password == nil, url.path.isEmpty,
                  url.query == nil, url.fragment == nil,
                  url.port.map({ (1...65535).contains($0) }) ?? true else { return false }
        }
        return true
    }
}
#endif
