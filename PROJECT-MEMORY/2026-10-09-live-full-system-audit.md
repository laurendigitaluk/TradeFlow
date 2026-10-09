# LIVE Full System Audit — 9 October 2026

## Environment boundary
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- TEST Supabase: `twfbmjwwqzxdxvclxbun`.
- Verify project ID before each query, migration, function operation or deployment.

## Verified LIVE state
- Adventure Outpost tenant ID: `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52`.
- `www.scenesource.co.uk` is primary, active, verified and activated; published-site index contains the published revision.
- Two non-deleted, email-confirmed Auth users: one Platform Owner and one Adventure Outpost subscriber owner.
- One active platform membership and one active tenant-owner membership.
- `public.customers` has zero rows and zero customer-to-auth links as of this read-only audit. No SceneSource customer account existed at audit time.
- User explicitly said they will create the test customer themselves through the public registration flow. Assistant must not create the account or change LIVE Auth/customer data on the user's behalf.

## Subscriber manual boundary
The Subscriber Website Manual must contain subscriber-facing instructions only. Platform Owner domain verification workflow, internal tenant/security explanation, audit counts and the owner/customer three-role acceptance test belong in owner/developer manuals and the audit checkpoint. On `audit/2026-10-09-live-audit-findings`, the 5,206-character appended owner-only tail was removed from `subscriber-website-manual.html`; owner-only content was added to the AI Operating Manual, Backend Manual, Human Manual, System Handbook and Master Roadmap.

## Known cleanup risks — do not act blindly
- Production Worker config `wrangler.jsonc` contains malformed LIVE URL `gxsrajtqzdjvmceqcpgv2.supabase.co`. A fresh one-line correction exists on isolated branch `audit/fix-live-supabase-url-current-prod-20261009`, commit `b6d838ae45d3c9830fd6bdd2c25d5eaee7dcfa2c`, based directly on current production and changing only `wrangler.jsonc`. Older Worker URL candidate branches are stale/diverged; do not merge them. No CI statuses are reported and the fresh candidate is not deployed. Do not promote until controlled runtime/browser verification passes.
- LIVE legacy domain-purchase/registration functions remain active: `porkbun-domain-availability`, `create-domain-checkout-session`, `reconcile-domain-payment`, `save-domain-registrant`, `porkbun-domain-registration`, and `index`. Legacy orders and one registrant record exist; do not invoke, delete, or disable without reviewing callers, provider secrets and historical checkpoints.
- TEST still has active legacy Parcel2Go functions and directly accessible legacy domain-purchase/registrant pages in `cloudflare-test`. Current subscriber-managed manual shipping and subscriber-owned domain connection are authoritative. Complete a repo-wide caller/history review before removing pages/functions.
- Supabase security/performance advisor findings are review items, not approval for bulk RLS, grants, or index changes.
- Production and main branches have diverged. Do not force-sync, merge a broad cleanup, or deploy from the audit branch.

## Current audit branch
`audit/2026-10-09-live-audit-findings`. Documentation-only changes are isolated here; production remains unchanged. Continue with static caller inventory, branch comparison, controlled TEST regression, then separate narrowly scoped changes. Never create a LIVE customer on the user's behalf.

## 2026-10-09 — TEST environment drift discovered during cleanup

The `cloudflare-test` branch is not a current copy of LIVE production:

- TEST `domain-settings.html` contained a retired `Buy a new domain` CTA linking to `domain-purchase.html`; the current LIVE architecture is subscriber-owned domains only.
- TEST `domain-settings.js` directly inserts/patches `tenant_domains` and does not use the current subscriber domain-request/status RPCs.
- Read-only TEST schema inspection found none of `subscriber_request_custom_domain()`, `subscriber_get_custom_domain_status()`, `platform_owner_list_domain_actions()` or `platform_owner_update_domain_action()`.
- TEST `platform-owner-dashboard.html/js` still exposes old domain-pricing/FX controls and does not implement the current owner domain-action workflow.
- An isolated branch `cleanup/test-retired-domain-ui-20261009` removes the obsolete purchase CTA and four directly accessible legacy purchase/registrant UI files. It also contains a checkpoint explaining that this branch is **not safe to deploy yet** because TEST frontend/backend architecture is stale. No LIVE code or database was changed.
- Legacy TEST Edge Functions remain active; the connector does not expose function deletion. Do not invoke or disable them without a separate caller, secret and dependency review.
- Do not blindly copy production files into TEST: the environment-specific Supabase URL/publishable key and required migrations/RPCs must be handled explicitly. The next safe TEST task is a controlled refresh/alignment plan and regression test, not deployment of the UI-only cleanup branch.

## Static session-isolation code review — 9 October 2026

Production source review found distinct role/session storage keys:
- Platform Owner: `tradeflow_platform_owner_session` in localStorage.
- Subscriber: `tradeflow_subscriber_session` plus `tradeflow_subscriber_tenant_id` in localStorage.
- Customer: `tradeflow_customer_session:<tenant_id>` in sessionStorage, with pending registration stored separately per tenant.
- Customer auth cleanup removes known legacy shared customer/test keys; it does not explicitly remove the current Platform Owner or Subscriber keys.
- The public-site controller checks for the subscriber key and uses the tenant-scoped customer session key.

This is encouraging static evidence that role storage is separated, but it is **not a runtime pass**. Owner and subscriber may share an origin while using different keys; the SceneSource customer domain is a different origin with separate browser storage. After the user creates the customer, test each role in the actual Chrome setup, including sign-in, refresh, route navigation and role-specific sign-out. Record observed outcomes; do not infer success from code alone.

