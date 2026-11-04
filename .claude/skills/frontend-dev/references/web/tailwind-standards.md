# Tailwind CSS v4 Standards

Guidelines for using Tailwind CSS v4 with Vite native plugin.

## Design System
- Use Tailwind's default theme with custom overrides in CSS
- Prefer semantic classes: `text-blue-600`, `bg-slate-50`
- Consistent spacing: `p-4`, `m-2`, `gap-4`

## Responsiveness
- Mobile first: default styles for mobile, then `md:`, `lg:` for larger screens
- Use `flex` and `grid` classes for layouts — avoid raw CSS positioning

## Best Practices
- Utility first: avoid `@apply` unless absolutely necessary for component reusability
- Never construct class names dynamically: `text-${color}-500` ❌ — use full class names or mapping objects
- Support dark mode using the `dark:` variant

## Integration
- Plugin: `@tailwindcss/vite` in `vite.config.js`
- Entry point: `src/index.css` using `@import "tailwindcss";`
