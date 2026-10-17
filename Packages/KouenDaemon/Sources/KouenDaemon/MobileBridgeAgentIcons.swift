import Foundation
import KouenIPC

// Brand marks for the Companion page, built from the same `AgentIconArt` geometry and
// `AgentKind.dotHex` tint the Mac sidebar uses, so the phone and the app never drift apart.
// Agents without a mark get a two-letter monogram on the client.
extension MobileBridgeServer {
    static let agentIconCSS = """
      .ai{width:22px;height:22px;border-radius:7px;display:inline-grid;place-items:center;flex:none;vertical-align:-6px;margin-right:8px;background:color-mix(in srgb,var(--c) 18%,transparent);color:var(--c);font:700 10px var(--f-mono)}
      .ai svg{width:14px;height:14px}
      """

    /// `const AGENT_ICONS = {"<kind rawValue>": {"c": "#hex", "svg": "<svg…>"}, …};`
    static let agentIconsJS: String = {
        var map: [String: [String: String]] = [:]
        for kind in AgentKind.allCases {
            var entry = ["c": "#" + kind.dotHex]
            if let art = AgentIconArt.icons[kind.rawValue] {
                let rule = art.evenOdd ? #" fill-rule="evenodd""# : ""
                let paths = art.subpaths.map { #"<path d="\#($0)"/>"# }.joined()
                entry["svg"] = #"<svg viewBox="0 0 \#(Int(art.viewBox.width)) \#(Int(art.viewBox.height))" fill="currentColor"\#(rule)>\#(paths)</svg>"#
            }
            map[kind.rawValue] = entry
        }
        let data = (try? JSONSerialization.data(withJSONObject: map, options: [.sortedKeys])) ?? Data("{}".utf8)
        return "const AGENT_ICONS = " + String(decoding: data, as: UTF8.self) + ";"
    }()
}
