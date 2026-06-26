# PLAN — Settings SwiftUI Migration

**Date:** 2026-06-26 | **Mode:** SDLC Dev Only

---

## Delivery Order

| Phase | Task | Files | Status |
|---|---|---|---|
| **S0** | `SettingsModel` — @Observable wrapper | `SettingsModel.swift` (NEW) | ✅ |
| **S1** | Terminal page | `SettingsTerminalView.swift` (NEW) | ✅ |
| **S2** | Appearance page | `SettingsAppearanceView.swift` (NEW) | ⬜ |
| **S3** | Colors page + `SwatchWellView` bridge | `SettingsColorsView.swift`, `SwatchWellView.swift` (NEW) | ⬜ |
| **S4** | Keys page + `KeyRecorderRepresentable` bridge | `SettingsKeysView.swift` (NEW) | ⬜ |
| **S5** | Agents page | `SettingsAgentsView.swift` (NEW) | ⬜ |
| **S6** | Advanced page | `SettingsAdvancedView.swift` (NEW) | ⬜ |
| **S7** | Remote page (NSTableView → SwiftUI List) | `SettingsRemoteView.swift` (NEW) | ⬜ |
| **S8** | Root container + NSHostingController wiring | `SettingsRootView.swift`, `SettingsHostingController.swift` (NEW) | ⬜ |
| **S9** | Delete AppKit SettingsViewController + LiveApply | 10 files deleted | ⬜ |

---

## Phase S0 — SettingsModel

```swift
@Observable @MainActor
final class SettingsModel {
    private(set) var settings: HarnessSettings
    
    init() {
        self.settings = SessionCoordinator.shared.settings
        NotificationCenter.default.addObserver(
            self, selector: #selector(snapshotChanged),
            name: NotificationBus.shared.snapshotChanged, object: nil
        )
    }
    
    @objc private func snapshotChanged(_ note: Notification) {
        settings = SessionCoordinator.shared.settings
    }
    
    func apply(_ keyPath: WritableKeyPath<HarnessSettings, some Any>, _ value: some Any) {
        // write path — TBD per field (some use requestDaemon, some use updateSettings)
    }
}
```

**Key:** model reads pull from `SessionCoordinator.shared.settings`; writes dispatch back through daemon.

---

## Phase S1 — Terminal Page (start here)

Source: `SettingsViewController+Terminal.swift` (127 lines)

Controls to migrate:
- `copyOnSelectToggle` → `Toggle("Copy text to clipboard on selection", isOn: $model.settings.copyOnSelect)`
- `scrollbackField` → `TextField` bound to scrollback limit
- `cursorStyleSegment` → `Picker(.segmented)` for block/underline/beam
- `cursorBlinkToggle` → `Toggle`
- `pasteProtectionToggle` → `Toggle`
- `promptGutterToggle` → `Toggle`
- `liveResizeReflowToggle` → `Toggle`
- `keepSessionsToggle` → `Toggle`

**Write path:** each toggle `.onChange` → `SessionCoordinator.shared.requestDaemon(.updateSettings(...))`

---

## Phase S8 — Wiring (last step)

```swift
final class SettingsHostingController: NSHostingController<SettingsRootView> {
    init() {
        let model = SettingsModel()
        super.init(rootView: SettingsRootView(model: model))
    }
}
```

Replace all `SettingsViewController()` call sites with `SettingsHostingController()`.

---

## Success Criteria

- [ ] `swift build` passes after each phase
- [ ] All 7 pages visually match original
- [ ] Toggle/Slider changes apply live (no relaunch)
- [ ] Theme switch re-renders Settings window correctly (no manual re-skin needed)
- [ ] `SettingsViewController*.swift` + `+LiveApply.swift` deleted
- [ ] `HarnessControls.swift` primitives still compile (used elsewhere)
