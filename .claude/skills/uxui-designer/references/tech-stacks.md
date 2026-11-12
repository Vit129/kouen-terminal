# Supported Tech Stacks

Design system recommendations tailored to each platform's conventions and constraints.

---

## Web Frameworks

### HTML + Tailwind CSS
- **Primary Use**: Static sites, rapid prototyping, utility-first design
- **Design System Output**:
  - Tailwind config (colors, spacing, typography)
  - Component CSS classes
  - Dark mode config
- **Best For**: Quick iteration, teams familiar with utility CSS
- **Accessibility**: Native semantic HTML + aria utilities

### React
- **Primary Use**: Interactive single-page apps, component libraries
- **Design System Output**:
  - Component .jsx files with styled-components / CSS modules
  - Prop-based theming (color, size, variant)
  - TypeScript definitions
  - Storybook stories
- **Best For**: Complex applications, design token reusability
- **State Management**: CSS-in-JS, styled-components, Emotion

### Next.js
- **Primary Use**: Full-stack React apps, SEO-optimized sites
- **Design System Output**:
  - App router & pages router examples
  - CSS modules + globals
  - Dark mode with next-themes
  - Server components (if App Router)
- **Best For**: Production applications, API integration
- **Performance**: Server-side rendering, static generation

### shadcn/ui
- **Primary Use**: Rapid component building on Radix + Tailwind
- **Design System Output**:
  - Copy-paste component code (customizable)
  - Tailwind-based variants (size, color, state)
  - Composition patterns (compound components)
- **Best For**: Standardized component library, Tailwind-first teams
- **Customization**: Full source control, no npm dependency

### Vue
- **Primary Use**: Progressive enhancement, reactive UIs
- **Design System Output**:
  - Single-file components (.vue)
  - Composition API examples
  - Options API examples
  - Scoped styles + CSS modules
- **Best For**: Flexible app architecture, gradual adoption
- **Reactivity**: Ref/reactive system, computed properties

### Nuxt
- **Primary Use**: Full-stack Vue apps, universal rendering
- **Design System Output**:
  - Nuxt components (auto-registering)
  - Composables (reusable logic)
  - Layouts (global structure)
  - Plugins (setup utilities)
- **Best For**: Server-rendered Vue, file-based routing
- **Performance**: Automatic code splitting, pre-rendering

### Svelte
- **Primary Use**: Compiler-based, minimal JavaScript
- **Design System Output**:
  - Svelte components (.svelte)
  - Stores (reactive state)
  - Transitions & animations (built-in)
  - Scoped styles (automatic)
- **Best For**: Performance-critical apps, small bundle size
- **DX**: True reactivity, no virtual DOM

### Astro
- **Primary Use**: Content-focused static sites + islands
- **Design System Output**:
  - Astro components (.astro)
  - Framework integrations (React, Vue, Svelte)
  - Markdown layouts
  - Static asset optimization
- **Best For**: Blogs, marketing sites, content platforms
- **Performance**: Zero JavaScript by default, selective hydration

### Angular
- **Primary Use**: Enterprise applications, large teams
- **Design System Output**:
  - Angular components (TypeScript, templates)
  - Services (business logic)
  - Directives & pipes
  - Module structure
- **Best For**: Structured architecture, dependency injection
- **Conventions**: Strict patterns, comprehensive tooling

### Laravel
- **Primary Use**: Server-rendered PHP apps
- **Design System Output**:
  - Blade templates (components, slots)
  - Tailwind integration
  - Livewire components (if applicable)
  - JavaScript integration (Inertia, Alpine)
- **Best For**: Monolithic backends, rapid development
- **Integration**: Seamless backend coupling, session management

---

## Mobile & Native

### SwiftUI
- **Primary Use**: iOS/macOS native apps
- **Design System Output**:
  - View structs with modifiers
  - Color/typography extensions
  - Container patterns
  - Accessibility modifiers
- **Best For**: Native iOS experience, Apple design conventions
- **Language**: Swift 5.x, Xcode

### Jetpack Compose
- **Primary Use**: Android native apps (Kotlin)
- **Design System Output**:
  - Composable functions
  - Material 3 theme configuration
  - Shape, color, typography theming
  - State management patterns
- **Best For**: Modern Android development, Material Design
- **Language**: Kotlin, Android Studio

### React Native
- **Primary Use**: Cross-platform (iOS + Android)
- **Design System Output**:
  - Native components (View, Text, ScrollView)
  - Platform-specific overrides (.ios.js / .android.js)
  - StyleSheet patterns
  - Navigation structure (React Navigation)
- **Best For**: Code sharing across mobile platforms
- **Caveat**: Learn platform conventions; not "write once, run anywhere"

### Flutter
- **Primary Use**: Cross-platform (iOS + Android + Web)
- **Design System Output**:
  - Dart widgets
  - ThemeData configuration
  - Material Design patterns
  - Custom painters (for complex graphics)
- **Best For**: Pixel-perfect apps, strong design control
- **Language**: Dart, Flutter SDK

---

## Design Token Output Format

All stacks receive (in priority order):

1. **Colors**
   - Semantic (primary, secondary, danger, success, info, warning)
   - Component-specific (button, card, input variants)
   - Dark mode overrides

2. **Typography**
   - Font families (headline, body, code)
   - Font sizes (scale: 12px–48px)
   - Font weights (300, 400, 600, 700)
   - Line heights (1.4–1.8)
   - Letter spacing

3. **Spacing**
   - Base unit (8px or 4px)
   - Scale: xs (4px) → 3xl (48px)
   - Padding, margin, gap standards

4. **Shape**
   - Border radius (none, sm, md, lg, full)
   - Stroke widths

5. **Shadows**
   - Elevation scale (0–24)
   - Color + blur + offset values

6. **Animations**
   - Duration (fast: 150ms, normal: 300ms, slow: 500ms)
   - Easing (ease-in, ease-out, ease-in-out, cubic-bezier)

---

## Platform-Specific Recommendations

| Stack | Best For | Bundle Size | Learning Curve | Community |
|-------|----------|-------------|-----------------|-----------|
| **React** | Complex UIs, teams | Medium | Moderate | Very Large |
| **Next.js** | Full-stack, SEO | Medium | Moderate | Large |
| **Vue** | Flexible, gradual | Medium | Low | Large |
| **Svelte** | Minimal JS, perf | Small | Low | Growing |
| **Angular** | Enterprise, structure | Large | High | Enterprise |
| **Flutter** | Cross-platform, native | Medium | High | Growing |
| **React Native** | iOS + Android sync | Large | Moderate | Large |
| **SwiftUI** | iOS-first, native | Small | Moderate | Large |

---

*Total Supported Stacks: 15*
