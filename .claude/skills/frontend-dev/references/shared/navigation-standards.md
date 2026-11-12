# Navigation & Deep Link Standards — All Platforms

> **Applies to:** React, Flutter, Android (Kotlin), iOS (Swift)

## Route Naming Convention

Use **kebab-case path segments**, hierarchical, noun-based:

```
/[system]/[feature]
/[system]/[feature]/[id]
/[system]/[feature]/[id]/[sub-feature]
```

### Rules
- Use kebab-case — no camelCase, no underscores
- Use nouns — not verbs (`/flights/search` not `/searchFlights`)
- Dynamic segments use `:paramName` convention
- Keep hierarchy max 3 levels deep

## Deep Link Scheme

```
[app-scheme]://[system]/[feature]/[id]
```

## Rules

1. Route paths MUST be defined in a single constants file per platform — never hardcoded inline
2. Route naming MUST follow kebab-case and noun-based convention
3. Dynamic segments MUST use `:paramName` pattern consistently across all platforms
4. Deep link scheme MUST be agreed upon before implementation and consistent across Android and iOS
5. Navigation MUST go through the coordinator/router — never direct view instantiation across features
