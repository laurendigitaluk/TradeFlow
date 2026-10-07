# Continuation Prompt — 2026-10-07 — Business Slug URL Verification

Continue TradeFlow LIVE from checkpoint `2026-10-07-business-slug-url-cleanup`.

Do not change authentication architecture, tenant UUIDs in the database, Website Builder, publishing workflow, or customer-owned-domain workflow.

The LIVE Worker is:
`tradeflow`

The branded LIVE platform URL is:
`https://tradeflow.laurendigital.co.uk`

The current objective is to verify that subscriber-facing URLs no longer expose `tenant_id=<UUID>`.

Expected current Adventure Outpost public slug:
`adventure-outpost`

Expected public website model:
`https://tradeflow.laurendigital.co.uk/?business=adventure-outpost`

First verify deployment and browser behaviour. Do not make further code changes unless a real failure is observed.

Verification order:
1. Subscriber dashboard URL.
2. Website area.
3. Preview website.
4. Public-site navigation.
5. Sign-in and tenant switching.
6. Only then continue with the next Cloudflare/customer-domain task.

The tenant UUID remains an internal database/API identifier and must not be removed from tenant-scoped backend operations.
