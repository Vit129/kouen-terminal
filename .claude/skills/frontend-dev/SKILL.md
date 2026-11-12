---
name: frontend-dev
description: >
  Thai triggers: "ทำหน้าเว็บ", "เขียน component", "ทำ UI ตาม design", "ทำแอป React/Flutter".
  This skill should be used when the user asks to "build a React app",
  "create a Flutter widget", "set up Tailwind",
  "configure Vite", "build Android Kotlin UI",
  "build iOS Swift UI", "write a component",
  "implement this design in code", "implement design", "set up Next.js",
  "use Server Components", "use React 19 hooks", "use useActionState", "use useOptimistic",
  or needs frontend development guidance for web or mobile applications.
  Use this for IMPLEMENTATION (how to code it), not design decisions (what to build).
version: 1.0.1
---

# Frontend Development


Build and maintain frontend applications across web and mobile.

Use this skill to implement components in code (React, Next.js, Tailwind, Flutter, native).
Use `uxui-designer` first if design tokens, visual language, or component specs haven't been defined yet.

## When to Load Each Reference

| User says | Load |
|-----------|------|
| "React component", "hooks", "state management", "React 19", "useActionState", "useOptimistic" | `references/web/react.md` |
| "Next.js", "App Router", "Server Components", "Server Actions", "RSC", "streaming" | `references/web/nextjs.md` |
| "Tailwind", "utility classes", "Tailwind v4", "Vite + Tailwind" | `references/web/tailwind-standards.md` |
| "code review", "review frontend code", "check quality", "audit code" | `references/shared/frontend-code-review.md` |
| "env config", "environment variables", "feature flags" | `references/shared/env-config-standards.md` |
| "error handling", "error boundary", "catch error" | `references/shared/error-handling-standards.md` |
| "logging", "logger", "log levels" | `references/shared/logging-standards.md` |
| "navigation", "routing", "deep link" | `references/shared/navigation-standards.md` |
| "testability", "data-testid", "accessibilityIdentifier", "testTag" | `references/shared/testability-standards.md` |
| "loading state", "empty state", "error state", "UI states" | `references/shared/ui-states-standards.md` |

## Web
- **React** — Component design, hooks, React 19 new hooks (useActionState, useOptimistic, useFormStatus). (Read `references/web/react.md`)
- **Next.js 15** — App Router, Server Components, Server Actions, streaming, middleware. (Read `references/web/nextjs.md`)
- **Tailwind CSS** — Tailwind v4 utility classes and best practices, including the Vite plugin integration point. (Read `references/web/tailwind-standards.md`)

## Mobile
No Android/iOS native skill exists in this workspace (removed — no active native mobile project,
low usage; the model's own Kotlin/Swift knowledge covers ad-hoc needs). No Flutter skill either
(deliberately not added — audited as generic best-practice only, no non-obvious convention worth
a dedicated skill). For a native mobile or Flutter task, fall back to `rules/ai-sdlc-workflow.md`/general
`rules/coding.md` conventions and match the existing repo's patterns.

## Shared Standards (All Platforms)
- **Frontend Code Review** — Static audit checklist for all platforms: architecture, UI states, testability, error handling. (Read `references/shared/frontend-code-review.md`)
- **Env Config** — Environment variables, feature flags, secrets management. (Read `references/shared/env-config-standards.md`)
- **Error Handling** — Error categories, logging, user-friendly messages. (Read `references/shared/error-handling-standards.md`)
- **Logging** — Log levels, format, security rules. (Read `references/shared/logging-standards.md`)
- **Navigation** — Route naming, deep links, navigation patterns. (Read `references/shared/navigation-standards.md`)
- **Testability** — data-testid, accessibilityIdentifier, testTag naming conventions. (Read `references/shared/testability-standards.md`)
- **UI States** — Loading, Success, Empty, Error state patterns. (Read `references/shared/ui-states-standards.md`)

## Inline Process

1. **Check prerequisites** — If design tokens/component specs don't exist yet, use `uxui-designer` skill first. This skill is for IMPLEMENTATION, not design decisions.
2. **Identify the stack** — Match to ONE platform. React/Next.js 15/Tailwind CSS/Vite → load the corresponding `references/web/` reference. Android Kotlin/iOS Swift/Flutter → no dedicated reference exists (see Mobile section below) — apply general Kotlin/Swift/Dart knowledge plus the Shared Standards and `references/shared/frontend-code-review.md`'s Platform-Specific Checks.
3. **Implement with testability** — Add `data-testid` on ALL interactive elements during component creation. Use platform equivalents: `accessibilityIdentifier` (iOS), `testTag` (Android).
4. **Handle all 4 UI states** — Every component must handle: Loading, Success, Empty, and Error states. These are part of the component contract, not polish for later.
5. **Write LLM-friendly comments** — Non-trivial functions get JSDoc/TSDoc with: what + why + who calls + params/return/throws.
6. **Follow platform patterns** — React 19: useActionState, useOptimistic. Next.js 15: Server vs Client Components. Mobile: MVVM, proper state management.
7. **Apply shared standards** — Environment config, error handling, logging, navigation, fresh provider/store per test.
8. **Verify build** — `data-testid` present, all 4 UI states handled, build passes, TypeScript clean (`tsc --noEmit`).

## ⚠️ Gotchas

- **Gemini introduces bugs on logic-heavy edits** — Gemini tends to fix one bug and introduce another (e.g., `null` vs `[]` conditional logic). Fix: use Claude Sonnet for any task graded 🟡 Medium or above. Never hand off Gemini output to Claude without flagging the cost.
- **Component missing `data-testid`** — new components built without testability attributes break Playwright tests silently. Fix: always add `data-testid` during component creation, not as an afterthought.
- **State not reset between renders** — shared state (context, store) leaks between component renders in tests. Fix: wrap each test in a fresh provider/store instance.
- **Only success state handled** — components without loading/empty/error handling crash or show blank screens in production. Fix: all 4 UI states (Loading, Success, Empty, Error) are part of the component contract, not polish for later.
- **LLM-Friendly comments omitted** — agent writes code without intent comments, making future AI edits error-prone. Fix: every non-trivial function needs a comment block with what + why + who calls it.

## LLM-Friendly Code Comments

Write comments that AI agents can understand — not just humans:

```ts
// ❌ Old style (for humans only):
// validate input

// ✅ New style (for AI + humans):
// Validates user input against business rules before saving to DB.
// If validation fails, returns structured error with field-level messages.
// Called by: handleSubmit() in FormComponent.
```

**Principles:**
- State **what** + **why** + **who calls** — not just what
- Include context AI needs to edit correctly (dependencies, side effects, constraints)
- Function signatures: add JSDoc/TSDoc with params + return + throws
- Complex logic: add comment block before section explaining the business rule

---

## Anti-Rationalization Table

| Excuse to Skip | Counter-Argument |
|---|---|
| "I don't need to load the reference file — I know React/Next.js well enough" | References contain project-specific conventions (React 19 hooks like useActionState, Next.js 15 App Router patterns). Using outdated patterns from training data introduces inconsistencies. |
| "I'll use the same state management approach for all components" | Server Components, Client Components, and shared state have different patterns in Next.js 15. Using client-side state where server state suffices bloats the bundle and breaks streaming. |

---

## Red Flags

- 🚩 Test file creates components without wrapping in fresh provider/store → Shared state leaks between tests causing flaky failures; isolate each test's state.
- 🚩 Agent used Gemini for a logic-heavy edit without flagging the risk → Gemini introduces subtle bugs on medium+ complexity; escalate to Claude Sonnet for logic-heavy work.

---


## Consistency Contract

> These steps MUST execute in the same order every time this skill runs.
> Output may vary, but the workflow is fixed.
> If any step is skipped, document the skip condition explicitly.

## Verification

Before declaring frontend implementation complete, confirm:

- [ ] Correct `references/web/` reference loaded for React/Next.js/Tailwind/Vite — or, for Flutter/Kotlin/Swift (no dedicated reference exists), the Mobile-section fallback was applied
- [ ] No shared state leaking between component instances
- [ ] Build passes: `npm run build` / `flutter build` / `xcodebuild`
- [ ] TypeScript: `tsc --noEmit` clean


---

## Required Context

| Dependency | Type | Purpose |
|-----------|------|---------|
| Design system / component library | Design reference | Tokens, component specs, visual language |
| Existing component patterns in codebase | Source code | Match conventions, reuse patterns |
| `references/web/` | Reference docs | Web-specific implementation patterns (React/Next.js/Tailwind/Vite) |
| `uxui-designer` skill output (if exists) | Design spec | Component specs and design tokens |
| `rules/coding.md` & `rules/aodd.md` | Rule | Core engineering principles and verification gates |
| `rules/data-testid-mapping.md` | Rule | Canonical `data-testid` naming — `references/shared/testability-standards.md` implements it, doesn't redefine it |
| `knowledge/` | Lessons learnt | Check before execute |

Related: drive the implementation test-first (Red→Green), then review the diff before merge against `references/shared/frontend-code-review.md`'s checklist.

## Human-in-the-Loop Points

| Step | Approval Type | When |
|------|--------------|------|
| After component structure proposal | Checkbox (confirm hierarchy) | Before implementing component tree |
| After state management choice | Single select (local vs global vs server) | When multiple state approaches are valid |
| After UI states implementation | Open field | Review loading/empty/error state handling |

**Rule:** At decision points, always present 2-3 options with tradeoffs — never a single answer.

## Pitfalls (verified)

- **Service worker cache-first for JS/CSS** serves a stale bundle → two React copies → "Invalid hook call" on a normal refresh. Use network-first for `script`/`style` requests and bump the cache name so the SW reinstalls.
- **Stale closure when saving several items in a row:** a handler that reads list state from the render snapshot keeps only the last items. Read store state at call time (`store.getState().<list>`) or use a functional updater `prev => ...`.
- **Client key ≠ server key** (`VITE_API_KEY` vs the backend secret) → 401 only in production. Align them before deploy and verify in a fresh browser profile (the old bundle stays cached).
- **Chart.js plugins:** register per chart (`plugins: [plugin]` / `plugins={[plugin]}`), not globally — global plugin ids collide.
- **iOS Safari modal:** lock `overflow` on both `document.documentElement` and `document.body` on mount, restore on unmount, or the page behind scrolls.
- **Mobile full-height drawer:** use `100dvh` (not `100vh`) and `flex-shrink: 0` on children so it can scroll on short screens; only block touch-move when `scrollHeight == clientHeight`.

## Self-Update (after every use)

This skill is its own memory. When using it brought a correction, a gotcha,
or a wrong/missing step, and the fix was verified, patch this file in place: a UI/state pattern or pitfall goes in its section; depth goes to `references/<topic>.md`.
Then bump `version` (patch) and `last_improved`. Procedure: `docs/skill-learning.md`.
