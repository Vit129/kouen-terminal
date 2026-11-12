# Environment Config Standards — All Platforms

> **Applies to:** React, Flutter, Android (Kotlin), iOS (Swift)
> **Purpose:** Manage environment-specific configuration (API URLs, feature flags, keys) consistently and securely across all platforms.

---

## Environments

| Env | Purpose |
|---|---|
| `local` | Developer's local machine |
| `sit` | System Integration Testing (default for QA) |
| `uat` | User Acceptance Testing |
| `prod` | Production |

---

## What Goes Where

| Type | Location | Examples |
|---|---|---|
| Sensitive | CI/CD secrets only — never in repo | passwords, API keys, OAuth secrets |
| Non-sensitive config | Environment config file | BASE_URL, FEATURE_FLAGS, TIMEOUT |
| Business test data | Fixture / constants file | companyCode, productCode, test user roles |

> ⚠️ Never commit sensitive values to the repository — use CI/CD secret injection.

---

## Key Naming Convention

Use `SCREAMING_SNAKE_CASE` for all config keys:

```
BASE_URL
API_TIMEOUT_MS
FEATURE_FLAG_DARK_MODE
CLIENT_ID
```

---

## Platform Implementation

### React / Web

```bash
# .env.sit
VITE_BASE_URL=https://api-sit.example.com
VITE_API_TIMEOUT_MS=10000
VITE_FEATURE_FLAG_DARK_MODE=false
```

```typescript
// config.ts — single access point
export const config = {
  baseUrl: import.meta.env.VITE_BASE_URL,
  apiTimeoutMs: Number(import.meta.env.VITE_API_TIMEOUT_MS),
  featureFlags: {
    darkMode: import.meta.env.VITE_FEATURE_FLAG_DARK_MODE === 'true',
  },
}
```

> Never access `import.meta.env` directly in components — always go through `config.ts`.

---

### Flutter

```bash
flutter run --dart-define=BASE_URL=https://api-sit.example.com \
            --dart-define=API_TIMEOUT_MS=10000
```

```dart
class AppConfig {
  static const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:3000');
  static const apiTimeoutMs = int.fromEnvironment('API_TIMEOUT_MS', defaultValue: 10000);
}
```

---

### Android (Kotlin)

```groovy
android {
    flavorDimensions += "env"
    productFlavors {
        sit {
            buildConfigField "String", "BASE_URL", '"https://api-sit.example.com"'
        }
        uat {
            buildConfigField "String", "BASE_URL", '"https://api-uat.example.com"'
        }
    }
}
```

```kotlin
object AppConfig {
    val baseUrl: String = BuildConfig.BASE_URL
}
```

---

### iOS (Swift)

```swift
enum AppConfig {
    static let baseUrl: String = Bundle.main.infoDictionary?["BASE_URL"] as? String ?? "http://localhost:3000"
}
```

---

## Rules

1. Every platform MUST have a single `AppConfig` / `config.ts` access point
2. Sensitive values MUST use CI/CD secret injection — never hardcoded
3. All keys MUST use `SCREAMING_SNAKE_CASE`
4. Default values MUST point to `local` or `sit` — never `prod`
