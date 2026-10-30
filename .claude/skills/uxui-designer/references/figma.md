# Figma & UI Analysis

Extract UI components, interactions, and test implications from Figma designs or screenshots.

## When to use
- Feature has Figma links or UI mockups
- Need to understand what screens, components, and flows exist
- Mapping design to test scenarios

## How it works

### Step 1: Check for Visual Context
- If Figma link found → try to access (2 attempts max)
- If no link → ask user:
  ```
  📸 Reference image for the test:
  Upload an image or send a Figma link.
  If you have none, type "no image".
  ```
- If user says "no image" → write "No content provided" and continue

### Step 2: Analyze Context
- Identify screens, components, user actions, states

### Step 3: Extract Details & Visual Mapping
1. **Extract UI Components** — buttons, forms, inputs, icons, modals
2. **Visual-to-Data Mapping** — create 1-to-1 mapping between visual elements and business rules (BL_XXX) or AC
3. **Visual Error Simulation** — imagine network failures/latency, identify which elements should show skeleton loaders, disabled states, or error boundaries
4. **Extract Business Rules** — validation, permission, workflow from UI
5. **Extract Test Implications** — user journey, edge cases

## Visual-to-Business Rules Mapping Table

| UI Element | Visual State | Mapped Business Rule (BL_XXX) / AC |
|------------|-------------|-------------------------------------|
| Submit button | Disabled when form invalid | Validation required before submit |
| Price field | Red when negative | Price must be >= 0 |
| Status badge | Green/Yellow/Red | Maps to Active/Pending/Inactive |

## Visual Error & Edge Simulation
- **Network Failure:** which elements should display fallback error UI
- **Loading State:** which elements should show skeleton loader while API processes
- **Empty State:** which elements should show user-friendly empty state
- **Concurrent Override:** what happens when data changes mid-interaction

## Output
```
Screens: [list with purpose]
Components: Buttons [list], Forms [list], Tables [list]
Interactions: Click [what happens], Submit [what happens]
States: Default, Loading, Error, Success

Visual-to-Business Rules:
| Element | State | Rule |

Business Rules from UI:
- Validation: [rules]
- Permission: [rules]
- Workflow: [rules]

Test Implications:
- User Journey: [step sequence]
- Detailed Steps: The user can [verb] [object] >> [next verb] >> [result]
- Validation Points: [list]
- Edge Cases: Network failure → [behavior], Empty state → [behavior]
```
