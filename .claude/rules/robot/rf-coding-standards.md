# Robot Framework Testing — Global Coding Standards

## Contents

- [1. Global Standards & Tooling Facts](#1-global-standards--tooling-facts)
- [2. Automation Strategy](#2-automation-strategy)
- [4. Mobile Expert Patterns & Gems](#4-mobile-expert-patterns--gems)
- [5. Mobile Platform Differences (Android vs iOS)](#5-mobile-platform-differences-android-vs-ios)

Core rules and strategies for Mobile Automation using Robot Framework + Appium, covering both iOS and Android.

---

## 1. Global Standards & Tooling Facts

### Environment Configuration
- Environment files: `.env.<os>.<env>` (e.g., `.env.android.sit`, `.env.ios.sit`).
- **Sensitive data (MUST be in `.env`):** credentials, tokens, passwords, secrets, login emails, API keys, OAuth URLs.
- **Non-sensitive data (MUST be in YAML fixture):** business data (`companyCode`, `customerCode`, user roles/identifiers).
- **Double Login Rule:** When SSO + project auth is needed, SSO credentials go in `.env`, project user identifiers go in `fixtures/`.

### Test Data & Fixtures
- Store test data in `fixtures/<os>/sit.yaml` — DO NOT hardcode in `.robot`.
- **Cross-Layer Shared Fixtures:** Data used across platforms (API + Mobile + Web) MUST be stored in `tests/shared-fixtures/[system-kebab]/[feature-kebab]/`.

### Locator Strategy & Wait Rules
- **Zero Hard Waits (MANDATORY):** Never use `Sleep` — use `Wait Until Element Is Visible` or explicit wait conditions instead.
- **No Inline Locators:** Do not write locators directly in test cases — encapsulate in Page Object Keywords.
- **Element Locator Priority:**
  1. `accessibility_id=` (Most stable across platforms)
  2. `id=`
  3. `class=` / predicate
  4. `xpath=` (Last resort only)

### Mandatory Naming & Tags
- **Cross-Platform Keyword Naming (MANDATORY):** Keyword names MUST be **100% identical** across Android and iOS — never append `Android` or `iOS` to keyword names.
- **Test Case ID:** Every Test Case MUST start with `[TC-xxxx]`.
- **Test Suite Naming:** Suite documentation MUST include `[ID-xxxx]` prefix.
- **Mandatory Tags (3 required):**
  - `Feature:<feature_name>`
  - `Important:<Critical|High|Medium|Low>`
  - `Scenario:<Success|Alternative|Error>`

### Folder Structure
```text
pages/[platform]/[system-kebab]/[feature-kebab]/[feature]Page.robot
tests-mobile/[platform]/[system-kebab]/[feature-kebab]/[feature].robot
fixtures/[platform]/sit.yaml
helpers/shared-services/[feature]_db_service.py
tests/shared-fixtures/[system-kebab]/[feature-kebab]/
```
- Folders: kebab-case (`user-management/`)
- Files: lowerCamelCase (`userLogin.robot`, `loginPage.robot`)
- Global variables: SCREAMING_SNAKE_CASE (`${BASE_URL}`)
- Keywords: Title Case with Spaces (`Tap Login Button`)

### Architecture-First for QA
Before writing a suite, declare the layer split: Page Keywords (`pages/`), Helpers/Services (`helpers/`), Test Data (`fixtures/`), Test Suites (`tests-mobile/`). Size target and the no-monolith rule: § Anti-Monolith & Separation Pattern in `rules/coding.md`.

---

## 2. Automation Strategy

### Priority Table
| Priority | Mobile UI | Strategy |
| :--- | :--- | :--- |
| **Critical** | Mandatory | Immediate Action (E2E Full Coverage) |
| **High** | Mandatory | Immediate Action (Focus on Core Flows) |
| **Medium** | Optional | Focus on Happy Path first |
| **Low** | Skip | Can be skipped if time is limited |

### Hybrid Execution Strategy
- Use Python helpers or APIs for data preparation instead of navigating through UI screens (seed data via API/DB, then verify via Mobile UI).
- Each test must be independent and not rely on execution state from other tests.

---

## 4. Mobile Expert Patterns & Gems

### 1. Hybrid Setup (API + Mobile)

Reduce setup time by bypassing irrelevant screens in a test case.

```robot
*** Keywords ***
Setup User Session Via API
    [Arguments]    ${username}    ${password}
    # 💎 Gem: Use RequestLibrary to fetch Token
    ${token}=    Get Auth Token Via API    ${username}    ${password}
    # 💎 Gem: Inject Token into App (if supported) or store for headers
    Set Test Variable    ${SESSION_TOKEN}    ${token}
```

### 2. Expert Locators Fallback

Technique to attempt finding a button using multiple locator formats before failing.

```robot
*** Keywords ***
Wait And Click Element Safely
    [Arguments]    ${primary_locator}    ${secondary_locator}=${NONE}
    # 💎 Gem: Try primary first; if not found in 5s, fallback to secondary
    ${status}    ${error}=    Run Keyword And Ignore Error    Wait Until Element Is Visible    ${primary_locator}    timeout=5s
    IF    '${status}' == 'FAIL' and '${secondary_locator}' != '${NONE}'
        Wait Until Element Is Visible    ${secondary_locator}    timeout=5s
        Click Element    ${secondary_locator}
    ELSE
        Click Element    ${primary_locator}
    END
```

### 3. Screen Record on Failure

Record video only when a test fails for CI/CD analysis.

```robot
*** Keywords ***
Capture Video On Failure
    Run Keyword If Test Failed    Capture Page Screenshot    filename=fail-{index}.png
    # 💎 Gem: Appium Library supports Start/Stop Screen Recording
```

### 4. Advanced Data Orchestration (Python Integration)

Use Python to generate dynamic, secure, and realistic test data.

```robot
*** Keywords ***
Generate Dynamic User Data
    # 💎 Gem: Call Python helper (Faker/Custom Logic)
    ${user}=    Generate Random User Profile
    Set Test Variable    ${DYNAMIC_USER}    ${user}
```

### 5. Mobile Visual Testing Strategy

Combining image comparison with locators for maximum precision.

```robot
*** Keywords ***
Verify Screen Content With Masking
    [Arguments]    ${template_image}
    # 💎 Gem: Mask volatile parts (time, battery) before comparison
    ${masks}=    Create List    accessibility_id=status-bar    accessibility_id=clock
    Check Screen    ${template_image}    mask_elements=${masks}
```

### 6. Reliability & Resilience (Self-Healing)

Expertly handle mobile environment uncertainties (Network, Pop-ups).

```robot
*** Keywords ***
Tap Element With Self-Healing
    [Arguments]    ${locator}
    # 💎 Gem: If blocked by a pop-up, close it and retry
    ${status}=    Run Keyword And Return Status    Click Element    ${locator}
    IF    '${status}' == '${FALSE}'
        Close Unexpected Popups
        Click Element    ${locator}
    END
```

---


---

## 5. Mobile Platform Differences (Android vs iOS)

> **🎯 Purpose:** Captures differences between Android and iOS.
> **⚠️ Unified Naming Rule:** Keyword names MUST be 100% identical across both platforms — DO NOT append `Android` or `iOS`.

### DIFF 1: Capabilities

| Config | Android | iOS |
|--------|---------|-----|
| Platform var | `${ANDROID_PACKAGE}` `${ANDROID_ACTIVITY}` | `${IOS_BUNDLE_ID}` |
| Automation | UiAutomator2 | XCUITest |
| Env file | `.env.android.sit` | `.env.ios.sit` |
| App binary | `.apk` | `.ipa` / `.app` |

### DIFF 2: Locator Priority

| Priority | Android | iOS |
|----------|---------|-----|
| 🥇 #1 | `accessibility_id=x` | `accessibility_id=x` (Same) |
| 🥈 #2 | `id=com.app:id/btn` | `ios=type == 'XCUIElementTypeButton' AND name == 'x'` |
| 🥉 #3 | `android=new UiSelector().text("x")` | `chain=**/XCUIElementTypeButton[-1]` |
| 🚫 #4 | `xpath=...` (Avoid) | `xpath=...` (Avoid 100%) |

**Platform-Specific Actions:**

| Action | Android | iOS |
|--------|---------|-----|
| Back | `Press Keycode    4` | No hardware back button |
| Hide Keyboard | `Hide Keyboard` + `Press Keycode    66` | `Click Element    accessibility_id=Done` |
| Scroll | `android=new UiScrollable(...).scrollIntoView(...)` | `Execute Script    mobile: scroll    {'direction': 'down', 'predicateString': '...'}` |
| System Alert | N/A | `Execute Script    mobile: alert    {'action': 'accept'}` |

### DIFF 3: Expert Gems

| Gem | Android | iOS |
|-----|---------|-----|
| Deep Link | `Execute Script    mobile: deepLink    url=x    package=${ANDROID_PACKAGE}` | `Execute Script    mobile: deepLink    url=x    bundleId=${IOS_BUNDLE_ID}` |
| Platform Gem | ADB: `Execute Adb Shell    pm grant ...` | Biometric: `Execute Script    mobile: sendBiometricMatch    type=faceid    match=true` |
| Performance flags | `ignoreUnimportantViews=true`, `disableWindowAnimation=true` | `includeSafariInWebviews=true`, `shouldTerminateApp=true` |

### DIFF 4: Unified Keyword Naming Examples

```robot
# ✅ CORRECT — Same name for both platforms (only locators inside vary)
Tap Login Button          # Android: accessibility_id=submit-btn
                          # iOS:     accessibility_id=submit-btn

Input Username            # Android: id=com.example.app:id/email_input
                          # iOS:     ios=type == 'XCUIElementTypeTextField' AND name == 'email_input'

# ❌ WRONG
Tap Login Button Android  # DO NOT append platform suffix
Tap Login Button iOS
```
