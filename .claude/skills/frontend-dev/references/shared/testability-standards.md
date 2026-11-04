# Testability Standards — Test Identifier (All Platforms)

> **Applies to:** React, Flutter, Android (Kotlin), iOS (Swift)
> **Purpose:** Ensure every interactive or verifiable UI element has a stable test identifier.

Naming convention lives in `rules/data-testid-mapping.md` — **do not invent a different scheme
here**. This file only covers how to attach that identifier per platform; the identifier
*string itself* must follow `rules/data-testid-mapping.md`'s `{type-abbr}_{context+element-name}_{page-name}`
pattern (mobile: `{screen-name}` in place of `{page-name}`) so QA's `getByTestId()`/`accessibility_id`
locators match exactly what Dev implements — this is the dev→QA handoff contract (see `skills/ai-sdlc/references/dev-qa-handoff.md`).

---

## Platform Implementation

### React / Web
Use `data-testid` attribute:
```tsx
<button data-testid="btn_searchFlights_flightSearchPage">Search</button>
<ul data-testid="tbl_flightResults_flightSearchPage">
  {flights.map(f => (
    <li key={f.id} data-testid={`lbl_flightResultItem-${f.id}_flightSearchPage`}>...</li>
  ))}
</ul>
```

### Flutter
```dart
Semantics(identifier: 'btn_searchFlights_flightSearchScreen', child: ElevatedButton(...))
```

### Android (Compose)
```kotlin
Button(modifier = Modifier.testTag("btn_searchFlights_flightSearchScreen"), onClick = {}) { Text("Search") }
```

### iOS (SwiftUI)
```swift
Button("Search") {}.accessibilityIdentifier("btn_searchFlights_flightSearchScreen")
```

---

## What Needs a Test Identifier

| Element Type | Required |
|---|---|
| Buttons (submit, action, navigation) | ✅ Mandatory |
| Form inputs, selects, checkboxes | ✅ Mandatory |
| Result lists / tables | ✅ Mandatory |
| Individual list/table items | ✅ Mandatory (with `{id}`) |
| Status indicators, banners, badges | ✅ Mandatory |
| Modal dialogs, confirmation panels | ✅ Mandatory |
| Static decorative elements | ❌ Not needed |

## i18n / multi-language

- The identifier itself is always English, per `rules/data-testid-mapping.md`'s naming rules
- QA keeps UI labels in `[systemFeature]Labels.ts` separate from business data

```typescript
export const flightBookingLabels = {
  de: { btnSelectFlight: 'Auswählen', btnSearchFlights: 'Flüge suchen' },
  en: { btnSelectFlight: 'Select', btnSearchFlights: 'Search Flights' },
}
const L = flightBookingLabels[process.env.LANG ?? 'en']
await page.getByTestId('lbl_flightResultItem-FL001_flightSearchPage')
         .getByRole('button', { name: L.btnSelectFlight }).click()
```

## Rules

1. Test identifiers are **for testing only** — never use in CSS, JS logic, or styling
2. Names **must match exactly** what `rules/data-testid-mapping.md` and the Logical Design spec define — don't shorten or reshape them per component
3. **PR will not be approved** if new interactive components are missing test identifiers
4. Dynamic list items **must include the item ID** — never use index (`item-0`, `item-1`)
5. Identifier names must be **identical across Android and iOS** for shared keyword support
6. All identifier names MUST be in **English**, following `rules/data-testid-mapping.md`'s
   `{type-abbr}_{context+element-name}_{page/screen-name}` pattern — never Thai text, never a
   different casing/shape invented per component
