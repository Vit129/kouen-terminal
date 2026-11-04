# Diversification Memory

[source:github.com/Nutlope/hallmark] — mechanism adapted from Hallmark's `.hallmark/log.json` + CSS-stamp diversification rule. Vocabulary translated to ui-designer's own axes (pattern/style/color/typography from `scripts/search.py`) instead of Hallmark's 21-theme/macrostructure catalog.

## Why this exists

Without memory, `--design-system` runs are stateless: two unrelated projects — or two pages in the same session — can land on the same pattern + style + color combination purely by BM25 coincidence, and nothing in the skill would notice or care. That's a structural repetition problem, distinct from the static Anti-Patterns (Hard Bans) list, which only bans generic *shapes* (card grids, cyan-on-dark, etc.) — it says nothing about "you already built this exact combination three builds ago for this project."

This file defines the state that closes that gap: a per-project log of what was generated before, a stamp that records the pick in the output itself, and a mandatory rotation check before every new pick.

## State file location

`.ui-designer/log.json` **at the root of the target project being designed** — never inside `$CLAUDE_HOME/skills/ui-designer/`. One ui-designer skill installation serves many different user projects; the memory must live with the project it describes, exactly like Hallmark's own `.hallmark/log.json` does for the codebase it's decorating.

Create `.ui-designer/` and the file on first write if they don't exist. Respect an existing `.gitignore` — don't fight the project's own convention on whether this file gets committed.

## Schema

JSON array, **newest entry first**:

```json
[
  {
    "date": "YYYY-MM-DD",
    "pattern": "Hero + Features + CTA",
    "style": "Minimalism & Swiss Style",
    "color_palette": "SaaS (General) — #2563EB primary",
    "typography": "Classic Elegant (Playfair Display / Inter)",
    "accent_hue_band": "cool",
    "inspo_reference": "mercury",
    "project": "<project name>",
    "brief": "<one-line summary of what was designed>"
  }
]
```

Field sources — each maps directly to a field ui-designer's own search results already produce, nothing new to compute except the hue band:

| Field | Comes from |
| ----- | ---------- |
| `pattern` | The `PATTERN` line of Design Mode Step 3's `--design-system` output (or macrostructure from Inspo `recommend`) |
| `style` | The `STYLE` line of the same output (or style from Inspo `recommend`) |
| `color_palette` | The `Product Type` + `Primary` hex from `data/colors.csv` (or Inspo palette suggestion) |
| `typography` | The `Font Pairing Name` from `data/typography.csv` / `google-fonts.csv` (or Inspo type ramp) |
| `accent_hue_band` | Bucket the accent/primary hex by eye: warm (red/orange/amber), cool (blue/indigo/cyan), neutral (desaturated/gray), or chromatic-other (green/purple/etc.) |
| `inspo_reference` | *(Optional)* The slug of the primary Inspo exemplar used (e.g. `"mercury"`, `"bandcamp"`), or `null` if local search was used |

Trim the file to the last 20 entries (drop the oldest) on every write.

## The diversification rule (mandatory)

Before committing to a pattern + style pick in Design Mode:

1. **Read `.ui-designer/log.json`** if it exists. If it doesn't, this is the first ui-designer run for this project — no constraint, state that plainly, and proceed (you'll create the file after this build).
2. Look at the **last 3–5 entries**.
3. Your new pick must differ from the immediately-previous entry on **at least one** of these axes:
   - **Pattern** — a different `Pattern Name` from `data/landing.csv`
   - **Style** — a different `Style Category` from `data/styles.csv`
   - **Accent hue band** — warm / cool / neutral / chromatic-other, per the bucket above
4. If the BM25 search's top result would repeat all three axes from the last entry, don't silently accept it — pull the next-ranked result from `--domain style` / `--domain color` (or re-run the design-system search with a `--domain` supplement) and pick a result that clears the rule. Never force variety onto industry-mandated choices (e.g. a finance dashboard genuinely calling for the same trust-blue palette twice) — when the industry rule and diversification rule conflict, state the conflict out loud and let the industry rule win, but say so explicitly rather than picking silently.

**State the rotation in plain text before picking** — this is the accountability line, same discipline as Hallmark's:

- **First-time** (no `log.json`): *"No prior ui-designer runs for this project — picking Hero + Features + CTA / Minimalism & Swiss Style fresh."*
- **Repeat project** (has entries): *"Last 3 builds: Hero+Features+CTA/Minimalism (warm) · Bento Grid/Neumorphism (neutral) · Hero+Features+CTA/Minimalism (warm). Pattern+style repeated twice — picking Split Hero / Brutalism (cool) this time to break the repetition."*

## Stamp the output

The first non-empty line of the generated CSS/tokens file (or the top of the `<style>` block if inline) must be a comment recording the pick:

```css
/* ui-designer · pattern: Hero + Features + CTA · style: Minimalism & Swiss Style · accent: cool */
```

This is the durable, in-code record — the next ui-designer run in this project can infer an entry from the stamp even if `.ui-designer/log.json` was deleted or never committed.

## Append to project memory

After stamping, append the new entry to the **front** of `.ui-designer/log.json` (create the file/dir if absent), trim to 20 entries. This is a normal Design Mode step — do it every time a design system is actually generated and delivered, not on exploratory searches that the user didn't commit to.

## Scope

- Applies to **Design Mode** page/system builds (Workflow Step 3 onward). Does not apply to single-component polish work (Implement Mode `/polish`, `/animate`, etc. on an existing component) — there's no new pattern/style pick to rotate.
- Applies to `redesign` (single-page flow) — see `references/redesign-verb.md`, which explicitly requires the new pick to differ from the log.
- **Does not apply** to a project with a locked `design-system/<project>/MASTER.md` or `DESIGN.md` (see Phase 0). Once a system is locked, the rule inverts: pages should match the locked system, not rotate away from it. Diversification only governs *picking a new system*, never *drifting from a settled one*.
