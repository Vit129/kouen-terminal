# Robot Framework Browser Library (Playwright-Powered)

Browser Library is a Robot Framework library that uses Playwright as its engine: faster than SeleniumLibrary, with built-in auto-wait.

## Installation

```bash
pip install robotframework-browser
rfbrowser init
```

## Basic Usage

```robotframework
*** Settings ***
Library    Browser

*** Test Cases ***
Flight Search Test
    New Browser    chromium    headless=True
    New Context    viewport={'width': 1280, 'height': 720}
    New Page       https://app.example.com/flights/search
    
    Get Text       id=flight-search-form    # verify page loaded
    Fill Text      [data-testid=origin-input]    BKK
    Fill Text      [data-testid=destination-input]    NRT
    Click          [data-testid=btn_searchFlights_flightSearchPage]
    
    Wait For Elements State    [data-testid=tbl_flightResults_flightSearchPage]    visible
    Get Element Count    [data-testid^=flight-result-item-]    >    0
    
    Close Browser
```

## Locator Strategies

```robotframework
# CSS selector (preferred)
Click    [data-testid=btn_searchFlights_flightSearchPage]
Click    css=[data-testid=btn_searchFlights_flightSearchPage]

# Role-based (accessibility)
Click    role=button >> text=Search Flights

# Text
Click    text=Search Flights

# XPath (last resort)
Click    xpath=//button[@data-testid='btn_searchFlights_flightSearchPage']

# Chaining (scope)
Click    [data-testid=flight-result-item-FL001] >> [data-testid=btn-select-flight-FL001]
```

## Auto-Wait (Key Advantage over Selenium)

```robotframework
# Browser Library waits automatically — no explicit waits needed for most cases
Click    [data-testid=btn_searchFlights_flightSearchPage]
# ↑ automatically waits for element to be visible, enabled, and stable

# Explicit wait when needed
Wait For Elements State    [data-testid=tbl_flightResults_flightSearchPage]    visible    timeout=10s
Wait For Elements State    [data-testid=loading-spinner]       hidden     timeout=15s
```

## Assertions

```robotframework
# Text content
Get Text    [data-testid=flight-price]    ==    $150.00

# Element state
Get Element State    [data-testid=btn-submit]    enabled
Get Element State    [data-testid=error-message]    visible

# Count
Get Element Count    [data-testid^=flight-result-item-]    >    0

# Attribute
Get Attribute    [data-testid=status-badge]    class    *=    active
```

## Screenshots

```robotframework
# Take screenshot on failure (automatic with Browser Library)
Take Screenshot    filename=flight-search-{index}.png

# Full page screenshot
Take Screenshot    fullPage=True
```

## Network Interception (Mock API)

```robotframework
*** Settings ***
Library    Browser

*** Test Cases ***
Test With Mocked API
    New Browser    chromium
    New Context
    New Page    https://app.example.com
    
    # Mock API response
    Mock Response    /api/flights    {"flights": [{"id": "FL001", "price": 15000}]}
    
    Click    [data-testid=btn_searchFlights_flightSearchPage]
    Get Text    [data-testid=flight-result-item-FL001]    contains    FL001
```

## Page Object Pattern with Browser Library

```robotframework
*** Settings ***
Library    Browser
Resource   ../pages/FlightSearchPage.resource

*** Test Cases ***
Search For Flight
    Open Flight Search Page
    Fill Search Form    origin=BKK    destination=NRT
    Submit Search
    Verify Results Displayed

*** Keywords ***
# FlightSearchPage.resource
Open Flight Search Page
    New Page    ${BASE_URL}/flights/search
    Wait For Elements State    [data-testid=flight-search-form]    visible

Fill Search Form
    [Arguments]    ${origin}    ${destination}
    Fill Text    [data-testid=origin-input]    ${origin}
    Fill Text    [data-testid=destination-input]    ${destination}

Submit Search
    Click    [data-testid=btn_searchFlights_flightSearchPage]
    Wait For Elements State    [data-testid=tbl_flightResults_flightSearchPage]    visible

Verify Results Displayed
    Get Element Count    [data-testid^=flight-result-item-]    >    0
```

## Parallel Execution

```robotframework
# pabot for parallel execution
pip install robotframework-pabot

# Run 4 parallel processes
pabot --processes 4 tests/
```

## When to Use Browser Library vs SeleniumLibrary

| Feature | Browser Library | SeleniumLibrary |
|---------|----------------|-----------------|
| Auto-wait | ✅ Built-in | ❌ Manual waits |
| Speed | ✅ Faster | Slower |
| Modern web (SPA) | ✅ Excellent | Moderate |
| Network mocking | ✅ Built-in | ❌ Not built-in |
| Mobile emulation | ✅ Built-in | Limited |
| Recommendation | ✅ New projects | Legacy projects |
