# Robot Framework + Flutter via Appium

Flutter app testing with Robot Framework using `appium-flutter-driver` or native Appium with Semantics.

## Two Approaches

| Approach | Driver | Locator | When to Use |
|----------|--------|---------|-------------|
| **Flutter Driver** | `appium-flutter-driver` | `flutter=byValueKey('xxx')` | Pure Flutter app, full widget-level access |
| **Native + Semantics** | UiAutomator2 / XCUITest | `accessibility_id=xxx` | Hybrid app, or Flutter with `Semantics` widgets |

**Recommended:** Flutter Driver approach — more stable, direct widget access.

---

## Flutter Code Preparation (Dev Team)

Devs must add `Key` to testable widgets:

```dart
ElevatedButton(
  key: const Key('login_button'),
  onPressed: _login,
  child: const Text('Login'),
)

TextField(
  key: const Key('email_field'),
  decoration: const InputDecoration(labelText: 'Email'),
)
```

For native Appium approach, use `Semantics`:

```dart
Semantics(
  label: 'login_button',
  child: ElevatedButton(onPressed: _login, child: const Text('Login')),
)
```

---

## Locator Strategy — Flutter Apps

### Priority Order (Flutter Driver)

| Priority | Locator | RF Syntax | When |
|----------|---------|-----------|------|
| 🥇 #1 | **byValueKey** | `flutter=byValueKey('login_button')` | Widget has `Key('xxx')` |
| 🥈 #2 | **byText** | `flutter=byText('Login')` | Visible text, no Key assigned |
| 🥉 #3 | **byType** | `flutter=byType('ElevatedButton')` | Only one widget of that type on screen |
| 🚫 #4 | **bySemanticsLabel** | `flutter=bySemanticsLabel('Login')` | Semantics label assigned |

### Priority Order (Native Appium — when Flutter context not available)

Falls back to standard Android/iOS locator rules:
- Android: `accessibility_id` → `id` → `android=UiSelector` → `xpath`
- iOS: `accessibility_id` → `ios=predicate` → `chain=class chain` → `xpath`

---

## Context Switching

Flutter apps have two contexts:

| Context | When Active | Locator Type |
|---------|-------------|--------------|
| `FLUTTER` | Flutter engine rendering | `flutter=byValueKey(...)` |
| `NATIVE_APP` | Native splash, system dialogs, permissions | Standard Appium locators |

```robot
*** Keywords ***
Switch To Flutter Context
    Switch Application Context    FLUTTER

Switch To Native Context
    Switch Application Context    NATIVE_APP

Handle Permission Dialog Then Return To Flutter
    Switch To Native Context
    Click Element    accessibility_id=permission_allow_button
    Switch To Flutter Context
```

---

## Capabilities — Flutter Driver

### Android

```robot
*** Variables ***
${PLATFORM_NAME}        Android
${APP_PATH}             ${CURDIR}/../../apps/android/app-debug.apk
${AUTOMATION_NAME}      Flutter
${DEVICE_NAME}          Android Emulator

*** Keywords ***
Open Flutter App Android
    Open Application    http://localhost:4723
    ...    platformName=${PLATFORM_NAME}
    ...    app=${APP_PATH}
    ...    automationName=${AUTOMATION_NAME}
    ...    deviceName=${DEVICE_NAME}
    ...    noReset=${TRUE}
```

### iOS

```robot
*** Variables ***
${PLATFORM_NAME}        iOS
${APP_PATH}             ${CURDIR}/../../apps/ios/Runner.app
${AUTOMATION_NAME}      Flutter
${DEVICE_NAME}          iPhone 15 Pro
${PLATFORM_VERSION}     17.0

*** Keywords ***
Open Flutter App iOS
    Open Application    http://localhost:4723
    ...    platformName=${PLATFORM_NAME}
    ...    app=${APP_PATH}
    ...    automationName=${AUTOMATION_NAME}
    ...    deviceName=${DEVICE_NAME}
    ...    platformVersion=${PLATFORM_VERSION}
    ...    noReset=${TRUE}
```

---

## Page Object Pattern — Flutter

```robot
*** Settings ***
Library    AppiumLibrary

*** Keywords ***
# ─── Login Page Keywords (Identical naming Android/iOS) ───

Input Email
    [Arguments]    ${email}
    Input Text    flutter=byValueKey('email_field')    ${email}

Input Password
    [Arguments]    ${password}
    Input Text    flutter=byValueKey('password_field')    ${password}

Tap Login Button
    Click Element    flutter=byValueKey('login_button')

Verify Home Screen Displayed
    Wait Until Element Is Visible    flutter=byValueKey('home_screen')    timeout=10s
```

---

## Test Example — Full Flow

```robot
*** Settings ***
Library    AppiumLibrary
Resource   ../pages/${PLATFORM}/login/loginPage.robot
Variables  ../fixtures/${PLATFORM}/${ENV}.yaml

Suite Setup       Open Flutter App ${PLATFORM}
Suite Teardown    Close Application

*** Test Cases ***
[TC-0001] User Should Login Successfully
    [Tags]    Feature:Auth    Important:Critical    Scenario:Success
    # Arrange
    ${email}=    Set Variable    ${LOGIN_EMAIL}
    ${password}=    Set Variable    ${LOGIN_PASSWORD}
    # Act
    Input Email    ${email}
    Input Password    ${password}
    Tap Login Button
    # Assert
    Verify Home Screen Displayed
```

---

## Scrolling in Flutter

```robot
*** Keywords ***
Scroll Down In Flutter
    # Flutter driver scroll
    Execute Script    flutter:scroll
    ...    finder=byType('ListView')
    ...    dx=0    dy=-300

Scroll To Element By Key
    [Arguments]    ${key}
    Execute Script    flutter:scrollUntilVisible
    ...    finder=byValueKey('${key}')
    ...    item_finder=byType('ListView')
    ...    dy=-100
```

---

## Build Requirements

| Mode | Works with Flutter Driver? | Notes |
|------|---------------------------|-------|
| `flutter build apk --debug` | ✅ Yes | Full VM service access |
| `flutter build apk --profile` | ✅ Yes | Better perf, still testable |
| `flutter build apk --release` | ❌ No | VM service stripped — driver can't connect |

**Rule:** Always test with `debug` or `profile` builds.

---

## Appium Server Setup for Flutter

```bash
# Install Flutter driver
appium driver install appium-flutter-driver

# Start Appium with Flutter support
appium --use-drivers=flutter

# Or with UiAutomator2 fallback for hybrid
appium --use-drivers=flutter,uiautomator2
```

---

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| `flutter=byValueKey` not found | Widget has no `Key()` | Ask dev to add `Key('xxx')` |
| Context switch fails | App still loading | Add wait before switch |
| Elements not accessible | Release build | Use debug/profile build |
| Timeout on first element | Flutter engine not ready | Wait for first Flutter element with longer timeout |
| `FLUTTER` context not listed | Wrong automation name | Set `automationName=Flutter` in capabilities |
