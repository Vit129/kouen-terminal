# Robot Framework 7.x New Features

Robot Framework 7.4 (latest stable as of 2025) — key improvements for modern automation.

## Secret Variables (RF 7.4)

Mask sensitive data in logs automatically:

```robotframework
*** Settings ***
Library    OperatingSystem

*** Variables ***
${PASSWORD}    %{TEST_PASSWORD}    # from environment variable

*** Test Cases ***
Login With Secret
    # Use $SECRET{} syntax to mask in logs
    ${secret_password}=    Get Variable Value    $SECRET{PASSWORD}
    Fill Text    [data-testid=password-input]    ${secret_password}
    # ↑ password will appear as ****** in logs
```

```robotframework
# Or use VAR with secret=True
VAR    ${api_key}    %{API_KEY}    secret=True
```

## Typed Keywords (RF 7.x)

Type hints in Python keywords for better validation:

```python
# keywords/flight_keywords.py
from robot.api.deco import keyword

@keyword
def search_flights(origin: str, destination: str, max_price: int = 50000) -> list[dict]:
    """Search flights with type validation."""
    # RF 7 validates types automatically
    return flight_service.search(origin, destination, max_price)
```

```robotframework
*** Test Cases ***
Search With Type Validation
    ${flights}=    Search Flights    origin=BKK    destination=NRT    max_price=20000
    # max_price is automatically converted to int
```

## WHILE Loop (RF 5+)

```robotframework
*** Keywords ***
Wait For Flight Results
    WHILE    True    limit=10    on_limit=PASS
        ${count}=    Get Element Count    [data-testid^=flight-result-item-]
        IF    ${count} > 0    BREAK
        Sleep    1s
    END
```

## TRY / EXCEPT / FINALLY (RF 5+)

```robotframework
*** Keywords ***
Safe Click With Retry
    [Arguments]    ${locator}    ${retries}=3
    FOR    ${i}    IN RANGE    ${retries}
        TRY
            Click    ${locator}
            RETURN
        EXCEPT    ElementNotFound    type=start
            Log    Retry ${i+1}/${retries}
            Sleep    1s
        END
    END
    Fail    Element ${locator} not found after ${retries} retries

*** Keywords ***
Cleanup After Test
    TRY
        Do Something Risky
    EXCEPT    AS    ${error}
        Log    Error occurred: ${error}    level=WARN
    FINALLY
        Close Browser    # always runs
    END
```

## Inline IF (RF 5+)

```robotframework
*** Keywords ***
Get Flight Price Text
    [Arguments]    ${flight_id}
    ${price}=    Get Text    [data-testid=flight-price-${flight_id}]
    ${formatted}=    IF    '${LANG}' == 'de'    Set Variable    Preis: ${price}    ELSE    Set Variable    Price: ${price}
    RETURN    ${formatted}
```

## VAR Syntax (RF 7+)

```robotframework
*** Test Cases ***
Modern Variable Assignment
    # Old way
    ${name}=    Set Variable    John

    # New way (RF 7+)
    VAR    ${name}    John
    VAR    ${count}    ${42}
    VAR    @{items}    item1    item2    item3
    VAR    &{config}    host=localhost    port=5432
```

## Native JSON Support

```robotframework
*** Keywords ***
Parse Flight Response
    [Arguments]    ${json_string}
    ${data}=    Evaluate    json.loads($json_string)    json
    ${flight_id}=    Set Variable    ${data}[flights][0][id]
    RETURN    ${flight_id}
```

## Improved Argument Conversion

```robotframework
*** Keywords ***
Set Timeout
    [Arguments]    ${timeout}    # accepts "10s", "1min", "500ms"
    Set Browser Timeout    ${timeout}

*** Test Cases ***
Use Human-Readable Timeout
    Set Timeout    30 seconds    # RF 7 converts automatically
    Set Timeout    2 minutes
```

## Skip Tests Conditionally

```robotframework
*** Test Cases ***
Android Only Test
    [Tags]    android
    Skip If    '${PLATFORM}' != 'android'    Test only runs on Android
    # ... test steps

iOS Only Test
    [Tags]    ios
    Skip If    '${PLATFORM}' != 'ios'    Test only runs on iOS
```

## Listener API v3 (RF 7)

```python
# listeners/test_reporter.py
class TestReporter:
    ROBOT_LISTENER_API_VERSION = 3

    def start_test(self, data, result):
        print(f"Starting: {data.name}")

    def end_test(self, data, result):
        if result.failed:
            # send alert, update dashboard, etc.
            notify_slack(f"FAILED: {data.name}")
```

```bash
robot --listener listeners/test_reporter.py tests/
```

## Best Practices for RF 7.x

- Use `VAR` instead of `Set Variable` for cleaner syntax
- Use `secret=True` for all sensitive variables (passwords, tokens, API keys)
- Use `TRY/EXCEPT` instead of `Run Keyword And Ignore Error`
- Use `WHILE` with `limit` to prevent infinite loops
- Add type hints to Python keywords for automatic validation
- Use `Skip If` for platform-specific tests instead of separate suites
