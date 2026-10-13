import AppKit
import HarnessCopyMode
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
import Metal
import QuartzCore

extension HarnessTerminalSurfaceView {
    // MARK: - Input

    public override var acceptsFirstResponder: Bool { true }

    public override func becomeFirstResponder() -> Bool {
        focused = true
        cursorBlinkVisible = true
        focusStateChanged()
        return true
    }

    public override func resignFirstResponder() -> Bool {
        focused = false
        // A modifier released while we're unfocused never reaches `flagsChanged`, so drop the
        // press-tracking state to keep Kitty modifier-key press/release reporting in sync on return.
        pressedModifierKeyCodes.removeAll()
        focusStateChanged()
        return true
    }

    /// React to any change of the effective focus state (first responder × key window):
    /// repaint (hollow cursor) and report DECSET 1004 focus in/out to the program exactly
    /// once per transition. Programs that enabled it (vim, tmux, …) get `CSI I` on
    /// focus-in and `CSI O` on focus-out.
    func focusStateChanged() {
        let now = effectivelyFocused
        if lastReportedFocus != now {
            lastReportedFocus = now
            if now { cursorBlinkVisible = true; onBecameFocused?() }
            if inputModes().focusReporting {
                emit([0x1B, 0x5B, now ? 0x49 : 0x4F]) // ESC [ I / ESC [ O
            }
            // Blink timer lives only while focused (idle efficiency): start on focus-in,
            // stop (cursor solid) on focus-out — see `restartBlinkTimer`.
            restartBlinkTimer()
        }
        scheduleRender()
    }

    public override func keyDown(with event: NSEvent) {
        // Mouse-hide-while-typing: a typing keystroke hides the cursor until the mouse
        // next moves. Skip bare ⌘-shortcuts — those are app commands, not text input. AppKit
        // auto-restores the cursor on the next mouse move, so this is self-correcting.
        if mouseHideWhileTyping, !event.modifierFlags.contains(.command) {
            NSCursor.setHiddenUntilMouseMoves(true)
        }
        // Copy mode is modal: it consumes every key (motions, search entry, copy/cancel)
        // and nothing reaches the PTY. ⌘ shortcuts still fall through to the app.
        if copyMode != nil, !event.modifierFlags.contains(.command) {
            handleCopyModeKey(event)
            return
        }
        // IME composition owns non-Command keys. Command shortcuts stay with the keymap and the app.
        if !event.modifierFlags.contains(.command), hasMarkedText() {
            interpretKeyEvents([event])
            return
        }
        // Config-file keymap, including exclusive modes and Command chords it binds.
        // An unbound Command chord falls through. A swallowed key never reaches the PTY.
        if consumeScriptKey?(event) == true { return }
        // Let the app handle Command shortcuts (menus, palette, etc.).
        if event.modifierFlags.contains(.command) {
            // ⌘ + an editing key drives readline line-editing (⌘ is otherwise reserved for the
            // app), matching macOS terminal convention: ⌘⌫ = delete to line start (^U), ⌘← / ⌘→ =
            // line start / end (^A / ^E). Other ⌘ keys keep falling through to the app.
            if let special = Self.specialKey(for: event) {
                let lineEdit: [UInt8]?
                switch special {
                case .backspace: lineEdit = [0x15] // ^U
                case .left: lineEdit = [0x01]      // ^A
                case .right: lineEdit = [0x05]     // ^E
                default: lineEdit = nil
                }
                if let bytes = lineEdit {
                    wakeCursor()
                    snapToBottom()
                    clearSelection()
                    emit(bytes)
                    return
                }
            }
            // ⌘C / ⌘X copy the active selection (a read-only terminal can't truly cut, so ⌘X
            // behaves as copy), ⌘V pastes. These also work via the Edit menu's key equivalents
            // (which fire copy:/cut:/paste: on the first responder before keyDown); handling them
            // here keeps copy/paste working even without the menu.
            switch event.charactersIgnoringModifiers?.lowercased() {
            case "c", "x":
                // Copy/cut the selection; with no selection, let the app handle ⌘C/⌘X.
                // Anchor check, not the region getter — the getter can `emulatorSync`.
                if selectionAnchor != nil { copySelection(); return }
                super.keyDown(with: event)
                return
            case "v":
                paste(nil)
                return
            default:
                super.keyDown(with: event)
                return
            }
        }
        wakeCursor()
        // Shift+PageUp/PageDown page through scrollback instead of going to the app.
        if event.modifierFlags.contains(.shift), let sk = Self.specialKey(for: event),
           sk == .pageUp || sk == .pageDown {
            scrollBy(lines: sk == .pageUp ? rows : -rows)
            return
        }
        // Any other key returns to the live bottom.
        snapToBottom()
        clearSelection()

        var mods: KeyModifiers = []
        let flags = event.modifierFlags
        if flags.contains(.shift) { mods.insert(.shift) }
        if flags.contains(.option) { mods.insert(.option) }
        if flags.contains(.control) { mods.insert(.control) }

        let modes = inputModes()
        // A held key auto-repeats; under Kitty "report event types" each repeat is tagged `:2`.
        let eventType: KeyEventType = event.isARepeat ? .repeat : .press

        if let special = Self.specialKey(for: event) {
            FrameSignposter.shared.noteKeystroke(source: ObjectIdentifier(self), outputGeneration: outputGeneration)
            emit(inputEncoder.encode(special, modifiers: mods, event: eventType, modes: modes))
            return
        }

        // A composing Option is not a modifier for the text path: drop it so the input context
        // can deliver the layout's character (option+L → @ on German/Nordic layouts — #155;
        // dead keys included via the marked-text path), and so Kitty modes report the key
        // without a stale alt bit (kitty itself treats a composing Option the same way).
        // Special keys (above) keep Meta semantics in every mode — opt+arrow word motion is
        // macOS terminal convention — and Ctrl+Option combos never compose.
        mods = Self.effectiveTextModifiers(mods, mode: optionAsMeta, eventFlags: flags)

        // Control/Option — or Kitty "report all keys as escape codes" — take the encoder path:
        // Meta prefix + Control collapsing in legacy mode, full CSI-u (with alternate-key and
        // associated-text fields) under Kitty. Plain keys otherwise go through the input context so
        // dead keys and IME composition work — committed text arrives via `insertText`.
        let reportAllKeys = modes.kittyKeyboardFlags & 0b1000 != 0
        if mods.contains(.control) || mods.contains(.option) || reportAllKeys {
            let rawUnshifted = event.charactersIgnoringModifiers ?? ""
            let unshifted = ControlKeyNormalizer.normalizedKey(
                from: rawUnshifted,
                controlPressed: mods.contains(.control)
            )
            FrameSignposter.shared.noteKeystroke(source: ObjectIdentifier(self), outputGeneration: outputGeneration)
            emit(inputEncoder.encode(
                text: unshifted,
                shifted: event.characters,
                modifiers: mods,
                event: eventType,
                associatedText: event.characters,
                modes: modes
            ))
            return
        }
        interpretKeyEvents([event])
    }

    public override func keyUp(with event: NSEvent) {
        // Terminals never report key release — except under the Kitty keyboard protocol's "report
        // event types" flag (0b10), which a program must explicitly enable. No-op otherwise.
        let modes = inputModes()
        guard modes.kittyKeyboardFlags & 0b10 != 0,
              copyMode == nil, !hasMarkedText(),
              !event.modifierFlags.contains(.command) else { return }

        var mods: KeyModifiers = []
        let flags = event.modifierFlags
        if flags.contains(.shift) { mods.insert(.shift) }
        if flags.contains(.option) { mods.insert(.option) }
        if flags.contains(.control) { mods.insert(.control) }

        if let special = Self.specialKey(for: event) {
            emit(inputEncoder.encode(special, modifiers: mods, event: .release, modes: modes))
            return
        }
        // Keep release events symmetric with the press: a composing Option was stripped from
        // the press encoding, so strip it here too.
        mods = Self.effectiveTextModifiers(mods, mode: optionAsMeta, eventFlags: flags)
        // Plain (text-producing) keys only have a release event when they're reported as escape
        // codes in the first place: Ctrl/Option-modified, or under "report all keys" (0b1000).
        let modified = mods.contains(.control) || mods.contains(.option)
        guard modified || modes.kittyKeyboardFlags & 0b1000 != 0 else { return }
        let unshifted = event.charactersIgnoringModifiers ?? ""
        guard !unshifted.isEmpty else { return }
        emit(inputEncoder.encode(
            text: unshifted, shifted: event.characters, modifiers: mods,
            event: .release, associatedText: nil, modes: modes
        ))
    }

    func emit(_ bytes: [UInt8]) {
        guard !bytes.isEmpty else { return }
        emulatorState.async { emulator in emulator.noteUserKey() }
        onInput?(Data(bytes))
    }

    /// Strip a composing Option from the text-path modifier set: when the held Option side(s)
    /// compose characters (per `mode`), the key is plain text — not Meta, no Kitty alt bit.
    /// Control is never stripped (Ctrl+Option combos don't compose). `internal` so the
    /// modifier seam can be unit-tested.
    static func effectiveTextModifiers(
        _ mods: KeyModifiers, mode: OptionAsMetaMode, eventFlags: NSEvent.ModifierFlags
    ) -> KeyModifiers {
        var result = mods
        if result.contains(.option), !result.contains(.control),
           !optionActsAsMeta(mode, eventFlags: eventFlags) {
            result.remove(.option)
        }
        return result
    }

    /// Whether the held Option key(s) act as Meta for text keys. The side-split modes read the
    /// event's device-dependent modifier bits (NX_DEVICELALTKEYMASK / NX_DEVICERALTKEYMASK);
    /// an event without side bits (synthesized input, some assistive hardware) honors the
    /// user's Meta intent rather than silently composing. With both Options held, Meta wins
    /// when the meta-designated side is down.
    static func optionActsAsMeta(_ mode: OptionAsMetaMode, eventFlags: NSEvent.ModifierFlags) -> Bool {
        switch mode {
        case .meta: return true
        case .composed: return false
        case .leftMetaOnly, .rightMetaOnly:
            let left = eventFlags.rawValue & 0x0000_0020 != 0
            let right = eventFlags.rawValue & 0x0000_0040 != 0
            guard left || right else { return true }
            return mode == .leftMetaOnly ? left : right
        }
    }

    /// Map an NSEvent to a SpecialKey using the AppKit function-key unicode values.
    /// `internal` (not `private`) so the NSEvent→SpecialKey seam can be unit-tested.
    static func specialKey(for event: NSEvent) -> SpecialKey? {
        // Numeric-keypad keys (F30, DECKPAM): the character alone can't distinguish keypad
        // '7' from top-row '7', so key off `.numericPad` + the hardware keycode. Arrow keys
        // also carry `.numericPad`; the keycode table only claims true keypad codes and
        // everything else falls through to the character switch below. In numeric mode the
        // encoder emits the same plain byte the text path used to, so nothing changes until
        // a program enables application keypad (`ESC =`). Only the UNMODIFIED key is claimed
        // (Shift/NumLock aside): `keypadLegacy` ignores modifiers, so claiming Ctrl/Option
        // combos here would drop the control collapse / ESC meta prefix the text path applies
        // — modified keypad keys keep their pre-keypad byte output in both keypad modes.
        if event.modifierFlags.contains(.numericPad),
           event.modifierFlags.isDisjoint(with: [.control, .option, .command]),
           let keypad = keypadKey(forKeyCode: event.keyCode) {
            return keypad
        }
        guard let scalar = event.charactersIgnoringModifiers?.unicodeScalars.first else { return nil }
        switch Int(scalar.value) {
        case NSUpArrowFunctionKey: return .up
        case NSDownArrowFunctionKey: return .down
        case NSLeftArrowFunctionKey: return .left
        case NSRightArrowFunctionKey: return .right
        case NSHomeFunctionKey: return .home
        case NSEndFunctionKey: return .end
        case NSPageUpFunctionKey: return .pageUp
        case NSPageDownFunctionKey: return .pageDown
        case NSInsertFunctionKey: return .insert
        case NSDeleteFunctionKey: return .deleteForward
        case NSF1FunctionKey: return .f1
        case NSF2FunctionKey: return .f2
        case NSF3FunctionKey: return .f3
        case NSF4FunctionKey: return .f4
        case NSF5FunctionKey: return .f5
        case NSF6FunctionKey: return .f6
        case NSF7FunctionKey: return .f7
        case NSF8FunctionKey: return .f8
        case NSF9FunctionKey: return .f9
        case NSF10FunctionKey: return .f10
        case NSF11FunctionKey: return .f11
        case NSF12FunctionKey: return .f12
        case NSF13FunctionKey: return .f13
        case NSF14FunctionKey: return .f14
        case NSF15FunctionKey: return .f15
        case NSF16FunctionKey: return .f16
        case NSF17FunctionKey: return .f17
        case NSF18FunctionKey: return .f18
        case NSF19FunctionKey: return .f19
        case NSF20FunctionKey: return .f20
        case NSMenuFunctionKey: return .menu
        case NSPauseFunctionKey: return .pause
        case NSPrintScreenFunctionKey: return .printScreen
        case NSScrollLockFunctionKey: return .scrollLock
        case 0x0D, 0x03: return .enter        // return, enter
        case 0x7F: return .backspace          // delete (backspace) key
        case 0x1B: return .escape
        case 0x09, 0x19: return .tab  // 0x19 = NSBackTabCharacter (Shift-Tab); encoder emits ESC[Z
        default: return nil
        }
    }

    /// ANSI keypad hardware keycodes (kVK_ANSI_Keypad*) → encoder keys.
    private static func keypadKey(forKeyCode keyCode: UInt16) -> SpecialKey? {
        switch keyCode {
        case 82: return .keypad0
        case 83: return .keypad1
        case 84: return .keypad2
        case 85: return .keypad3
        case 86: return .keypad4
        case 87: return .keypad5
        case 88: return .keypad6
        case 89: return .keypad7
        case 91: return .keypad8
        case 92: return .keypad9
        case 65: return .keypadDecimal
        case 75: return .keypadDivide
        case 67: return .keypadMultiply
        case 78: return .keypadMinus
        case 69: return .keypadPlus
        case 76: return .keypadEnter
        case 81: return .keypadEquals
        default: return nil
        }
    }
}
