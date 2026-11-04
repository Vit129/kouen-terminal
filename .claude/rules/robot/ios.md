# Appium Testing (iOS) — Platform Rules & Capabilities

## Contents

- [1. iOS Capabilities & Lifecycle](#1-ios-capabilities--lifecycle)
- [2. iOS Locator Strategy & Actions](#2-ios-locator-strategy--actions)
- [3. iOS Expert Gems (Performance & Bypass)](#3-ios-expert-gems-performance--bypass)
- [4. iOS CLI Execution Commands](#4-ios-cli-execution-commands)

iOS-specific Appium and Robot Framework automation rules, locators, and platform capabilities.
Global standards (environment variables, cross-layer fixtures, zero hard wait, identical keyword naming, mandatory tags) are defined centrally in `rules/robot/rf-coding-standards.md`.

---

## 1. iOS Capabilities & Lifecycle

### iOS App Lifecycle & Configurations

iOS Automation is controlled through the **XCUITest** driver.

- Always specify **`bundleId`** (equivalent to `appPackage`) when connecting to a real device or simulator.
- Use **`app`** to provide the path to the .app or .ipa binary.

```robot
*** Variables ***
${IOS_PLATFORM_NAME}        iOS
${IOS_PLATFORM_VERSION}     17.2    # DO NOT hardcode; fetch from .yaml
${IOS_DEVICE_NAME}          iPhone 15 Pro
${IOS_BUNDLE_ID}            com.example.myapp
${IOS_AUTOMATION}           XCUITest
```

---

## 2. iOS Locator Strategy & Actions

### 1. 🎯 Locator Strategy (iOS DOM Lookup Strategy)

iOS element discovery via XCUITest follows this Priority Order. Name new `accessibility_id`/
`accessibilityIdentifier` values per `rules/data-testid-mapping.md`'s Mobile section — same
`{type-abbr}_{context}_{screen}` pattern as the web `data-testid` convention.

| Priority | Locator Type | Syntax in Robot | Stability |
| :------- | :----------- | :-------------- | :--------- |
| 🥇 #1 | **Accessibility ID** | `accessibility_id=login-btn` | Most stable (Maps to `accessibilityIdentifier`) |
| 🥈 #2 | **Predicate** | `ios=type == 'XCUIElementTypeButton' AND name == 'Login'` | Fast and precise (using `-ios predicate string`) |
| 🥉 #3 | **Class Chain** | `chain=**/XCUIElementTypeButton[-1]` | Efficient lookup (using `-ios class chain`), faster than XPath |
| 🚫 #4 | **XPath** | `xpath=//XCUIElementTypeButton[@name='Login']`| Slowest and most fragile in XCUITest (Avoid 100%) |

### 🛠️ Example Correct iOS Locator Usage

```robot
*** Keywords ***
Tap Login Button
    # ✅ BEST: Use accessibilityIdentifier
    Tap Element Safely    accessibility_id=submit-btn

Input Username
    # ✅ GOOD: Use Predicate (iOS native lookup) if accessibility_id is missing
    Input Text Into Field    ios=type == 'XCUIElementTypeTextField' AND name == 'email_input'    ${username}
```

### 🦋 Flutter App Locator Strategy (iOS)

> **When:** App is built with Flutter + `automationName=Flutter` in capabilities.
> **Reference:** See `robotframework-testing/references/flutter-appium.md` for full details.

| Priority | Locator | RF Syntax | Stability |
|----------|---------|-----------|-----------|
| 🥇 #1 | **byValueKey** | `flutter=byValueKey('login_button')` | Most stable — requires `Key('xxx')` in Flutter code |
| 🥈 #2 | **byText** | `flutter=byText('Login')` | Stable for unique visible text |
| 🥉 #3 | **byType** | `flutter=byType('ElevatedButton')` | Only when single widget of type on screen |
| 🚫 #4 | **bySemanticsLabel** | `flutter=bySemanticsLabel('Login')` | Fallback — requires `Semantics` widget |

**Context switching:** Use `Switch Application Context    FLUTTER` for Flutter widgets, `NATIVE_APP` for system dialogs/permissions.

```robot
*** Keywords ***
Tap Login Button (Flutter)
    # ✅ BEST: Use Flutter Key
    Click Element    flutter=byValueKey('login_button')

Handle Permission Then Return
    Switch Application Context    NATIVE_APP
    Click Element    accessibility_id=permission_allow_button
    Switch Application Context    FLUTTER
```

### 2. 🤖 iOS-Specific Actions

iOS-specific mechanisms supported by Appium:

**A. Keyboard Interaction (iOS):**
(Different from Android; usually requires tapping a specific button or background)

```robot
*** Keywords ***
Submit Form
    # Method 1: Tapping the "Done" button on the soft keyboard
    Click Element    accessibility_id=Done
    
    # Method 2: Tapping an empty area (requires a helper)
    Tap Element Safely    xpath=//XCUIElementTypeApplication
```

**B. Scrolling on iOS (Native Search):**

```robot
*** Keywords ***
Scroll To Settings Menu
    # Fast scrolling using iOS native predicate
    Execute Script    mobile: scroll    {'direction': 'down', 'predicateString': 'name == "Settings"'}
```

**C. Handling System Alerts:**
OS-level pop-ups (e.g., location or notification permissions) require special handling:

```robot
*** Keywords ***
Accept System Alert
    # Can also set Capabilities: autoAcceptAlerts=true
    Execute Script    mobile: alert    {'action': 'accept'}
```

---

## 3. iOS Expert Gems (Performance & Bypass)

### 1. iOS Deep Linking (Fast Navigation Gem)

Jump directly to a specific screen to save time and reduce test fragility.

```robot
*** Keywords ***
Jump To Profile Screen
    # 💎 Gem: Use mobile: deepLink to navigate directly
    Execute Script    mobile: deepLink    url=myapp://profile    bundleId=${IOS_BUNDLE_ID}
```

### 2. Biometric Simulation (FaceID/TouchID Gem)

Test apps requiring biometric auth without manual intervention.

```robot
*** Keywords ***
Simulate FaceID Success
    # 💎 Gem: Instruct simulator to mock a successful FaceID scan
    Execute Script    mobile: enrollBiometric    isEnabled=true
    Execute Script    mobile: sendBiometricMatch    type=faceid    match=true
```

### 3. Advanced Predicate String (Performance Gem)

Perform complex lookups at maximum speed (10-20x faster than XPath).

```robot
*** Keywords ***
Verify Status Is Completed
    # 💎 Gem: Multi-attribute lookup using native iOS syntax
    ${locator}    Set Variable    ios=type == 'XCUIElementTypeStaticText' AND label CONTAINS 'Completed' AND visible == 1
    Element Should Be Visible    ${locator}
```

---


---

## 4. iOS CLI Execution Commands

```bash
# === 🚀 Start Appium Server ===
appium

# === 🍏 iOS Test Execution (Robot Framework) ===

# Run all tests in the default environment
robot tests-mobile/ios/

# Specify Environment (SIT / UAT)
robot --variable ENV:sit tests-mobile/ios/
robot --variable ENV:uat tests-mobile/ios/

# Run by Tag (e.g., smoke, regression)
robot --include smoke tests-mobile/ios/
robot --include regression tests-mobile/ios/

# Run specific folder
robot tests-mobile/ios/[system-kebab]/[feature-kebab]/

# === 📊 Reports ===
robot --outputdir results tests-mobile/ios/
# View report
open results/report.html

# === 🛠️ Device & Debugging ===
xcrun simctl list devices
xcrun simctl boot "iPhone 15 Pro"
robot --loglevel DEBUG tests-mobile/ios/auth/login.robot
```

---

