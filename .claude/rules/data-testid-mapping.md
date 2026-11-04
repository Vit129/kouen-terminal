# data-testid Naming Convention

## Contents

- [Pattern](#pattern)
- [Type Abbreviation Table](#type-abbreviation-table)
- [Naming Rules](#naming-rules)
- [Shared Components](#shared-components)
- [Usage](#usage)
- [Mobile (Robot Framework + Appium)](#mobile-robot-framework--appium)

Naming rule for `data-testid` values used with `getByTestId` (Locator Strategy #1). Applies whenever a new `data-testid` is being named — either by hand or when asking a dev to add one to a component.

Shared between `playwright-testing` (web, `data-testid`) and `robotframework-testing` (native
mobile, `accessibility_id` — see `rules/robot/android.md`/`ios.md`'s Locator Priority #1). One
naming pattern across web and mobile keeps the same element type/context/screen legible in
either automation layer, instead of drifting into ad-hoc per-platform IDs.

## Pattern

```
data-testid = "{type-abbr}_{context+element-name}_{page-name}"
```

Examples:
```
btn_searchPermission_searchMapPermissionPage
txt_searchKeyword_searchMapPermissionPage
tbl_permissionMatrix_searchMapPermissionPage
chk_perm-0-ADMIN_PLANT-view_searchMapPermissionPage
icn_deletePerm-0_searchMapPermissionPage
```

## Type Abbreviation Table

| Type | Use for | Rationale |
|------|---------|-----------|
| `btn` | Any button | clickable |
| `txt` | Text/email/password/search input | typeable |
| `cmb` | Dropdown/Select | pick from list |
| `mcmb` | Multi-select combobox | pick multiple from list |
| `chk` | Checkbox | tick/untick |
| `rdo` | Radio button | pick one of a group |
| `lbl` | Dynamic text that needs asserting | displays info |
| `tbl` | Table | displays data rows |
| `dlg` | Modal/Dialog/Popup | popup container |
| `nav` | Menu/Sidebar/Breadcrumb | navigation |
| `tst` | Toast/Notification | transient alert |
| `crd` | Card | container for one item |
| `lnk` | Clickable link | navigates to another page |
| `tab` | Tab | switches section |
| `icn` | Icon-only button (no text) | clickable, no label |
| `frm` | Form container | wraps form elements |

Pick the abbreviation by what the element does:
```
clickable            → btn, lnk, icn, tab
typeable/selectable   → txt, cmb, mcmb, chk, rdo
displays data         → lbl, tbl, crd
container             → dlg, nav, frm, tst
```

## Naming Rules

1. Three underscore-separated segments: `{type}_{context+element-name}_{page-name}`
2. Type abbreviation always comes first: `btn_submitOrder_bookListPage`
3. Context+element-name is camelCase: `searchPermission`, `deleteRow-0`
4. Page name is camelCase with a `Page` suffix: `searchMapPermissionPage`, `createNewUserPage`
5. If a name collides across sections, add context to disambiguate: `txt_billingEmail` vs `txt_shippingEmail`
6. Dynamic elements use an index/id placeholder: `btn_actionEditRow-{N}_{page}`, `chk_perm-{index}-{roleId}-view_{page}`
7. Keep it short but legible

## Shared Components

Elements reused across every page of an app (toast, confirm dialog, nav sidebar, loading spinner, pagination) drop the `_{pageName}` suffix and use `_shared` instead:

```
tst_success_shared
dlg_confirm_shared
nav_sidebar_shared
```

Only elements that are genuinely app-wide (not just repeated on two pages) qualify — everything else keeps its page suffix.

## Usage

```typescript
await page.getByTestId('flight-result-item-FL001')
  .getByRole('button', { name: L.btnSelectFlight })
  .click()
```

`getByTestId` scopes to the container/dynamic item, `getByRole` targets the specific control inside it — see the Hybrid Locator Pattern above.

## Mobile (Robot Framework + Appium)

Same pattern, applied to `accessibilityIdentifier`/`content-desc` instead of `data-testid`:

```
accessibility_id = "{type-abbr}_{context+element-name}_{screen-name}"
```

```robotframework
Click Element    accessibility_id=btn_submitOrder_checkoutScreen
```

`{screen-name}` replaces `{page-name}` (mobile has screens, not pages) — same type abbreviations,
same segment order, same shared-component `_shared` suffix rule. Falls back to `resource-id`
(Android) only when `accessibility_id` genuinely can't be set — see `rules/robot/android.md`/`ios.md`'s
Locator Priority table for the full fallback order.
