# Checkpoint — Subscriber Website SEO Settings
Date: 30 October 2026

## Scope
Code/documentation restore point for the page-level SEO editor and public metadata output. No tenant website content or customer data was copied or modified.

## Branches and starting points
- LIVE: `production`, starting commit `9bf9e11ecb835242445cc4d13d307b2c6faf28b2`.
- TEST: `test/stripe-connect-test-mode-repair-20261020`, starting commit `4966b3a574077b1a72a15f240fbab5332c257ca7`.
- Supabase LIVE: `gxsrajtqzdjvmceqcpgv`.
- Supabase TEST: `nnsshnfkjcflucjrftzi`.

## Existing data model
No new table or migration is required. Existing SEO keys are retained on `site_revisions.content->site->pages[]`. Home is separate from `site.pages[]`, so homepage fields are stored under `site.homepage`.

## Change
- Added SEO title and meta description inputs to the Website Builder Pages panel.
- Added homepage SEO state and persistence through existing `buildContent()`.
- Preserved per-page SEO values on `site.pages[]`.
- Added public metadata resolution for active route: document title, meta description, Open Graph title and description.
- Added subscriber Website Manual guidance.
- Updated System Handbook, AI Operating Manual and Backend User Manual.
- Added this checkpoint and a subscriber website diagnostic roadmap.

## Safety / separation
- No Supabase rows, tenant website revisions, customer data, Auth, Stripe settings, Cloudflare settings or deployment configuration were changed.
- LIVE and TEST tenant records remain separate.
- Do not copy TEST content or SEO values into LIVE.

## Verification still required
- Static JavaScript syntax checks on both branches.
- TEST authenticated builder: Home SEO fields save, survive reload and publish.
- TEST internal page SEO fields save, survive reload and publish.
- Public TEST pages emit expected title, description and Open Graph tags; route changes do not leave stale descriptions.
- Confirm LIVE code parity and actual deployed worker version.
- Confirm no regression to locked starter template, editor interactions, Save Draft, Preview or Publish.


### TEST/LIVE runtime endpoint correction — 30 October 2026
The Website Builder must use `window.TRADEFLOW_CONFIG.supabaseUrl` supplied by `subscriber-auth.js`; it must not hard-code the LIVE Supabase URL. The subscriber auth layer selects TEST (`nnsshnfkjcflucjrftzi`) on the TEST worker and LIVE (`gxsrajtqzdjvmceqcpgv`) on the production worker. A hard-coded LIVE URL caused the TEST builder to send TEST credentials to LIVE and prevented the TEST draft from loading. This is an environment-routing defect, not an SEO schema or tenant-data migration. Keep the two projects isolated and verify the TEST builder loads and saves against TEST only.
