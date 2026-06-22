import Foundation
import HarnessSettings

// MARK: - Persistence (needs HarnessPaths — lives in HarnessCore, not HarnessSettings package)

extension HarnessSettings {
    public static func load() -> HarnessSettings {
        let imported = TerminalConfigImporter.load()
        let url = HarnessPaths.settingsURL
        if FileManager.default.fileExists(atPath: url.path), let data = try? Data(contentsOf: url) {
            guard var settings = try? JSONDecoder().decode(HarnessSettings.self, from: data) else {
                HarnessPaths.backupCorruptFile(at: url, label: "Harness")
                return HarnessSettings.makeDefaults(imported: imported)
            }
            let hasStoredColorChoice = settingsDataContainsColorChoice(data)
            var didMutate = false
            if let imported, settings.importedConfigSignature != imported.signature {
                if settings.hasUserVisualCustomizations {
                    settings.importedConfigSignature = imported.signature
                } else {
                    settings.applyImportedDefaults(imported)
                }
                didMutate = true
            }
            let clampedOpacity = HarnessSettings.clampedOpacity(settings.backgroundOpacity)
            if clampedOpacity != settings.backgroundOpacity { settings.backgroundOpacity = clampedOpacity; didMutate = true }
            let clampedBlur = HarnessSettings.clampedBlur(settings.backgroundBlur)
            if clampedBlur != settings.backgroundBlur { settings.backgroundBlur = clampedBlur; didMutate = true }
            let clampedFontSize = HarnessSettings.clampedFontSize(settings.fontSize)
            if clampedFontSize != settings.fontSize { settings.fontSize = clampedFontSize; didMutate = true }
            let clampedPaddingX = HarnessSettings.clampedPadding(settings.windowPaddingX)
            if clampedPaddingX != settings.windowPaddingX { settings.windowPaddingX = clampedPaddingX; didMutate = true }
            let clampedPaddingY = HarnessSettings.clampedPadding(settings.windowPaddingY)
            if clampedPaddingY != settings.windowPaddingY { settings.windowPaddingY = clampedPaddingY; didMutate = true }
            let migrationKey = "HarnessColorFidelityMigrationV1"
            if !UserDefaults.standard.bool(forKey: migrationKey) {
                UserDefaults.standard.set(true, forKey: migrationKey)
                if !hasStoredColorChoice, settings.colorRendering != .accurate {
                    settings.colorRendering = .accurate
                    didMutate = true
                }
            }
            if didMutate {
                do { try settings.save() }
                catch { fputs("Harness: failed to persist migrated settings.json — \(error)\n", harnessStderr) }
            }
            return settings
        }
        let seeded = HarnessSettings.makeDefaults(imported: imported)
        do { try seeded.save() }
        catch { fputs("Harness: failed to seed settings.json — \(error)\n", harnessStderr) }
        return seeded
    }

    public func save() throws {
        try HarnessPaths.ensureDirectories()
        let data = try JSONEncoder().encode(self)
        try data.write(to: HarnessPaths.settingsURL, options: .atomic)
    }

    // Uses raw key strings to avoid exposing CodingKeys from HarnessSettings package.
    private static func settingsDataContainsColorChoice(_ data: Data) -> Bool {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return false
        }
        return object["vividColors"] != nil || object["colorRendering"] != nil
    }
}
