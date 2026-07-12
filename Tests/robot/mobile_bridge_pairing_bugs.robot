*** Settings ***
Documentation    Regression guards for the P37 mobile-bridge pairing bugs found in real-device
...              testing (iPhone over Tailscale). All are STRUCTURAL invariants that, if
...              regressed, silently reintroduce a bug WITHOUT failing `swift build` — the
...              behavioral coverage lives in Tests/KouenDaemonTests/MobileBridgePairingTests.swift
...              (PairingBox.check grace logic) and the P37 scripted-client live check (WS wire).
...
...              Bug 1 (root cause, proven by controlled live experiment): the daemon rotated the
...                    6-digit token every window and accepted ONLY the single current token, so a
...                    phone holding the token embedded in its page URL at load time — after
...                    Tailscale latency + camera->browser handoff + a manual Connect tap — always
...                    hit "invalid or expired pairing token". Fix: PairingBox keeps the
...                    just-rotated-out token redeemable for one grace window (current OR previous).
...              Bug 2: an abrupt connection.cancel() right after the server's error text tore the
...                    socket down without a WS close handshake; browsers read that as an ABNORMAL
...                    close and fired ws.onerror, clobbering the specific server error with the
...                    generic "WebSocket error" banner. Fix: rejectAndClose() sends a graceful
...                    close frame (opcode 0x8) with policy-violation code 1008, and the client
...                    surfaces errors from onmessage/onclose+code, not onerror.
...              Bug 3: runPairingLoop unconditionally printed a QR + pairing URL every rotation
...                    even when BOTH WS listeners failed to bind (e.g. another Kouen daemon
...                    already holding the port) — the phone could scan a QR whose WebSocket could
...                    never connect, with no clue why. Fix: gate the mint/print on
...                    anyWSListenerReady, warning once (after a short debounce, to ride out the
...                    normal async listener-ready race) instead of silently printing a dead QR.
Library          OperatingSystem
Library          Process

*** Variables ***
${ROOT}            ${CURDIR}/../..
${MOBILE_BRIDGE}   ${ROOT}/Packages/KouenDaemon/Sources/KouenDaemon/MobileBridgeServer.swift

*** Test Cases ***
Bug 1 - Rotation Grace Slot Keeps The Previous Token Redeemable
    [Documentation]    The proven root-cause fix: token validation must consider the
    ...                just-rotated-out previous token within its grace window, not only the
    ...                single current token. If PairingBox.check() ever drops the previous-token
    ...                branch, every real device that crosses a rotation boundary silently breaks
    ...                again — and swift build stays green because it still compiles.
    ${content}=    Get File    ${MOBILE_BRIDGE}
    Should Contain    ${content}    private var _previous: PendingPairing?
    ...    msg=PairingBox must retain the just-rotated-out token (grace slot) — dropping it reintroduces Bug 1
    Should Contain    ${content}    private var _previousValidUntil: Date?
    ...    msg=the grace window's deadline must exist alongside the previous token
    Should Contain    ${content}    if let prev = _previous, constantTimeEquals(Array(prev.token.utf8), bytes)
    ...    msg=check() must compare the submitted token against the previous token, not just current
    Should Contain    ${content}    if let until = _previousValidUntil, now < until { return .accepted }
    ...    msg=the previous token must be accepted only WITHIN its grace window

Bug 1 - Rotation Shifts The Outgoing Token Into The Grace Slot
    [Documentation]    The `current` setter must move the outgoing token into the grace slot on
    ...                every rotation — otherwise there is never a "previous" to honor and Bug 1
    ...                returns even with check()'s previous-branch intact.
    ${content}=    Get File    ${MOBILE_BRIDGE}
    Should Contain    ${content}    _previous = outgoing
    ...    msg=rotation must shift the outgoing token into the grace slot
    Should Contain    ${content}    _previousValidUntil = Date().addingTimeInterval(graceWindow)
    ...    msg=the grace deadline must be stamped from graceWindow at rotation time

Bug 1 - Stop Fully Clears The Grace Slot
    [Documentation]    A stopped bridge must not leave the last token redeemable through the grace
    ...                slot. stop() must call clear() (not `current = nil`, which would leave
    ...                _previous live), and clear() must null every field.
    ${content}=    Get File    ${MOBILE_BRIDGE}
    Should Contain    ${content}    pairingBox.clear()
    ...    msg=stop() must fully clear pairing state via clear(), not just current = nil
    Should Contain    ${content}    _current = nil; _previous = nil; _previousValidUntil = nil; _failedAttempts = 0
    ...    msg=clear() must null the grace slot too, or a stopped bridge stays pairable

Bug 1 - Token Lifetime Not Regressed Below The Human-Flow Window
    [Documentation]    120s is deliberate: real-device timing (Tailscale first-connect + camera
    ...                handoff + manual tap) routinely exceeds the old 15s/45s. Silently shrinking
    ...                it back narrows the window the grace slot has to cover.
    ${content}=    Get File    ${MOBILE_BRIDGE}
    Should Contain    ${content}    private let pairingLifetime: TimeInterval = 120
    ...    msg=pairingLifetime must stay at 120s — a smaller value reintroduces the timing pressure Bug 1 came from

Bug 2 - Reject Path Closes Gracefully With Policy-Violation Code 1008
    [Documentation]    rejectAndClose() must send a real WS close frame (opcode 0x8) carrying the
    ...                RFC 6455 status 1008 (Policy Violation, big-endian 0x03 0xF0) so the browser
    ...                fires a clean onclose instead of onerror.
    ${content}=    Get File    ${MOBILE_BRIDGE}
    Should Contain    ${content}    private func rejectAndClose(_ json: String, on connection: NWConnection)
    ...    msg=the single graceful-reject helper must exist
    Should Contain    ${content}    Data([0x03, 0xF0])
    ...    msg=the close frame must carry status code 1008 (0x03 0xF0), not an empty/no-code close
    Should Contain    ${content}    Self.encodeWSFrame(opcode: 0x8, payload: closeFrame)
    ...    msg=the reject must send a WS close frame (opcode 0x8), not just cancel the socket

Bug 2 - No Abrupt Cancel Immediately After The Error Text
    [Documentation]    The exact pre-fix pattern — sendText(error) with a trailing
    ...                `{ connection.cancel() }` closure — is what made onerror clobber the real
    ...                server error. It must never reappear; all reject sites go through
    ...                rejectAndClose().
    ${content}=    Get File    ${MOBILE_BRIDGE}
    Should Not Contain    ${content}    on: connection) { connection.cancel() }
    ...    msg=abrupt cancel right after an error message reintroduces Bug 2 (onerror clobbers the real error)

Bug 2 - Client onerror Does Not Clobber The Server Error Banner
    [Documentation]    The MDN/WHATWG contract: a WS error event carries no reason. The mobile
    ...                page must NOT drive a user-facing banner from onerror; the specific server
    ...                error arrives via onmessage, and onclose reads the close code.
    ${content}=    Get File    ${MOBILE_BRIDGE}
    Should Contain    ${content}    ws.onerror = () => console.error('[kouen mobile] websocket error');
    ...    msg=onerror must only log — driving showError() from it reintroduces the generic-banner mask (Bug 2)
    Should Not Contain    ${content}    ws.onerror = () => showError
    ...    msg=onerror must not call showError(); the reason is unavailable there by design
    Should Contain    ${content}    showError(ev.code === 1008
    ...    msg=the user-facing fallback banner must branch on the onclose close code, not onerror

Bug 3 - QR Not Printed When No Listener Is Ready
    [Documentation]    runPairingLoop must not mint a token or print a QR/pairing URL while
    ...                anyWSListenerReady is false (both WS listeners failed to bind, e.g. port
    ...                already held by another Kouen daemon instance) — otherwise the phone scans
    ...                a QR whose WebSocket can never connect, with no clue why.
    ${content}=    Get File    ${MOBILE_BRIDGE}
    Should Contain    ${content}    guard anyWSListenerReady else {
    ...    msg=runPairingLoop must guard the token-mint/print path on anyWSListenerReady
    Should Contain    ${content}    mobile bridge: no WS listener bound — cannot pair
    ...    msg=the not-ready branch must warn the operator instead of silently withholding the QR
    Should Contain    ${content}    notReadyTicks >= 8 && !warnedNoListener
    ...    msg=the warning must debounce past the normal async listener-ready startup race, not fire on the first not-ready tick

Pairing Unit Tests Pass
    [Documentation]    Behavioral coverage of the grace logic (current+previous acceptance, grace
    ...                expiry classified as expired-not-mismatch, clear() making tokens
    ...                unredeemable) lives in the Swift suite — run it here so a logic regression
    ...                fails the robot gate too, not just a structural one.
    ${result}=    Run Process    swift    test    --filter    MobileBridgePairingTests
    ...    cwd=${ROOT}    timeout=240s
    Should Be Equal As Integers    ${result.rc}    0
    ...    msg=MobileBridgePairingTests must pass: ${result.stderr}

Build Compiles Successfully
    [Documentation]    The project must compile without errors after all fixes.
    ${result}=    Run Process    swift    build
    ...    cwd=${ROOT}    timeout=180s
    Should Be Equal As Integers    ${result.rc}    0
    ...    msg=swift build must succeed: ${result.stderr}
