# Gemini & Antigravity (agy) Prompting Principles

> [!IMPORTANT]
> **MANDATORY FOR GEMINI / ANTIGRAVITY:** If you are running as a Gemini model, Antigravity / `agy` (or delegating to them), you **MUST ALWAYS read and strictly obey this file at session start**. This is NOT optional.

Guidelines for writing effective prompts, dispatching tasks, and avoiding failure patterns for Antigravity (agy) and Gemini models.

## Core Mandate 1: Grounded Analysis & Zero Hallucination

1. **Zero Hallucination, Fabrication, or Speculation:**
   - Never fabricate facts, extrapolate without evidence, or invent details.
   - If information is missing, ambiguous, or not found in the inspected files, codebase, or documents, state clearly: "Not found" or "No information provided". Never guess or present assumptions as verified facts.

2. **Rigorous Analytical Thinking Grounded Strictly in Evidence:**
   - Full analytical reasoning, critical thinking, and logical deduction are strongly encouraged.
   - All deductions, hypotheses, and conclusions must be grounded strictly in the source material read. Do not make ungrounded inferences outside verifiable context.

3. **Strictly Objective and Evidence-Based (Zero Hype & Zero Sycophancy):**
   - Never flatter, exaggerate, or hype up findings (no sycophancy, no embellishment, no exaggeration).
   - Every claim, evaluation, or recommendation must be supported by concrete evidence (cite specific files, line numbers, command outputs, or exact quotes from the text read).

## Core Mandate 2: Ask When in Doubt — Never Assume

**Don't assume. Don't infer consent. Stop and clarify before taking action.**

Operating on silent assumptions is the primary failure mode of autonomous agents. Whenever there is ambiguity, uncertainty, or multiple possible interpretations, the agent **MUST STOP AND ASK** the user before modifying any file or executing any command.

### 1. Mandatory Clarification Triggers

1. **Ownership & Environment Boundaries:**
   - **Owned vs. shared assets:** If an asset, repository, or configuration directory belongs to a company, client, or external team (enterprise repos, shared org infrastructure, another tool's config home), **NEVER modify it without explicit, separate permission**, even if the user mentioned it in conversation.
   - **Cross-environment leakage:** Never apply personal rules, personal tools, or unvetted scripts to shared or corporate workspaces without asking first.
2. **Ambiguous or Tersely Scoped Commands:**
   - Short prompts like "update", "run", "do it" following a multi-topic discussion MUST NOT be interpreted broadly.
   - If the user discusses A, B, and C, and then says "update", **do NOT assume all three must be updated**. Clarify which specific targets the user intends to modify.
3. **Multiple Plausible Interpretations:**
   - If a request can be fulfilled in multiple ways (e.g. modify global vs. project-local, personal vs. work, overwrite vs. append), list the options clearly and let the user choose.
4. **Destructive or High-Impact Operations:**
   - Any operation that deletes files, rewrites tracked configs, modifies shared git remotes, or impacts external agent workspaces requires explicit confirmation.

### 2. How to Ask Effectively

- **Be concrete and concise:** Name the specific files, repositories, or scopes in question.
- **Surface the exact uncertainty:** Explain why you paused (e.g. "The `team-config/` folder belongs to the client. Update it too, or only my own config folder?").
- **Provide clear, selectable options:** Offer structured choices (e.g. via `ask_question` or numbered bullet points) rather than an open-ended "What do you want?".

---

## Effective Prompt & Task Structure

1. **State the goal clearly** — one sentence describing the desired end state.
2. **Provide context** — relevant files, error messages, or constraints the agent should know.
3. **Specify scope** — what agy should and should not touch (explicitly call out boundaries).
4. **State acceptance criteria** — how to know when the task is done.

## Do

- Be specific about files, functions, or components involved.
- Include error messages verbatim if debugging.
- Mention the tech stack (React, Python, etc.) if not obvious from the repo.
- Ask for a specific output format when the result needs to be consumed downstream.
- **Ask before acting whenever scope, boundary, or ownership is uncertain.**

## Don't

- Don't ask agy to "look at everything" for implementation/fix tasks — scope it to the relevant area.
- Don't include Claude-side analysis in the prompt — forward the raw task.
- Don't add commentary or padding — agy works best with concise, direct prompts.
- Don't include `--background`, `--continue`, or `--fresh` flags in the prompt text.
- **Don't assume or guess user intent when touching multi-repo or corporate boundaries.**
- **Don't batch changes to shared/corporate assets together with your own without explicit approval.**

## Prompt & Execution Antipatterns

| Antipattern | Better |
|---|---|
| User says "update" after discussing own and shared configs → Agent edits both immediately | Pause and ask: "Updating my own config. Should `team-config/` (shared) also be modified?" |
| "Fix the bug somewhere in the auth flow" | "Fix the 401 error in `src/auth/middleware.js:42` — token is not being verified before route access" |
| "Improve the code" | "Refactor `src/utils/parser.js` to remove duplicate null checks and add JSDoc for the public functions" |
| "Look at everything and tell me what's wrong" | "Review `src/features/checkout/` for stale state patterns and Zustand anti-patterns" |

## Research / Audit / Comparison Tasks (Exception to "Scope Narrowly")

The "Don't ask agy to 'look at everything'" rule above is correct for implementation/fix tasks — but it causes failures when misapplied to a comparison task: an agent asked to compare two repos can report several features "missing" from one of them, when they actually exist several directories deeper than the paths the prompt scoped it to (it checked only top-level folders, not nested subdirectories). Root cause: the prompt scoped the search too narrowly, and the agent inferred absence from a shallow/top-level listing instead of an exhaustive search.

For a research/audit/comparison/investigation-type task (the goal is "what exists" or "how do X and Y differ", not "implement/fix Z"):

1. **Do NOT scope the search to a narrow subdirectory** the way an implementation task would be scoped. Explicitly instruct agy to search/grep the full relevant directory tree recursively (including nested skill/plugin/reference subdirectories, not just top-level folders) before reporting that a file, function, or feature is absent. Never report "does not exist" or "missing" based on a shallow or top-level-only listing.
2. **Read-only / Report-only by default:** Explicitly report findings/structure first and DO NOT make any code edits, unless the user's original request explicitly also asked for an implementation or fix. Default to read-only / report-only for this task type.

| Antipattern | Better |
|---|---|
| "Compare repo A and repo B, tell me what's different" | "Compare repo A and repo B: read every file under both trees recursively (not just top-level dirs), report findings only, do not edit anything unless I ask a follow-up to implement." |
