import Foundation

/// Handles automated generation and synchronization of AI-SDLC Markdown files
/// (`agent-memory/plans/<slug>/<slug>-architecture.md` and `ai-sdlc-task-progress.md`)
/// when features and gates are updated.
public enum KouenFeatureMarkdownSync {

    public static func planDirectoryURL(for slug: String, repoPath: String) -> URL {
        URL(fileURLWithPath: repoPath, isDirectory: true)
            .appendingPathComponent("agent-memory", isDirectory: true)
            .appendingPathComponent("plans", isDirectory: true)
            .appendingPathComponent(slug, isDirectory: true)
    }

    public static func architectureFileURL(for slug: String, repoPath: String) -> URL {
        planDirectoryURL(for: slug, repoPath: repoPath)
            .appendingPathComponent("\(slug)-architecture.md")
    }

    public static func progressFileURL(for slug: String, repoPath: String) -> URL {
        planDirectoryURL(for: slug, repoPath: repoPath)
            .appendingPathComponent("ai-sdlc-task-progress.md")
    }

    /// Automatically generates directory and template files if they don't already exist.
    @discardableResult
    public static func ensurePlanFilesExist(for feature: KouenFeature) -> Bool {
        let fm = FileManager.default
        let planDir = planDirectoryURL(for: feature.slug, repoPath: feature.repoPath)

        do {
            try fm.createDirectory(at: planDir, withIntermediateDirectories: true)

            // 1. Ensure <slug>-architecture.md exists
            let archFile = architectureFileURL(for: feature.slug, repoPath: feature.repoPath)
            if !fm.fileExists(atPath: archFile.path) {
                let archTemplate = """
                # Architecture Design — \(feature.slug)
                Last updated: \(ISO8601DateFormatter().string(from: Date()))
                Status: In Progress (\(feature.phase.title))

                ## 1. Context & Scope
                - System: Kouen
                - Feature: \(feature.slug)
                - Target Branch: \(feature.branch ?? "-") (base: \(feature.baseBranch ?? "main"))

                ## 2. Core Decisions & Philosophy
                - **CLI-First / Terminal Ergonomics**: No unnecessary IDE bloat or Electron overhead.
                - **Strict Concurrency**: Swift 6 strict concurrency compliance.
                - **Deterministic Persistence**: Daemon-owned state and atomic writes.

                ## 3. System Architecture & Seams
                - Core Stores & Models
                - IPC Protocol & Wire Shapes
                - CLI & UI Integration

                ## 4. Worktree Lifecycle & Verification
                - Worktree 1:1 binding: \(feature.worktreePath ?? ".kouen-worktrees/\(feature.slug)")
                - Merged-sweep with dirty-guard
                """
                try archTemplate.write(to: archFile, atomically: true, encoding: .utf8)
            }

            // 2. Ensure ai-sdlc-task-progress.md exists
            let progressFile = progressFileURL(for: feature.slug, repoPath: feature.repoPath)
            if !fm.fileExists(atPath: progressFile.path) {
                let progressTemplate = """
                # AI-SDLC Task Progress — \(feature.slug)
                Last updated: \(ISO8601DateFormatter().string(from: Date()))
                Status: In Progress (\(feature.phase.title))

                ## Context
                - Feature: \(feature.slug)
                - Repo: \(feature.repoPath)
                - Branch: \(feature.branch ?? "-") (base: \(feature.baseBranch ?? "main"))

                ## SDLC Workflow Gates
                - [ ] Gate 1 (Architect design) — approver: pending
                - [ ] Gate 2 (Scenario list) — approver: pending
                - [ ] Gate 3 (Seam agreement) — approver: pending

                ## Artifacts
                - Architecture: agent-memory/plans/\(feature.slug)/\(feature.slug)-architecture.md

                ## Tasks
                - [ ] [Phase 0] Setup & Foundational architecture
                """
                try progressTemplate.write(to: progressFile, atomically: true, encoding: .utf8)
            }

            return true
        } catch {
            return false
        }
    }

    /// Automatically updates the gate approval checkbox in `ai-sdlc-task-progress.md`.
    @discardableResult
    public static func syncGateApproval(
        slug: String,
        repoPath: String,
        gate: Int,
        approver: String,
        notes: String? = nil
    ) -> Bool {
        let progressFile = progressFileURL(for: slug, repoPath: repoPath)
        guard let content = try? String(contentsOf: progressFile, encoding: .utf8) else {
            return false
        }

        let dateStr = ISO8601DateFormatter().string(from: Date())
        var noteSuffix = ""
        if let notes, !notes.isEmpty {
            noteSuffix = ", notes: \(notes)"
        }

        let scope: String
        switch gate {
        case 1: scope = "Architect design"
        case 2: scope = "Scenario list"
        case 3: scope = "Seam agreement"
        default: scope = "Gate \(gate)"
        }
        let newLine = "- [x] Gate \(gate) (\(scope)) — approver: \(approver), approved: \(dateStr)\(noteSuffix)"

        let lines = content.components(separatedBy: "\n")
        let matchIndices = lines.indices.filter { idx in
            lines[idx].contains("Gate \(gate)") && (lines[idx].contains("- [ ]") || lines[idx].contains("- [x]"))
        }

        var updatedLines = lines
        switch matchIndices.count {
        case 1:
            // Exactly one gate-N checkbox line — unambiguous, safe to update in place.
            updatedLines[matchIndices[0]] = newLine
        case 0:
            // No existing gate line — add it under ## SDLC Workflow Gates.
            if let idx = updatedLines.firstIndex(where: { $0.contains("## SDLC Workflow Gates") }) {
                updatedLines.insert(newLine, at: idx + 1)
            }
        default:
            // More than one line already mentions "Gate N" (e.g. separate dated scope-extension
            // approvals for the same gate number) — overwriting any single one would silently
            // discard real approval history (their own "scope: ..." text, which this function
            // never carries forward). Append this approval as a new dated entry right after the
            // last one instead of guessing which existing line to destroy.
            updatedLines.insert(newLine, at: matchIndices[matchIndices.count - 1] + 1)
        }

        let newContent = updatedLines.joined(separator: "\n")
        do {
            try newContent.write(to: progressFile, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }

    /// Automatically updates the phase header in `ai-sdlc-task-progress.md`.
    @discardableResult
    public static func syncPhase(slug: String, repoPath: String, phase: FeaturePhase) -> Bool {
        let progressFile = progressFileURL(for: slug, repoPath: repoPath)
        guard let content = try? String(contentsOf: progressFile, encoding: .utf8) else {
            return false
        }

        let lines = content.components(separatedBy: "\n")
        var updatedLines: [String] = []

        for line in lines {
            if line.hasPrefix("Status:") {
                updatedLines.append("Status: \(phase.title)")
            } else if line.hasPrefix("Last updated:") {
                updatedLines.append("Last updated: \(ISO8601DateFormatter().string(from: Date()))")
            } else {
                updatedLines.append(line)
            }
        }

        let newContent = updatedLines.joined(separator: "\n")
        do {
            try newContent.write(to: progressFile, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
}
