# Project Memory — 2026-10-07 — Business Slug URLs

The LIVE TradeFlow platform now uses business slugs instead of exposing tenant UUIDs in subscriber-facing browser URLs.

Current LIVE platform:
`https://tradeflow.laurendigital.co.uk`

Internal tenant UUIDs remain authoritative and must continue to be used for Supabase tenant scoping, authentication state and database/API calls.

Current Adventure Outpost public slug:
`adventure-outpost`

Public website query model:
`?business=adventure-outpost`

New LIVE Supabase functions:
- `get_published_site_by_slug(text)`
- `subscriber_get_my_tenant_slug(uuid)`

Production files changed:
- `subscriber-auth.js`
- `subscriber-tenant-context.js`
- `subscriber-website.html`
- `public-site.js`

The Website Builder, publishing workflow, authentication architecture, customer-owned-domain workflow and Cloudflare Worker custom-domain configuration were not otherwise changed.

Next task is browser verification after the current production deployment is live.
