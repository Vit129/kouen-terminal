import Foundation
import KouenIPC
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
#if canImport(CryptoKit)
import CryptoKit
#endif

/// Snapshot and extraction for append-only JSONL indexes. The cursor always ends at a newline,
/// so an incomplete final record remains available when the writer completes it.
struct AgentHistoryIncrementalFTS {
    struct Cursor: Sendable {
        let offset: Int
        let digest: String
    }
    struct Result: Sendable {
        let previous: Cursor?
        let cursor: Cursor
        let append: Bool
        let spool: AgentHistoryTranscriptSpool
        let hasText: Bool
        let files: Set<String>
        let tools: Set<String>
        let fileSize: Int
        let modified: Date
        let fileNumber: UInt64
        let deviceNumber: UInt64

        func matches(path: String) -> Bool {
            guard let attrs = try? FileManager.default.attributesOfItem(atPath: path),
                  let size = attrs[.size] as? NSNumber,
                  let time = attrs[.modificationDate] as? Date,
                  let inode = attrs[.systemFileNumber] as? NSNumber,
                  let device = attrs[.systemNumber] as? NSNumber else { return false }
            return size.intValue == fileSize && time == modified && inode.uint64Value == fileNumber && device.uint64Value == deviceNumber
        }
    }

    static func extract(url: URL, previous: Cursor?, provider: AgentKind) -> Result? {
        #if canImport(CryptoKit)
        do {
            let handle = try FileHandle(forReadingFrom: url)
            defer { try? handle.close() }
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            guard let sizeNumber = attrs[.size] as? NSNumber,
                  let modified = attrs[.modificationDate] as? Date,
                  let inode = attrs[.systemFileNumber] as? NSNumber,
                  let device = attrs[.systemNumber] as? NSNumber else { return nil }
            let size = sizeNumber.intValue
            var descriptorStat = stat()
            guard fstat(handle.fileDescriptor, &descriptorStat) == 0,
                  UInt64(descriptorStat.st_ino) == inode.uint64Value,
                  UInt64(descriptorStat.st_dev) == device.uint64Value else { return nil }
            var hash = SHA256()
            var remaining = max(0, min(previous?.offset ?? 0, size))
            while remaining > 0 {
                let data = try handle.read(upToCount: min(remaining, 64 * 1024)) ?? Data()
                guard !data.isEmpty else { return nil }
                hash.update(data: data)
                remaining -= data.count
            }
            let prefixHash = hash
            let prefixDigest = prefixHash.finalize().map { String(format: "%02x", $0) }.joined()
            var boundaryIsNewline = true
            if let previous, previous.offset > 0, previous.offset < size {
                try handle.seek(toOffset: UInt64(previous.offset - 1))
                boundaryIsNewline = try handle.read(upToCount: 1)?.first == 10
            }
            let canAppend = previous.map { $0.offset >= 0 && $0.offset <= size && $0.digest == prefixDigest && boundaryIsNewline } ?? false
            let start = canAppend ? previous!.offset : 0
            if !canAppend { hash = SHA256() }
            try handle.seek(toOffset: UInt64(start))
            let spool = try AgentHistoryTranscriptSpool()
            var hasText = false
            var files: Set<String> = []
            var tools: Set<String> = []
            func appendText(_ text: String) throws {
                if hasText { try spool.append("\n") }
                try spool.append(text)
                hasText = true
            }
            func process(_ line: Data) throws {
                if line.allSatisfy({ [UInt8(0x20), 0x09, 0x0D].contains($0) }) { return }
                guard let json = historyJSONObject(line) else { throw CocoaError(.fileReadCorruptFile) }
            switch provider {
            case .claudeCode:
                guard let message = json["message"] as? [String: Any] else { return }
                if let value = message["content"] as? String {
                    let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !clean.isEmpty { try appendText(clean) }
                } else if let items = message["content"] as? [[String: Any]] {
                    for item in items {
                        if item["type"] as? String == "text", let value = item["text"] as? String {
                            let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !clean.isEmpty { try appendText(clean) }
                        } else if item["type"] as? String == "tool_use" {
                            if let name = item["name"] as? String, !name.isEmpty { tools.insert(name) }
                            if let input = item["input"] as? [String: Any] {
                                for key in ["file_path", "path", "filePath", "TargetFile"] {
                                    if let value = input[key] as? String, !value.isEmpty { files.insert((value as NSString).lastPathComponent) }
                                }
                            }
                        }
                    }
                }
            case .antigravity:
                let type = json["type"] as? String ?? ""
                if (type == "USER_INPUT" || type == "PLANNER_RESPONSE"), var value = json["content"] as? String {
                    if let start = value.range(of: "<USER_REQUEST>"), let end = value.range(of: "</USER_REQUEST>") {
                        value = String(value[start.upperBound..<end.lowerBound])
                    }
                    let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !clean.isEmpty { try appendText(clean) }
                }
                for call in json["tool_calls"] as? [[String: Any]] ?? [] {
                    if let name = call["name"] as? String, !name.isEmpty { tools.insert(name) }
                    let params = (call["args"] as? [String: Any]) ?? (call["parameters"] as? [String: Any]) ?? [:]
                    for key in ["TargetFile", "AbsolutePath", "file_path", "path"] {
                        if let value = params[key] as? String, !value.isEmpty {
                            files.insert((value.trimmingCharacters(in: CharacterSet(charactersIn: "\"'\n\r\t ")) as NSString).lastPathComponent)
                        }
                    }
                }
            case .codex:
                let type = json["type"] as? String ?? ""
                let payload = json["payload"] as? [String: Any]
                let itemType = payload?["type"] as? String ?? type
                if itemType == "function_call" {
                    let name = (payload?["name"] as? String) ?? (json["name"] as? String) ?? ""
                    if !name.isEmpty { tools.insert(name) }
                    if let args = (payload?["arguments"] as? String) ?? (json["arguments"] as? String),
                       let bytes = args.data(using: .utf8), let object = historyJSONObject(bytes) {
                        for key in ["path", "file_path", "workdir"] {
                            if let value = object[key] as? String, !value.isEmpty { files.insert((value as NSString).lastPathComponent) }
                        }
                    }
                }
                if type == "message" || (type == "response_item" && itemType == "message") {
                    let role = ((payload?["role"] ?? json["role"]) as? String)?.lowercased() ?? ""
                    guard role == "user" || role == "assistant" else { return }
                    let content = payload?["content"] ?? json["content"]
                    let value: String
                    if let string = content as? String { value = string }
                    else if let items = content as? [[String: Any]] { value = items.compactMap { ($0["text"] ?? $0["input_text"]) as? String }.joined() }
                    else { return }
                    let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !clean.isEmpty && !(role == "user" && (AgentHistoryScanner.isCodexBoilerplatePrompt(clean) || clean.hasPrefix("<environment_context>"))) { try appendText(clean) }
                }
            default: return
            }
            }
            var pending = Data()
            var end = start
            var remainingBytes = size - start
            while remainingBytes > 0 {
                let chunk = try handle.read(upToCount: min(remainingBytes, 64 * 1024)) ?? Data()
                guard !chunk.isEmpty else { return nil }
                remainingBytes -= chunk.count
                var position = chunk.startIndex
                while position < chunk.endIndex {
                    let newline = chunk[position...].firstIndex(of: 10)
                    let stop = newline ?? chunk.endIndex
                    pending.append(chunk[position..<stop])
                    guard pending.count <= AgentHistoryScanner.maxJSONLRecordBytes else { return nil }
                    if newline != nil {
                        try process(pending)
                        hash.update(data: pending)
                        hash.update(data: Data([10]))
                        end += pending.count + 1
                        pending.removeAll(keepingCapacity: true)
                        position = stop + 1
                    } else { position = stop }
                }
            }
            // A complete JSON value at EOF is searchable immediately. If it later grows,
            // the boundary check above forces a full replacement because it had no newline.
            if !pending.isEmpty, historyJSONObject(pending) != nil {
                try process(pending)
                hash.update(data: pending)
                end += pending.count
            }
            let digest = hash.finalize().map { String(format: "%02x", $0) }.joined()
            let result = Result(previous: previous, cursor: Cursor(offset: end, digest: digest), append: canAppend,
                                spool: spool, hasText: hasText, files: files, tools: tools,
                                fileSize: size, modified: modified, fileNumber: inode.uint64Value, deviceNumber: device.uint64Value)
            guard fstat(handle.fileDescriptor, &descriptorStat) == 0,
                  UInt64(descriptorStat.st_ino) == inode.uint64Value,
                  UInt64(descriptorStat.st_dev) == device.uint64Value,
                  result.matches(path: url.path) else { return nil }
            return result
        } catch { return nil }
        #else
        return nil
        #endif
    }
}
