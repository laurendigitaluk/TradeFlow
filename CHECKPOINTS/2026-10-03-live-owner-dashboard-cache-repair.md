# TradeFlow LIVE Continuity Checkpoint — 2026-10-03 — Owner Dashboard Cache Repair

## Current position

TradeFlow is in the LIVE launch workstream. Do not return to CameraShack-specific TEST polishing unless a defect is first reproduced in LIVE and the repair is deliberately promoted.

## LIVE verified backend state

- Supabase project: `TradeFlow Live`
- Ref: `gxsrajtqzdjvmceqcpgv`
- Region: `eu-west-2`
- Status: `ACTIVE_HEALTHY`
- LIVE platform owner membership exists and is active.
- `platform_ai_settings`: `active_provider=none`, `allowed_providers=["none"]`.
- `assistant_conversations` and `assistant_messages` exist with controlled tenant/customer/subscriber RPC access.
- `tradeflow-assistant` Edge Function is ACTIVE with JWT verification.
- `inventory_assets_tenant_serial_idx` is UNIQUE again.
- TEST-only helper RPCs `test_lab_current_customer` and `test_lab_current_customer_v2` are absent from LIVE.
- No TEST tenant/customer data was copied into LIVE.

## Owner Dashboard incident and evidence

The production Cloudflare deployment exists and is confirmed in the Cloudflare Worker version history. However, a clean Incognito browser was still requesting:

`platform-owner-dashboard.js?v=4` → HTTP 304

while the current production HTML in GitHub referenced:

`platform-owner-dashboard.js?v=6`.

During the failed owner sign-in attempt, LIVE Supabase showed no `/auth/v1/token` request. The LIVE auth user and active platform membership both exist. Therefore the evidence pointed to stale Owner Dashboard HTML/asset serving rather than a LIVE password, owner membership, or tenant-data problem.

Do not delete the displayed test-looking businesses or recreate the owner account on the basis of stale dashboard content. LIVE `public.tenants` was verified empty at the point this issue was diagnosed.

## Repair

Production commit:

`6c9b061e5a20210aa8b6f416a3f8b68fb6357329`

Message:

`Prevent stale production owner dashboard HTML caching`

Change:

`worker/index.js` now special-cases `/platform-owner-dashboard.html` and returns it with `Cache-Control: no-store`. The JavaScript asset was already returned with `no-store`. The repair closes the missing HTML cache boundary that could leave an older `?v=4` JavaScript reference in the browser.

No LIVE Supabase schema, auth, tenant or credential data was changed for this repair.

## Required next verification

1. Wait for the new production Worker version to be served.
2. Open the LIVE Owner Dashboard in a clean browser session.
3. Verify the HTML selects `platform-owner-dashboard.js?v=6` (or a newer version).
4. Sign in with the LIVE platform-owner account.
5. Verify a real LIVE `/auth/v1/token` request occurs.
6. Verify the dashboard loads LIVE data and does not display stale TEST businesses.
7. Continue to the real LIVE subscriber/customer launch.
8. Record the result before any further production change.

## Documentation / continuity rule

Following the user's explicit instruction, this checkpoint is accompanied by updates to:

- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
- `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

These documents now record the current LIVE launch position, the cache-boundary evidence, the repair commit, and the verification rule. Future material changes must refresh the same documentation set plus a dated checkpoint so project continuity remains recoverable across chats.


## Cloudflare production branch correction — 2026-10-03

During LIVE owner-login verification, Cloudflare Workers & Pages → Settings → Builds was found configured with the GitHub repository `laurendigitaluk/TradeFlow` but the **Production branch was `main`**. In this project, `main` is TEST and `production` is LIVE.

This explained why the Cloudflare Production Worker was serving TEST-connected Owner Dashboard behaviour even though the GitHub `production` branch source was already corrected to the LIVE Supabase project.

The Cloudflare Production branch has now been changed to:

`production`

No application code, Supabase credentials, owner password, or database state was changed for this configuration repair.

### Required verification

Cloudflare must produce a new successful production deployment from the `production` branch before the LIVE owner login is retested. After deployment:

1. Open a fresh Incognito session.
2. Load the Owner Dashboard.
3. Sign in with the LIVE owner credentials.
4. Confirm the request reaches the LIVE Supabase Auth endpoint.
5. Confirm the dashboard shows LIVE data rather than TEST data.
