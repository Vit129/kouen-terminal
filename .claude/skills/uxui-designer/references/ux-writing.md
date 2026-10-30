# UX Writing

## Button Labels

Never use "OK", "Submit", or "Yes/No". Use specific verb + object:

| Bad | Good |
|-----|------|
| OK | Save changes |
| Submit | Create account |
| Yes | Delete message |
| Cancel | Keep editing |
| Click here | Download PDF |

For destructive actions: "Delete 5 items" not "Delete selected".

## Error Messages

Answer: (1) What happened? (2) Why? (3) How to fix it?

| Situation | Template |
|-----------|----------|
| Format error | "[Field] needs to be [format]. Example: [example]" |
| Missing required | "Please enter [what's missing]" |
| Permission denied | "You don't have access to [thing]. [What to do instead]" |
| Network error | "We couldn't reach [thing]. Check your connection and [action]." |
| Server error | "Something went wrong on our end. We're looking into it." |

Don't blame the user.

## Empty States

Empty states are onboarding moments: (1) Acknowledge, (2) Explain value, (3) Provide action.
"No projects yet. Create your first one to get started." not "No items".

## Voice vs Tone

Voice is consistent. Tone adapts:
- Success: Celebratory, brief
- Error: Empathetic, helpful
- Loading: Reassuring
- Destructive: Serious, clear

Never use humor for errors.

## Accessibility

- Link text must have standalone meaning
- Alt text describes information, not the image
- Icon buttons need `aria-label`

## Translation

German +30%, French +20%, Finnish +30-40%. Keep numbers separate. Use full sentences. Avoid abbreviations.

## Consistency

Pick one term: Delete (not Remove/Trash), Settings (not Preferences/Options), Sign in (not Log in).
