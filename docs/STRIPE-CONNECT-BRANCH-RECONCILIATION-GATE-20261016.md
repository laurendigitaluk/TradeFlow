# Stripe Connect Branch Reconciliation Gate — 16 October 2026

Repository: `laurendigitaluk/TradeFlow`
Base: `production`
Feature: `feature/live-stripe-connect-onboarding-20261015`
Latest reviewed feature commit before this note: `07ef1087edb1d4b65226ecefa48b89db12956e99`

## Current comparison

GitHub's compare endpoint reports the feature branch as **diverged**, with **2 commits on production not yet incorporated**. On the latest check before this documentation update, the feature branch was 126 commits ahead and 2 behind; that ahead count changes as checkpoint documentation commits are added. The merge base remains `dc5e0dfeabd0f86e98a1b709e01c31b1185cb5a1`, and the production head observed was `419dc34b42bb60b175b65e9beacb430a195c7a00`.

Treat the exact ahead count as a timestamped snapshot, not a stable invariant. The critical point is that the histories remain divergent. Do not merge/rebase blindly.

## Required before integration

1. Identify both commits on `production` that are not in the feature branch and inspect their changed files and behavior.
2. Inspect the 44 feature commits as a set, especially settings, checkout, onboarding, webhook, migrations, and manual changes.
3. Determine whether production changes overlap any modified files or change assumptions in the checkout/payment flows.
4. Reconcile the histories on a separate integration branch or via a reviewed merge/rebase plan. Do not force-update either `production` or the current feature branch.
5. Run static checks, migration validation, and tests on the resulting candidate commit; preserve the original feature branch as a checkpoint until the candidate is verified.

## CI evidence

The earlier GitHub Actions lookup for checkout commit `aa000aeb34e904e2f13c43919f4da76ae218bd37` returned no workflow runs. This does not prove no workflow exists or that the code fails; it means there is no CI result available from that lookup. Check the current head and workflow configuration before release.

## Safety

No merge, rebase, deployment, LIVE migration, connected-account creation, or live charge is authorised by this note. Preserve the existing DJI Osmo Action 6 Adventure Combo transaction (sale £125, acquisition cost £70, seller payment marked paid by bank transfer).


## Additional validation findings — 16 October 2026

### Existing duplicate migration version

The production branch contains two distinct migration files with the same version prefix, `20261002131500`:

- `supabase/migrations/20261002131500_domain_registrant_details.sql`
- `supabase/migrations/20261002131500_domain_registrant_details_status.sql`

Both files are also present on the feature branch. This is a migration-order/replay hazard for fresh database setup and branch migration validation, because migration tooling commonly expects each migration version to be unique. The duplicate has not been proven to be the cause of the earlier Supabase branch failure. Do not rename or rewrite these historical migrations casually: LIVE's migration history is not a direct filename-for-filename mirror. Resolve this only with a reviewed migration-history plan and test it against a disposable database.

### CI and source validation

A feature-branch workflow was added in commit `f7f0af67543deed44ca08b6691fd67849d18d891`: `.github/workflows/stripe-connect-candidate-checks.yml`. It runs `deno check --no-lock` on the retail checkout, payment webhook, Connect onboarding, and refund worker Edge Functions for pushes to this feature branch and pull requests targeting `production`.

The GitHub connector returned no combined status checks or workflow runs for the workflow-creation commit at the time of this check. Therefore, this workflow is configured in source but its execution is not yet confirmed. It does not validate SQL migrations, database concurrency, Stripe test-mode behavior, or browser journeys. Those remain outstanding. Treat source inspection as review only, not validation evidence.

### Checkout routing observation

The current feature-branch checkout function creates the retail Checkout Session using the stored connected account in the Stripe `Stripe-Account` request header. This is a connected-account direct-charge context, rather than a platform-account Checkout Session. The draft PR #151 description says retail checkout still charges through the platform account; that wording appears stale relative to the current feature source and must be reconciled before review/merge. The function currently does not set an application fee in the inspected Session parameters, so do not assume TradeFlow commission collection is implemented by this path.

These findings are read-only source observations. No LIVE database, deployment, connected account, or Stripe payment was changed.


## Follow-up audit snapshot — 16 October 2026

A fresh GitHub compare reports the feature branch **135 commits ahead and 2 commits behind** `production`, with merge base still `dc5e0dfeabd0f86e98a1b709e01c31b1185cb5a1`. The two production-only changes touch `settings.html` and `settings.js`, the same files modified by the feature branch. This is a confirmed overlap, not merely theoretical divergence. Review the actual combined behavior for the subscriber payment settings panel, Stripe Connect status refresh, and any legacy payment-provider settings before integration. Do not cherry-pick or merge either side automatically.

The latest workflow lookup for commit `f7f0af67543deed44ca08b6691fd67849d18d891` returned no pull-request-triggered workflow runs. The connector lookup does not enumerate push-triggered runs, so it cannot establish whether the new push workflow executed. The workflow file is present on the feature branch, but a passing Deno check is still unverified. Confirm the actual Actions run or obtain an explicit successful check result before relying on it.

PR #151 remains a draft and its description still states that retail checkout charges through the platform account. The feature checkout source uses connected-account direct-charge context. Update the PR description only after the intended charge model and TradeFlow commission policy are explicitly settled. No `application_fee_amount` was present in the reviewed Checkout Session parameters; commission collection remains unverified.

No merge, rebase, LIVE deployment, migration, Stripe account creation, or charge was performed during this follow-up.

## Settings overlap inspection — follow-up

The latest read-only fetch confirms the production settings.js is 21,940 characters and retains the legacy PAYMENT_PROVIDERS catalogue plus providerRow, providerStatus, renderPaymentProviders, and savePaymentProvider. The feature branch settings.js is 10,215 characters and removes those legacy provider setup/save routines while retaining the Stripe Connect status/onboarding and Stripe payment-method controls. Both versions retain the Connect panel event handlers and load the tenant's Stripe payment methods. The feature branch additionally handles Stripe's stripe_connect=refresh return by requesting a fresh onboarding link; production currently strips the query string and then only refreshes status.

This clarifies the overlap: integration must preserve the feature branch's intended single-Stripe-provider simplification and refresh-link handling, while confirming no other live settings workflow depends on the legacy provider functions. Do not simply take production's settings.js, because it reintroduces legacy UI code and loses the explicit refresh return handling. Do not simply overwrite production either; reconcile the two-file change against the actual production UI and existing data model.

No code was changed as part of this source comparison. No database, payment, or LIVE deployment was touched.
## DOM/reference sanity check — 16 October 2026

Read-only comparison of settings.html and settings.js shows all DOM IDs referenced by feature-branch settings.js exist in feature-branch settings.html. Production settings.js references one absent ID, payment-providers; the corresponding renderPaymentProviders() function first checks for that element and returns when it is absent, so this specific missing element is guarded and is not by itself a demonstrated runtime failure. Production HTML already presents the single Stripe Connect panel and tenant Stripe method controls, despite the old provider functions still being present in its JavaScript.

The feature settings.html retains substantial generic legacy payment-provider CSS, and includes a rule targeting a Stripe provider card under #payment-providers even though no such provider-card container exists in the inspected page. This appears to be dead styling residue, not evidence of an active provider UI. It can be cleaned up during a reviewed settings reconciliation, but is not a reason to change LIVE independently.

Static ID/reference check only; this is not browser execution, Deno validation, database validation, or proof that onboarding/checkout works end-to-end. No production files were modified.

## Checkout amount invariant review — 16 October 2026

A further source review identified a settlement invariant that must be tested and preferably enforced before release:

- `create-stripe-checkout-session` sets Stripe's Checkout `line_items[0][price_data][unit_amount]` from the retail order's `amount_due`.
- The attempt-aware webhook passes Stripe's `amount_total` to `process_retail_checkout_attempt_event`.
- That RPC compares the received amount and currency with the linked `payment_records.amount` and `payment_records.currency`. A mismatch produces `reconciliation_required` rather than settlement.

This is a defensive check, but checkout creation does not visibly compare the order amount against the newly created/reused payment record before creating the Stripe Session. If those records can differ, a legitimate paid checkout could be routed to reconciliation and leave the order unsettled. The source review alone does not prove that the values currently diverge; inspect `customer_create_order_payment` and test the invariant with real schema data in a disposable environment. Before release, either derive the Checkout amount from the validated payment record or explicitly reject a mismatch before calling Stripe, while preserving customer authorization and currency checks.

The checkout function also creates the Session as a direct charge in the connected account without a visible `application_fee_amount`. Commission collection remains an unresolved product/payment design decision, separate from the amount consistency guard.

No code change was made for this finding because the correct payment-record creation contract and amount source must be verified first. No LIVE data, deployment, migration, or Stripe object was changed.


## Latest branch comparison after amount-invariant note

The latest compare endpoint snapshot reports **139 commits ahead and 2 commits behind** production, still diverged from merge base `dc5e0dfeabd0f86e98a1b709e01c31b1185cb5a1`. Production head observed: `419dc34b42bb60b175b65e9beacb430a195c7a00`. The two production-only commits still require inspection; settings overlap remains a merge risk. The updated ahead count includes subsequent feature-branch checkpoint/documentation commits and is not evidence of additional runtime validation.

Release gate remains closed: no verified Deno run, disposable database migration test, Stripe test-mode lifecycle test, or end-to-end customer checkout test is available. Do not merge, deploy, or apply candidate migrations to LIVE on the basis of source inspection alone.

## Follow-up validation and checkout amount guard — 16 October 2026

The contract for `customer_create_order_payment(uuid, uuid, text)` was located in `supabase/migrations/20260930215656_remote_schema.sql`. It returns `payment_id`, `status`, `amount`, and `currency`; for a new payment row it copies amount and currency from the locked retail order. However, when the stable order-level idempotency key already exists, or an active pending/processing payment is reused, the function returns that existing payment row without asserting that its amount and currency still match the current order. The earlier mismatch concern was therefore a real contract gap, not merely an unknown RPC contract.

Feature-branch commit `0158a73f00f547b12b0af90c99f304f54c2e7ada` now validates the returned/reused payment record against the current order before any Stripe API request that creates or retrieves a connected-account checkout session: amount is compared in minor units, currency is normalized and compared, and invalid/missing values are rejected with HTTP 409 and a reconciliation message. This is intended to prevent a stale payment record from creating a Checkout Session at a different amount/currency. It does not reconcile or repair an existing mismatched record; that remains an explicit recovery task.

The earlier TypeScript issue in `stripe-payment-webhook/index.ts` was fixed in commit `3122bd227a796e447089c7c312a9eccf503ee7f2` by typing the Stripe account header map as `Record<string, string>`. GitHub Actions run `38946930897` completed successfully after that fix. The follow-up run for checkout amount validation, `38947040326`, also completed successfully; its configured Deno check passed for checkout, webhook, Connect onboarding, and refund-worker functions.

These are source-level/type-check results only. SQL migration execution, PostgreSQL concurrency and recovery tests, Stripe test-mode lifecycle behavior, and browser end-to-end checkout remain unverified. Release gate stays closed. No LIVE database, deployment, migration, customer transaction, or Stripe object was changed.



## Duplicate Stripe event concurrency guard — 16 October 2026

A further source review found that the attempt-aware settlement RPC checked whether a Stripe event ID already existed, but did not serialize concurrent deliveries of that same event ID before the check. Concurrent copies routed against different attempts could therefore race past the existence check. Feature commit `deae2f31171a4bb917c76b9cd48e3a9f960b0165` adds a transaction-scoped PostgreSQL advisory lock keyed by the Stripe event ID before row locking and deduplication.

This is a candidate-side concurrency safeguard, not a verified fix until PostgreSQL tests demonstrate duplicate deliveries serialize correctly and do not double-settle or incorrectly complete a second attempt. The lock ordering and interaction with `process_external_payment_event` must be exercised in disposable PostgreSQL, including two simultaneous calls with the same event ID targeting distinct attempts. Do not apply the migration to LIVE. Current feature-vs-production comparison is now 143 commits ahead / 2 behind before this latest commit; branch counts should be refreshed before integration.


## Latest comparison after concurrency safeguard — 16 October 2026

The latest GitHub compare reports the feature branch **147 commits ahead and 2 commits behind** `production`, still diverged from merge base `dc5e0dfeabd0f86e98a1b709e01c31b1185cb5a1`. Production head observed remains `419dc34b42bb60b175b65e9beacb430a195c7a00`. The ahead count includes documentation/checkpoint commits; it is not a measure of completed validation.

The settlement migration now includes a transaction-scoped advisory lock for each Stripe event ID (commit `deae2f31171a4bb917c76b9cd48e3a9f960b0165`). The commit-status connector currently reports no status entries for this commit or the latest manual update, and the workflow-run lookup used here only returns pull-request-triggered runs. Therefore, there is no newly verified CI result for the latest SQL change. The release gate remains closed pending disposable PostgreSQL tests, Stripe test-mode lifecycle tests, and a reviewed settings/branch integration plan.

## Candidate SQL regression harness update — 16 October 2026

The feature branch now includes an isolated PostgreSQL CI job in `.github/workflows/stripe-connect-candidate-checks.yml`. It builds a minimal fixture, applies the four candidate Stripe Connect migrations in timestamp order, and runs SQL regression checks for connected-account mismatch, amount mismatch, successful settlement, sequential duplicate delivery, the downstream-transition/refund fallback, and idempotent refund completion. A separate Python test races two deliveries with the same Stripe event ID against different attempts and expects one `applied` and one `duplicate` result.

The settlement fallback was adjusted to upsert the existing `payment_provider_events` row when the legacy transition has already recorded the event but declines the business transition. A read-only inspection of TRADEFLOW LIVE confirmed the existing table has `UNIQUE (provider, event_id)`, matching the candidate's conflict target. No LIVE schema or data was changed by that inspection.

**Execution status:** the test files and workflow are committed to the feature branch, but no successful run of the new PostgreSQL job has been verified yet. Treat this as a test harness added, not passing test evidence. The fixture intentionally stubs `process_external_payment_event`; it does not validate the full TradeFlow ledger, inventory, credit, or order side effects. Stripe test-mode lifecycle tests, actual runtime/browser checkout, commission collection, and branch/settings reconciliation remain outstanding. Do not apply candidate migrations to LIVE or merge the feature branch until the workflow run is confirmed and remaining release blockers are resolved.

### Additional regression assertions — 16 October 2026

The isolated SQL regression suite now also asserts that a mismatched PaymentIntent is rejected without recording the event, and that a late paid Session for a superseded checkout attempt creates a durable refund intent without changing the already-settled payment. Expected-value assertions use `IS DISTINCT FROM` so unexpected NULL values fail the tests rather than slipping through SQL's three-valued logic.

The concurrent test still expects one `applied` and one `duplicate` result for concurrent deliveries of the same Stripe event ID. These tests are committed but not yet confirmed by an observed successful GitHub Actions run.

## Latest CI verification — 16 October 2026, 19:14 UTC

GitHub Actions run [38953346975](https://github.com/laurendigitaluk/TradeFlow/actions/runs/38953346975) passed on feature commit `0e59819c8e7cee825a9e2e6d7ba7c0818bd037ab`:
- Deno type-check for checkout, webhook, onboarding and refund Edge Functions: passed.
- Isolated PostgreSQL 16 fixture setup and application of all four candidate migrations: passed.
- SQL settlement, mismatch, late-session refund-intent, duplicate-event and refund-finalization regressions: passed.
- Concurrent duplicate Stripe event delivery test: passed.

This is verified CI evidence for the candidate SQL harness and type-check at that exact commit. It is not full production-schema or end-to-end proof: the fixture stubs `process_external_payment_event`, so actual ledger, inventory, credit and order workflow side effects are not exercised. Stripe test-mode lifecycle tests remain outstanding.

For the same commit, the Cloudflare `tradeflow` build succeeded but the `tradeflow-test` preview check failed. The failure cause has not been established. Do not interpret the successful `tradeflow` build as a LIVE deployment.

Release gate remains closed pending the commission/charge-model decision, Stripe test-mode lifecycle tests, reconciliation of the production/feature settings overlap, investigation of the failed test preview, and explicit release authorization. No LIVE migration, deployment, merge/rebase, or Stripe mutation was performed. Preserve the active DJI Osmo Action 6 Adventure Combo test transaction.

## Authoritative payment-model decision — 16 October 2026

The owner has already confirmed that TradeFlow must **not collect application fees or transaction commission** on subscriber retail sales. Subscriber payments are direct charges on each subscriber's own connected Stripe account; TradeFlow subscription billing remains separate. Do not ask the owner to decide this again or treat commission policy as an unresolved blocker.

The candidate source creates accounts with `controller.fees.payer=account`, `controller.losses.payments=stripe`, and `controller.stripe_dashboard.type=full`, then validates these settings before allowing checkout. Checkout sends `Stripe-Account` and does not set `application_fee_amount`. This aligns with the intended no-commission model. Stripe's documentation states that for direct charges the connected account bears Stripe fees, refunds and chargeback costs, while Stripe covers connected-account loss liability under the Stripe-managed loss configuration; TradeFlow is not configured to collect a transaction fee. See [Stripe Connect pricing and account-loss responsibility](https://stripe.com/gb/connect/pricing) and [Stripe direct-charge guidance](https://support.stripe.com/questions/what-should-i-know-about-using-direct-charges?locale=en-GB). Account terms, eligibility and actual account configuration still govern; this is not a guarantee against every possible platform-level contractual liability.

The earlier notes in this document/manual describing the charge model or commission policy as undecided, or saying retail checkout still charges through the platform account, are superseded by this checkpoint. Remaining release blockers are Stripe test-mode lifecycle/recovery tests, reconciliation of the feature/production settings overlap, investigation of the failed `tradeflow-test` preview, and validation against the actual LIVE schema and business side effects. The branch remains unreleased; do not merge, deploy or apply candidate migrations to LIVE without explicit authorization. Preserve the DJI Osmo Action 6 Adventure Combo test transaction.

## Subscriber settings overlap audit — 16 October 2026

Compared production and feature `settings.html` / `settings.js` directly. Both HTML versions contain the same subscriber settings control IDs and the same Stripe Connect/payment-method panel. Production's extra `PAYMENT_PROVIDERS`, `providerRow`, `providerStatus`, `renderPaymentProviders` and `savePaymentProvider` code is legacy provider-catalogue code: the current HTML has no `payment-providers` container and does not invoke that renderer. The feature removes those unused functions rather than restoring a second manual provider setup beside the single Stripe Connect flow. The feature's refresh-on-return handling is retained.

Found a concrete browser-cache risk: production references `settings.js?v=19`, while the feature had `v=18`. The feature HTML has now been bumped to `settings.js?v=20`, and the candidate workflow now checks JavaScript syntax plus the required Stripe Connect control IDs and cache-buster. These new checks are awaiting CI verification on the latest commit. This resolves the identified settings-file overlap at source level; it does not resolve broader branch divergence, Stripe integration testing, or the failed Cloudflare preview.
