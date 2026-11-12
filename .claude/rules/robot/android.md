# Appium Testing (Android) — Platform Rules & Capabilities

## Contents

- [1. Android Capabilities & Lifecycle](#1-android-capabilities--lifecycle)
- [2. Android Locator Strategy & Actions](#2-android-locator-strategy--actions)
- [3. Android Expert Gems (Power User)](#3-android-expert-gems-power-user)
- [4. Android CLI Execution Commands](#4-android-cli-execution-commands)

Android-specific Appium and Robot Framework automation rules, locators, and platform capabilities.
Global standards (environment variables, cross-layer fixtures, zero hard wait, identical keyword naming, mandatory tags) are defined centrally in `rules/robot/rf-coding-standards.md`.

---

## 1. Android Capabilities & Lifecycle

### Android App Lifecycle & Configurations

Configure Capabilities correctly to prevent unnecessary data clearing and to speed up execution.

- **`appPackage`** and **`appActivity`** are the core variables for starting Android apps.
- Set `noReset` to `${TRUE}` to avoid reinstalling the app if a clean state is not required.

```robot
*** Variables ***
${ANDROID_PLATFORM_NAME}    Android
${ANDROID_PACKAGE}          com.example.myapp
${ANDROID_ACTIVITY}         com.example.myapp.MainActivity
${ANDROID_AUTOMATION}       UiAutomator2
```

---

## 2. Android Locator Strategy & Actions

### 1. 🎯 Locator Strategy (Android DOM Lookup Strategy)

Android element discovery follows this Priority Order. Name new `accessibility_id`/`content-desc`
values per `rules/data-testid-mapping.md`'s Mobile section — same `{type-abbr}_{context}_{screen}`
pattern as the web `data-testid` convention.

| Priority | Locator Type | Syntax in Robot | Stability |
| :------- | :----------- | :-------------- | :--------- |
| 🥇 #1 | **Accessibility ID** | `accessibility_id=login-btn` | Most stable (Maps to `content-desc` in UiAutomator) |
| 🥈 #2 | **ID** | `id=com.app.package:id/btn_login` | Highly reliable (Resource ID) |
| 🥉 #3 | **UIAutomator** | `android=new UiSelector().text("Login")` | Flexible (but complex syntax) |
| 🚫 #4 | **XPath** | `xpath=//android.widget.TextView[@text='Login']`| Slow and fragile (Avoid) |

### 🛠️ Example Correct Android Locator Usage

```robot
*** Keywords ***
Tap Login Button
    # ✅ BEST: Use content-desc from UiAutomator
    Tap Element Safely    accessibility_id=submit-btn

Input Username
    # ✅ GOOD: Use Resource-ID if accessibility_id is missing
    Input Text Into Field    id=com.example.app:id/email_input    ${username}
```

### 🦋 Flutter App Locator Strategy (Android)

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

### 2. 🤖 Android-Specific Actions

Appium actions specific to the Android platform:

**A. Back Button (Hardware):**

```robot
*** Keywords ***
Go Back To Previous Screen
    # Call directly via Appium Library
    Press Keycode    4
```

**B. Keyboard Interaction:**

```robot
*** Keywords ***
Submit Form
    Hide Keyboard    # Close the soft keyboard
    # Press Enter on the virtual keyboard
    Press Keycode    66    
```

**C. Scrolling with UIAutomator (Native Scrolling):**
(Used when normal swipe is inaccurate or for long pages)

```robot
*** Keywords ***
Scroll To Settings Menu
    # Use UIAutomator to scroll element into view
    ${scroll_to_element}    Set Variable    android=new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().textContains("Settings"))
    Wait Until Element Is Visible    ${scroll_to_element}    timeout=10s
    Click Element    ${scroll_to_element}
```

---

## 3. Android Expert Gems (Power User)

### 1. Deep Linking (Fast Navigation Gem)

Bypass complex navigation by jumping directly to a screen via URL Scheme.

```robot
*** Keywords ***
Jump To Payment Screen
    # 💎 Gem: Open app URL Scheme using Execute Script
    Execute Script    mobile: deepLink    url=myapp://payment    package=${ANDROID_PACKAGE}
```

### 2. ADB Command Integration (Power User Gem)

Leverage Android Debug Bridge (ADB) through Appium to handle system-level tasks.

```robot
*** Keywords ***
Grant App Permissions Via ADB
    # 💎 Gem: Grant permissions without waiting for OS pop-ups
    Execute Adb Shell    pm grant ${ANDROID_PACKAGE} android.permission.CAMERA
    Execute Adb Shell    pm grant ${ANDROID_PACKAGE} android.permission.ACCESS_FINE_LOCATION
```

### 3. Network Speed Simulation

Simulate slow network conditions to test loading and error handling.

```robot
*** Keywords ***
Simulate Slow Network
    [Arguments]    ${speed}=gsm
    # 💎 Gem: Adjust connection speed (gsm, edge, hscsd, gprs, umts, hsdpa, lte, evdo, full)
    Set Network Connection Status    ${4}    # Example: Data only
```

---


---

## 4. Android CLI Execution Commands

```bash
# === 🚀 Start Appium Server ===
appium

# === 📱 Android Test Execution (Robot Framework) ===

# Run all tests in the default environment
robot tests-mobile/android/

# Specify Environment (SIT / UAT)
robot --variable ENV:sit tests-mobile/android/
robot --variable ENV:uat tests-mobile/android/

# Run by Tag (e.g., smoke, regression)
robot --include smoke tests-mobile/android/
robot --include regression tests-mobile/android/

# Run specific folder
robot tests-mobile/android/[system-kebab]/[feature-kebab]/

# === 📊 Reports ===
robot --outputdir results tests-mobile/android/
# View report
open results/report.html

# === 🛠️ Device & Debugging ===
adb devices
adb kill-server && adb start-server
robot --loglevel DEBUG tests-mobile/android/auth/login.robot
```

---

