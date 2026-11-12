# UI States Standards — All Platforms

> **Applies to:** React, Flutter, Android (Kotlin), iOS (Swift)
> **Purpose:** Every screen/component that loads async data MUST handle all 4 states consistently.

---

## The 4 Mandatory States

| State | When | User sees |
|---|---|---|
| **Loading** | Data is being fetched | Skeleton / spinner |
| **Success** | Data loaded successfully | Content |
| **Empty** | Request succeeded but no data | Empty state message + action |
| **Error** | Request failed | Error message + retry |

> ⚠️ Empty and Error are different states — never combine them.

---

## Test Identifier Requirements

| State | Required testId |
|---|---|
| Loading | `[feature]-loading` |
| Success | `[feature]-content` (or the content itself) |
| Empty | `[feature]-empty-state` |
| Error | `[feature]-error-state` |

---

## State Model Pattern (All Platforms)

```typescript
// TypeScript
type UiState<T> =
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'empty' }
  | { status: 'error'; message: string }
```

```kotlin
// Kotlin
sealed class UiState<out T> {
    object Loading : UiState<Nothing>()
    data class Success<T>(val data: T) : UiState<T>()
    object Empty : UiState<Nothing>()
    data class Error(val message: String) : UiState<Nothing>()
}
```

```swift
// Swift
enum UiState<T> {
    case loading
    case success(T)
    case empty
    case error(String)
}
```

---

## Rules

1. Every screen/component loading async data MUST implement all 4 states — no exceptions
2. Loading state MUST show skeleton or spinner — never a blank screen
3. Empty and Error states MUST be separate — different message, different testId
4. Error state MUST include a retry action where applicable
5. State model MUST use a typed sealed class / union type — no boolean flags like `isLoading`, `isError`
