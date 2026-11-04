# Emerging Tech Industry Rules (20 Rules)

## Overview
Emerging tech covers products built on technology most users can't yet form intuitions about — Web3/NFT, spatial computing (AR/VR), quantum computing, autonomous robotics, conversational AI, and biotech/climate tech. Because the underlying mechanism is unfamiliar or unproven, every category in this group treats credibility signaling (real-time data, scientific rigor, transaction transparency) as load-bearing, not decorative — the anti-patterns list below is almost entirely about *not* papering over that unfamiliarity with generic or misleading design.

---

## Recommended Patterns (5 Rules)

### 1. Wallet/Identity Integration with Transaction Feedback
- **Pattern**: Wallet connect flow → gas fee display before confirmation → explicit transaction status (pending/confirmed/failed)
- **Best For**: NFT/Web3 platforms
- **Rationale**: Both wallet integration and gas-fee display are named `must_have` decision rules — crypto transactions are irreversible, so the UI must never leave the user uncertain about state

### 2. Spatial Depth & Gaze/Gesture Interaction
- **Pattern**: Frosted-glass panels floating at different depths, gaze-to-target + pinch-to-select interaction model, environment-awareness (content responds to real-world surfaces/lighting)
- **Best For**: Spatial computing OS/apps (AR/VR, VisionOS-style interfaces)
- **Rationale**: Depth hierarchy and environment awareness are both named `must_have`s — flattening a spatial UI back to a 2D mental model is the single most-cited anti-pattern in this category
- **Mobile**: The underlying Spatial UI style is rated ✓ High mobile-friendliness "if adapted" — a flat-screen companion view needs its own 2D layout pass, not a literal port of the 3D scene

### 3. Real-Time Telemetry & Monitoring HUD
- **Pattern**: Live-updating map or spatial view → telemetry readouts (position, battery, signal) → latency indicator → safety-alert channel that overrides other UI
- **Best For**: Autonomous drone fleet management, space tech/aerospace monitoring
- **Rationale**: Real-time telemetry and safety alerts are named `must_have`s — a monitoring interface that lags or hides alerts behind a menu is a safety failure, not a UX nitpick

### 4. Conversational / Streaming AI Interface
- **Pattern**: Chat-style input → streamed token-by-token response with a visible typing indicator → context carried across turns
- **Best For**: AI/chatbot platforms
- **Rationale**: Streaming text and context-awareness are named `must_have`s — a chat UI that shows nothing until the full response is ready reads as broken, since users have learned to expect the streaming pattern

### 5. Scientific Data Visualization with Credibility Signals
- **Pattern**: Complex underlying data (qubit states, biological markers, carbon impact) rendered as an explained visualization, paired with an explicit statement of data source/methodology
- **Best For**: Quantum computing interfaces, biotech/life sciences, biohacking/longevity apps, climate/sustainable-energy platforms
- **Rationale**: "Scientific credibility" and "data transparency" are named `must_have`s across every one of these rows — the visualization has to earn trust, not just look impressive

---

## Style Priorities (5 Rules)

### 6. Dark Mode as Default, Not Optional
- **Priority**: NFT/Web3, quantum computing, drone fleet management, and space tech all name "light mode default" as an explicit anti-pattern
- **Rationale**: These are control-room and trading-style contexts (often used for extended monitoring sessions) where OLED-dark backgrounds reduce eye strain and make alert colors (red/green) pop correctly

### 7. Holographic / HUD Sci-Fi Aesthetic
- **Priority**: Quantum interfaces, drone fleets, and space tech share a "heads-up display" visual language — thin glowing lines, tactical/terminal greens, deep blacks
- **Rationale**: This is a deliberate genre signal: it borrows the visual vocabulary users already associate with "advanced technology" from film/games, which shortcuts the credibility problem these categories otherwise face
- **Accessibility**: The HUD/Sci-Fi FUI style is rated ⚠ Poor accessibility in the source style data specifically because of its thin glowing lines — for any genuinely safety-critical telemetry (Rule 3's drone/aerospace alerts), pair the aesthetic with a higher-contrast, thicker-stroke alert state rather than keeping alerts in the same thin-line language as decorative HUD chrome

### 8. Spatial UI Depth Over Flat 2D
- **Priority**: Spatial computing interfaces must express real depth (layered translucency, parallax on head movement), not a 2D screen redesigned with a glass filter
- **Anti-Pattern**: "2D design" and "no spatial depth" are named explicitly — a spatial app that could be flattened into a normal screen without losing anything has failed the category's core premise
- **Accessibility**: Spatial UI (VisionOS-style) is explicitly rated with "contrast risks" and flagged "do not use for" high-contrast-requirement content — frosted-glass depth layering needs a per-surface contrast check, it isn't accessible by default just because Apple's own system uses it

### 9. Clean Scientific Minimalism for Biotech/Climate
- **Priority**: Biotech and climate-tech platforms use sterile whites, glassmorphism, and restrained color specifically to read as rigorous rather than promotional
- **Anti-Pattern**: "Greenwashing" is named explicitly for climate tech — an emotionally warm, nature-imagery-heavy design without real backing data reads as marketing, not measurement, and undermines the product's own premise

### 10. Minimal Chrome for AI-Native Interfaces
- **Priority**: AI/chatbot platforms favor near-invisible UI — a text field, a stream of messages, minimal navigation
- **Anti-Pattern**: "Heavy chrome" is named explicitly — dashboards, sidebars, and toolbars compete with the one thing the product is actually about, the conversation itself

---

## Color Moods (3 Rules)

### 11. Neon on Deep Black
- **Primary**: #8B5CF6 purple + #FBBF24 gold (NFT/Web3), #00FFFF cyan (quantum), #00FF41 tactical green (drone fleet)
- **Background**: Near-black (#0F0F23, #050510, #0D1117) across all three
- **Rationale**: A single saturated neon accent on true-dark is legible for long monitoring sessions and reads as "advanced system," consistent with Rule 7's HUD aesthetic

### 12. AI Purple + Aurora Gradients
- **Primary**: #7C3AED / #6366F1 AI-purple family, paired with a slow-morphing gradient rather than a flat fill
- **Use Cases**: AI/chatbot platforms specifically — the same purple family recurs in AI-generation creative tools (see `references/creative.md` Rule 13), but here it's paired with a *minimal* chrome rather than an expressive one, since the product is a utility, not a creative canvas
- **Caution**: Purple/pink AI gradients are flagged as an anti-pattern *elsewhere* (finance, legal, B2B) precisely because they read as "generic AI product" — reserve this palette for products where that association is the goal

### 13. Earth Green + Solar Yellow for Climate/Sustainability
- **Primary**: #059669 earth green, #10B981 secondary green
- **Accent**: Solar yellow/gold for energy-generation states
- **Contrast**: Distinct from Biohacking/Longevity's cellular pink + DNA blue (#FF4D4D / #4D94FF) — climate tech reads as "planet," biohacking reads as "body," even though both are in the same broader scientific-credibility cluster

---

## Typography Personality (3 Rules)

### 14. Futuristic Monospace/Technical Type
- **Pairing**: Orbitron (heading) + Exo 2 (body) — the "Crypto/Web3" pairing; Share Tech Mono + Fira Code for HUD/sci-fi dashboards; Exo + Roboto Mono for science/tech contexts
- **Rationale**: Monospace and geometric-futurist letterforms reinforce the "advanced system" genre signal from the Color Moods section — proportional humanist fonts would undercut it

### 15. Spatial Clear System Type
- **Pairing**: Inter (heading) + Inter (body) — the "Spatial Clear" pairing, purpose-built for AR/VR and glassmorphism interfaces
- **Rationale**: Spatial UI already carries visual complexity from depth and translucency; the type itself should stay neutral and highly legible against variable, moving backgrounds

### 16. Scientific/Academic Clarity
- **Pairing**: Crimson Pro (heading) + Atkinson Hyperlegible (body) — the "Academic/Research" pairing
- **Best For**: Biotech, biohacking, and climate-tech platforms that need to read as citation-backed rather than marketing-driven

---

## Key Effects (2 Rules)

### 17. Wallet-Connect & Transaction State Animations
- **Pattern**: Distinct animated states for "connecting wallet," "awaiting confirmation," and "confirmed" — never a single generic spinner covering all three
- **Rationale**: Directly supports Rule 1's transaction-feedback requirement; irreversible on-chain actions need the state distinction to be visually unambiguous, not just textual

### 18. Telemetry & Impact-Data Animations
- **Pattern**: Live-updating numeric counters and probability/impact visualizations (qubit state clouds, carbon-impact meters, drone position updates) rather than static snapshots
- **Rationale**: Named across quantum, drone-fleet, and climate-tech rows alike — a static number undersells the "real-time" and "measured, not claimed" credibility these categories depend on

---

## Anti-Patterns (2 Rules)

### 19. What to Avoid in Emerging Tech

❌ **Light Mode Default or Missing Transaction/Alert Status**
- **Why**: Named explicitly across Web3, quantum, and drone-fleet rows — both undermine the control-room credibility these interfaces need
- **Instead**: Dark-first design with explicit, persistent status indicators for anything transactional or safety-related

❌ **Flattening Spatial UI to 2D, or Generic Tech Design Without Real Visualization**
- **Why**: Spatial computing and quantum computing both name this directly — a spatial app with no depth, or a "high-tech" interface with no actual data visualization, fails the category's core premise
- **Instead**: Real depth hierarchy for spatial; real complexity-visualization (not decorative graphics) for quantum/scientific interfaces

### 20. Greenwashing or Unsubstantiated Claims
- **Example**: A climate-tech dashboard showing "impact" numbers with no visible data source, or a biohacking app making health claims with no privacy/data-handling disclosure
- **Why**: Named directly for climate tech ("greenwashing + no real data") and implied for biohacking ("no privacy" as an anti-pattern) — these categories are trading on scientific/environmental credibility, so an unsupported claim is worse here than a plain missing feature
- **Instead**: Show the data source and methodology alongside any impact or health claim; make privacy/data-handling policy visible before requesting personal biological data

---

*Rules Count: 20*
