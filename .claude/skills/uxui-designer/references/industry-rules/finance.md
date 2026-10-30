# Finance Industry Rules (21 Rules)

## Overview
Finance products demand trust, security, data accuracy, and regulatory clarity. Users handle sensitive information; even small design mistakes can erode confidence.

---

## Recommended Patterns (5 Rules)

### 1. Account Dashboard with Net Worth at Top
- **Pattern**: Primary metric above fold (total balance, net worth, account summary) with trend sparkline, period comparison
- **Rationale**: Users check account status first
- **Accessibility**: Large text (18px+), high contrast

### 2. Transaction Lists with Filtering & Search
- **Pattern**: Sortable table/list, date range picker, category filter. Columns: date, description, amount, balance, category
- **Rationale**: Users need to find and understand spending/earning patterns
- **Mobile**: Card-based list, swipe to reveal actions

### 3. Multi-Step Verification (2FA)
- **Pattern**: SMS/App PIN → security question → email confirmation, for login, large transactions, settings changes
- **Rationale**: Sensitive-action confirmation reduces account takeover risk
- **Error Handling**: Retry limit, lockout mechanism explained clearly

### 4. Account Settings with Permission Hierarchy
- **Pattern**: Nested settings (Personal → Security → Notifications)
- **Rationale**: Fine-grained control avoids accidental changes
- **Confirmation**: Destructive actions (delete account, change email) require email confirmation; 30-day deletion window
- **Audit Log**: Show recent logins, device changes, IP addresses

### 5. Clear CTAs for Financial Actions
- **Pattern**: Primary action (transfer, invest, pay) in prominent button
- **Button Text**: Be specific ("Transfer $500 to Savings" not just "Confirm")
- **Confirmation**: Show summary before execution (from/to accounts, amount)
- **Disabled State**: If fields invalid, disable CTA + explain why

---

## Style Priorities (5 Rules)

### 6. Trust Through Formality
- **Priority**: Convey stability, security, confidence
- **Colors**: Navy blues, dark grays, accent greens/golds; no playful gradients or unusual shapes
- **Typography**: Conservative serif (Merriweather) or clean sans (Source Sans)

### 7. Visual Hierarchy for Numbers
- **Priority**: Numbers are primary content; everything else supports them
- **Font Size**: Large for balances (24–32px), smaller for labels (12px)
- **Emphasis**: Bold for current balance; regular for historical

### 8. Conservative Color Palette
- **Primary**: Navy (#003366), Dark Gray (#1a1a1a)
- **Accent**: Deep Green (#155724 - growth), Gold (#D4AF37 - premium)
- **Danger**: Dark Red (#C41E3A - loss, error, decline)
- **Neutral**: Light gray backgrounds, white content areas
- **Why**: Matches financial institutions, conveys stability

### 9. Trust & Security Signals
- **Priority**: Show security affordances users already recognize — lock icon for secure sections, padlock in login
- **Links**: Privacy policy, terms, regulatory disclosures in footer (always available)
- **No Deception**: Never hide terms, conditions, or fees
- *Design pattern only — this is not a compliance checklist; verify actual regulatory obligations (PCI-DSS, SOC 2, etc.) with legal/security teams.*

### 10. Accessibility for Vision Impairment
- **Priority**: Financial data must be accessible via screen reader
- **Color Alone**: Never use color to indicate status (positive/negative) — pair icons with text labels
- **Numbers**: 16px+ font size, 1.5+ line height

---

## Color Moods (3 Rules)

### 11. Trust & Security (Navy, Dark Gray)
- **Primary**: #003366, #1a1a1a
- **Psychology**: Stability, confidence, professionalism
- **Use Cases**: Main navigation, primary buttons, headers
- **Avoid**: Bright, trendy colors (undermines trust)

### 12. Growth & Gain (Deep Green)
- **Accent**: #155724, #0d7a3a
- **Psychology**: Growth, profit, positive performance
- **Example**: "+$500.00 gain" in green, bold

### 13. Caution & Loss (Dark Red)
- **Alert**: #C41E3A, #dc2626
- **Psychology**: Warning, risk, loss, decline
- **Example**: "-$200.00 loss" in red, bold
- **Contrast**: Must meet 4.5:1 on white

---

## Typography Personality (3 Rules)

### 14. Traditional Yet Modern
- **Headline**: Merriweather (serif) or Source Sans (sans)
- **Monospace**: IBM Plex Mono for transaction IDs, account numbers
- **Rationale**: Serif conveys heritage; sans conveys modern security

### 15. Numbers Are Content
- **Font**: Monospace (JetBrains Mono) or tabular figures (lining)
- **Alignment**: Right-aligned for amounts (decimal alignment)
- **Example**: `$10,234.56` (right-aligned, monospace, 18px bold)

### 16. Clear Instructions & Warnings
- **Legal Text**: 11–12px, gray (#666), but always readable
- **Never Abbreviate**: Avoid jargon; spell out terms
- **Example**: "Funds will arrive in 1–3 business days" (clear, not "~3 bdays")

---

## Key Effects (3 Rules)

### 17. Subtle Feedback on Input
- **Validation**: Green checkmark on valid entry, red error on invalid
- **Disabled**: Gray background, not clickable

### 18. Animated Notifications & Alerts
- **Toast Notifications**: Slide up from bottom, 4-second auto-dismiss
- **Persistent Alerts**: Banner at top, manual dismiss required

### 19. Loading States During Transactions
- **Text**: "Processing transfer..." + time estimate if known
- **Disable**: Primary button disabled during processing (no double-clicks)
- **Timeout**: Show error if processing > 30 seconds

---

## Anti-Patterns (3 Rules)

### 20. What to Avoid in Finance

❌ **Hidden Fees or Fine Print**
- **Why**: Erodes trust; may be illegal
- **Instead**: Transparent fee display, breakdown before confirmation

❌ **Ambiguous Transaction Descriptions**
- **Why**: Users can't verify legitimate vs. fraudulent transactions
- **Example**: "SomeCompany" is bad; "SomeCompany - Subscription (Jan)" is good

❌ **Auto-Login or Session Hijacking**
- **Why**: Major security breach risk
- **Instead**: Require login on each session, especially on shared devices

### 21. Confusing Currency or Language
- **Example**: "$500" vs "500€" must be visually distinct
- **Instead**: Always show currency symbol + code (USD, EUR); format numbers by locale (1,000.00 vs 1.000,00)

---

*Rules Count: 21*
