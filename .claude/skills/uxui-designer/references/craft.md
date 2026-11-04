# Craft Flow

Build a feature with impeccable UX and UI quality: shape the design, load references, build and iterate visually.

## Step 1: Shape the Design

Gather design context and create a design brief covering:
- Purpose and audience
- Aesthetic direction and tone
- Key states and interactions
- Recommended references to load

Wait for the brief to be confirmed before proceeding.

## Step 2: Load References

Based on the brief, always consult:
- `spatial-design.md` for layout and spacing
- `typography.md` for type hierarchy

Then add based on needs:
- Complex interactions/forms → `interaction-design.md`
- Animation/transitions → `motion-design.md`
- Color-heavy/themed → `color-and-contrast.md`
- Responsive requirements → `responsive-design.md`
- Heavy on copy/labels/errors → `ux-writing.md`

## Step 3: Build

Work in this order:
1. Structure first (HTML/semantic, no styling)
2. Layout and spacing
3. Typography and color
4. Interactive states (hover, focus, active, disabled)
5. Edge case states (empty, loading, error, overflow)
6. Motion (purposeful transitions)
7. Responsive adaptation

During build:
- Test with real/realistic data, not placeholder text
- Check each state as you build it
- Every visual choice should trace back to the design brief

## Step 4: Visual Iteration

Do NOT stop after the first pass. Check:
1. Does it match the brief?
2. Does it pass the AI slop test?
3. Check against anti-pattern guidelines
4. Check every state (empty, error, loading)
5. Check responsive behavior
6. Check details (spacing, type hierarchy, contrast, motion)

Repeat until you would be proud to show it.

## Step 5: Present

Show the feature, walk through key states, explain design decisions, ask for feedback. Iterate.
