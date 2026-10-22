# TradeFlow LIVE Checkpoint — Multi-Tenant Isolation Audit Start

Checkpoint date: 2026-10-20

## Scope and safety constraints

- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`
- LIVE Supabase URL: `https://gxsrajtqzdjvmceqcpgv.supabase.co`
- Supabase account link: `link_6ad13c4afe848191899041a0a95b487d`
- GitHub repository: `laurendigitaluk/TradeFlow`
- Production/release branch: `production`
- This checkpoint branch was created from `production`: `checkpoint-live-multitenant-audit-start-20261020`
- The GitHub default branch is `main`; do not assume it represents LIVE.
- Work against LIVE only for read-only audit unless a specific change is agreed and verified.
- Preserve all customer, subscriber, tenant, order, valuation, payment, and acquisition data.
- Do not delete or replace Stripe accounts, rotate secrets, or modify TradeFlow subscription billing as part of tenant isolation work.
- Do not merge divergent historical Stripe Connect PRs or diagnostic branches into production without reviewing diffs.

## Stripe Connect evidence at checkpoint

- Stripe Connect onboarding Edge Function was reported active at version 13 on LIVE after the account-retrieval correction.
- The LIVE `stripe-connect-webhook` Edge Function was retrieved as active version 4, `verify_jwt=false`, with Stripe signature verification implemented in the function.
- Stripe Workbench screenshots showed the `TradeFlow Connected Account Payments` event destination active. A recent `account.updated` delivery returned HTTP 200 with `received: true`, `connected_account_updated: true`, `matched_connections: 1`, and `status: connected`.
- The TradeFlow LIVE Settings page showed “Stripe is connected. Charges and payouts are enabled.”
- This verifies account-update delivery and the connected-account status path, not a complete customer checkout/payment lifecycle.
- Existing Stripe connected account should be retained unless a later read-only inspection proves otherwise. Do not create a replacement account.
- Keep platform subscription billing separate from subscriber customer payments.
- Do not claim end-to-end payment readiness until checkout, webhook processing, payment-record matching, and tenant isolation have been verified.

## Supabase branch state observed

- Supabase project `gxsrajtqzdjvmceqcpgv` listed a default development branch `main` with `with_data=false`, status `FUNCTIONS_DEPLOYED`.
- A branch named `stripe-connect-validation-harness` was listed with status `MIGRATIONS_FAILED`, `with_data=false`, and a different preview project ref. Do not treat it as a working restore point.
- A Supabase development branch is not, by itself, a verified point-in-time backup of LIVE data or a complete snapshot of deployed function code/settings. A database backup/restore procedure and function/config inventory still need to be verified.
- No claim is made here that a complete Supabase data backup has been created.

## Next task: multi-subscriber / multi-customer isolation audit

1. Read-only inventory of LIVE tenant, subscriber membership, customer linkage, and payment-provider connection records.
2. Inspect RLS policies, grants, security-definer RPCs, Edge Functions, tenant scoping, storage policies, and frontend requests for all subscriber/customer-sensitive data.
3. Establish two separate subscriber identities and separate customer identities. Use clearly marked non-financial test records; avoid real customer payments.
4. Test both expected access and denied cross-tenant access through the dashboards and direct authenticated requests.
5. Verify isolation for customers, valuations/offers, messages, orders, acquisitions, inventory, shipping/tracking, payment records, subscriber settings, website content, and connected Stripe account mappings.
6. Review Stripe retail checkout and webhook handling together. Do not change subscription billing.
7. Fix only confirmed issues, add regression checks, and retest before considering any production deployment.
8. Before making a real test site, design an isolated staging environment from version-controlled code/schema and safe synthetic data. Do not copy LIVE customer/payment data into test. Confirm environment variables, auth URLs, storage, webhook endpoints, domains, Stripe mode, and deployment pipeline are separate.

## Restore and release discipline

- This branch preserves the GitHub `production` branch state at checkpoint creation; it does not automatically snapshot Supabase runtime state.
- Keep production changes minimal and auditable. Capture deployed function source/version and schema/migration state before making backend changes.
- Never use the old divergent branch `feature/live-stripe-connect-onboarding` (previously reported 181 commits ahead / 2 behind production) as a merge candidate without a full review.
- A future checkpoint should include a verified database backup/restore point, GitHub commit SHA, deployed Edge Function versions and source hashes, migration inventory, and configuration inventory with secrets redacted.


## Audit continuation — 22 October 2026 (LIVE source reconciliation and Supabase advisors)

- Latest GitHub comparison for `production` against `test/stripe-connect-test-mode-repair-20261020`: TEST is 114 commits ahead and 42 behind. Earlier 38/33-behind figures in prior notes are stale. Do not bulk-merge.
- LIVE deployed Edge Functions are present: `stripe-connect-onboarding` version 13 (JWT verification enabled; deployed source SHA-256 `f4f4d6054e486901cab6ec488bcd6baa1e9f445485b558102603822771c3c7de`) and `stripe-connect-webhook` version 4 (JWT verification disabled as expected for a webhook; deployed source SHA-256 `ec13b5ff7d6ceda7a42c3bf00d046fd184759c4500687de9208eec4eed7ecdd7`). Both are ACTIVE in LIVE.
- The corresponding source files were absent from `production`. Exact source was retrieved from the deployed LIVE functions and committed to version control without redeploying or changing runtime behavior: onboarding source commit `421c7e66529b20f0542925a0c66a5c7b32238afd`; webhook source commit `6e83cfe28faec14fbfbb8e563c67ee38038f3609`. This repairs source traceability only; it is not a deployment or a functional test.
- LIVE onboarding source uses a LIVE-key guard, validates the Supabase user and active tenant owner/admin membership, and uses a Stripe idempotency key. TEST source is not interchangeable: it includes an explicit environment-mode guard and differs in implementation. Keep each deployed implementation environment-specific.
- Read-only SQL checks in LIVE and TEST each found 99 public tables, zero public tables without RLS, zero SECURITY DEFINER functions missing a configured search_path, and zero direct anon/PUBLIC grants on the inspected sensitive payment, membership, subscription and customer tables. These checks do not prove all RLS expressions, RPC authorization, storage policies, or tenant boundaries are correct.
- Supabase security advisors in both environments report: `pg_net` installed in `public`; 8 SECURITY DEFINER RPCs executable by `anon`; 165 such functions executable by `authenticated` in LIVE and 164 in TEST; and leaked-password protection disabled. Review the eight anon-callable functions individually because some public-site/catalogue RPCs may intentionally serve public pages. Do not blanket-revoke function grants. Enable leaked-password protection through a separately verified Auth settings change.
- Performance advisor snapshot: both environments report 65 unindexed foreign keys, 166 RLS init-plan warnings, and 14 multiple-permissive-policy warnings. LIVE reports 64 unused-index notices and 3 duplicate-index notices; TEST reports 112 unused-index notices. Do not drop indexes based only on a fresh/low-traffic usage snapshot. Review duplicate indexes against constraints and migrations before any change.
- Sensitive-table policy inspection showed tenant-membership/permission checks on customers, payment records, payment-provider connections, payment-provider customers and tenant subscriptions in both environments. This was a targeted inspection, not a complete cross-tenant penetration test.
- Outstanding: inspect all advisor-listed anon-callable SECURITY DEFINER functions and their grants/body authorization; audit full tenant isolation and payment/ledger writes; compare deployed LIVE/TEST checkout and payment-webhook source; verify the complimentary setup resend flow only under a deliberate test plan; run manual browser checks where specified. No SQL permissions, schemas, Stripe settings, data or Edge Function deployments were changed in this audit.
