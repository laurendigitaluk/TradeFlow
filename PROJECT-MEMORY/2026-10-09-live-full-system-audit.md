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
- Production Worker config `wrangler.jsonc` contains malformed LIVE URL `gxsrajtqzdjvmceqcpgv2.supabase.co`. Isolated candidate fix already exists on `audit/fix-live-supabase-url-20261009`, commit `04fc24cad71aaf6efe5e7472022bfd5bc6b8d939`. Do not repeat or deploy until controlled runtime/browser verification passes.
- LIVE legacy domain-purchase/registration functions remain active: `porkbun-domain-availability`, `create-domain-checkout-session`, `reconcile-domain-payment`, `save-domain-registrant`, `porkbun-domain-registration`, and `index`. Legacy orders and one registrant record exist; do not invoke, delete, or disable without reviewing callers, provider secrets and historical checkpoints.
- TEST still has active legacy Parcel2Go functions and directly accessible legacy domain-purchase/registrant pages in `cloudflare-test`. Current subscriber-managed manual shipping and subscriber-owned domain connection are authoritative. Complete a repo-wide caller/history review before removing pages/functions.
- Supabase security/performance advisor findings are review items, not approval for bulk RLS, grants, or index changes.
- Production and main branches have diverged. Do not force-sync, merge a broad cleanup, or deploy from the audit branch.

## Current audit branch
`audit/2026-10-09-live-audit-findings`. Documentation-only changes are isolated here; production remains unchanged. Continue with static caller inventory, branch comparison, controlled TEST regression, then separate narrowly scoped changes. Never create a LIVE customer on the user's behalf.
