# Error Handling Standards — All Platforms

> **Applies to:** React, Flutter, Android (Kotlin), iOS (Swift)

## Error Categories

| Category | Description | Example |
|---|---|---|
| Network Error | API unreachable, timeout, 5xx | Server down, no internet |
| Business Error | API returns 4xx with error code | Invalid input, not found, unauthorized |
| Unexpected Error | Unhandled exception, null crash | NullPointerException, JS runtime error |
| Validation Error | Client-side form validation | Required field empty, invalid format |

## Response Convention

Every error must be handled with:
1. **Log** — record error with context
2. **Display** — show user-friendly message (never raw stack trace)
3. **Recover** — provide a clear next action (retry, go back)

## Rules

1. Every API call MUST have error handling — no silent failures
2. Unexpected errors MUST be caught at the global level
3. Error messages shown to users MUST be defined in a constants/strings file
4. Sensitive data (tokens, passwords, PII) MUST NOT appear in logs
5. Error states MUST have a `data-testid` / `accessibilityIdentifier`
