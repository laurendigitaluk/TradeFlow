# Checkpoint — Signup/login header styling — 4 November 2026

## User-reported issue
On the LIVE signup page, the TradeFlow brand and Sign in link appeared as plain text joined together at the top edge instead of a separated brand and button.

## Cause
`subscriber-signup.html` and `subscriber-login.html` use the shared `topbar`, `brand` and `login` classes, but `signup.css` did not define their layout or visual styling.

## Repair
- Added a responsive flex layout and spacing for `.topbar`.
- Styled `.brand` as the left-aligned TradeFlow wordmark.
- Styled `.login` as a visible orange button with hover state.
- Bumped the linked stylesheet reference to `signup.css?v=3` on signup and login pages to avoid stale cached CSS.
- Mirrored the same source changes to LIVE and TEST.

## Scope and safety
Presentation-only change. No changes to signup/login JavaScript, Supabase, authentication, subscription pricing, Stripe checkout, tenant data or customer data. Confirm Cloudflare deployment and browser rendering separately for each environment.
