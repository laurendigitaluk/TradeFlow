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
