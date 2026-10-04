# CHECKPOINT — 2026-10-04 LIVE Website Builder starter-template lock

## Environment
LIVE/production is the active Website Builder source for this phase. The existing draft → preview → publish architecture remains unchanged.

## Root cause identified
New tenants are bootstrapped with an empty site revision by `private.bootstrap_tenant_site()`. The Website Builder then runs `resetToFreshWebsite()` for the initial schema/template state. Therefore the approved starter arrangement must be encoded in that fresh-start path; changing only the current subscriber draft does not define the next subscriber's starting layout.

## Implemented
- Locked the approved 4 October content-block arrangement into `resetToFreshWebsite()`.
- Preserved the measured positions from the current approved builder arrangement: left text block, right image block, lower text block.
- Removed starter placeholder copy so new subscribers receive empty editable text boxes rather than `Your Text Here` / `Edit this text`.
- Kept subscriber logo and banner tenant-specific; Action Outlet branding is not hard-coded into the generic starter template.
- Cache-busted `website-builder.js` from v109 to v110.
- Updated the System Handbook and AI Operating Manual.

## Important deletion behaviour
The current builder correctly treats deletion as a draft edit. Removing a logo/banner marks the draft dirty; **Save Draft** is required before a reload will preserve the deletion. Publish remains a separate explicit action.

## Commits
- `230e2ec8f96ba7281a17a4acf62bd5581009b02b` — approved starter layout positions
- `1e764d578274b484a9278eca9df33fab6880de87` — remove starter placeholder copy
- `63b1e6e6c5551c05ca7ab8b73ba563017c422ec8` — builder asset cache v110
- `4eaf5d44734d06db7db16d3910a369e8d51cc012` — System Handbook update
- `2d75752e0276d3b0d0765277e9a75bdf5f1805bd` — AI Operating Manual update

## Browser verification still required
Create/initialise a genuinely fresh subscriber site and confirm the starter layout appears exactly as approved, with empty text boxes, an empty image box, and tenant-specific branding. Then test logo/banner deletion → Save Draft → reload. Do not declare the starter-template work fully browser-verified until those checks pass.
