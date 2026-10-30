# Logging Standards — All Platforms

> **Applies to:** React, Flutter, Android (Kotlin), iOS (Swift)

## Log Levels

| Level | When to use |
|---|---|
| `debug` | Detailed flow info — dev/sit only, never prod |
| `info` | Key business events (user logged in, order created) |
| `warn` | Recoverable issues (retry attempt, fallback used) |
| `error` | Failures that need attention (API error, crash) |

## Security Rules

**NEVER log:** passwords, tokens, API keys, full credit card numbers, passport numbers, OAuth codes

**Safe to log:** user ID, error codes, endpoint paths, timestamps, durations

## Rules

1. Never use `print()`, `console.log()`, `println()` directly — always use the project logger
2. `debug` logs MUST be disabled in production builds
3. Sensitive data MUST never appear in any log level
4. Every `error` log MUST include the original exception/error object
5. In production, error logs SHOULD be forwarded to a monitoring service (Sentry, Firebase Crashlytics)
