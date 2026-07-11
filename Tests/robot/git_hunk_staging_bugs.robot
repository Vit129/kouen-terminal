*** Settings ***
Documentation    Regression tests for P39 C1 (git hunk staging) bugs found in manual testing.
...              Bug 1: hunksButton had no explicit size constraint, collapsed to zero-width
...                     inside the .fill-distribution NSStackView, so it never appeared on screen.
Library          OperatingSystem
Library          Process

*** Variables ***
${ROOT}              ${CURDIR}/../..
${GIT_PANEL_VIEW}    ${ROOT}/Apps/Kouen/Sources/KouenApp/UI/Git/GitPanelView.swift

*** Test Cases ***
Bug 1 - Hunks Button Has Explicit Size Constraints
    [Documentation]    A plain NSButton with only an image (no intrinsic content size
    ...                guarantee) collapses to zero-width inside a .fill NSStackView without
    ...                explicit width/height constraints — same class of issue StageToggleButton
    ...                avoids with its own explicit 16x16 constraints. Without this, the button
    ...                compiles fine and never crashes, it just never appears — silent, not
    ...                caught by `swift build`/`swift test` alone.
    ${content}=    Get File    ${GIT_PANEL_VIEW}
    ${func_start}=    Evaluate    """${content}""".find("let hunksButton = NSButton(")
    Should Not Be Equal As Integers    ${func_start}    -1
    ...    msg=hunksButton construction not found in GitPanelView.swift
    ${slice}=    Evaluate    """${content}"""[${func_start}:${func_start}+950]
    Should Contain    ${slice}    hunksButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
    ...    msg=hunksButton must have an explicit width constraint or it silently disappears
    Should Contain    ${slice}    hunksButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
    ...    msg=hunksButton must have an explicit height constraint or it silently disappears
    Should Contain    ${slice}    translatesAutoresizingMaskIntoConstraints = false
    ...    msg=hunksButton must opt into Auto Layout for its explicit size constraints to apply

Bug 1 - Hunks Button Symbol Has A Guaranteed-Valid Fallback
    [Documentation]    If the primary SF Symbol name is ever wrong/unavailable,
    ...                NSImage(systemSymbolName:) returns nil — must fall back to a
    ...                certainly-valid symbol rather than an empty NSImage(), which would
    ...                reproduce the same zero-content symptom the size-constraint fix guards
    ...                against, just via a different path.
    ${content}=    Get File    ${GIT_PANEL_VIEW}
    ${func_start}=    Evaluate    """${content}""".find("let hunksButton = NSButton(")
    ${slice}=    Evaluate    """${content}"""[${func_start}:${func_start}+950]
    Should Contain    ${slice}    ?? NSImage(systemSymbolName:
    ...    msg=must fall back to a second, guaranteed-valid systemSymbolName, not an empty NSImage()

Build Compiles Successfully
    [Documentation]    The project must compile without errors after all fixes.
    ${result}=    Run Process    swift    build
    ...    cwd=${ROOT}    timeout=120s
    Should Be Equal As Integers    ${result.rc}    0
    ...    msg=swift build must succeed: ${result.stderr}
