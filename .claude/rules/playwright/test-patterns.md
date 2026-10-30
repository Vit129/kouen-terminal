# Test structure by design technique

> Parent: `rules/playwright/pw-coding-standards.md`. Load only when implementing scenarios designed with Base-Choice, Pairwise (MC), State Transition or W-method. EP and BVA need no special pattern (plain arrange → act → assert with inline values).

## Base-Choice (1 base E2E + N one-parameter variations)

- Base test first, titled `[Base]`; variations titled `[Variation]`.
- Variations via spread override `{ ...baseData, ...v.override }` in a `for...of` loop (not `test.describe.each`, reports read better).
- A boundary variation that must fail carries `expectFail` and asserts 400.

## Multiple-Choice / pairwise (data-driven)

- The combination matrix is generated outside test code (PICT output) and committed as `fixtures/[system-kebab]/[feature]Combinations.json`. Never generate combinations inside a test.
- Each combo has `label`, `data`, `expectedStatus`; one `test()` per combo titled `[Combo]`.

## State Transition

- Reach the starting state through `setupInState(targetState)` in `helpers/[feature]Helper.ts`; never navigate the UI to a state.
- Each test asserts the new state and its side effects (timestamps, notifications). Invalid transitions assert rejection (422/400) with a clear error message. Titles tagged `[State]`.

## Transition tree / W-method

- Paths are a committed JSON fixture generated from the FSM diagram: `fixtures/[system-kebab]/transitionTreePaths.json`, each `{ label, steps: [{ fromState, event, toState }], finalState, verify: [{ field, expected }] }`.
- The state model diagram must exist in `implementation-plan-{feature}.md` (next to the specs) before writing path fixtures.
- One generic walker loop over the paths via `triggerEvent`; never hard-code state sequences in test code. Titles tagged `[W-method]`.

## Stateful helper requirements

- One helper per stateful feature with `setupInState(targetState)` (fastest API path, no UI) and `triggerEvent(id, event)`; register it as a Playwright fixture.

## Security tests

Tag `@Security`, fixtures in `fixtures/security/` (permissionMatrix, injectionPayloads, expiredTokens), pipeline `continueOnError: false`. Full rules: the `security` skill; load it when the feature has auth, permissions or user input.
