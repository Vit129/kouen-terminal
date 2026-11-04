# Extract Flow

Identify reusable patterns, components, and design tokens, then consolidate into the design system.

## Step 1: Discover the Design System

Find the design system, component library, or shared UI directory. Understand its structure, naming conventions, token structure.

If no design system exists, ask before creating one.

## Step 2: Identify Patterns

Look for:
- Repeated components (3+ times)
- Hard-coded values that should be tokens
- Inconsistent variations of the same concept
- Composition patterns (form rows, toolbar groups, empty states)
- Type styles (repeated font-size + weight + line-height)
- Animation patterns (repeated easing, duration, keyframes)

Only extract things used 3+ times with the same intent.

## Step 3: Plan Extraction

- Components to extract
- Tokens to create
- Variants to support
- Naming conventions matching existing patterns
- Migration path for existing uses

## Step 4: Extract & Enrich

- Components: clear props API, proper variants, accessibility built in, documentation
- Design tokens: clear naming (primitive vs semantic), proper hierarchy
- Patterns: when to use, code examples, variations

## Step 5: Migrate

Replace existing uses with shared versions. Test for visual and functional parity. Delete dead code.

## Step 6: Document

Update component library, document token usage, add examples and guidelines.

## Never

- Extract one-off implementations without generalization
- Create components so generic they're useless
- Skip TypeScript types or prop documentation
- Create tokens for every single value (tokens need semantic meaning)
- Extract things that differ in intent
