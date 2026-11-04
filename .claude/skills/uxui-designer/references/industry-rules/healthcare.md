# Healthcare Industry Rules (20 Rules)

## Overview
Healthcare products prioritize patient safety, empathy, accessibility, and careful handling of sensitive personal data. Users include patients, caregivers, and medical professionals with varying tech literacy.

---

## Recommended Patterns (5 Rules)

### 1. Patient Timeline or Health Journey
- **Pattern**: Chronological view of events (appointments, prescriptions, test results); vertical timeline, icons for event type, expandable details
- **Best For**: EHR, telemedicine, patient portals
- **Accessibility**: Screen-reader friendly; timestamps clear

### 2. Medication Lists with Clear Instructions
- **Pattern**: Table with medication name, dosage, frequency, reason, refill status
- **Rationale**: Confusion about medications can cause harm
- **Include**: Side effects, interactions warning, pharmacy contact

### 3. Appointment Booking with Confirmation
- **Pattern**: Date/time picker → specialist selection → reason → confirmation
- **Rationale**: Reduces no-shows, ensures proper scheduling
- **Confirmation**: Email + SMS with appointment details, directions, preparation tips

### 4. Symptom Checker (Guided Q&A)
- **Pattern**: Decision tree with yes/no questions → severity assessment → recommendations
- **Disclaimer**: "Not a diagnosis; consult a doctor"
- **Recommendation**: Urgent care / ER / home care / schedule visit

### 5. Health Data Visualization (Charts with Context)
- **Pattern**: Blood pressure, heart rate, weight trends as line/bar charts, with medication changes/lifestyle events annotated
- **Sharing**: Export as PDF or image for doctor
- **Interpretation**: AI-generated insight ("Your BP is trending down") + disclaimer

---

## Style Priorities (5 Rules)

### 6. Empathy & Reassurance
- **Priority**: Calm, supportive tone; reduce anxiety
- **Colors**: Soft blues, warm earth tones; avoid alarming reds except for emergencies
- **Language**: Patient-friendly (avoid medical jargon; explain terms)

### 7. Accessibility First
- **Priority**: WCAG AAA (not just AA) for inclusivity
- **Text Size**: 16px+ for body, support 200% zoom
- **Color Contrast**: 7:1 for critical content (vs. the 4.5:1 AA standard used elsewhere) — the higher bar matters here because misread dosage/allergy info causes harm
- **Motor**: Large touch targets (48px+), no time-dependent interactions

### 8. Trust Through Transparency
- **Priority**: Be honest about limitations, risks, and how patient data is handled
- **Disclaimers**: Always visible for medical advice/AI recommendations
- **Data Privacy**: Explain what data is collected and how it's used, in plain language
- **Contact Info**: Always provide phone number or live chat for urgent questions
- *Design pattern only — actual regulatory compliance (e.g. HIPAA) requires review with legal/privacy counsel, not a UI checklist.*

### 9. Mobile-First Design
- **Priority**: Many patients access via phone (especially for urgent care)
- **Offline**: Critical info (medications, appointments) available without internet

### 10. Calm, Minimal Aesthetic
- **Priority**: Reduce cognitive load and anxiety
- **Animation**: Avoid auto-play videos, flashing content
- **Typography**: Serif for body (easier to read for older users), clear sans for labels

---

## Color Moods (3 Rules)

### 11. Trust & Care (Soft Blue)
- **Primary**: #4a90e2, #50c878, #87ceeb
- **Psychology**: Healing, professionalism, calm
- **Avoid**: Bright, saturated blues (too clinical)

### 12. Health & Wellness (Green)
- **Accent**: #10b981, #50c878, #7cb342
- **Example**: "Your exercise goal: 7/7 days completed" in green

### 13. Caution & Urgency (Orange/Red)
- **Alert**: #f97316, #ef4444
- **Use Cases**: Allergy warnings, medication interactions, urgent symptoms
- **Reserve**: Red only for true emergencies; orange for caution

---

## Typography Personality (3 Rules)

### 14. Clear, Accessible Fonts
- **Headline**: Merriweather (serif) or Source Sans (modern, trustworthy)
- **Body**: Georgia or Roboto (highly readable, even at small sizes)
- **Rationale**: Serif is traditional (medical); sans is modern (tech)

### 15. Patient-Friendly Language
- **Jargon-Free**: Avoid medical terminology; explain concepts simply
- **Example**: "Blood pressure: The force of blood pushing on artery walls" (explain)

### 16. Hierarchical Information
- **Bold**: Medication names, dates, important values
- **Caption**: Dosage, frequency, next review date (smaller, gray)

---

## Key Effects (2 Rules)

### 17. Reassuring Feedback
- **Confirmation**: "✓ Appointment booked for March 15, 2:00 PM"
- **Duration**: No instant confirmations (feels untrustworthy); 1-2 second feedback

### 18. Gentle Transitions
- **Duration**: 200–300ms (not too fast, not slow)
- **Avoid**: Jarring animations, auto-play content

---

## Anti-Patterns (2 Rules)

### 19. What to Avoid in Healthcare

❌ **Medical Advice Without Disclaimer**
- **Why**: Legal liability; patient safety risk
- **Instead**: "This is not medical advice. Consult your doctor." Always visible

❌ **Confusing Medication Instructions**
- **Example**: "Take 1–2 tablets as needed" is ambiguous; "Take 1 tablet every 8 hours (max 2 tablets/day)" is clear
- **Instead**: Specific dosage, frequency, conditions

❌ **Hidden Privacy or Data Sharing**
- **Why**: Erodes trust in how personal health data is used
- **Instead**: Transparent privacy policy; explicit consent for data sharing

❌ **No Emergency Contact**
- **Instead**: Visible hotline, emergency info on every page

### 20. Time-Sensitive Actions Without Warning
- **Example**: "Are you sure?" is insufficient; show details
- **Instead**: Modal with appointment date/time + confirm button

---

*Rules Count: 20*
