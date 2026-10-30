# Services Industry Rules (20 Rules)

## Overview
Services products span two very different registers: high-trust professional services (legal, B2B, senior care) where credibility and clarity dominate, and consumer-facing hospitality/booking services (restaurants, hotels, spas, home repair) where warmth, urgency, and frictionless booking dominate. Nearly every sub-category shares one structural spine: a service/slot to browse, a provider to trust, and a booking or contact action to complete.

---

## Recommended Patterns (5 Rules)

### 1. Booking Flow with Calendar + Slot Grid
- **Pattern**: Calendar strip or month picker → available time-slot grid → service + staff/provider selector → confirmation summary → reminder
- **Rationale**: Booking & appointment products are inherently two-sided (provider ↔ client); the slot grid is the moment of commitment and must be unambiguous
- **Confirmation**: Email + SMS/push with date, time, provider, location/directions
- **Flexibility**: Always expose reschedule/cancel from the same confirmation, not buried in settings
- **Mobile**: Card-based slot list over a dense grid on small screens; tap targets sized for one-thumb selection since booking is a frequent on-the-go action

### 2. Service Menu with Transparent Pricing
- **Pattern**: List of services/packages with price shown upfront, not "call for quote" unless legally required
- **Rationale**: Price transparency is a `must_have` decision rule across home services, legal, and beauty categories — hiding it is the single most common trust-breaker in this sector
- **Trust Signals**: Certifications, licenses, insurance badges displayed next to the price, not on a separate "About" page

### 3. Provider Credibility Block
- **Pattern**: Attorney/consultant/staff profile with credentials, years of experience, case results or client outcomes, professional photo
- **Rationale**: For legal, B2B consulting, and senior/child care, the buying decision is a trust decision about a specific person or firm before it is a decision about the service itself
- **Evidence**: Case studies and ROI messaging for B2B; case results and bar credentials for legal; safety certifications for care services
- **Accessibility**: Credential text at body size (16px+), not caption-size fine print — burying credentials in small type reads as the same evasiveness as omitting them

### 4. Client/Case Pipeline Dashboard
- **Pattern**: Contact card list with avatar → pipeline kanban (stage columns) → activity timeline → quick-log action (call/email/meeting) → deal amount + probability
- **Rationale**: CRM, freelancer platforms, and invoicing tools are the operator-facing side of services — they need dense, fast-entry UI, not the marketing-facing warmth of the client-facing pages
- **Mobile**: Quick-log and touch-optimized actions matter more than desktop density here, since providers log activity between jobs

### 5. Reservation & Gallery-Led Discovery
- **Pattern**: Hero imagery → menu/room/amenity gallery → reviews/social proof → booking or reservation CTA
- **Rationale**: Restaurant, hotel, wedding, and coworking bookings are sold on the experience before the transaction — food photography, room tours, and portfolio galleries do the persuading that spec sheets do in B2B
- **Requirement**: High-quality, current imagery is a `must_have`; outdated photos are flagged as a severity-HIGH anti-pattern across every hospitality-style row

---

## Style Priorities (5 Rules)

### 6. Trust & Authority for Professional Services
- **Priority**: Legal, B2B, invoicing, and senior care read as competent and safe, not creative
- **Colors**: Navy (#1E3A8A–#1E3A5F), muted gold/amber accents, neutral greys — no playful gradients
- **Typography**: Formal serif/sans pairing (EB Garamond + Lato for legal; Lexend + Source Sans 3 for corporate-trust B2B)
- **Accessibility**: The underlying "Trust & Authority" style carries a WCAG AAA rating and is explicitly rated wrong for casual/entertainment/viral-first products — the inverse of Rule 7 below

### 7. Warm Hospitality for Consumer-Facing Services
- **Priority**: Restaurant, hotel, beauty/spa, and wedding read as inviting and sensory, not clinical
- **Colors**: Warm reds/browns for food (restaurant), warm neutrals + gold for luxury hospitality (hotel), soft pastels for beauty/spa, soft pink + gold for weddings
- **Motion**: Gallery reveals and hover transitions (200–300ms) — gentle, not the fast 150ms snap used in operator dashboards
- **Accessibility**: The Claymorphism/Soft-UI styles this warmth draws on are rated only ⚠ 4.5:1 contrast (not AAA) and are explicitly flagged "do not use for" formal/legal/finance contexts — confirm text-on-pastel contrast per page rather than assuming the palette is accessible by default

### 8. Emergency & Urgency Affordances for Home Services
- **Priority**: Home repair (plumber/electrician/HVAC) is often an urgent, high-stress purchase
- **Requirement**: Emergency contact number visible without scrolling on every page — this is a `must_have` decision rule, not a nice-to-have
- **Colors**: Trust blue paired with a safety-orange accent for the emergency CTA, so it reads distinct from routine navigation

### 9. Two-Sided Marketplace Clarity
- **Priority**: Booking apps, freelancer platforms, and coworking spaces have both a provider and a client persona using the same surfaces
- **Pattern**: Design the provider-facing views (availability, portfolio, skill tags) and client-facing views (search, book, review) as distinct flows, even inside one app — don't force one generic UI to serve both
- **Mobile**: `if_mobile: optimize-touch-targets` is a named decision rule for CRM/freelancer-style flows — providers frequently update availability or log activity from a phone between jobs, not just at a desk

### 10. Accessibility First for Vulnerable Users
- **Priority**: Senior care and childcare serve users (or their family decision-makers) who need higher clarity and reassurance than a typical booking flow
- **Accessibility**: WCAG AAA text sizing (18px+ body text), 48px+ touch targets — small text and complex navigation are explicit `HIGH`-severity anti-patterns here
- **Mobile**: A visible family/parent portal is a `must_have` — family decision-makers check in from a phone, so status updates need to surface without navigating past the primary care-recipient view

---

## Color Moods (3 Rules)

### 11. Trust Navy + Gold (Professional Services)
- **Primary**: #1E3A8A (legal, hotel authority), #1E3A5F (invoicing navy)
- **Accent**: #A16207 / #B45309 (credibility gold), adjusted for WCAG contrast from the raw brand gold
- **Use Cases**: Legal services, B2B, invoicing/billing tools, hotel booking headers

### 12. Warm Hospitality (Restaurant, Beauty, Wedding)
- **Primary**: #DC2626 warm red (restaurant appetite), #EC4899 soft pink (beauty/spa), #DB2777 romantic pink (wedding)
- **Accent**: Warm gold (#A16207) across all three — the shared "premium hospitality" signal
- **Psychology**: Appetite, calm indulgence, and celebration respectively — never the cool blues used for operator-facing tools

### 13. Booking-Blue + Confirm-Green (Transactional Services)
- **Primary**: #0284C7 (booking & appointment), #2563EB (CRM & client management)
- **Accent**: #059669 available/confirmed green
- **Use Cases**: Calendar availability states, "confirmed" badges, pipeline "closed-won" stages

---

## Typography Personality (3 Rules)

### 14. Formal Authority Serif/Sans
- **Pairing**: EB Garamond (heading) + Lato (body) — the "Legal Professional" pairing, formal and trustworthy
- **Alternative**: Lexend + Source Sans 3 for B2B/corporate-trust contexts needing higher accessibility
- **Rationale**: Traditional serif headlines signal institutional gravity; a clean sans body keeps contracts and case detail readable

### 15. Warm Editorial for Hospitality
- **Pairing**: Playfair Display SC (heading) + Karla (body) for restaurant menus; Great Vibes + Cormorant for wedding/romance contexts
- **Rationale**: Display serifs read as curated and appetizing/celebratory — never use them for operator dashboards in the same product

### 16. Clean Functional for Booking & Operator Tools
- **Pairing**: Poppins (heading) + Open Sans (body) — the "Modern Professional" pairing
- **Rationale**: Booking flows, CRM pipelines, and invoicing tools are used repeatedly and quickly; personality takes a back seat to scan speed

---

## Key Effects (2 Rules)

### 17. Confirmation & Reminder Feedback
- **Pattern**: Explicit confirmation state ("✓ Booked for March 15, 2:00 PM") plus a scheduled reminder (push/SMS/email) ahead of the appointment
- **Rationale**: No-show reduction is a named rationale in the source data for appointment booking — confirmation alone isn't enough without a reminder loop

### 18. Gallery & Portfolio Reveal Animations
- **Pattern**: Room/space tours, before/after sliders, and portfolio reveals on scroll or hover (200–300ms)
- **Rationale**: These are the "wow factor" and social-proof carriers named across creative-agency-adjacent service rows (coworking space tours, photography-style beauty before/afters, wedding portfolios)

---

## Anti-Patterns (2 Rules)

### 19. What to Avoid in Services

❌ **Hidden Contact Info or Certifications**
- **Why**: For home services and legal, hidden credentials/contact is a named `HIGH`-severity anti-pattern — it reads as evasive exactly where trust matters most
- **Instead**: Certifications, licenses, and emergency contact visible on the primary page, not nested in an "About Us" submenu

❌ **AI Purple/Pink Gradients on Trust-Sensitive Services**
- **Why**: Named explicitly as an anti-pattern across legal, B2B, and senior-care source rows — a generic "AI startup" gradient look undercuts the institutional credibility these categories are selling
- **Instead**: Reserve gradient-heavy, AI-coded aesthetics for the AI/chatbot and generation-tool categories (`references/emerging-tech.md`, `references/creative.md`) where that association is the goal

❌ **Outdated Photos or Confusing Booking Flow**
- **Why**: Hospitality and coworking rows explicitly flag "outdated photos" and "confusing layout" as anti-patterns — stale imagery undercuts the experience-led sell these categories rely on
- **Instead**: Recent, high-quality photography and a booking flow that never exceeds a few steps before confirmation

### 20. Generic Design Without Portfolio or Proof
- **Example**: A creative-agency-style service page (wedding planning, marketing agency, coworking) that ships a generic template with no portfolio gallery
- **Instead**: Lead with real case studies, real venue/room photography, or a real portfolio — genericness is the named anti-pattern precisely because these purchases are trust-and-taste decisions, not spec comparisons

---

*Rules Count: 20*
